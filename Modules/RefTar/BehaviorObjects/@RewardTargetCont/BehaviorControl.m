function [Events, exptparams] = BehaviorControl(O, HW, StimEvents, globalparams, exptparams, TrialIndex)
% Behavior Object for RewardTargetCont object
% Behavioral Conditions
%  - EARLY   :  Lick before the response window
%  - HIT                  : Lick during the response window at correct spout
%  - ERROR      : Lick during response window at wrong spout
%  - SNOOZE                : No Lick until after response window
%
% Reward Conditions :
% If a EARLY occurs :
%  - trial is stopped immediately, time-out is interspersed 
% If a HIT occurs : 
%  - water is provided at the correct spout and a sound is played
% If a ERROR occurs :
%  - negative sound is played
% If a SNOOZE occurs :
%  - just continue 
%
% Options (future)
% - Decrease reward if too many early responses
%
% BE 2013/10

Events = [ ];

%% INITIALIZE WATER (in units of ml, necessary for )
exptparams.WaterUnits = 'milliliter';
RewardAmount = get(O,'RewardAmount');
PrewardAmount = get(O,'PrewardAmount');

%% GET TARGET & REFERENCE INDICES
tmp = get(exptparams.TrialObject,'ReferenceIndices'); ReferenceIndices = tmp{exptparams.InRepTrials};
tmp = get(exptparams.TrialObject,'TargetIndices'); TargetIndices = tmp{exptparams.InRepTrials};

%% COMPUTE RESPONSE WINDOWS
TarInd = find(~cellfun(@isempty,strfind({StimEvents.Note},'Target')));
EarlyWindow = StimEvents(end).StartTime;        % include 0.4s PreStimSilence / 2s Frozen / ToC (without response window)
TargetStartTime = 0; %StimEvents(TarInd(1)).StartTime;
TarWindow(1) = TargetStartTime + EarlyWindow;
TarWindow(2) = TarWindow(1) + get(O,'ResponseWindow');
RefWindow = [0,TarWindow(1)];
Objects.Tar = get(exptparams.TrialObject,'TargetHandle');
Simulick = get(O,'Simulick'); if Simulick LickTime = rand*(TarWindow(2)+1); end

%% PREPARE FOR PREWARD
cPositions = {'center'};
% IF MULTIPLE POSSIBLE : RANDOM REWARD or ALWAYS REWARD (comment out next line)
cRandInd = randi(1,1,[1,length(cPositions)]);
TargetSensors = IOMatchPosition2Sensor(cPositions);
PumpNames = IOMatchPosition2Pump(cPositions);
PumpName = PumpNames{cRandInd};
PumpIndex = 1;%IOMatchPump2Index(HW,PumpName);
PrewardDuration = PrewardAmount/globalparams.PumpMlPerSec.(PumpName);
Prewarded = 0; 

%% PREPARE FOR LIGHT CUE
LightCueDuration = get(O,'LightCueDuration'); LightCued = 0;
LightNames = IOMatchPosition2Light(HW,cPositions);
LightName = LightNames{cRandInd}; % CUE SHOULD ALWAYS BE RANDOM

%% WAIT FOR THE CLICK AND RECORD POSITION AND TIME
SensorNames = {HW.Didx.Name};
SensorChannels=find(strcmp(SensorNames,'Touch'));
AllLickSensorNames = SensorNames(~cellfun(@isempty,strfind(SensorNames,'Touch')));

% SYNCHRONIZE COMPUTER CLOCK WITH DAQ TIME
tic; CurrentTime = IOGetTimeStamp(HW); InitialTime = CurrentTime;
fprintf(['Running Trial [ <=',n2s(exptparams.LogDuration),'s ] ... ']);
while CurrentTime < exptparams.LogDuration

DetectType = 'ON'; LickOccured = 0;
  %CurrentTime = IOGetTimeStamp(HW); % INACCURATE WITH DISCRETE STEPS
  CurrentTime = toc+InitialTime;
  % READ LICKS FROM ALL SENSORS
  if ~Simulick   cLick = IOLickRead(HW,SensorChannels);
  else cLick = ones(size(SensorChannels)); 
    if CurrentTime>= LickTime cLick(ceil(length(cLick)*rand)) = 0; end
  end
  switch DetectType
    case 'ON'; if any(cLick) LickOccured = 1; end;
    case 'OFF'; if any(~cLick) LickOccured = 1; end;
  end
  
  % PROCESS LICK GENERALLY
  if LickOccured
    ResponseTime = CurrentTime; 
    cSensorChannels = SensorChannels(find(cLick,1,'first'));
    if ~isempty(cSensorChannels)
      cLickSensorInd = find(cLick,1,'first');
      cLickSensor = SensorNames{SensorChannels(cLickSensorInd)}; % CORRECT FOR BOTH 'ON' AND 'OFF' RESULTS
      cLickSensorNot = setdiff(SensorNames(SensorChannels),cLickSensor);
    else
      cLickSensor = 'None'; cLickSensorNot = 'None';
    end
   
    Events=AddEvent(Events,['LICK,',cLickSensor],TrialIndex,ResponseTime,[]);
    break;
  end
  
  % GIVE LIGHT CUE ON REWARD SIDE
  if ~LightCued && LightCueDuration && (CurrentTime > TarWindow(1)-(LightCueDuration+0.05))
    fprintf('Light Cued ');
    [State,LightEvent] = IOLightSwitch(HW,1,LightCueDuration,[],[],[],LightName);
    fprintf('\b ... '); LightCued = 1;
    Events = AddEvent(Events, LightEvent, TrialIndex);
  end
  
  % DELIVER PREWARD IF PREWARDDURATION > 0
  if ~Prewarded && any(PrewardDuration) && (CurrentTime > TarWindow(1)-(PrewardDuration+0.05))
    fprintf('Preward ');
    PumpEvent = IOControlPump(HW,'Start',PrewardDuration,PumpName);
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    exptparams.Water = exptparams.Water + PrewardAmount;
    fprintf('\b ... '); Prewarded = 1;
  end
end
% IF NO RESPONSE OCCUREE
if ~LickOccured ResponseTime = inf; end

if LickOccured
  fprintf(['\t Lick detected [ ',cLickSensor,', at ',n2s(ResponseTime,3),'s ] ... ']);
else
  fprintf(['\t No Lick detected ... ']); cLickSensor = ''; 
end

%%  PROCESS LICK
if ResponseTime < TarWindow(1)         
  Outcome = 'EARLY';
elseif ResponseTime > TarWindow(2)  % CASES NO LICK AND LATE LICK
  Outcome = 'SNOOZE';
else % HIT OR ERROR
  switch cLickSensor % CHECK WHERE THE LICK OCCURED
    case TargetSensors;   Outcome = 'HIT'; % includes ambigous if both are specified 
    otherwise                  Outcome = 'ERROR';
  end
end
Events=AddEvent(Events,['OUTCOME,',Outcome],TrialIndex,ResponseTime,[]);
fprintf(['\t [ ',Outcome,' ] ... ']);

%% ACTUALIZE VISUAL FEEDBACK FOR THE SUBJECT
if globalparams.HWSetup == 11
  VisualDispColor = exptparams.FeedbackFigure;
  [VisualDispColor] = VisualDisplay(0,Outcome,VisualDispColor);
end

%% TAKE ACTION BASED ON OUTCOME
switch Outcome
  case 'EARLY'; % STOP SOUND, TIME OUT + LIGHT ON
    StopEvent = IOStopSound(HW);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    LightEvents = LF_TimeOut(HW,get(O,'TimeOutEarly'),0,TrialIndex);
    Events = AddEvent(Events, LightEvents, TrialIndex);

  case 'ERROR'; % STOP SOUND, HIGH VOLUME NOISE, LIGHT ON, TIME OUT
    StopEvent = IOStopSound(HW); Events = AddEvent(Events, StopEvent, TrialIndex);
    if strcmp(get(O,'PunishSound'),'Noise') 
      IOStartSound(HW,randn(10000,1)); pause(0.25); IOStopSound(HW); 
    end
    TimeOut = get(O,'TimeOutError'); if ischar(TimeOut) TimeOut = str2num(TimeOut); end
    LightEvents = LF_TimeOut(HW,roundn(TimeOut*(1+rand),-1),1,TrialIndex);
    Events = AddEvent(Events, LightEvents, TrialIndex);
  
  case 'HIT'; % STOP SOUND, PROVIDE REWARD AT CORRECT SPOUT
    StopEvent = IOStopSound(HW);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    
    PumpName = cell2mat(IOMatchSensor2Pump(cLickSensor));
    if length(RewardAmount)>1 % ASYMMETRIC REWARD SCHEDULE ACROSS SPOUTS
      RewardAmount = RewardAmount(cLickSensorInd);
    end
    if ~globalparams.PumpMlPerSec.(PumpName)
      globalparams.PumpMlPerSec.(PumpName) = inf;
    end
    PumpDuration = RewardAmount/globalparams.PumpMlPerSec.(PumpName);
    pause(0.05); % PAUSE TO ALLOW FOR HEAD TURNING
    PumpEvent = IOControlPump(HW,'Start',PumpDuration,PumpName);
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    exptparams.Water = exptparams.Water+RewardAmount;
    % MAKE SURE PUMPS ARE OFF (BECOMES A PROBLEM WHEN TWO PUMP EVENTS TOO CLOSE)
    pause(PumpDuration);
    PumpEvent = IOControlPump(HW,'stop',0,PumpName);
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    IOControlPump(HW,'stop',0,'Pump');
    
  case 'SNOOZE';  % STOP SOUND
    StopEvent = IOStopSound(HW);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    
    cLickSensor = 'None'; cLickSensorNot = 'None';
    pause(0.1); % TO AVOID EMPTY LICKSIGNAL
    
  otherwise error(['Unknown outcome ''',Outcome,'''!']);
end
fprintf('\n');

if ~strcmp(Outcome,'SNOOZE') LickTime = ResponseTime; else LickTime = NaN; end
exptparams.Performance(TrialIndex).ReferenceIndices = ReferenceIndices;
exptparams.Performance(TrialIndex).TargetIndices = TargetIndices;
exptparams.Performance(TrialIndex).Outcome = Outcome;
exptparams.Performance(TrialIndex).TarWindow = TarWindow;
exptparams.Performance(TrialIndex).RefWindow = RefWindow;
exptparams.Performance(TrialIndex).LickTime = LickTime;
exptparams.Performance(TrialIndex).LickSensor = cLickSensor; 
exptparams.Performance(TrialIndex).LickSensorInd = find(strcmp(cLickSensor,AllLickSensorNames));
if isempty(exptparams.Performance(TrialIndex).LickSensorInd) exptparams.Performance(TrialIndex).LickSensorInd = NaN; end 
exptparams.Performance(TrialIndex).LickSensorNot = cLickSensorNot;
exptparams.Performance(TrialIndex).LickSensorNotInd = find(strcmp(cLickSensorNot,AllLickSensorNames));
if isempty(exptparams.Performance(TrialIndex).LickSensorNotInd) exptparams.Performance(TrialIndex).LickSensorNotInd = NaN; end 
exptparams.Performance(TrialIndex).DetectType = DetectType;

%% WAIT AFTER RESPONSE TO RECORD POST-DATA
if ~strcmp(Outcome,'SNOOZE')
  while CurrentTime < ResponseTime + get(O,'AfterResponseDuration');
    CurrentTime = toc+InitialTime; pause(0.05);
  end
end

function Events = LF_TimeOut(HW,TimeOut,Light,cTrial)

fprintf(['\t Timeout [ ',n2s(TimeOut),'s ]']);

if Light % TURN LIGHT ON DURING TIMEOUT
  Positions = {'left','right'};
  for i=1:length(Positions)
    LightNames = IOMatchPosition2Light(HW,Positions{i});
    [State,LightEvent] = IOLightSwitch(HW,1,TimeOut,[],[],[],LightNames{1});
    if i==1  Events = AddEvent([],LightEvent,cTrial);  else Events = AddEvent(Events,LightEvent,cTrial); end
  end
end

% TIME OUT
ThisTime = clock; StartTime = IOGetTimeStamp(HW);
while etime(clock,ThisTime) < TimeOut   drawnow;  end
StopTime = IOGetTimeStamp(HW);
TimeOutEvent = struct('Note',['TIMEOUT,',n2s(TimeOut,4),' seconds'],'StartTime',StartTime,'StopTime',StartTime + TimeOut);

  % TURN LIGHT OFF AFTER TIMEOUT
if Light
  for i=1:length(Positions)
    LightNames = IOMatchPosition2Light(HW,Positions{i});
    [State,LightEvent] = IOLightSwitch(HW,0,[],[],[],[],LightNames{1});
    Events(i).StopTime = LightEvent.StartTime;
  end
end

% ADD TIME OUT EVENT
if ~exist('Events','var')
  Events = TimeOutEvent;
else
  Events = AddEvent(Events,TimeOutEvent,cTrial);
end