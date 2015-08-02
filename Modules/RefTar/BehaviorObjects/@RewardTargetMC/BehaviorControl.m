function [Events, exptparams] = BehaviorControl(O, HW, StimEvents, globalparams, exptparams, TrialIndex)
% Behavior Object for RewardTargetMC object
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

Events = [];
HW.TwoAFCtask = 1;

%% INITIALIZE WATER (in units of ml, necessary for )
exptparams.WaterUnits = 'milliliter';
RewardAmount = get(O,'RewardAmount');
PrewardAmount = get(O,'PrewardAmount');
ShockDuration = get(O,'ShockDuration');

%% GET TARGET & REFERENCE INDICES
tmp = get(exptparams.TrialObject,'ReferenceIndices'); ReferenceIndices = tmp{exptparams.InRepTrials};
tmp = get(exptparams.TrialObject,'TargetIndices'); TargetIndices = tmp{exptparams.InRepTrials};

%% COMPUTE RESPONSE WINDOWS
TarInd = find(~cellfun(@isempty,strfind({StimEvents.Note},'Target')));
% TargetStartTime = StimEvents(TarInd(1)).StartTime;
% TarWindow(1) = TargetStartTime + get(O,'EarlyWindow');
% TarWindow(2) = TarWindow(1) + get(O,'ResponseWindow');
TargetStartTime = StimEvents(end).StopTime;
TarWindow(1) = TargetStartTime + get(O,'EarlyWindow');
TarWindow(2) = TarWindow(1) + get(O,'ResponseWindow');
RefWindow = [0,TarWindow(1)];
Objects.Tar = get(exptparams.TrialObject,'TargetHandle');
TargetPositions = get(Objects.Tar,'CurrentTargetPositions');
Simulick = get(O,'Simulick'); if Simulick LickTime = rand*(TarWindow(2)+1); end

%% PREPARE FOR PREWARD
cPositions = TargetPositions;
% IF MULTIPLE POSSIBLE : RANDOM REWARD or ALWAYS REWARD (comment out next line)
cRandInd = randint(1,1,[1,length(cPositions)]);
%cPositions = cPositions(cRandInd); cRandInd = 1;
TargetSensors = IOMatchPosition2Sensor(cPositions,HW);
PumpNames = IOMatchPosition2Pump(cPositions,HW);
PumpName = PumpNames{cRandInd};
PumpIndex = IOMatchPump2Index(HW,PumpName);
% PrewardDuration = PrewardAmount/globalparams.PumpMlPerSec.(PumpName);
PrewardDuration = PrewardAmount/globalparams.PumpMlPerSec.Pump;
Prewarded = 0;
AutomaticReward = get(O,'AutomaticReward');

% PREPARE FOR LATE CENTERING REWARD
CenteringRewardDelay = get(O,'CenteringRewardDelay');
CenteringRewarded = 1;

% PREPARE FOR CENTER REWARD
CenterRewardAmount = get(O,'CenterRewardAmount');
CenterRewarded = 0;

%% PREPARE FOR LIGHT CUE
LightCueDuration = get(O,'LightCueDuration'); LightCued = 0;
LightNames = IOMatchPosition2Light(HW,cPositions);
LightName = LightNames{cRandInd}; % CUE SHOULD ALWAYS BE RANDOM

%% WAIT FOR THE CLICK AND RECORD POSITION AND TIME
% SensorNames = HW.DIO.Line.LineName;
SensorNames = {HW.Didx.Name};
SensorChannels(1)=find(strcmp(SensorNames,'TouchL'));
SensorChannels(2)=find(strcmp(SensorNames,'TouchR'));
AllLickSensorNames = SensorNames(~cellfun(@isempty,strfind(SensorNames,'Touch')));
LightSensorChannels = find(strcmp(SensorNames,'Light'));

automatichit=0;

% SYNCHRONIZE COMPUTER CLOCK WITH DAQ TIME
 CurrentTimeIndice=1;
tic; CurrentTime = IOGetTimeStamp(HW); InitialTime = CurrentTime;
fprintf(['Running Trial [ <=',n2s(exptparams.LogDuration),'s ] ... ']);
while CurrentTime < exptparams.LogDuration
  
  DetectType = 'ON'; LickOccured = 0; BrokenLight = 0;
  %CurrentTime = IOGetTimeStamp(HW); % INACCURATE WITH DISCRETE STEPS
  CurrentTime = toc+InitialTime;
  
  AutomaticLick=0;
  
  tictocresolution=0.000001;
  if CurrentTime<TarWindow(1)
    % READ LIGHT SENSOR
    if ~Simulick
      cVals(CurrentTimeIndice)= IOLickRead(HW,LightSensorChannels);
      if CurrentTimeIndice>=30001 && mean(cVals(CurrentTimeIndice-30000:CurrentTimeIndice))==0 % tictoc resolution : 0.000001 du coup *30000 pour 30ms Trying to prevent too many snoozes for Paneer
        BrokenLight = 1;
      end
    end
    
    
  elseif CurrentTime>TarWindow(1) && CurrentTime<TarWindow(2)
    % READ LICKS FROM ALL SENSORS
    if ~Simulick   cLick = IOLickRead(HW,SensorChannels);
    else cLick = ones(size(SensorChannels));
      if CurrentTime>= LickTime cLick(ceil(length(cLick)*rand)) = 0; end
    end
    switch DetectType
      case 'ON'; if any(cLick) LickOccured = 1; end;
      case 'OFF'; if any(~cLick) LickOccured = 1; end;
    end
    
  else % change 23/01/15 Y&J 
    if strcmp(AutomaticReward,'yes')
      LickOccured = 1;
      AutomaticLick=1;
    end
  end

    CurrentTimeIndice=CurrentTimeIndice+1;
     
    % PROCESS LIGHT BEAM
    if BrokenLight    
      ResponseTime = CurrentTime;
      Events=AddEvent(Events,'LIGHT',TrialIndex,ResponseTime,[]);
      break;
    end
    
    % PROCESS LICK GENERALLY
    if LickOccured
      if strcmp(AutomaticReward,'yes') && AutomaticLick==1
%         pause(0.4)
        ResponseTime = TarWindow(2)-0.001;
        automatichit=1;
        cLickSensorInd = find( not( cellfun(@isempty , strfind({SensorNames{SensorChannels}},TargetSensors{1}) ) ) );
        cLickSensor = SensorNames{SensorChannels(cLickSensorInd)};
        cLickSensorNot = setdiff(SensorNames(SensorChannels),cLickSensor);
      else
        ResponseTime = CurrentTime;
        cSensorChannels = SensorChannels(find(cLick,1,'first'));
        if ~isempty(cSensorChannels)
          cLickSensorInd = find(cLick,1,'first');
          cLickSensor = SensorNames{SensorChannels(cLickSensorInd)}; % CORRECT FOR BOTH 'ON' AND 'OFF' RESULTS
          cLickSensorNot = setdiff(SensorNames(SensorChannels),cLickSensor);
        else
          cLickSensor = 'None'; cLickSensorNot = 'None';
        end
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
    
    % DELIVER DELAYED CENTERING REWARD (FOR CASES IN WHICH THE CENTERING OCCURS DURING RECORDING)
    if CenteringRewarded && any(CenterRewardAmount) && (CurrentTime > CenteringRewardDelay)
      fprintf('Centering reward ');
      cPumpDuration = CenterRewardAmount/globalparams.PumpMlPerSec.Pump;
      PumpEvent = IOControlPump(HW,'start',cPumpDuration,'Pump');
      exptparams.Water = exptparams.Water+CenterRewardAmount;
      Events = AddEvent(Events, PumpEvent, TrialIndex);
      fprintf('\b ... '); CenteringRewarded = 0;
    end
    
    % DELIVER CENTER STAYING REWARD
    if CenterRewarded && any(CenterRewardAmount) && (CurrentTime > TarWindow(1))
      fprintf('Center reward ');
      cPumpDuration = CenterRewardAmount/globalparams.PumpMlPerSec.Pump;
      PumpEvent = IOControlPump(HW,'start',cPumpDuration,'Pump');
      exptparams.Water = exptparams.Water+CenterRewardAmount;
      Events = AddEvent(Events, PumpEvent, TrialIndex);
      fprintf('\b ... '); CenterRewarded = 0;
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
  % IF NO RESPONSE OCCURED
  if ~LickOccured
    ResponseTime = inf;
  end
  
  if LickOccured
    fprintf(['\t Lick detected [ ',cLickSensor,', at ',n2s(ResponseTime,3),'s ] ... ']);
  else
    fprintf(['\t No Lick detected ... ']); if strcmp(AutomaticReward,'no'); cLickSensor = ''; end
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
  
  %% TAKE ACTION BASED ON OUTCOME
  switch Outcome
    case 'EARLY'; % STOP SOUND, TIME OUT + LIGHT ON
      StopEvent = IOStopSound(HW);
      Events = AddEvent(Events, StopEvent, TrialIndex);
      LightEvents = LF_TimeOut(HW,get(O,'TimeOutEarly'),0,TrialIndex);
      Events = AddEvent(Events, LightEvents, TrialIndex);
      
    case 'ERROR'; % STOP SOUND, HIGH VOLUME NOISE, LIGHT ON, TIME OUT
      StopEvent = IOStopSound(HW); Events = AddEvent(Events, StopEvent, TrialIndex);
      if ShockDuration
        ShockEvent = IOControlShock(HW,ShockDuration);
        Events = AddEvent(Events,ShockEvent,TrialIndex);
      end
      if strcmp(get(O,'PunishSound'),'Noise')
        IOStartSound(HW,randn(10000,1)); pause(0.25); IOStopSound(HW);
      end
      TimeOut = get(O,'TimeOutError'); if ischar(TimeOut) TimeOut = str2num(TimeOut); end
      LightEvents = LF_TimeOut(HW,TimeOut,0,TrialIndex);
      Events = AddEvent(Events, LightEvents, TrialIndex);
      
    case 'HIT'; % PROVIDE REWARD AT CORRECT SPOUT
      StopEvent = IOStopSound(HW);
      PumpName = cell2mat(IOMatchSensor2Pump(cLickSensor,HW));
      if length(RewardAmount)>1 % ASYMMETRIC REWARD SCHEDULE ACROSS SPOUTS
        RewardAmount = RewardAmount(cLickSensorInd);
      end
      %different reward depending on either voluntary lick or automatic
      %5/02/15 Jennifer
      if  automatichit == 1
        RewardAmount = RewardAmount/3;
      else
        RewardAmount = RewardAmount;
      end
      PumpDuration = RewardAmount/globalparams.PumpMlPerSec.Pump;
      pause(0.05); % PAUSE TO ALLOW FOR HEAD TURNING
      PumpEvent = IOControlPump(HW,'Start',PumpDuration,PumpName);
      Events = AddEvent(Events, PumpEvent, TrialIndex);
      exptparams.Water = exptparams.Water+RewardAmount;
      % MAKE SURE PUMPS ARE OFF (BECOMES A PROBLEM WHEN TWO PUMP EVENTS TOO CLOSE)
      pause(PumpDuration);
      PumpEvent = IOControlPump(HW,'stop',0,PumpName);
      Events = AddEvent(Events, PumpEvent, TrialIndex);
      IOControlPump(HW,'stop',0,'Pump');
      
    case 'SNOOZE';
     StopEvent = IOStopSound(HW);
      Events = AddEvent(Events, StopEvent, TrialIndex);
      cLickSensor = 'None'; cLickSensorNot = 'None';
      pause(0.1); % TO AVOID EMPTY LICKSIGNAL
      
      TimeOut = get(O,'TimeOutEarly'); if ischar(TimeOut) TimeOut = str2num(TimeOut); end
      LightEvents = LF_TimeOut(HW,TimeOut,0,TrialIndex);
      Events = AddEvent(Events, LightEvents, TrialIndex);
      
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
  disp(LickTime)
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