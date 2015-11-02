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
% 15/04: currently requires Silence duration = 0 / PreStimSilence = 0 /
% Attenuation in SO = 0

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
RH = get(exptparams.TrialObject,'ReferenceHandle');
TH = get(exptparams.TrialObject,'TargetHandle');
switch get(TH,'descriptor')
  case 'TextureMorphing'
    DistributionTypeByInd = get(TH,'DistributionTypeByInd');
    DistributionTypeNow = DistributionTypeByInd(Index);
    DifficultyLvl = str2num(get(TH,['DifficultyLvl_D' num2str(DistributionTypeNow)]));
    DifficultyLvlByInd = get(TH,'DifficultyLvlByInd');
    DifficultyNow = DifficultyLvl( DifficultyLvlByInd(Index) );
    if DifficultyNow==0; CatchTrial=1; else CatchTrial=0; end
  case 'RandSeqTorc'
%     if TargetIndices==get(TH,'MaxIndex')
%       CatchTrial=1;
%     else CatchTrial=0; end
    CatchTrial=0;
end

TarInd = find(~cellfun(@isempty,strfind({StimEvents.Note},'Target')));
EarlyWindow = StimEvents(end-1).StartTime;        % include Ref-Silence, PreStimSilence until ToC (without response window)
TargetStartTime = 0; %StimEvents(TarInd(1)).StartTime;
RespWinDur = get(O,'ResponseWindow');
if ~CatchTrial % not a catch trial
  TarWindow(1) = TargetStartTime + EarlyWindow;
  TarWindow(2) = TarWindow(1) + get(O,'ResponseWindow');
  CatchStr = '';
else
  TarWindow(1) = TargetStartTime + EarlyWindow  + get(O,'ResponseWindow');
  TarWindow(2) = TarWindow(1);
  RespWinDur = 0;
  CatchStr = 'Catch ';
end
RefWindow = [0,TarWindow(1)];
Simulick = get(O,'Simulick'); if Simulick; LickTime = rand*(TarWindow(2)+1); end
MinimalDelayResponse = get(O,'MinimalDelayResponse');

TrialObject = get(exptparams.TrialObject);
LickTargetOnly = TrialObject.LickTargetOnly;
RewardSnooze = TrialObject.RewardSnooze;

%% SOUND SLICES
SF = get(TH,'SamplingRate');
RefSliceDuration = get(O,'RefSliceDuration');
TarWin1 = TarWindow(1);
switch get(TH,'descriptor')
  case 'TextureMorphing'
    AnticipatedLoadingDuration = 0.300;
    Par = get(TH,'Par');
    ChordDuration = Par.ToneDuration;
    % TarWin1 = round(TarWin1/ChordDuration)*ChordDuration;            % sec.
    % RefSliceDuration = RefSliceDuration+AnticipatedLoadingDuration;
    RefSliceDuration = round(RefSliceDuration/ChordDuration)*ChordDuration;            % sec.
  case 'RandSeqTorc'
    AnticipatedLoadingDuration = 0.450;
end
% Slice Duration is also the ToC of the last (Target) slice
% SlicesInAsegment = round(SliceDuration/ChordDuration);
% SegmentMeanDuration = 3;        % sec.
% SegmentStdDuration = 1;         % sec.
% SegmentMinDuration = 0.6; SegmentMinDuration = round(SegmentMinDuration/ChordDuration/SlicesInAsegment);             % segment nb
% SegmentPostHitDuration = 1; SegmentPostHitDuration = round(SegmentPostHitDuration/ChordDuration/SlicesInAsegment);   % segment nb
% SegmentPostFADelay = 2.5; SegmentPostFADelay = round(SegmentPostFADelay/ChordDuration/SlicesInAsegment);               % segment nb
% BufferSize = 45; BufferSize = round(BufferSize/ChordDuration/SlicesInAsegment);                                      % segment nb
% CatchIndices = find(DifficultyLvl==0);
% IndexLst = 1:(CatchIndices(1)-1); for CatchNum = 2:length(CatchIndices); IndexLst = [IndexLst (CatchIndices(CatchNum-1)+1) : (CatchIndices(CatchNum)+1) ]; end
% IndexLst = [IndexLst (CatchIndices(end)+1):get(TH,'MaxIndex') ];

%% SOUND OBJECTS % Re-parameterize the SO according to what is needed
% Initial distribution SO
THcatch = TH;
PreStimSilence = get(THcatch,'PreStimSilence');
MaxIndex = get(TH,'MaxIndex');
% THcatch = set(THcatch,'PreStimSilence',0);
% After change sound
ActualTrialSound = exptparams.wAccu((get(RH,'Duration')*SF+1):end);
switch get(TH,'descriptor')
  case 'TextureMorphing'
    THcatch = set(THcatch,'StimulusBisDuration',ChordDuration);
    THcatch = set(THcatch,'MinToC',RefSliceDuration+2*ChordDuration); THcatch = set(THcatch,'MaxToC',RefSliceDuration+2*ChordDuration);
    THcatch = ObjUpdate(THcatch);
    % COMPUTE LOUDNESS ATTENUATION
    AttenuationD0 = str2num(get(TH,'AttenuationD0'));
    % if AttenuationD0~=0
    %   global LoudnessAdjusted;
    % end
    % AttenuationD0 = -15;
    % if AttenuationD0~=0 % replace with behavior parameters
    %   global LoudnessAdjusted;
    %   LoudnessAdjusted = 1;
    %   NormFactor = maxLocalStd(ActualTrialSound(1:(TarWin1*SF)),SF,floor(length(ActualTrialSound(1:(TarWin1*SF)))/SF))
    %   RatioToDesireddB = 10^(AttenuationD0/20);   % dB to ratio in SPL
    %   ActualTrialSound(1:(TarWin1*SF)) = ActualTrialSound(1:(TarWin1*SF))*RatioToDesireddB;
    %   ActualTrialSound = ActualTrialSound/NormFactor;
    % end
    
    % % Incremented distribution SO
    % THincr = TH;
    % THincr = set(THincr,'PreStimSilence',0);
    % % THincr = set(THincr,'Inverse_D0Dbis','yes');
    % THincr = set(THincr,'MinToC',TarWin1); THincr = set(THincr,'MaxToC',TarWin1);
    % THincr = set(THincr,'StimulusBisDuration',RespWinDur);
    % THincr = ObjUpdate(THincr);
    TargetPartNb = 1;
  case 'RandSeqTorc'  % much longer than TMG sometimes
    PartDuration = 2.5;
    TargetPartNb = max(floor(length(ActualTrialSound)/SF/PartDuration),1)
    if TargetPartNb>1
      if (floor(length(ActualTrialSound)/SF)-PartDuration)<RefSliceDuration
        TargetPartNb = 1;
      else
        PartPointer = 1;
        for PartNum = 1:(TargetPartNb-1)
          ActualTrialSoundParts{PartNum} = ...
            ActualTrialSound(PartPointer:(PartPointer+PartDuration*SF));
          PartPointer = PartPointer + PartDuration*SF + 1;
        end
        ActualTrialSoundParts{TargetPartNb} = ActualTrialSound(PartPointer:end);
      end
    end
end
if TargetPartNb==1
  ActualTrialSoundParts{1} = ActualTrialSound;
end

%% BUILD SEQUENCES OF INDEX
% SliceCounter = 1;
% IndexListing = []; SegmentDurations = [];
% Xnormcdf = 0:ChordDuration:(SegmentMeanDuration+3*SegmentStdDuration);
% SegmentDurationDistri = normcdf(Xnormcdf,SegmentMeanDuration,SegmentStdDuration); SegmentDurationDistri([1 length(SegmentDurationDistri)]) = [0 1];
% for RepetitionNum = 1: round(BufferSize/(round(SegmentMeanDuration/ChordDuration)*ChordDuration))
%   ShuffledInd = ones(1,2*length(IndexLst)) * CatchIndices(1);
%   ShuffledInd( 2:2:2*length(IndexLst) )= shuffle(IndexLst);
%   IndexListing = [ IndexListing ShuffledInd ];
%   SegmentDurations_tmp = interp1( SegmentDurationDistri , Xnormcdf , rand(1,length(ShuffledInd)) );
%   SegmentDurations = [ SegmentDurations max(round(SegmentDurations_tmp/ChordDuration/SlicesInAsegment),SegmentMinDuration) ];
% end
% IndexSequence = zeros(1,sum(SegmentDurations));
% for IndNum = 1:length(IndexListing)
%   IndexSequence( sum(SegmentDurations(1:(IndNum-1))) + (1:SegmentDurations(IndNum)) ) = IndexListing(IndNum);
% end
% IndexSequence = IndexSequence(1:BufferSize);

LEDfeedback = get(O,'LEDfeedback');
cPositions = {'center'}; TargetSensors = IOMatchPosition2Sensor(cPositions);
cLickSensor = TargetSensors{1};
CountingLicks = [];

%% WAIT FOR THE CLICK AND RECORD POSITION AND TIME
SensorNames = {HW.Didx.Name};
SensorChannels = find(strcmp(SensorNames,'Touch'));
AllLickSensorNames = SensorNames(~cellfun(@isempty,strfind(SensorNames,'Touch')));

% SYNCHRONIZE COMPUTER CLOCK WITH DAQ TIME
switch get(TH,'descriptor')
  case 'TextureMorphing'
    fprintf(['Running Trial [' CatchStr 'ToC=' num2str(TarWin1) 's] [ <=',n2s(exptparams.LogDuration),'s ] ... ']);
  case 'RandSeqTorc'
    fprintf(['Running Trial [ <=',n2s(exptparams.LogDuration),'s ] ... ']);
end
CurrentTime = 0; LickOccured = 0; 
AddTar = 0; RefSliceCounter = 0; NextSliceTiming = 0; TimingLastChange = RefSliceDuration;
wAccu = [ ]; TargetPartCounter = 0;
% while ~TargetPlayed(CurrentTime+SliceDuration) < (length(IndexSequence)*SliceDuration)
while CurrentTime < (TimingLastChange+RespWinDur)
  if ~AddTar
    RefSliceCounter = RefSliceCounter+1;
    SliceDuration = RefSliceDuration;
  elseif AddTar
    TargetPartCounter = TargetPartCounter+1;
    if TargetPartNb == 1
      SliceDuration = TarWin1+RespWinDur-PreStimSilence-get(RH,'Duration');
      AnticipatedLoadingDuration = 0;  % goes until the end of the slice for target
    else
      SliceDuration = length(ActualTrialSoundParts{TargetPartCounter})/SF;
      if TargetPartCounter==TargetPartNb
        AnticipatedLoadingDuration = 0;  % goes until the end of the slice for target
      end
    end
  end
  if TargetPartCounter<=1
    TimingLastChange = RefSliceCounter*RefSliceDuration+TarWin1;
  end
%   % If lick occured, actualize IndexSequence
%   if LickOccured
%     switch Outcome
%       case 'HIT'
%         NextDifferentIndex = find(IndexSequence(SliceCounter+1:end)~=IndexSequence(SliceCounter),1,'first');
%         IndexSequence = [IndexSequence(1:SliceCounter) ones(1,SegmentPostHitDuration)*IndexSequence(SliceCounter) IndexSequence(SliceCounter+NextDifferentIndex:end)];
%       case 'EARLY'
%         IndexSequence = [IndexSequence(1:SliceCounter) ones(1,SegmentPostFADelay)*IndexSequence(SliceCounter) IndexSequence(SliceCounter+1:end)];
%     end
%   end  
%   Index = IndexSequence(SliceCounter);
%   if SliceCounter~=1 && Index ~= IndexSequence(SliceCounter-1)
%     TimingLastChange = toc+InitialTime;
%   end
  
  % SLICE GENERATION IF WE MOVED INTO THE AnticipatedLoadingDuration
   
   
%   if ismember(Index,CatchIndices)
%     w = waveform(THcatch,Index,[],[],SliceCounter*TrialIndex);
%   else
%     w = waveform(THincr,Index,[],[],SliceCounter*TrialIndex);
% %     w = waveform(THincr,Index*2,SliceDuration+ChordDuration,[],SliceCounter*TrialIndex); % Incremented distribution. 'Inverse_D0Dbis' is true, so we have to choose the right index
%   end
  if ~AddTar
    % Trick for keeping the same spectral shape (generated by IniSeed and
    %chosen by TrialIndex) with a different tone sequence (generated by Index)
    switch get(TH,'descriptor')
      case 'TextureMorphing'
        IndexRefSlice(RefSliceCounter) = randi(MaxIndex,1);
        w = waveform(THcatch,IndexRefSlice(RefSliceCounter),[],[],TrialIndex);
        w = w(1:round((SliceDuration+2*ChordDuration+PreStimSilence)*SF));
        %     NormFactor = maxLocalStd(w,SF,floor(length(w)/SF))
      case 'RandSeqTorc'
        IndexRefSlice(RefSliceCounter) = randi(100,1);
        THcatch = set(THcatch,'Key',IndexRefSlice(RefSliceCounter));
        w = waveform(THcatch,3,[],[],TrialIndex);
        w = w(1:round((SliceDuration+PreStimSilence)*SF));
    end
    stim = w;%*RatioToDesireddB/NormFactor;
  else
    w = ActualTrialSoundParts{TargetPartCounter}; %waveform(THincr,Index,[],[],(RefSliceCounter+AddTar)*TrialIndex);
    stim = w;
  end
  
  global LoudnessAdjusted; LoudnessAdjusted  = 1;
  wAccu = [wAccu ; stim(round(PreStimSilence*SF)+(1:round(SliceDuration*SF)))];
  % Do calibration manually with an extra chord to avoid clicks at the end
  % from IOloadSound.m
%   if AttenuationD0~=0
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
%   end
%   if ~AddTar
  if RefSliceCounter==1
    NormFactor = maxLocalStd(stim(round(PreStimSilence*SF)+(1:round(SliceDuration*SF))),SF,floor(round(SliceDuration*SF)/SF));
    if ~AddTar
      stim = [zeros(get(RH,'Duration')*SF,1) ; stim];
      SliceDuration = SliceDuration+get(RH,'Duration');
    end
  end
  stim = HW.Calibration(1).Loudness.Parameters.SignalMatlab80dB*stim/NormFactor;
  NewSlice = stim(round(PreStimSilence*SF)+(1:round(SliceDuration*SF)));
  
  RampBetweenSlices = 0.004;   % s 
  Ramp = (sin(linspace(-pi/2,pi/2,RampBetweenSlices*SF))  + 1)/2;
  NewSlice(1:length(Ramp)) = NewSlice(1:length(Ramp)).*Ramp';
  NewSlice((end-length(Ramp)+1) : end) = NewSlice((end-length(Ramp)+1) : end).*Ramp(end:-1:1)';
%   else
%     NewSlice = stim(1:end);
%   end
  
  if RefSliceCounter>1 && (toc+InitialTime)>NextSliceTiming
    disp(['\n Likely anticipation is not long enough: ' num2str(NextSliceTiming) 'toc=' num2str(toc)])
  end
%   if AttenuationD0~=0
    % LOAD SLICE (w/ trick for skipping the calibration step)
    CalibrationIIRBU = HW.Calibration.IIR;
    HW.Calibration.IIR = zeros(1,length(NewSlice)+1);
    HW = IOLoadSound(HW, NewSlice);
    LoudnessAdjusted = 1;
    HW.Calibration.IIR = CalibrationIIRBU;
%   else
%     HW = IOLoadSound(HW, NewSlice);
%   end
  
  % Start the acquisition and sound play / skipped in RefTarScript.m for this BehaviorObject
  if RefSliceCounter==1 && ~AddTar
    [StartEvent,HW] = IOStartAcquisition(HW);
    tic;
    CurrentTime = IOGetTimeStamp(HW);
    InitialTime = CurrentTime;
  end
  
  NextSliceTiming = NextSliceTiming+SliceDuration;
  CurrentTime = toc+InitialTime;
  fprintf(['\n Current time before loop: ' num2str(CurrentTime)])
  
  if (CurrentTime)>NextSliceTiming
    disp(['\n AIE PEPITO!! Next: ' num2str(NextSliceTiming) ' toc=' num2str(toc)])
  end    
  fprintf([' | Next-anticipation ' num2str(NextSliceTiming-AnticipatedLoadingDuration)])
  fprintf([' | TimingLastChange ' num2str(TimingLastChange)])
  
  % MONITOR POTENTIAL LICK UNTIL SLICE IS ALMOST FINISHED
  LickOccured = 0; QuitLoop = 0;
  while CurrentTime < (NextSliceTiming-AnticipatedLoadingDuration)
    if ~LickOccured % if Lick occured in this Ref Slice, just wait (Ref slice)
      %CurrentTime = IOGetTimeStamp(HW); % INACCURATE WITH DISCRETE STEPS      
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
        if AddTar
          if ResponseTime < (TimingLastChange + MinimalDelayResponse)
            Outcome = 'EARLY';
          elseif ResponseTime >= (TimingLastChange + MinimalDelayResponse) &&...
              ResponseTime <= (TimingLastChange + RespWinDur)
            Outcome = 'HIT';
          else
            Outcome = 'SNOOZE';
          end
          
          CountingLicks = [CountingLicks ResponseTime];
          cSensorChannels = SensorChannels(find(cLick,1,'first'));
          if ~isempty(cSensorChannels)
            cLickSensorInd = find(cLick,1,'first');
            cLickSensor = SensorNames{SensorChannels(cLickSensorInd)}; % CORRECT FOR BOTH 'ON' AND 'OFF' RESULTS
            cLickSensorNot = setdiff(SensorNames(SensorChannels),cLickSensor);
          else
            cLickSensor = 'None'; cLickSensorNot = 'None';
          end          
          
%           Events = AddEvent(Events,['OUTCOME,',Outcome],TrialIndex,ResponseTime,[]);
%           [Events] = ProcessLick(Outcome,Events,HW,O,TH,globalparams,exptparams,LEDfeedback,RewardAmount,IncrementRewardAmount,TrialIndex,...
%             cLickSensor,MaxIncrementRewardNb);
%         
%           if strcmp(Outcome,'HIT'); Outcome2Display = [Outcome ', RT = ' num2str(ResponseTime-TarWindow(1))]; else Outcome2Display = Outcome; end
%           fprintf(['\t [ ',Outcome2Display,' ] ... ']);
%           fprintf(['\t Lick detected [ ',cLickSensor,', at ',n2s(ResponseTime,3),'s ] ... ']);

           QuitLoop = 1;
           break
        end
      end
    end
    CurrentTime = toc+InitialTime;
  end
  % Move to Target if no lick during the reference
  if ~AddTar && ~LickOccured
    AddTar = 1;
  elseif AddTar && ~LickOccured && TargetPartCounter==TargetPartNb
    if ~CatchTrial
      Outcome = 'SNOOZE';
    else
      Outcome = 'HIT'; % includes ambigous if both are specified
    end
    break
  elseif QuitLoop
    break
  end
end

TarWindow = [TimingLastChange TimingLastChange+RespWinDur];

% IF NO RESPONSE OCCURED
if ~LickOccured || strcmp(Outcome,'SNOOZE'); ResponseTime = inf; end

if LickOccured
  fprintf(['\n Lick detected [ ',cLickSensor,', at ',n2s(ResponseTime,3),'s ] ... ']);
else
  fprintf(['\n No Lick detected ... ']); cLickSensor = ''; 
end

%%  PROCESS LICK
if CatchTrial && strcmp(Outcome,'HIT')
  ResponseTime = TarWindow(2);
  cLickSensor = TargetSensors{1}; cLickSensorNot = 'None';
end
% if ~isempty(CountingLicks) && all( CountingLicks < (TarWindow(1) + MinimalDelayResponse) )
%   Outcome = 'EARLY';
%   ResponseTime = CountingLicks(1);
% elseif ~isempty(CountingLicks) && any( CountingLicks>(TarWindow(1) + MinimalDelayResponse) & CountingLicks<TarWindow(2) ) % HIT OR ERROR
%   switch cLickSensor % CHECK WHERE THE LICK OCCURED
%     case TargetSensors;   Outcome = 'HIT'; ResponseTime = CountingLicks(end); % includes ambigous if both are specified 
%     otherwise;                   Outcome = 'ERROR';
%   end  
% elseif ResponseTime > TarWindow(2)  % CASES NO LICK AND LATE LICK
%   if ~CatchTrial
%     Outcome = 'SNOOZE';
%   else
%     ResponseTime = TarWindow(2);
%     cLickSensor = TargetSensors{1}; cLickSensorNot = 'None';
%     Outcome = 'HIT'; % includes ambigous if both are specified
%   end
% end
Events = AddEvent(Events,['OUTCOME,',Outcome],TrialIndex,ResponseTime,[]);
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
    LightEvents = LF_TimeOut(HW,roundn(TimeOut*(1+rand),-1),0,TrialIndex);
    Events = AddEvent(Events, LightEvents, TrialIndex);
  
  case 'HIT'; % STOP SOUND, PROVIDE REWARD AT CORRECT SPOUT
    StopEvent = IOStopSound(HW);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    % 14/02/20-YB: Patched to change LED/pump structure + Duration2Play (cf. lab notebook)
    Duration2Play = 0.5; LEDposition = {'left'};
    % Stop Dbis sound when <Duration2Play> is elapsed
    if ~CatchTrial; pause(max([0 , (TarWindow(1)+Duration2Play)-IOGetTimeStamp(HW) ])); end
    
    PumpName = cell2mat(IOMatchSensor2Pump(cLickSensor,HW));
    if length(RewardAmount)>1 % ASYMMETRIC REWARD SCHEDULE ACROSS SPOUTS
      RewardAmount = RewardAmount(cLickSensorInd);
    end
    
    if ~globalparams.PumpMlPerSec.Pump
      globalparams.PumpMlPerSec.Pump = inf;
    end
    if TrialIndex>1
      LastOutcomes = {exptparams.Performance((TrialIndex-1) :-1: max([1 (TrialIndex-MaxIncrementRewardNb)]) ).Outcome};
    else LastOutcomes = {'HIT'}; end
%     NbContiguousLastHits = min([find(strcmp(LastOutcomes,'EARLY'),1,'first') , find(strcmp(LastOutcomes,'SNOOZE'),1,'first') ])-1; 
    NbContiguousLastHits = find(strcmp(LastOutcomes,'EARLY'),1,'first')-1;   % Only Early are taken into account
    if isempty(NbContiguousLastHits), NbContiguousLastHits = length( find(strcmp(LastOutcomes,'HIT')) );
    else NbContiguousLastHits = NbContiguousLastHits - length( find(strcmp(LastOutcomes(1:(NbContiguousLastHits+1)),'SNOOZE')) ); end  % But Snoozes don't give bonus
%     MinToC = str2double(get(get(exptparams.TrialObject,'TargetHandle'),'MinToC')); MaxToC = str2double(get(get(exptparams.TrialObject,'TargetHandle'),'MaxToC'));
    if CatchTrial
      if ~(RewardSnooze); RewardAmount = 0; else RewardAmount = (randi(2,1)-1)*RewardAmount/2; pause(0.2); end
    end
%     elseif MaxToC==MinToC
%       RewardAmount = RewardAmount + IncrementRewardAmount*NbContiguousLastHits;
%     else
%       RewardAmount = RewardAmount * (0.5 + (TarWindow(1)-MinToC)/(MaxToC-MinToC)) + IncrementRewardAmount*NbContiguousLastHits;
%     end

%     if get(O,'GradualResponse')
%       RewardAmount = MinRewardAmount + (RewardAmount-MinRewardAmount)*(MaxTimeBin-BadLickSum)/MaxTimeBin;
%     end
    
    PumpDuration = RewardAmount/globalparams.PumpMlPerSec.Pump;
    % pause(0.05); % PAUSE TO ALLOW FOR HEAD TURNING
    PumpName = IOMatchPosition2Pump('center',HW); PumpName = PumpName{1};
    PumpEvent = IOControlPump(HW,'Start',PumpDuration,PumpName);
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    exptparams.Water = exptparams.Water+RewardAmount;
    % MAKE SURE PUMPS ARE OFF (BECOMES A PROBLEM WHEN TWO PUMP EVENTS TOO CLOSE)
    pause(PumpDuration/2);
    % Turn LED ON
    LightNames = IOMatchPosition2Light(HW,LEDposition);
    [State,LightEvent] = IOLightSwitch(HW,1,0,[],[],[],LightNames{1});
%     Events = AddEvent([],LightEvent,TrialIndex);
    
    pause(PumpDuration/2);
    PumpEvent = IOControlPump(HW,'stop',0,PumpName);
    Events = AddEvent(Events, PumpEvent, TrialIndex);
    IOControlPump(HW,'stop',0,'Pump');
    
    % Turn LED OFF
    [State,LightEvent] = IOLightSwitch(HW,0,0,[],[],[],LightNames{1});
%     Events = AddEvent([],LightEvent,TrialIndex);
  case 'SNOOZE';  % STOP SOUND
    StopEvent = IOStopSound(HW);
    Events = AddEvent(Events, StopEvent, TrialIndex);
    
    if RewardSnooze
      pause(0.2);
      LEDposition = {'left'}; cLickSensor =TargetSensors;
      PumpName = cell2mat(IOMatchSensor2Pump(cLickSensor,HW));
      RewardAmount = RewardAmount/3;
      PumpDuration = RewardAmount/globalparams.PumpMlPerSec.Pump;
      % pause(0.05); % PAUSE TO ALLOW FOR HEAD TURNING
      PumpEvent = IOControlPump(HW,'Start',PumpDuration,PumpName);
      Events = AddEvent(Events, PumpEvent, TrialIndex);
      exptparams.Water = exptparams.Water+RewardAmount;
      % MAKE SURE PUMPS ARE OFF (BECOMES A PROBLEM WHEN TWO PUMP EVENTS TOO CLOSE)
      pause(PumpDuration/2);
      % Turn LED ON
      LightNames = IOMatchPosition2Light(HW,LEDposition);
      [State,LightEvent] = IOLightSwitch(HW,1,0,[],[],[],LightNames{1});
%       Events = AddEvent([],LightEvent,TrialIndex);
      
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
exptparams.wAccu = wAccu;
exptparams.Performance(TrialIndex).ReferenceIndices = ReferenceIndices;
exptparams.Performance(TrialIndex).RefSliceCounter = RefSliceCounter;
exptparams.Performance(TrialIndex).IndexRefSlice = IndexRefSlice;
exptparams.Performance(TrialIndex).ToC = TarWin1;
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
else
  pause(get(O,'AfterResponseDuration'));
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


%%
% function [Events] = ProcessLick(Outcome,Events,HW,O,TH,globalparams,exptparams,LEDfeedback,RewardAmount,IncrementRewardAmount,TrialIndex,...
%   cLickSensor,MaxIncrementRewardNb)
% 
% % TAKE ACTION BASED ON OUTCOME
% switch Outcome
%   case 'EARLY';
%     LightEvents = LF_TimeOut(HW,get(O,'TimeOutEarly'),LEDfeedback,TrialIndex,Outcome);
%     Events = AddEvent(Events, LightEvents, TrialIndex);    
%     
%   case 'HIT'; % PROVIDE REWARD AT CORRECT SPOUT
%     % 14/02/20-YB: Patched to change LED/pump structure + Duration2Play (cf. lab notebook)
%     Duration2Play = 0.5; LEDposition = {'left'};
%     
%     PumpName = cell2mat(IOMatchSensor2Pump(cLickSensor));
%     if length(RewardAmount)>1 % ASYMMETRIC REWARD SCHEDULE ACROSS SPOUTS
%       RewardAmount = RewardAmount(cLickSensorInd);
%     end
%     
%     if ~globalparams.PumpMlPerSec.(PumpName)
%       globalparams.PumpMlPerSec.(PumpName) = inf;
%     end
%     if TrialIndex>1
%       LastOutcomes = {exptparams.Performance((TrialIndex-1) :-1: max([1 (TrialIndex-MaxIncrementRewardNb)]) ).Outcome};
%     else LastOutcomes = {'HIT'}; end
%     %     NbContiguousLastHits = min([find(strcmp(LastOutcomes,'EARLY'),1,'first') , find(strcmp(LastOutcomes,'SNOOZE'),1,'first') ])-1;
%     NbContiguousLastHits = find(strcmp(LastOutcomes,'EARLY'),1,'first')-1;   % Only Early are taken into account
%     if isempty(NbContiguousLastHits), NbContiguousLastHits = length( find(strcmp(LastOutcomes,'HIT')) );
%     else NbContiguousLastHits = NbContiguousLastHits - length( find(strcmp(LastOutcomes(1:(NbContiguousLastHits+1)),'SNOOZE')) ); end  % But Snoozes don't give bonus
%     MinToC = str2double(get(TH,'MinToC')); MaxToC = str2double(get(TH,'MaxToC'));
%     RewardAmount = RewardAmount + IncrementRewardAmount*NbContiguousLastHits;
%     PumpDuration = RewardAmount/globalparams.PumpMlPerSec.(PumpName);
%     % pause(0.05); % PAUSE TO ALLOW FOR HEAD TURNING
%     PumpEvent = IOControlPump(HW,'Start',PumpDuration,PumpName);
%     Events = AddEvent(Events, PumpEvent, TrialIndex);
%     exptparams.Water = exptparams.Water+RewardAmount;
%     % MAKE SURE PUMPS ARE OFF (BECOMES A PROBLEM WHEN TWO PUMP EVENTS TOO CLOSE)
%     pause(PumpDuration/2);
%     % Turn LED ON
%     LightNames = IOMatchPosition2Light(HW,LEDposition);
%     [State,LightEvent] = IOLightSwitch(HW,1,0,[],[],[],LightNames{1});
%     Events = AddEvent([],LightEvent,TrialIndex);
%     
%     pause(PumpDuration/2);
%     PumpEvent = IOControlPump(HW,'stop',0,PumpName);
%     Events = AddEvent(Events, PumpEvent, TrialIndex);
%     IOControlPump(HW,'stop',0,'Pump');
%     
%     % Turn LED OFF
%     [State,LightEvent] = IOLightSwitch(HW,0,0,[],[],[],LightNames{1});
%     Events = AddEvent([],LightEvent,TrialIndex);
% 
% end
% fprintf('\n');
% 
% %%
% function [Events, exptparams] = PostProcessLick()
% 
% if CatchTrial; LickTime = NaN; elseif ~strcmp(Outcome,'SNOOZE'); LickTime = ResponseTime; else LickTime = NaN; end
% exptparams.Performance(TrialIndex).ReferenceIndices = ReferenceIndices;
% exptparams.Performance(TrialIndex).TargetIndices = TargetIndices;
% exptparams.Performance(TrialIndex).Outcome = Outcome;
% exptparams.Performance(TrialIndex).TarWindow = TarWindow;
% exptparams.Performance(TrialIndex).RefWindow = RefWindow;
% exptparams.Performance(TrialIndex).LickTime = LickTime;
% exptparams.Performance(TrialIndex).LickSensor = cLickSensor;
% exptparams.Performance(TrialIndex).LickSensorInd = find(strcmp(cLickSensor,AllLickSensorNames));
% if isempty(exptparams.Performance(TrialIndex).LickSensorInd) exptparams.Performance(TrialIndex).LickSensorInd = NaN; end
% exptparams.Performance(TrialIndex).LickSensorNot = cLickSensorNot;
% exptparams.Performance(TrialIndex).LickSensorNotInd = find(strcmp(cLickSensorNot,AllLickSensorNames));
% if isempty(exptparams.Performance(TrialIndex).LickSensorNotInd) exptparams.Performance(TrialIndex).LickSensorNotInd = NaN; end
% exptparams.Performance(TrialIndex).DetectType = DetectType;
% 
% % WAIT AFTER RESPONSE TO RECORD POST-DATA
% if ~strcmp(Outcome,'SNOOZE')
%   while CurrentTime < ResponseTime + get(O,'AfterResponseDuration');
%     CurrentTime = toc+InitialTime; pause(0.05);
%   end
% end
% 
% %%
% function Events = LF_TimeOut(HW,TimeOut,Light,cTrial,Outcome)
% % 14/02/20-YB: adapted to give a visual feedback for EARLY (we don't want TimeOut for HIT)
% 
% if strcmpi(Outcome,'Early');
%   Positions = {'right'}; fprintf(['\t Timeout [ ',n2s(TimeOut),'s ]']);
% elseif strcmpi(Outcome,'Hit')
%   Positions = {'left'};
% end
% 
% if Light % TURN LIGHT ON DURING TIMEOUT
%   LightNames = IOMatchPosition2Light(HW,Positions);
%   [State,LightEvent] = IOLightSwitch(HW,1,TimeOut,[],[],[],LightNames{1});
%   Events = AddEvent([],LightEvent,cTrial);
% end
% 
% % TIME OUT
% ThisTime = clock; StartTime = IOGetTimeStamp(HW);
% while etime(clock,ThisTime) < TimeOut; drawnow;  end
% StopTime = IOGetTimeStamp(HW);
% if strcmpi(Outcome,'Early'); TimeOutEvent = struct('Note',['TIMEOUT,',n2s(TimeOut,4),' seconds'],'StartTime',StartTime,'StopTime',StartTime + TimeOut); end
% 
% % TURN LIGHT OFF AFTER TIMEOUT
% if Light
%   LightNames = IOMatchPosition2Light(HW,Positions);
%   [State,LightEvent] = IOLightSwitch(HW,0,[],[],[],[],LightNames{1});
%   Events.StopTime = LightEvent.StartTime;
% end
% 
% % ADD TIME OUT EVENT
% if strcmpi(Outcome,'Early');
%   if ~exist('Events','var')
%     Events = TimeOutEvent;
%   else
%     Events = AddEvent(Events,TimeOutEvent,cTrial);
%   end
% end