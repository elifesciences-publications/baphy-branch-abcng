function exptparams = PerformanceAnalysis(O, HW, StimEvents, globalparams, exptparams, TrialIndex, LickData)
%
%  HIT RATE = #hitevents/(#hitevents + #falsenegative)  
%                = P(E[Target]|Target) \in [0,1]
%  For Positive RE, this just corresponds to the #hits/#trials
%
%  DISCRIMINATION RATE := HITRATELEFT * HITRATERIGHT \in [0,1]

AllPerf = exptparams.Performance;

%% CURRENT PERFORMANCE
cP = AllPerf(TrialIndex);
% warning('YVES : reactivate this line and set AllTargetPositions in your Soundobject');
% cP.AllTargetPositions = {'center'};
cP.AllTargetPositions = get(get(exptparams.TrialObject,'TargetHandle'),'AllTargetPositions');
cP.CurrentTargetPositions = get(get(exptparams.TrialObject,'TargetHandle'),'CurrentTargetPositions'); 
cHitInd =  strcmp({AllPerf.Outcome},'HIT');
cP.HitRate = sum(cHitInd)/TrialIndex;
cP.SnoozeRate = sum(strcmp({AllPerf.Outcome},'SNOOZE'))/TrialIndex;
cP.EarlyRate = sum(strcmp({AllPerf.Outcome},'EARLY'))/TrialIndex;
cP.ErrorRate = sum(strcmp({AllPerf.Outcome},'ERROR'))/TrialIndex;  % no ERROR in the detection change task
% ToC = StimEvents(end-1).StartTime;        % include Ref-Silence, PreStimSilence until ToC (without response window)
ToC = exptparams.Performance(end).ToC;
% ToC = actual ToC of the initial TrialSound
% cP.TarWindow = ToC which includes all added Ref

% cluster by difficulty for plot purpoises
TO = exptparams.TrialObject;
SO = get(TO,'TargetHandle');
TargetIndices = get(TO,'TargetIndices');
if mod(TrialIndex,get(SO,'MaxIndex')) ==0
  CurrentTrialIndex = TargetIndices(get(SO,'MaxIndex'));
else
  CurrentTrialIndex = TargetIndices( mod(TrialIndex,get(SO,'MaxIndex')) );  % Condition number
end
CurrentTrialIndex = CurrentTrialIndex{1};
switch get(SO,'descriptor')
  case 'TextureMorphing'
    DiffiLevels = get(SO,'DifficultyLvlByInd');
    DistributionTypes = get(SO,'DistributionTypeByInd');
    
    DistributionTypeNow = DistributionTypes(CurrentTrialIndex);
    DifficultyLvl = str2num(get(SO,['DifficultyLvl_D' num2str(DistributionTypeNow)]));
    DifficultyNow = DifficultyLvl( DiffiLevels(CurrentTrialIndex) );
    if DifficultyNow==0; CatchTrial = 1; else CatchTrial = 0; end
    
    TrialDiffiMat = zeros(length(unique(DifficultyLvl ,'stable')),3);
    if DistributionTypes(CurrentTrialIndex) == 1  % Display for only one DistributionType
      TrialDiffiLvl = find(DifficultyNow==unique(DifficultyLvl ,'stable'));
      TrialSuccessCase = find( strcmp({'HIT','SNOOZE','EARLY'} , {AllPerf(end).Outcome}) );
      TrialDiffiMat(TrialDiffiLvl,TrialSuccessCase) = 1;
    end
  case 'RandSeqTorc'
%     if CurrentTrialIndex==get(SO,'MaxIndex')
%       CatchTrial=1;
%     else CatchTrial=0; end
    CatchTrial=0;
    if mod(TrialIndex,get(SO,'MaxIndex')) ==0
      CurrentTrialIndex = TargetIndices(get(SO,'MaxIndex'));
    else
      CurrentTrialIndex = TargetIndices( mod(TrialIndex,get(SO,'MaxIndex')) );  % Condition number
    end
    CurrentTrialIndex = CurrentTrialIndex{1};
    MaxIndex =get(SO,'MaxIndex');
    IndexLst = 1:MaxIndex;
    TarInd = find(~cellfun(@isempty,strfind({StimEvents.Note},'TargetSequence')));
    if isempty(TarInd)
      IndexNow = MaxIndex;
    else
      str1ind = strfind(StimEvents(TarInd).Note,'-'); str1ind = str1ind(end)+2;
      str2ind = strfind(StimEvents(TarInd).Note,','); str2ind = str2ind(end)-2;
      IndexNow = str2num(StimEvents(TarInd).Note((str1ind):(str2ind)));
    end
    % EarlyWindow = StimEvents(TarInd(end)+1).StartTime;
    % EndWindow = StimEvents(TarInd(end)+1).StopTime;
    
    TrialIndexMat = zeros(length(unique(IndexLst ,'stable')),3);
    
    TrialIndexLvl = find(IndexNow==unique(IndexLst ,'stable'));
    TrialSuccessCase = find( strcmp({'HIT','SNOOZE','EARLY'} , {AllPerf(end).Outcome}) );
    TrialIndexMat(TrialIndexLvl,TrialSuccessCase) = 1;
    
    TrialDiffiMat = TrialIndexMat; DifficultyLvl = IndexLst; TrialDiffiMat = TrialIndexMat;
end

if TrialIndex == 1   
  DiffiMatPreviousTrial = zeros(length(unique(DifficultyLvl ,'stable')),3);
else
  cPreviousTrial = exptparams.Performance(TrialIndex-1);
  DiffiMatPreviousTrial = cPreviousTrial.DiffiMat;
end
DiffiMat = DiffiMatPreviousTrial+TrialDiffiMat;
cP.DiffiMat = DiffiMat;

% compute hit rates for the different sensors/responses
if TrialIndex==1 AllPerf = cP; else AllPerf(end) = cP; end; cTargetsInd = zeros(1,TrialIndex); 
for i=1:length(cP.AllTargetPositions) 
  for j=1:TrialIndex cTargetsInd(j) = any(strcmp(AllPerf(j).CurrentTargetPositions,cP.AllTargetPositions{i})); end
  cP.HitRates(i) = sum(cTargetsInd.*cHitInd)/sum(cTargetsInd);
end
cP.Trials = TrialIndex;
switch get(SO,'descriptor')
  case 'TextureMorphing'  % compute avg number of ref slices before actual trials start
    % cP.DiscriminationRate = prod(cP.HitRates);
    cP.DiscriminationRate = ( sum([AllPerf.RefSliceCounter])-TrialIndex )/(TrialIndex*10);
    if isnan(cP.DiscriminationRate) cP.DiscriminationRate = 0; end
  case 'RandSeqTorc'      % HERE we should compute d prime    
    TH = get(exptparams.TrialObject,'TargetHandle');
    % cP.DiscriminationRate = prod(cP.HitRates);
    cP.DiscriminationRate = ( sum([AllPerf.RefSliceCounter])-TrialIndex )/(TrialIndex*10);
    if isnan(cP.DiscriminationRate) cP.DiscriminationRate = 0; end
    
    %% Not yet done; future dprime
RespWinDur = get(O,'ResponseWindow');
    EARLYlst = strcmp('EARLY' , {AllPerf.Outcome});
    HITlst = strcmp('HIT' , {AllPerf.Outcome});
    SNOOZElst = strcmp('SNOOZE' , {AllPerf.Outcome});
    if CurrentTrialIndex==MaxIndex
      NumRef = MaxIndex; AllPerf(TrialIndex).Catch = 1;
    else
      NumRef = CurrentTrialIndex-1; AllPerf(TrialIndex).Catch = 0;
    end
    
    switch AllPerf(end).Outcome
      case 'HIT'
        
      case 'SNOOZE'
        
      case 'EARLY'  % only complicated case bc we need to find the seq. the animal licked on
        RefSliceDuration = get(O,'RefSliceDuration');
        RefSliceCounter = AllPerf(TrialIndex).RefSliceCounter;
        % Isolate Ref sequences within the actual trials in order to reject
        %licks that during tone sequences
        RefEvNoteInd = find(not(cellfun(@isempty,cellfun(@(x)strfind(x,'ReferenceSequence'),{StimEvents.Note},'UniformOutput',0))));
        TarEvNoteInd = find(not(cellfun(@isempty,cellfun(@(x)strfind(x,'TargetSequence'),{StimEvents.Note},'UniformOutput',0))));
        ThreeNoteDuration = (get(TH,'ToneDur')+get(TH,'ToneGap'))*3;
        RefEvNoteInd = [RefEvNoteInd TarEvNoteInd];
        % Lick timings
        LD = find(LickData(:,cP.LickSensorInd));
        LD = LD/HW.params.fsAI;
        % Find sequence with lick
        LT = []; cc = 1;
        while isempty(LT) && cc<=length(RefEvNoteInd)
          RefEvNoteNum = RefEvNoteInd(cc);
          LT = find( (LD-(RefSliceCounter*RefSliceDuration))>[StimEvents(RefEvNoteNum).StartTime+ThreeNoteDuration] & ...
            (LD-(RefSliceCounter*RefSliceDuration))<(StimEvents(RefEvNoteNum).StartTime+ThreeNoteDuration+RespWinDur) );          
          NumRef = find(RefEvNoteInd==RefEvNoteNum);
          cc = cc+1;
        end
%         if isempty(LT)
%           [~,LT] = min(abs(LD-(RefSliceCounter*RefSliceDuration)-[StimEvents(RefEvNoteNum).StartTime+ThreeNoteDuration]));
%         end
        LT = LD(LT(1))-RefSliceCounter*RefSliceDuration-StimEvents(RefEvNoteNum).StartTime-ThreeNoteDuration;
    end
    
    % now calculate the performance:
    if isfield(exptparams, 'Performance') && TrialIndex>1
      prevNumRefTot = AllPerf(TrialIndex-1).NumRefTot;
    else
      prevNumRefTot = 0;
    end
    
    AllPerf(TrialIndex).NumRefTot = prevNumRefTot+NumRef; % sum of false alarms divided by num of ref
    if AllPerf(TrialIndex).NumRefTot==0
      AllPerf(TrialIndex).FaRate = 0;
    else
      AllPerf(TrialIndex).FaRate = length(find(EARLYlst))/AllPerf(TrialIndex).NumRefTot;
    end
    AllPerf(TrialIndex).Ineffective  = AllPerf(TrialIndex).Catch || EARLYlst(TrialIndex);  % target was not presented
    AllPerf(TrialIndex).WarningTrial = double(~AllPerf(TrialIndex).Ineffective);             % target was presented
    %
    AllPerf(TrialIndex).Hit          = ~AllPerf(TrialIndex).Catch && HITlst(TrialIndex);
    
    TotalWarnAndNoCatch         = sum([AllPerf.WarningTrial] & ~[AllPerf.Catch]);
    AllPerf(TrialIndex).HitRate          = sum(cat(1,AllPerf.Hit)) / TotalWarnAndNoCatch;
    
    if AllPerf(TrialIndex).HitRate==0
      cP.DiscriminationRate = 0;
    elseif AllPerf(TrialIndex).FaRate==0
      cP.DiscriminationRate = 0;
    elseif AllPerf(TrialIndex).HitRate==1
      HitRate = (sum(cat(1,AllPerf.Hit))-1) / sum(~[AllPerf.Catch]);
      cP.DiscriminationRate =  erfinv(HitRate)-erfinv(AllPerf(TrialIndex).FaRate);
    else
      cP.DiscriminationRate =  erfinv(AllPerf(TrialIndex).HitRate)-erfinv(AllPerf(TrialIndex).FaRate);
    end
    cP.NumRefTot = AllPerf(TrialIndex).NumRefTot;
    cP.WarningTrial = AllPerf(TrialIndex).WarningTrial;
    cP.Hit = AllPerf(TrialIndex).Hit;
    cP.Ineffective = AllPerf(TrialIndex).Ineffective;
    cP.Catch = AllPerf(TrialIndex).Catch;
%     cP.FaRate = AllPerf(TrialIndex).FaRate;
%     cP.HitRate = AllPerf(TrialIndex).HitRate;
%     cP.FaRate = AllPerf(TrialIndex).FaRate;
end

%% RECENT PERFORMANCE
AverageSteps = 10;
RecentPerf = AllPerf([max([1,end-AverageSteps+1]):end]);
cP.HitRateRecent = sum(strcmp({RecentPerf.Outcome},'HIT'))/AverageSteps;
cP.SnoozeRateRecent = sum(strcmp({RecentPerf.Outcome},'SNOOZE'))/AverageSteps;
cP.EarlyRateRecent = sum(strcmp({RecentPerf.Outcome},'EARLY'))/AverageSteps;
cP.ErrorRateRecent = sum(strcmp({RecentPerf.Outcome},'ERROR'))/AverageSteps;

%% TIMING  % so far, LICKS before the ToC are not seen in LickTargetOnly MODE
% switch cP.DetectType
%   case 'ON';   % Corrected by Yves / 2013/10
%     if ~isnan(cP.LickSensorInd)
%       if ~get(TO,'LickTargetOnly')
%         cP.LickTime = find(LickData(:,cP.LickSensorInd)>0.5,1,'first');
%       else
%         MinimalInterval = 0.250*HW.params.fsAI;     % samples  
%         LickTimings = find( diff( LickData(:,cP.LickSensorInd) ) >0)';
%         FarLickTimingsIndex = unique( [1 find(diff(LickTimings)>MinimalInterval)+1] );
%         cP.LickTime = LickTimings(FarLickTimingsIndex);
%       end
%     else cP.LickTime = []; 
%     end
%   case 'OFF';
%     if ~isnan(cP.LickSensorNotInd)
%       cP.LickTime = find(LickData(:,cP.LickSensorNotInd)<0.5,1,'first');
%     else cP.LickTime = []; 
%     end
% end
switch cP.DetectType
  case 'ON';   % 2015/04-YB: modified for RewardTargetContinuous for displaying only the first lick
    if ~isnan(cP.LickSensorInd)
      if strcmp(AllPerf(end).Outcome,'HIT')
        LD = find(LickData(:,cP.LickSensorInd));
        cP.LickTime = LD(LD>(cP.TarWindow(1)*HW.params.fsAI));
        if ~isempty(cP.LickTime); cP.LickTime = cP.LickTime(1); end
      elseif strcmp(AllPerf(end).Outcome,'EARLY') && ~CatchTrial
        LD = find(LickData(:,cP.LickSensorInd));
        cP.LickTime = LD(LD>((cP.TarWindow(1)-ToC)*HW.params.fsAI));
        if ~isempty(cP.LickTime); cP.LickTime = cP.LickTime(1); end
      elseif strcmp(AllPerf(end).Outcome,'EARLY') && CatchTrial
        RespWinDur = get(O,'ResponseWindow');
        LD = find(LickData(:,cP.LickSensorInd));
        cP.LickTime = LD(LD>((cP.TarWindow(1)-ToC-RespWinDur)*HW.params.fsAI));
        if ~isempty(cP.LickTime); cP.LickTime = cP.LickTime(1)+RespWinDur; end  % to shift to the virtual change location
      else
        MinimalInterval = 0.250*HW.params.fsAI;     % samples
        LickTimings = find( diff( LickData(:,cP.LickSensorInd) ) >0)';
        FarLickTimingsIndex = unique( [1 find(diff(LickTimings)>MinimalInterval)+1] );
        cP.LickTime = LickTimings(FarLickTimingsIndex);
      end
    else
      cP.LickTime = [];
    end
  case 'OFF';
    if ~isnan(cP.LickSensorNotInd)
      cP.LickTime = find(LickData(:,cP.LickSensorNotInd)<0.5,1,'first');
    else cP.LickTime = []; 
    end
end

if isempty(cP.LickTime); cP.LickTime = NaN; cP.LickSensorInd = NaN; end  % pump after catch induces fake licks
cP.LickTime = cP.LickTime/HW.params.fsAI;
if strcmp(get(SO,'descriptor'),'RandSeqTorc') && strcmp(AllPerf(end).Outcome,'EARLY') &&...
    ~isnan(cP.LickTime)
%   cP.LickTime = LT;
  cP.FirstLickRelTarget = LT;
%   % lock on last reference sequence
%   SeqOnsetTiming = [ find(~cellfun(@isempty,strfind({StimEvents.Note},'ReferenceSequence'))) ...
%     TarInd];
%   RelativeRefStartTiming = ToC - [StimEvents(SeqOnsetTiming).StartTime];
%   LD = find(LickData(:,cP.LickSensorInd));
%   RT = LD(find(LD>((cP.TarWindow(1)-ToC)*HW.params.fsAI),1,'first'))/HW.params.fsAI - cP.TarWindow(1);
%   LastRefNum = find( (RelativeRefStartTiming + RT)>0,1,'last');
%   if ~isempty(TarInd)
%     cP.FirstLickRelTarget = LD(find(LD>((cP.TarWindow(1)-ToC)*HW.params.fsAI),1,'first'))/HW.params.fsAI -...
%       (cP.TarWindow(1)-ToC)-StimEvents(SeqOnsetTiming(LastRefNum)).StartTime-(ToC-StimEvents(TarInd).StartTime);
%   else % Catch
%     cP.FirstLickRelTarget = LD(find(LD>((cP.TarWindow(1)-ToC)*HW.params.fsAI),1,'first'))/HW.params.fsAI -...
%       (cP.TarWindow(1)-ToC)-StimEvents(SeqOnsetTiming(LastRefNum)).StartTime-(ToC-StimEvents(end).StartTime);
%   end
else
  cP.FirstLickRelTarget = cP.LickTime - cP.TarWindow(1);
end
cP.FirstLickRelReference = cP.LickTime - cP.RefWindow(1);

%% WRITE BACK
if TrialIndex == 1   
  exptparams.Performance = cP;
  exptparams.DBfields.Performance = {'DiscriminationRate','HitRate','SnoozeRate','EarlyRate','ErrorRate','Trials'};
else
  exptparams.Performance(TrialIndex) = cP;
end