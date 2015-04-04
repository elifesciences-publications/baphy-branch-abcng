function [Events, exptparams] = BehaviorControl(O, HW, StimEvents, globalparams, exptparams, TrialIndex)
% Behavior Object for RewardTargetContinuous object
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
% YB 2014/07

Events = [ ];
DetectType = 'ON';

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
RespWinDur = get(O,'ResponseWindow');

TrialObject = get(exptparams.TrialObject);
LickTargetOnly = TrialObject.LickTargetOnly;
RewardSnooze = TrialObject.RewardSnooze;

%% SOUND SLICES
SF = get(TH,'SamplingRate');
AnticipatedLoadingDuration = 0.200;
Par = get(TH,'Par');
ChordDuration = Par.ToneDuration;
SliceDuration = 0.400; SliceDuration = round(SliceDuration/ChordDuration)*ChordDuration;            % sec.
SlicesInAsegment = round(SliceDuration/ChordDuration);
SegmentMeanDuration = 3;        % sec.
SegmentStdDuration = 1;         % sec.
SegmentMinDuration = 0.6; SegmentMinDuration = round(SegmentMinDuration/ChordDuration/SlicesInAsegment);             % segment nb
SegmentPostHitDuration = 1; SegmentPostHitDuration = round(SegmentPostHitDuration/ChordDuration/SlicesInAsegment);   % segment nb
SegmentPostFADelay = 2.5; SegmentPostFADelay = round(SegmentPostFADelay/ChordDuration/SlicesInAsegment);               % segment nb
BufferSize = 45; BufferSize = round(BufferSize/ChordDuration/SlicesInAsegment);                                      % segment nb
CatchIndices = find(DifficultyLvl==0);
IndexLst = 1:(CatchIndices(1)-1); for CatchNum = 2:length(CatchIndices); IndexLst = [IndexLst (CatchIndices(CatchNum-1)+1) : (CatchIndices(CatchNum)+1) ]; end
IndexLst = [IndexLst (CatchIndices(end)+1):get(TH,'MaxIndex') ];

%% SOUND OBJECTS % Re-parameterize the SO according to what is needed
% Initial distribution SO
THcatch = TH;
THcatch = set(THcatch,'PreStimSilence',0);
THcatch = set(THcatch,'StimulusBisDuration',ChordDuration);
THcatch = ObjUpdate(THcatch);
% Incremented distribution SO
THincr = TH;
THincr = set(THincr,'PreStimSilence',0);
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
  IndexSequence( sum(SegmentDurations(1:(IndNum-1))) + (1:SegmentDurations(IndNum)) ) = IndexListing(IndNum);
end
IndexSequence = IndexSequence(1:BufferSize);

LEDfeedback = get(O,'LEDfeedback');
cPositions = {'center'}; TargetSensors = IOMatchPosition2Sensor(cPositions);
cLickSensor = TargetSensors{1};

%% WAIT FOR THE CLICK AND RECORD POSITION AND TIME
SensorNames = {HW.Didx.Name};
SensorChannels=find(strcmp(SensorNames,'Touch'));
AllLickSensorNames = SensorNames(~cellfun(@isempty,strfind(SensorNames,'Touch')));

% SYNCHRONIZE COMPUTER CLOCK WITH DAQ TIME
fprintf(['Running Trial [ <=',n2s(exptparams.LogDuration),'s ] ... ']);
CurrentTime = 0; SliceCounter = 0; LickOccured = 0; TimingLastChange = 0;
while (CurrentTime+SliceDuration) < (length(IndexSequence)*SliceDuration)
  SliceCounter = SliceCounter+1;
  
  % If lick occured, actualize IndexSequence
  if LickOccured
    switch Outcome
      case 'HIT'
        NextDifferentIndex = find(IndexSequence(SliceCounter+1:end)~=IndexSequence(SliceCounter),1,'first');
        IndexSequence = [IndexSequence(1:SliceCounter) ones(1,SegmentPostHitDuration)*IndexSequence(SliceCounter) IndexSequence(SliceCounter+NextDifferentIndex:end)];
      case 'EARLY'
        IndexSequence = [IndexSequence(1:SliceCounter) ones(1,SegmentPostFADelay)*IndexSequence(SliceCounter) IndexSequence(SliceCounter+1:end)];
    end
  end
  
  Index = IndexSequence(SliceCounter);
  if SliceCounter~=1 && Index ~= IndexSequence(SliceCounter-1)
    TimingLastChange = toc+InitialTime;
  end
  
  % SLICE GENERATION
  if ismember(Index,CatchIndices)
    w = waveform(THcatch,Index,SliceDuration+ChordDuration,[],SliceCounter*TrialIndex);
  else % Incremented distribution. 'Inverse_D0Dbis' is true, so we have to choos ehte right index
    w = waveform(THincr,Index*2,SliceDuration+ChordDuration,[],SliceCounter*TrialIndex);
  end
  
  stim = w(1:round((SliceDuration+ChordDuration)*SF));
  % Do calibration manually with an extra chord to avoid clicks at the end
  if isfield(HW.params,'driver') && strcmpi(HW.params.driver,'NIDAQMX'),
    if isfield(HW,'Calibration') && length(stim)>length(HW.Calibration.IIR)
      % ADAPT SAMPLING RATE
      cIIR = HW.Calibration.IIR; CalSR = HW.Calibration.SR;
      TCal = [0:1/CalSR:(length(cIIR)-1)/CalSR];
      TCurrent = [0:1/HW.params.fsAO:(length(cIIR)-1)/CalSR];
      cIIR = interp1(TCal,cIIR,TCurrent,'spline');
      % CONVOLVE WITH INVERSE IMPULSE RESPONSE OF SPEAKER
      tstim = conv(stim(:,1),cIIR)*CalSR/HW.params.fsAO;
      % UNDO SHIFT DUE TO CALIBRATION
      cDelaySteps = round(HW.Calibration.Delay*HW.params.fsAO);
      stim(:,1) = [tstim(cDelaySteps:end-length(cIIR)+1);zeros(cDelaySteps-1,1)];
    end
  end
  NewSlice = stim(1:round(SliceDuration*SF));
  
  % LOAD SLICE (w/ trick for skipping the calibration step)
  CalibrationIIRBU = HW.Calibration.IIR;
  HW.Calibration.IIR = zeros(1,length(NewSlice)+1);
  HW = IOLoadSound(HW, NewSlice);
  HW.Calibration.IIR = CalibrationIIRBU;
  
  % Start the acquisition and sound play / skipped in RefTarScript.m for this BehaviorObject
  if SliceCounter==1
    [StartEvent,HW] = IOStartAcquisition(HW);
    tic; CurrentTime = IOGetTimeStamp(HW); InitialTime = CurrentTime;
  end
  
  if (toc+InitialTime)>(SliceCounter-1)*SliceDuration
    disp('AIE PEPITO!!')
  else
    disp(toc+InitialTime)
  end
  
  CurrentTime = toc+InitialTime;
  NextSliceTiming = SliceCounter*SliceDuration;
  LickOccured = 0;
  
  % MONITOR POTENTIAL LICK UNTIL SLICE IS ALMOST FINISHED
  while CurrentTime < (NextSliceTiming-AnticipatedLoadingDuration)
    if ~LickOccured % if Lick occured in this Slice, just wait
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
        ResponseTime = CurrentTime;
        
        Events = AddEvent(Events,['LICK,',cLickSensor],TrialIndex,ResponseTime,[]);
        
        if ResponseTime < (TimingLastChange + MinimalDelayResponse) ||...
            ResponseTime > (TimingLastChange + RespWinDur)
          Outcome = 'EARLY';
        else
          Outcome = 'HIT';
        end
        Events = AddEvent(Events,['OUTCOME,',Outcome],TrialIndex,ResponseTime,[]);
        [Events] = ProcessLick(Outcome,Events,HW,O,TH,globalparams,exptparams,LEDfeedback,RewardAmount,IncrementRewardAmount,TrialIndex,...
          cLickSensor,MaxIncrementRewardNb);
        
        if strcmp(Outcome,'HIT'); Outcome2Display = [Outcome ', RT = ' num2str(ResponseTime-TarWindow(1))]; else Outcome2Display = Outcome; end
        fprintf(['\t [ ',Outcome2Display,' ] ... ']);
        fprintf(['\t Lick detected [ ',cLickSensor,', at ',n2s(ResponseTime,3),'s ] ... ']);
        break
      end
    end
    

  end

end

%%
function [Events] = ProcessLick(Outcome,Events,HW,O,TH,globalparams,exptparams,LEDfeedback,RewardAmount,IncrementRewardAmount,TrialIndex,...
  cLickSensor,MaxIncrementRewardNb)

% TAKE ACTION BASED ON OUTCOME
switch Outcome
  case 'EARLY';
    LightEvents = LF_TimeOut(HW,get(O,'TimeOutEarly'),LEDfeedback,TrialIndex,Outcome);
    Events = AddEvent(Events, LightEvents, TrialIndex);    
    
  case 'HIT'; % PROVIDE REWARD AT CORRECT SPOUT
    % 14/02/20-YB: Patched to change LED/pump structure + Duration2Play (cf. lab notebook)
    Duration2Play = 0.5; LEDposition = {'left'};
    
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

end
fprintf('\n');

%%
function [Events, exptparams] = PostProcessLick()

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

% WAIT AFTER RESPONSE TO RECORD POST-DATA
if ~strcmp(Outcome,'SNOOZE')
  while CurrentTime < ResponseTime + get(O,'AfterResponseDuration');
    CurrentTime = toc+InitialTime; pause(0.05);
  end
end

%%
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