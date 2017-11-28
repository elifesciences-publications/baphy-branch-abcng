function [Events, exptparams] = BehaviorControl(O, HW, StimEvents, globalparams, exptparams, TrialIndex)
% Behavior Object for RewardTargetCont object
% Behavioral Conditions
%  - EARLY   :  Lick before the response window
%  - HIT                  : Lick during the response window at correct spout
%  - ERROR      : Lick during response window at wrong spout
%  - SNOOZE                : No Lick until after response window
%
% YB/JN 2017/09

Events = [ ];

%% INITIALIZE WATER (in units of ml, necessary for )
exptparams.WaterUnits = 'milliliter';
RewardAmount = get(O,'RewardAmount');
AutomaticReward = get(O,'AutomaticReward');

%% GET TARGET & REFERENCE INDICES
tmp = get(exptparams.TrialObject,'ReferenceIndices'); ReferenceIndices = tmp{exptparams.InRepTrials};
tmp = get(exptparams.TrialObject,'TargetIndices'); TargetIndices = tmp{exptparams.InRepTrials};
TargetChannel = get(O,'TargetChannel');
SoundSR = get(get(exptparams.TrialObject,'TargetHandle'),'SamplingRate');

%% COMPUTE RESPONSE WINDOWS
LastEv = StimEvents(end).Note;
Index = str2num(LastEv( (find(LastEv=='-',1,'first')+1):(find(LastEv==',',1,'first')-1) ));
TAR = ismember(Index,TargetChannel);
EarlyWindow = StimEvents(end-1).StartTime;

RW(1) = EarlyWindow + get(O,'MinimalDelayResponse');
RW(2) = RW(1) + get(O,'ResponseWindow');

%% PREPARE FOR LIGHT CUE
LightCueDuration = get(O,'LightCueDuration'); LightCued = 0; cPositions = {'center'};
LightNames = IOMatchPosition2Light(HW,cPositions);

%% WAIT FOR THE CLICK AND RECORD POSITION AND TIME
SensorNames = {HW.Didx.Name}; 
TouchType = IOMatchPosition2Sensor('center',HW); TouchType = TouchType{1};
SensorChannels = find(strcmp(SensorNames,TouchType));
AllLickSensorNames = SensorNames(~cellfun(@isempty,strfind(SensorNames,TouchType)));

% SYNCHRONIZE COMPUTER CLOCK WITH DAQ TIME
tic; CurrentTime = IOGetTimeStamp(HW); InitialTime = CurrentTime;
while CurrentTime < exptparams.LogDuration
  DetectType = 'ON'; LickOccured = 0;
  %CurrentTime = IOGetTimeStamp(HW); % INACCURATE WITH DISCRETE STEPS
  CurrentTime = toc+InitialTime;
  % READ LICKS FROM ALL SENSORS
  cLick = IOLickRead(HW,SensorChannels);
  switch DetectType
      case 'ON'; if any(cLick); LickOccured = 1; end;
      case 'OFF'; if any(~cLick); LickOccured = 1; end;
  end
  
  % PROCESS LICK GENERALLY
  if LickOccured
    LickTime = CurrentTime;
    cSensorChannels = SensorChannels(find(cLick,1,'first'));
    if ~isempty(cSensorChannels)
      cLickSensorInd = find(cLick,1,'first');
      cLickSensor = SensorNames{SensorChannels(cLickSensorInd)}; % CORRECT FOR BOTH 'ON' AND 'OFF' RESULTS
      cLickSensorNot = setdiff(SensorNames(SensorChannels),cLickSensor);
    else
      cLickSensor = 'None'; cLickSensorNot = 'None';
    end
    
    Events = AddEvent(Events,['LICK,',cLickSensor],TrialIndex,LickTime,[]);
    break
  end
  
  % GIVE LIGHT CUE ON REWARD SIDE
  if ~LightCued && LightCueDuration && (CurrentTime > RW(1)-(LightCueDuration+0.05))
    fprintf('Light Cued ');
    [State,LightEvent] = IOLightSwitch(HW,1,LightCueDuration,[],[],[],LightName);
    fprintf('\b ... '); LightCued = 1;
    Events = AddEvent(Events, LightEvent, TrialIndex);
  end
end
StopEvent = IOStopSound(HW);
Events = AddEvent(Events, StopEvent, TrialIndex);

% IF NO RESPONSE OCCURED
if ~LickOccured; LickTime = inf; end

if LickOccured
  fprintf(['\t Lick detected [ ',cLickSensor,', at ',n2s(LickTime,3),'s ] ... ']);
else
  fprintf(['\t No Lick detected ... ']); cLickSensor = ''; 
end

%%  PROCESS LICK
if LickTime < RW(1)
  Outcome = 'EARLY';
elseif LickTime>RW(1) && LickTime<RW(2) % HIT OR ERROR
  switch TAR
    case 1; Outcome = 'HIT';
    case 0; Outcome = 'FA';
  end  
else
  switch TAR
    case 1; Outcome = 'MISS';
    case 0; Outcome = 'CR';
  end
end
Events = AddEvent(Events,['OUTCOME,',Outcome],TrialIndex,LickTime,[]);
if strcmp(Outcome,'HIT'); Outcome2Display = [Outcome ', RT = ' num2str(LickTime-RW(1))]; else Outcome2Display = Outcome; end
fprintf(['\t [ ',Outcome2Display,' ] ... ']);

%% AUTOMATIC REWARD
if AutomaticReward>0 && strcmp(Outcome,'MISS')
    PumpDuration = AutomaticReward/globalparams.PumpMlPerSec.Pump;
    PumpName = IOMatchPosition2Pump('center',HW); PumpName = PumpName{1};
    PumpEvent = IOControlPump(HW,'Start',PumpDuration,PumpName);
    PumpEvent.Note = [PumpEvent.Note ',AUTOMATICREWARD'];
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    exptparams.Water = exptparams.Water+AutomaticReward;
    % MAKE SURE PUMPS ARE OFF (BECOMES A PROBLEM WHEN TWO PUMP EVENTS TOO CLOSE)
    pause(PumpDuration);
    PumpEvent = IOControlPump(HW,'stop',0,PumpName);
    PumpEvent.Note = [PumpEvent.Note ',AUTOMATICREWARD'];
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    IOControlPump(HW,'stop',0,'Pump');
end

%% TAKE ACTION BASED ON OUTCOME
switch Outcome
  case 'EARLY'; % TIME OUT
    if strcmp(get(O,'PunishSound'),'EarlyBuzz') || strcmp(get(O,'PunishSound'),'Buzz') 
      BuzzDuration = 0.3;
      Tbuzz = 0:(1/SoundSR):BuzzDuration; Xbuzz = sin(2.*pi.*110.*Tbuzz);
      Ybuzz = square(2*pi*1000*Tbuzz +2*Xbuzz);
      IOStartSound(HW,Ybuzz*15); pause(BuzzDuration); IOStopSound(HW);
    end
    LightEvents = LF_TimeOut(HW,get(O,'TimeOutEarly'),0,TrialIndex,Outcome);
    Events = AddEvent(Events, LightEvents, TrialIndex);
    
  case 'FA'; % TIME OUT
    if strcmp(get(O,'PunishSound'),'FABuzz') || strcmp(get(O,'PunishSound'),'Buzz') 
      BuzzDuration = 0.7;
      Tbuzz = 0:(1/SoundSR):BuzzDuration; Xbuzz = sin(2.*pi.*110.*Tbuzz);
      Ybuzz = square(2*pi*1000*Tbuzz +2*Xbuzz);
      IOStartSound(HW,Ybuzz*15); pause(BuzzDuration); IOStopSound(HW);
    end
    if isstr(get(O,'TimeOutError')); TimeOut = str2num(get(O,'TimeOutError'));
    else  TimeOut = get(O,'TimeOutError'); end
    LightEvents = LF_TimeOut(HW,TimeOut,0,TrialIndex,Outcome);
    Events = AddEvent(Events, LightEvents, TrialIndex);
  
  case 'HIT'; % PROVIDE REWARD AT CORRECT SPOUT
    if length(RewardAmount)>1 % ASYMMETRIC REWARD SCHEDULE ACROSS SPOUTS
      RewardAmount = RewardAmount(cLickSensorInd);
    end    
    if ~globalparams.PumpMlPerSec.Pump
      globalparams.PumpMlPerSec.Pump = inf;
    end    
    PumpDuration = RewardAmount/globalparams.PumpMlPerSec.Pump;
    PumpName = IOMatchPosition2Pump('center',HW); PumpName = PumpName{1};
    PumpEvent = IOControlPump(HW,'Start',PumpDuration,PumpName);
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    exptparams.Water = exptparams.Water+RewardAmount;
    % MAKE SURE PUMPS ARE OFF (BECOMES A PROBLEM WHEN TWO PUMP EVENTS TOO CLOSE)
    pause(PumpDuration);
    PumpEvent = IOControlPump(HW,'stop',0,PumpName);
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    IOControlPump(HW,'stop',0,'Pump');
    
    % Turn LED OFF
    [State,LightEvent] = IOLightSwitch(HW,0,0,[],[],[],LightNames{1});
    Events = AddEvent(Events,LightEvent,TrialIndex);
    pause(3);
  case {'MISS';'CR'}
    cLickSensor = 'None'; cLickSensorNot = 'None';
    pause(0.1); % TO AVOID EMPTY LICKSIGNAL
  otherwise error(['Unknown outcome ''',Outcome,'''!']);
end

fprintf('\n');
if strcmp(Outcome,'CR') || strcmp(Outcome,'MISS'); LickTime = NaN; end
exptparams.Performance(TrialIndex).ReferenceIndices = ReferenceIndices;
exptparams.Performance(TrialIndex).TargetIndices = TargetIndices;
exptparams.Performance(TrialIndex).Outcome = Outcome;
exptparams.Performance(TrialIndex).TarWindow = RW;
exptparams.Performance(TrialIndex).RefWindow = RW;
exptparams.Performance(TrialIndex).LickTime = LickTime;
exptparams.Performance(TrialIndex).LickSensor = cLickSensor; 
exptparams.Performance(TrialIndex).LickSensorInd = find(strcmp(cLickSensor,AllLickSensorNames));
if isempty(exptparams.Performance(TrialIndex).LickSensorInd) exptparams.Performance(TrialIndex).LickSensorInd = NaN; end 
exptparams.Performance(TrialIndex).LickSensorNot = cLickSensorNot;
exptparams.Performance(TrialIndex).LickSensorNotInd = find(strcmp(cLickSensorNot,AllLickSensorNames));
if isempty(exptparams.Performance(TrialIndex).LickSensorNotInd) exptparams.Performance(TrialIndex).LickSensorNotInd = NaN; end 
exptparams.Performance(TrialIndex).DetectType = DetectType;

%% WAIT AFTER RESPONSE TO RECORD POST-DATA
if ~strcmp(Outcome,'CR') && ~strcmp(Outcome,'MISS')
  while CurrentTime < LickTime + get(O,'AfterResponseDuration');
    CurrentTime = toc+InitialTime; pause(0.05);
  end
end

function Events = LF_TimeOut(HW,TimeOut,Light,cTrial,Outcome)
% 14/02/20-YB: adapted to give a visual feedback for EARLY (we don't want TimeOut for HIT)

if strcmpi(Outcome,'Early'); 
  Positions = {'right'}; fprintf(['\t Timeout [ ',n2s(TimeOut),'s ]']); 
elseif strcmpi(Outcome,'Hit')
  Positions = {'left'};
end

if Light % TURN LIGHT ON DURING TIMEOUT
    LightNames = IOMatchPosition2Light(HW,Positions);
    [State,LightEvent] = IOLightSwitch(HW,1,TimeOut,[],[],[],LightNames{1});
    Events = AddEvent([],LightEvent,cTrial);
end

% TIME OUT
ThisTime = clock; StartTime = IOGetTimeStamp(HW);
while etime(clock,ThisTime) < TimeOut; drawnow;  end
StopTime = IOGetTimeStamp(HW);
if strcmpi(Outcome,'Early')||strcmpi(Outcome,'FA'); TimeOutEvent = struct('Note',['TIMEOUT,',n2s(TimeOut,4),' seconds'],'StartTime',StartTime,'StopTime',StartTime + TimeOut); end

  % TURN LIGHT OFF AFTER TIMEOUT
if Light
    LightNames = IOMatchPosition2Light(HW,Positions);
    [State,LightEvent] = IOLightSwitch(HW,0,[],[],[],[],LightNames{1});
    Events.StopTime = LightEvent.StartTime;
end

% ADD TIME OUT EVENT
if strcmpi(Outcome,'Early') || strcmpi(Outcome,'FA') 
  if ~exist('Events','var')
    Events = TimeOutEvent;
  else
    Events = AddEvent(Events,TimeOutEvent,cTrial);
  end
end

%% ACTUALIZE VISUAL FEEDBACK FOR THE SUBJECT
