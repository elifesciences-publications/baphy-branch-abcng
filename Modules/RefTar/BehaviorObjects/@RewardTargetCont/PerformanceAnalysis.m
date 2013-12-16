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
  CurrentTrialIndex = get(SO,'MaxIndex');
else
  CurrentTrialIndex = TargetIndices( mod(TrialIndex,get(SO,'MaxIndex')) );  % Condition number
  CurrentTrialIndex = CurrentTrialIndex{1};
end
DiffiLevels = get(SO,'DifficultyLvlByInd'); 
DistributionTypes = get(SO,'DistributionTypeByInd');

TrialDiffiMat = zeros(length(unique(DiffiLevels)),3);
if DistributionTypes(CurrentTrialIndex) == 1  % Display only for one DistributionType
  TrialDiffiLvl = DiffiLevels(CurrentTrialIndex);
  TrialSuccessCase = find( strcmp({'HIT','SNOOZE','EARLY'} , {AllPerf(end).Outcome}) );
  TrialDiffiMat(TrialDiffiLvl,TrialSuccessCase) = 1;
end

if TrialIndex == 1   
  DiffiMatPreviousTrial = zeros(length(unique(DiffiLevels)),3);
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
cP.DiscriminationRate = prod(cP.HitRates);
if isnan(cP.DiscriminationRate) cP.DiscriminationRate = 0; end
cP.Trials = TrialIndex;

%% RECENT PERFORMANCE
AverageSteps = 10;
RecentPerf = AllPerf([max([1,end-AverageSteps+1]):end]);
cP.HitRateRecent = sum(strcmp({RecentPerf.Outcome},'HIT'))/AverageSteps;
cP.SnoozeRateRecent = sum(strcmp({RecentPerf.Outcome},'SNOOZE'))/AverageSteps;
cP.EarlyRateRecent = sum(strcmp({RecentPerf.Outcome},'EARLY'))/AverageSteps;
cP.ErrorRateRecent = sum(strcmp({RecentPerf.Outcome},'ERROR'))/AverageSteps;

%% TIMING
switch cP.DetectType
  case 'ON';   % Corrected by Yves / 2013/10
    if ~isnan(cP.LickSensorInd)
      cP.LickTime = find(LickData(:,cP.LickSensorInd)>0.5,1,'first');
    else cP.LickTime = []; 
    end
  case 'OFF';
    if ~isnan(cP.LickSensorNotInd)
      cP.LickTime = find(LickData(:,cP.LickSensorNotInd)<0.5,1,'first');
    else cP.LickTime = []; 
    end
end
if isempty(cP.LickTime) cP.LickTime = NaN; cP.LickSensorInd = NaN; end
cP.LickTime = cP.LickTime/HW.params.fsAI;
cP.FirstLickRelTarget = cP.LickTime - cP.TarWindow(1);
cP.FirstLickRelReference = cP.LickTime - cP.RefWindow(1);

%% WRITE BACK
if TrialIndex == 1   
  exptparams.Performance = cP;
  exptparams.DBfields.Performance = {'DiscriminationRate','HitRate','SnoozeRate','EarlyRate','ErrorRate','Trials'};
else
  exptparams.Performance(TrialIndex) = cP;
end