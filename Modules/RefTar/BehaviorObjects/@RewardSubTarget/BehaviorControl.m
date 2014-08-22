function [Events, exptparams] = BehaviorControl(O, HW, StimEvents, globalparams, exptparams, TrialIndex)
% Behavior Object for RewardSubTarget object
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
MinRewardAmount = get(O,'MinRewardAmount');
IncrementRewardAmount = get(O,'IncrementRewardAmount');
MaxIncrementRewardNb = get(O,'MaxIncrementRewardNb');
SamplingRate = get(get(exptparams.TrialObject,'TargetHandle'),'SamplingRate');

%% GET TARGET & REFERENCE INDICES
tmp = get(exptparams.TrialObject,'ReferenceIndices'); ReferenceIndices = tmp{exptparams.InRepTrials};
tmp = get(exptparams.TrialObject,'TargetIndices'); TargetIndices = tmp{exptparams.InRepTrials};

%% COMPUTE RESPONSE WINDOWS
str1ind = strfind(StimEvents(end-2).Note,'-'); str1ind = str1ind(end)+2;
str2ind = strfind(StimEvents(end-2).Note,','); str2ind = str2ind(end)-2;
Index = str2num(StimEvents(end-2).Note((str1ind):(str2ind)));

% TarInd = find(~cellfun(@isempty,strfind({StimEvents.Note},'LickWindow')));
EarlyWindow = StimEvents(end-1).StartTime;
EndWindow = StimEvents(end-1).StopTime;
TargetStartTime = 0; %StimEvents(TarInd(1)).StartTime;
MinimalDelayResponse = get(O,'MinimalDelayResponse');
ExtendResponseWindow = get(O,'ExtendResponseWindow');

TarWindow(1) = EarlyWindow + MinimalDelayResponse;
TarWindow(2) = EndWindow + ExtendResponseWindow;

RefWindow = [0,TarWindow(1)];
Objects.Tar = get(exptparams.TrialObject,'TargetHandle');
Simulick = get(O,'Simulick'); if Simulick; LickTime = rand*(TarWindow(2)+1); end
MinimalDelayResponse = get(O,'MinimalDelayResponse');

TrialObject = get(exptparams.TrialObject);
LickTargetOnly = TrialObject.LickTargetOnly;

%% PREPARE FOR PREWARD
cPositions = {'center'};
% IF MULTIPLE POSSIBLE : RANDOM REWARD or ALWAYS REWARD (comment out next line)
cRandInd = 1; %randi(1,1,[1,length(cPositions)]);
TargetSensors = IOMatchPosition2Sensor(cPositions);
PumpNames = IOMatchPosition2Pump(cPositions);
PumpName = PumpNames{cRandInd};
PumpIndex = 1;%IOMatchPump2Index(HW,PumpName);
PrewardDuration = PrewardAmount/globalparams.PumpMlPerSec.(PumpName);
Prewarded = 0; 

%% PREPARE FOR LIGHT CUE
LEDfeedback = get(O,'LEDfeedback');
LightCueDuration = get(O,'LightCueDuration'); LightCued = 0;
LightNames = IOMatchPosition2Light(HW,cPositions);
LightName = LightNames{cRandInd}; % CUE SHOULD ALWAYS BE RANDOM

%% WAIT FOR THE CLICK AND RECORD POSITION AND TIME
SensorNames = {HW.Didx.Name};
SensorChannels=find(strcmp(SensorNames,'Touch'));
AllLickSensorNames = SensorNames(~cellfun(@isempty,strfind(SensorNames,'Touch')));

% SYNCHRONIZE COMPUTER CLOCK WITH DAQ TIME
CountingLicks = [];
tic; CurrentTime = IOGetTimeStamp(HW); InitialTime = CurrentTime;
fprintf(['Running Trial [ <=',n2s(exptparams.LogDuration),'s ] ... ']);
while CurrentTime < exptparams.LogDuration
DetectType = 'ON'; LickOccured = 0;
  %CurrentTime = IOGetTimeStamp(HW); % INACCURATE WITH DISCRETE STEPS
  CurrentTime = toc+InitialTime;
  % READ LICKS FROM ALL SENSORS
  if ~Simulick;   cLick = IOLickRead(HW,SensorChannels);
    
  else cLick = ones(size(SensorChannels)); 
    if CurrentTime>= LickTime; cLick(ceil(length(cLick)*rand)) = 0; end
  end
  if ~LickTargetOnly
    switch DetectType
      case 'ON'; if any(cLick); LickOccured = 1; end;
      case 'OFF'; if any(~cLick); LickOccured = 1; end;
    end
  else  % Only licks in Target window stop the trial
    InTarget = CurrentTime > (TarWindow(1) +MinimalDelayResponse);
    switch DetectType
      case 'ON'; if any(cLick) && InTarget; LickOccured = 1; end;
      case 'OFF'; if any(~cLick) && InTarget; LickOccured = 1; end;
    end    
  end
  
  
  % PROCESS LICK GENERALLY
  if LickOccured
    ResponseTime = CurrentTime; 
    CountingLicks = [CountingLicks ResponseTime];
    
    %strfind(StimEvents(end).Note, ' / ')-2
   % IndRef = StimEvents(end).Note(strfind(StimEvents(end).Note,'/')-1);
    cSensorChannels = SensorChannels(find(cLick,1,'first'));
    if ~isempty(cSensorChannels)
      cLickSensorInd = find(cLick,1,'first');
      cLickSensor = SensorNames{SensorChannels(cLickSensorInd)}; % CORRECT FOR BOTH 'ON' AND 'OFF' RESULTS
      cLickSensorNot = setdiff(SensorNames(SensorChannels),cLickSensor);
    else
      cLickSensor = 'None'; cLickSensorNot = 'None';     
    end   
    Events = AddEvent(Events,['LICK,',cLickSensor],TrialIndex,ResponseTime,[]);
    if ~get(O,'GradualResponse')%&& ResponseTime >  StimEvents(1).StopTime + SeqLen/2;
      break
    elseif get(O,'GradualResponse') && ResponseTime >TarWindow(1) 
      break
    end    
  else
    ResponseTime =inf;    
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

% % Count number of references where a lick occured
% if get(O,'GradualResponse')
%   DidItLicks = zeros(1,length(StimEvents) - 3);
%   if not(isempty(CountingLicks))
%     for j = 1:length(CountingLicks)
%       for jj = 2:length(StimEvents)-2
%         if CountingLicks(j)>StimEvents(jj).StartTime && CountingLicks(j)<StimEvents(jj).StopTime && DidItLicks(jj) == 0
%           DidItLicks(jj)=j ;
%         end
%       end
%     end
%   end
%   BadLickSum = sum(DidItLicks ~= 0);
% end

%   MinimalInterval = 0.250*HW.params.fsAI;     % samples  
%   LickTimings = find( diff( LickData(:,cP.LickSensorInd) ) >0)';
%   FarLickTimingsIndex = unique( [1 find(diff(LickTimings)>MinimalInterval)+1] );
%   cP.LickTime = LickTimings(FarLickTimingsIndex);
% IF NO RESPONSE OCCURED
if ~LickOccured; ResponseTime = inf; end

if LickOccured
  fprintf(['\t Lick detected [ ',cLickSensor,', at ',n2s(ResponseTime,3),'s ] ... ']);
else
  fprintf(['\t No Lick detected ... ']); cLickSensor = ''; 
end

%%  PROCESS LICK
if any( CountingLicks>TarWindow(1)  & CountingLicks < TarWindow(2) ) % && BadLickSum == 0
  Outcome = 'HIT';
 % IndexLicks = find( CountingLicks>TarWindow(1)  & CountingLicks < TarWindow(2) );
  ResponseTime = CountingLicks(end);
elseif ~isempty(CountingLicks) && all( CountingLicks<TarWindow(1) )%& CountingLicks >(StimEvents(1).StopTime + SeqLen/2)  )
  Outcome = 'EARLY';
  % IndexLicks = find( CountingLicks<TarWindow(1) ); 
  ResponseTime = CountingLicks(1);  
else  % CASES NO LICK AND LATE LICK
   Outcome = 'SNOOZE';
% else % HIT OR ERROR
%   switch cLickSensor % CHECK WHERE THE LICK OCCURED
%     case TargetSensors;   Outcome = 'HIT'; % includes ambigous if both are specified 
%     otherwise                  Outcome = 'ERROR';
%   end
end
Events = AddEvent(Events,['OUTCOME,',Outcome],TrialIndex,ResponseTime,[]);
if strcmp(Outcome,'HIT')
  Outcome2Display = [Outcome ' / ' num2str(Index) ', RT = ' num2str(ResponseTime-TarWindow(1)+MinimalDelayResponse)];
else
  Outcome2Display = [Outcome ' / ' num2str(Index)];
end
fprintf(['\t [ ',Outcome2Display,' ] ... ']);

%% ACTUALIZE VISUAL FEEDBACK FOR THE SUBJECT
if TrialObject.VisualDisplay
    [VisualDispColor,exptparams] = VisualDisplay(TrialIndex,Outcome,exptparams);
end

%% TAKE ACTION BASED ON OUTCOME
switch Outcome
  case 'EARLY'; % STOP SOUND, TIME OUT + LIGHT ON
    
      
    StopEvent = IOStopSound(HW);
      if strcmp(get(O,'PunishSound'),'Noise') 
      IOStartSound(HW,randn(5000,1)*15); pause(0.25); IOStopSound(HW); 
    elseif  strcmp(get(O,'PunishSound'),'Buzz') 
      BuzzDuration = 0.8;
      Tbuzz = [0:(1/SamplingRate): BuzzDuration]; Xbuzz = sin(2.*pi.*110.*Tbuzz);
      Ybuzz = square(2*pi*1000*Tbuzz +2*Xbuzz);
      % Mbuzz = maxLocalStd(Ybuzz,SamplingRate,length(Tbuzz)/SamplingRate);
      %Ybuzz = Ybuzz/Mbuzz;
      IOStartSound(HW,Ybuzz*15); pause( BuzzDuration); IOStopSound(HW);
      % IOStartSound(HW,randn(5000,1)*15); pause(0.25); IOStopSound(HW);
    end
    pause(0.25);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    LightEvents = LF_TimeOut(HW,get(O,'TimeOutEarly'),LEDfeedback,TrialIndex,Outcome);
    Events = AddEvent(Events, LightEvents, TrialIndex);
    
      

  case 'ERROR'; % STOP SOUND, HIGH VOLUME NOISE, LIGHT ON, TIME OUT
    StopEvent = IOStopSound(HW); Events = AddEvent(Events, StopEvent, TrialIndex);
    if strcmp(get(O,'PunishSound'),'Noise') 
      Tbuzz = [0:1/SamplingRate:0.7]; Xbuzz = sin(2.*pi.*110.*Tbuzz); 
      Ybuzz = square(2*pi*440*Tbuzz + Xbuzz);
      Mbuzz = maxLocalStd(Ybuzz,SamplingRate,length(Tbuzz)/SamplingRate);
      Ybuzz = Ybuzz/Mbuzz;
      IOStartSound(HW,Ybuzz); pause(0.25); IOStopSound(HW); 
    end
    TimeOut = get(O,'TimeOutError'); if ischar(TimeOut) TimeOut = str2num(TimeOut); end
    LightEvents = LF_TimeOut(HW,roundn(TimeOut*(1+rand),-1),1,TrialIndex);
    Events = AddEvent(Events, LightEvents, TrialIndex);
  
  case 'HIT'; % STOP SOUND, PROVIDE REWARD AT CORRECT SPOUT
    % 14/02/20-YB: Patched to change LED/pump structure + Duration2Play (cf. lab notebook)
    Duration2Play = 0.5; LEDposition = {'left'};
    % Stop Dbis sound when <Duration2Play> is elapsed
    pause(max([0 , (TarWindow(1)+Duration2Play)-IOGetTimeStamp(HW) ]));
    StopEvent = IOStopSound(HW);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    
    PumpName = cell2mat(IOMatchSensor2Pump(cLickSensor));
    if length(RewardAmount)>1 % ASYMMETRIC REWARD SCHEDULE ACROSS SPOUTS
      RewardAmount = RewardAmount(cLickSensorInd);
    end
    
    if ~globalparams.PumpMlPerSec.(PumpName)
      globalparams.PumpMlPerSec.(PumpName) = inf;
    end
    if TrialIndex>1
      LastOutcomes = {exptparams.Performance((TrialIndex-1) :-1: max([1 (TrialIndex-MaxIncrementRewardNb)]) ).Outcome};
    else LastOutcomes = {'HIT'}; end
%     NbContiguousLastHits = min([find(strcmp(LastOutcomes,'EARLY'),1,'first') , find(strcmp(LastOutcomes,'SNOOZE'),1,'first') ])-1; 
    NbContiguousLastHits = find(strcmp(LastOutcomes,'EARLY'),1,'first')-1;   % Only Early are taken into account
    if isempty(NbContiguousLastHits), NbContiguousLastHits = length( find(strcmp(LastOutcomes,'HIT')) );
    else NbContiguousLastHits = NbContiguousLastHits - length( find(strcmp(LastOutcomes(1:(NbContiguousLastHits+1)),'SNOOZE')) ); end  % But Snoozes don't give bonus
%     if get(O,'GradualResponse')
%       RewardAmount = MinRewardAmount + ...
%         (RewardAmount-MinRewardAmount)*((length(StimEvents) - 3)-BadLickSum)/(length(StimEvents) - 3)
%     end
   
    RewardAmount = RewardAmount + IncrementRewardAmount*NbContiguousLastHits;

    PumpDuration = RewardAmount/globalparams.PumpMlPerSec.(PumpName);
    % pause(0.05); % PAUSE TO ALLOW FOR HEAD TURNING
    PumpEvent = IOControlPump(HW,'Start',PumpDuration,PumpName);
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    exptparams.Water = exptparams.Water+RewardAmount;
    % MAKE SURE PUMPS ARE OFF (BECOMES A PROBLEM WHEN TWO PUMP EVENTS TOO CLOSE)
    pause(PumpDuration/2);
    % Turn LED ON
    LightNames = IOMatchPosition2Light(HW,LEDposition);
    [State,LightEvent] = IOLightSwitch(HW,1,0,[],[],[],LightNames{1});
    Events = AddEvent([],LightEvent,TrialIndex);
    
    pause(PumpDuration/2);
    PumpEvent = IOControlPump(HW,'stop',0,PumpName);
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    IOControlPump(HW,'stop',0,'Pump');
    
    % Turn LED OFF
    [State,LightEvent] = IOLightSwitch(HW,0,0,[],[],[],LightNames{1});
    Events = AddEvent([],LightEvent,TrialIndex);
  case 'SNOOZE';  % STOP SOUND
    StopEvent = IOStopSound(HW);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    
    cLickSensor = 'None'; cLickSensorNot = 'None';
    pause(0.1); % TO AVOID EMPTY LICKSIGNAL
    
  otherwise error(['Unknown outcome ''',Outcome,'''!']);
end
fprintf('\n');

if ~strcmp(Outcome,'SNOOZE'); LickTime = ResponseTime; else LickTime = NaN; end
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
if strcmpi(Outcome,'Early'); TimeOutEvent = struct('Note',['TIMEOUT,',n2s(TimeOut,4),' seconds'],'StartTime',StartTime,'StopTime',StartTime + TimeOut); end

  % TURN LIGHT OFF AFTER TIMEOUT
if Light
    LightNames = IOMatchPosition2Light(HW,Positions);
    [State,LightEvent] = IOLightSwitch(HW,0,[],[],[],[],LightNames{1});
    Events.StopTime = LightEvent.StartTime;
end

% ADD TIME OUT EVENT
if strcmpi(Outcome,'Early'); 
  if ~exist('Events','var')
    Events = TimeOutEvent;
  else
    Events = AddEvent(Events,TimeOutEvent,cTrial);
  end
end