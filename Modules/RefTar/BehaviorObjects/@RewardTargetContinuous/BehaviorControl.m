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
IncrementRewardAmount = get(O,'IncrementRewardAmount');
MaxIncrementRewardNb = get(O,'MaxIncrementRewardNb');

%% GET TARGET & REFERENCE INDICES
tmp = get(exptparams.TrialObject,'ReferenceIndices'); ReferenceIndices = tmp{exptparams.InRepTrials};
tmp = get(exptparams.TrialObject,'TargetIndices'); TargetIndices = tmp{exptparams.InRepTrials};

%% COMPUTE RESPONSE WINDOWS
str1ind = strfind(StimEvents(end).Note,' '); str2ind = strfind(StimEvents(end).Note,'-')-1;
Index = str2num(StimEvents(end).Note(str1ind(3):str2ind(1)));
TH = get(exptparams.TrialObject,'TargetHandle');
DistributionTypeByInd = get(TH,'DistributionTypeByInd');
DistributionTypeNow = DistributionTypeByInd(Index); 
DifficultyLvl = str2num(get(TH,['DifficultyLvl_D' num2str(DistributionTypeNow)]));
DifficultyLvlByInd = get(TH,'DifficultyLvlByInd');
DifficultyNow = DifficultyLvl( DifficultyLvlByInd(Index) );

TarInd = find(~cellfun(@isempty,strfind({StimEvents.Note},'Target')));
EarlyWindow = StimEvents(end).StartTime;        % include 0.4s PreStimSilence / 2s Frozen / ToC (without response window)
TargetStartTime = 0; %StimEvents(TarInd(1)).StartTime;
if DifficultyNow~=0 % not a catch trial
  CatchTrial = 0;
  TarWindow(1) = TargetStartTime + EarlyWindow;
  TarWindow(2) = TarWindow(1) + get(O,'ResponseWindow');
else
  CatchTrial = 1;
  TarWindow(1) = TargetStartTime + EarlyWindow  + get(O,'ResponseWindow');
  TarWindow(2) = TarWindow(1);
end
RefWindow = [0,TarWindow(1)];
Simulick = get(O,'Simulick'); if Simulick; LickTime = rand*(TarWindow(2)+1); end
MinimalDelayResponse = get(O,'MinimalDelayResponse');

TrialObject = get(exptparams.TrialObject);
LickTargetOnly = TrialObject.LickTargetOnly;
RewardSnooze = TrialObject.RewardSnooze;

%% SOUND SLICES
SF = get(TH,'SamplingRate');
AnticipatedLoadingDuration = 0.15;
Par = get(TH,'Par');
ChordDuration = Par.ToneDuration;
SliceDuration = 0.250; SliceDuration = round(SliceDuration/ChordDuration)*ChordDuration;            % sec.
SlicesInAsegment = round(SliceDuration/ChordDuration);
SegmentMeanDuration = 3;        % sec.
SegmentStdDuration = 1;         % sec.
SegmentMinDuration = 0.6; SegmentMinDuration = round(SegmentMinDuration/ChordDuration/SlicesInAsegment);             % segment nb
SegmentPostHitDuration = 1; SegmentPostHitDuration = round(SegmentPostHitDuration/ChordDuration/SlicesInAsegment);   % segment nb
SegmentPostFADelay = 2; SegmentPostFADelay = round(SegmentPostFADelay/ChordDuration/SlicesInAsegment);               % segment nb
BufferSize = 45; BufferSize = round(BufferSize/ChordDuration/SlicesInAsegment);                                      % segment nb
CatchIndices = find(DifficultyLvl==0);           
IndexLst = 1:(CatchIndices(1)-1); for CatchNum = 2:length(CatchIndices); IndexLst = [IndexLst (CatchIndices(CatchNum-1)+1) : (CatchIndices(CatchNum)+1) ]; end
IndexLst = [IndexLst (CatchIndices(end)+1):str2num(get(TH,'MaxIndex')) ];

%% SOUND OBJECTS
% Initial distribution SO
THcatch = TH;
THcatch = set(THcatch,'PreStimSilence',0);
THcatch = set(THcatch,'MinToC',ChordDuration*2);
THcatch = ObjUpdate(THcatch);
% Incremented distribution SO
THincr = TH;
THincr = set(THincr,'PreStimSilence',0);
THincr = set(THincr,'MinToC',SliceDuration*2);
THincr = set(THincr,'Inverse_D0Dbis','yes');
THincr = set(THincr,'StimulusBisDuration',ChordDuration);
THincr = ObjUpdate(THincr);

%% BUILD SEQUENCES OF INDEX
SliceCounter = 1; IndexListing = []; SegmentDurations = [];
Xnormcdf = 0:ChordDuration:(SegmentMeanDuration+3*SegmentStdDuration);
SegmentDurationDistri = normcdf(Xnormcdf,SegmentMeanDuration,SegmentStdDuration); SegmentDurationDistri([1 length(SegmentDurationDistri)]) = [0 1];
for RepetitionNum = 1: round(BufferSize/(round(SegmentMeanDuration/ChordDuration)*ChordDuration))
    ShuffledInd = ones(1,2*length(IndexLst)) * CatchIndices(1);
    ShuffledInd( 2:2:2*length(IndexLst) )= shuffle(IndexLst);
    IndexListing = [ IndexListing ShuffledInd ];
    SegmentDurations_tmp = interp1( SegmentDurationDistri , Xnormcdf , rand(1,length(ShuffledInd)) );
    SegmentDurations = [ SegmentDurations max(round(SegmentDurations_tmp/ChordDuration/SlicesInAsegment),SegmentMinDuration) ];
end
IndexSequence = zeros(1,sum(SegmentDurations));
for IndNum = 1:length(IndexListing)
    IndexSequence( sum(SegmentDurations(1:(IndNum-1))) + 1:SegmentDurations(IndNum)) = IndexListing(IndNum);
end
IndexSequence = IndexSequence(1:BufferSize);

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
tic; StartingBloc = toc; CurrentTime = IOGetTimeStamp(HW); InitialTime = CurrentTime;
fprintf(['Running Trial [ <=',n2s(exptparams.LogDuration),'s ] ... ']);

SliceCounter = 0;
while CurrentTime < (StartingBloc+BufferSize)
    SliceCounter = SliceCounter+1;
    Index = IndexSequence(SliceCounter);
    
    % Re-parameterize the SO according to what is needed
    if ismember(Index,CatchIndices)
        w = waveform(THcatch,Index,SliceDuration,[],SliceCounter*TrialIndex);
    else % Incremented distribution. 'Inverse_D0Dbis' is true, so we have to choos ehte right index
        w = waveform(THincr,Index*2,SliceDuration,[],SliceCounter*TrialIndex);
    end
    
    NewSlice = w(1:round(SliceDuration*SF));
    HW = IOLoadSound(HW, NewSlice);
    NextSliceTiming = CurrentTime+length(NewSlice)/SF;
    while CurrentTime < (NextSliceTiming-AnticipatedLoadingDuration)

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
        exptparams.Water = exptparams.Water +  PrewardAmount;
        fprintf('\b ... '); Prewarded = 1;
      end
    end
    
end
% IF NO RESPONSE OCCURED
if ~LickOccured ResponseTime = inf; end

if LickOccured
  fprintf(['\t Lick detected [ ',cLickSensor,', at ',n2s(ResponseTime,3),'s ] ... ']);
else
  fprintf(['\t No Lick detected ... ']); cLickSensor = ''; 
end

%%  PROCESS LICK
if ResponseTime < (TarWindow(1) +MinimalDelayResponse)
  Outcome = 'EARLY';
elseif ResponseTime > TarWindow(2)  % CASES NO LICK AND LATE LICK
  if ~CatchTrial
    Outcome = 'SNOOZE';
  else
    ResponseTime = TarWindow(2);
    cLickSensor = TargetSensors{1}; cLickSensorNot = 'None';
    Outcome = 'HIT'; % includes ambigous if both are specified
  end
else % HIT OR ERROR
  switch cLickSensor % CHECK WHERE THE LICK OCCURED
    case TargetSensors;   Outcome = 'HIT'; % includes ambigous if both are specified 
    otherwise;                   Outcome = 'ERROR';
  end
end
Events=AddEvent(Events,['OUTCOME,',Outcome],TrialIndex,ResponseTime,[]);
if strcmp(Outcome,'HIT'); Outcome2Display = [Outcome ', RT = ' num2str(ResponseTime-TarWindow(1))]; else Outcome2Display = Outcome; end
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
      Tbuzz = [0:1/100000:0.7]; Xbuzz = sin(2.*pi.*110.*Tbuzz);
      Ybuzz = 2*square(2*pi*440*Tbuzz + Xbuzz);
      IOStartSound(HW,Ybuzz*15); pause(0.25); IOStopSound(HW);
    end
    
    Events = AddEvent(Events, StopEvent, TrialIndex);
    LightEvents = LF_TimeOut(HW,get(O,'TimeOutEarly'),LEDfeedback,TrialIndex,Outcome);
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
    % 14/02/20-YB: Patched to change LED/pump structure + Duration2Play (cf. lab notebook)
    Duration2Play = 0.5; LEDposition = {'left'};
    % Stop Dbis sound when <Duration2Play> is elapsed
    if ~CatchTrial; pause(max([0 , (TarWindow(1)+Duration2Play)-IOGetTimeStamp(HW) ])); end
    
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
    MinToC = str2double(get(TH,'MinToC')); MaxToC = str2double(get(TH,'MaxToC'));
    if CatchTrial
      if ~(RewardSnooze); RewardAmount = 0; else RewardAmount = RewardAmount/3; pause(0.2); end 
    else
      RewardAmount = RewardAmount * (0.5 + (TarWindow(1)-MinToC)/(MaxToC-MinToC)) + IncrementRewardAmount*NbContiguousLastHits;
    end   
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
    
    StopEvent = IOStopSound(HW);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    
    % Turn LED OFF
    [State,LightEvent] = IOLightSwitch(HW,0,0,[],[],[],LightNames{1});
    Events = AddEvent([],LightEvent,TrialIndex);
  case 'SNOOZE';  % STOP SOUND
    StopEvent = IOStopSound(HW);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    
    if RewardSnooze
      pause(0.2);
      LEDposition = {'left'}; cLickSensor =TargetSensors;
      PumpName = cell2mat(IOMatchSensor2Pump(cLickSensor));
      RewardAmount = RewardAmount/3;
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
    end 
    
    cLickSensor = 'None'; cLickSensorNot = 'None';
    pause(0.1); % TO AVOID EMPTY LICKSIGNAL
    
  otherwise error(['Unknown outcome ''',Outcome,'''!']);
end
fprintf('\n');

if CatchTrial; LickTime = NaN; elseif ~strcmp(Outcome,'SNOOZE'); LickTime = ResponseTime; else LickTime = NaN; end
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