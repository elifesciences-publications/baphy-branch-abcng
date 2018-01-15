function exptparams = PerformanceAnalysis(O, HW, StimEvents, globalparams, exptparams, TrialIndex, LickData)
%
%  HIT RATE = #hitevents/(#hitevents + #falsenegative)  
%                = P(E[Target]|Target) \in [0,1]
%  For Positive RE, this just corresponds to the #hits/#trials
%
%  DISCRIMINATION RATE = DPRIME

AllPerf = exptparams.Performance;
LastEv = StimEvents(end).Note;
Index = str2num(LastEv( (find(LastEv=='-',1,'first')+1):(find(LastEv==',',1,'first')-1) ));
TargetChannel = get(O,'TargetChannel');
TAR = ismember(Index,TargetChannel);

%% CURRENT PERFORMANCE
cP = AllPerf(TrialIndex);
cP.TargetTrial = double(TAR);
cP.ProbeChannel = Index;
% warning('YVES : reactivate this line and set AllTargetPositions in your Soundobject');
cP.AllTargetPositions = {'center'}; cP.CurrentTargetPositions = {'center'};
cHitInd =  strcmp({AllPerf.Outcome},'HIT');
cP.HitRate = sum(cHitInd)/TrialIndex;
cP.MissRate = sum(strcmp({AllPerf.Outcome},'MISS'))/TrialIndex;
cP.EarlyRate = sum(strcmp({AllPerf.Outcome},'EARLY'))/TrialIndex;
cP.FARate = sum(strcmp({AllPerf.Outcome},'FA'))/TrialIndex;
cP.CrRate = sum(strcmp({AllPerf.Outcome},'CR'))/TrialIndex;
NonEarlyTrialNb = TrialIndex-sum(strcmp({AllPerf.Outcome},'EARLY'));
cP.ActualFARate = sum(strcmp({AllPerf.Outcome},'FA'))/NonEarlyTrialNb;
if cP.ActualFARate==0; cP.ActualFARate = 1/NonEarlyTrialNb;
    elseif cP.ActualFARate==1; cP.ActualFARate = (NonEarlyTrialNb-1)/NonEarlyTrialNb; end
cP.ActualHitRate = sum(cHitInd)/NonEarlyTrialNb;
if cP.ActualHitRate==0; cP.ActualHitRate = 1/NonEarlyTrialNb;
    elseif cP.ActualHitRate==1; cP.ActualHitRate = (NonEarlyTrialNb-1)/NonEarlyTrialNb; end

TO = exptparams.TrialObject;
SO = get(TO,'TargetHandle');
TargetIndices = get(TO,'TargetIndices');
if mod(TrialIndex,get(SO,'MaxIndex')) ==0
  CurrentTrialIndex = TargetIndices(get(SO,'MaxIndex'));
else
  CurrentTrialIndex = TargetIndices( mod(TrialIndex,get(SO,'MaxIndex')) );  % Condition number
end
CurrentTrialIndex = CurrentTrialIndex{1};

% Compute hit rates for the different sensors/responses
if TrialIndex==1 AllPerf = cP; else AllPerf(end) = cP; end; cTargetsInd = zeros(1,TrialIndex); 
for i=1:length(cP.AllTargetPositions) 
  for j=1:TrialIndex cTargetsInd(j) = any(strcmp(AllPerf(j).CurrentTargetPositions,cP.AllTargetPositions{i})); end
  cP.HitRates(i) = sum(cTargetsInd.*cHitInd)/sum(cTargetsInd);
end
% cP.DiscriminationRate = (cP.HitRate+cP.MissRate) * (1-cP.EarlyRate);
% if isnan(cP.DiscriminationRate) cP.DiscriminationRate = 0; end
zHr = norminv(cP.ActualHitRate);
zFPr = norminv(cP.ActualFARate);
cP.DiscriminationRate = zHr-zFPr;  % DPRIME
cP.Trials = TrialIndex;

%% RECENT PERFORMANCE
AverageSteps = 10;
RecentPerf = AllPerf([max([1,end-AverageSteps+1]):end]);
cP.HitRateRecent = sum(strcmp({RecentPerf.Outcome},'HIT'))/AverageSteps;
cP.MissRateRecent = sum(strcmp({RecentPerf.Outcome},'MISS'))/AverageSteps;
cP.EarlyRateRecent = sum(strcmp({RecentPerf.Outcome},'EARLY'))/AverageSteps;
cP.FARateRecent = sum(strcmp({RecentPerf.Outcome},'FA'))/AverageSteps;

%% TIMING
switch cP.DetectType
  case 'ON'
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
% if isempty(cP.LickTime) || CatchTrial; cP.LickTime = NaN; cP.LickSensorInd = NaN; end  % pump after catch induces fake licks
cP.LickTime = cP.LickTime/HW.params.fsAI;
if cP.TargetTrial
    cP.FirstLickRelTarget = cP.LickTime' - cP.TarWindow(1);
    cP.FirstLickRelReference = [];
else
    cP.FirstLickRelReference = cP.LickTime - cP.RefWindow(1);
    cP.FirstLickRelTarget = [];
end

%% WRITE BACK
if TrialIndex == 1   
  exptparams.Performance = cP;
  exptparams.DBfields.Performance = {'DiscriminationRate','HitRate','MissRate','EarlyRate','FARate','Trials'};
else
  exptparams.Performance(TrialIndex) = cP;
end