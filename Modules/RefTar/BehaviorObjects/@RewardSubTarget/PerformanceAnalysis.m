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
MaxIndex =get(SO,'MaxIndex');
IndexLst = 1:MaxIndex;
TarInd = find(~cellfun(@isempty,strfind({StimEvents.Note},'TargetSequence')));
str1ind = strfind(StimEvents(TarInd).Note,'-'); str1ind = str1ind(end)+2;
str2ind = strfind(StimEvents(TarInd).Note,','); str2ind = str2ind(end)-2;
IndexNow = str2num(StimEvents(TarInd).Note((str1ind):(str2ind)));
% EarlyWindow = StimEvents(TarInd(end)+1).StartTime;
% EndWindow = StimEvents(TarInd(end)+1).StopTime;

TrialIndexMat = zeros(length(unique(IndexLst ,'stable')),3);

TrialIndexLvl = find(IndexNow==unique(IndexLst ,'stable'));
TrialSuccessCase = find( strcmp({'HIT','SNOOZE','EARLY'} , {AllPerf(end).Outcome}) );
TrialIndexMat(TrialIndexLvl,TrialSuccessCase) = 1;

if TrialIndex == 1   
  IndexMatPreviousTrial = zeros(length(unique(IndexLst ,'stable')),3);
else
  cPreviousTrial = exptparams.Performance(TrialIndex-1);
  IndexMatPreviousTrial = cPreviousTrial.DiffiMat;
end
DiffiMat = IndexMatPreviousTrial+TrialIndexMat;
cP.DiffiMat = DiffiMat;

% compute hit rates for the different sensors/responses
if TrialIndex==1 AllPerf = cP; else AllPerf(end) = cP; end; cTargetsInd = zeros(1,TrialIndex); 
for i=1:length(cP.AllTargetPositions) 
  for j=1:TrialIndex cTargetsInd(j) = any(strcmp(AllPerf(j).CurrentTargetPositions,cP.AllTargetPositions{i})); end
  cP.HitRates(i) = sum(cTargetsInd.*cHitInd)/sum(cTargetsInd);
end
cP.DiscriminationRate = prod(cP.HitRate);
if isnan(cP.DiscriminationRate) cP.DiscriminationRate = 0; end
cP.Trials = TrialIndex;

%% RECENT PERFORMANCE
AverageSteps = 10;
RecentPerf = AllPerf([max([1,end-AverageSteps+1]):end]);
cP.HitRateRecent = sum(strcmp({RecentPerf.Outcome},'HIT'))/AverageSteps;
cP.SnoozeRateRecent = sum(strcmp({RecentPerf.Outcome},'SNOOZE'))/AverageSteps;
cP.EarlyRateRecent = sum(strcmp({RecentPerf.Outcome},'EARLY'))/AverageSteps;
cP.ErrorRateRecent = sum(strcmp({RecentPerf.Outcome},'ERROR'))/AverageSteps;

%% TIMING  % so far, LICKS before the ToC are not seen in LickTargetOnly MODE
switch cP.DetectType
  case 'ON';   % Corrected by Yves / 2013/10
    if ~isnan(cP.LickSensorInd)%&& ~isempty(cP.LickData)
      if ~get(TO,'LickTargetOnly')
        cP.LickTime = find(LickData(:,cP.LickSensorInd)>0.5,1,'first');
      else
        MinimalInterval = 0.300*HW.params.fsAI;     % samples
        LickTimings = find( diff( LickData(:,cP.LickSensorInd) ) >0)';   % ascending wave
        FarLickTimingsIndex = unique( [1 find(diff(LickTimings)>MinimalInterval)+1] );
        if ~isnan(LickTimings)
          cP.LickTime = LickTimings(FarLickTimingsIndex);
        else
          cP.LickTime = [];
        end
      end
    else cP.LickTime = []; 
    end
  case 'OFF';
    if ~isnan(cP.LickSensorNotInd)
      cP.LickTime = find(LickData(:,cP.LickSensorNotInd)<0.5,1,'first');
    else cP.LickTime = []; 
    end
end
if isempty(cP.LickTime); cP.LickTime = NaN; cP.LickSensorInd = NaN; end  % pump after catch induces fake licks
cP.LickTime = cP.LickTime/HW.params.fsAI;
Licks = cP.LickTime(cP.LickTime < cP.TarWindow(2));
cP.FirstLickRelTarget = Licks - cP.TarWindow(1);
cP.FirstLickRelReference = cP.LickTime - cP.RefWindow(1);

%% WRITE BACK
if TrialIndex == 1   
  exptparams.Performance = cP;
  exptparams.DBfields.Performance = {'DiscriminationRate','HitRate','SnoozeRate','EarlyRate','ErrorRate','Trials'};
else
  exptparams.Performance(TrialIndex) = cP;
end