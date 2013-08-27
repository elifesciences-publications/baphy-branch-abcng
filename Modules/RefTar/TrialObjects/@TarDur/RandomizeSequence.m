function [exptparams] = RandomizeSequence (o, exptparams, globalparams, RepIndex, RepOrTrial)
% Function Trial Sequence is one of the methods of class ReferenceTarget
% This function is responsible for producing the random sequence of
% references, targets, trials and etc.

% Nima Mesgarani, October 2005
% Edited by NAF, 2/12

if nargin<4, RepOrTrial = 0;end   % default is its a trial call
if nargin<3, RepIndex = 1;end
if RepOrTrial == 0, return; end

% read the trial parameters
par = get(o);

% generate exponential distribution of number of torcs
RandTorcs = 2:7;
w = exppdf(RandTorcs,mean(RandTorcs));
NumRef=randsample(RandTorcs,100,'true',w)';

% pick torcs for this trial that sum up to par.ReferenceMaxIndex
RefNumTemp = [];
ReferenceMaxIndex = par.ReferenceMaxIndex;
while sum(RefNumTemp) < ReferenceMaxIndex      % while not all the references are covered
    if isempty(NumRef)  % if not and if NumRef is empty just finish it
        RefNumTemp = [RefNumTemp ReferenceMaxIndex-sum(RefNumTemp)]; % RefNumTemp holds the number of references in each trial
    elseif sum(RefNumTemp)+NumRef(1) <= ReferenceMaxIndex % can we add NumRef(1)?
        RefNumTemp = [RefNumTemp NumRef(1)]; % if so, add it and circle NumRef
        NumRef = circshift (NumRef, -1);
    else
        NumRef(1)=[]; % otherwise remove this number from NumRef
    end
end

TotalTrials = length(RefNumTemp);
NotShamTrials = find(RefNumTemp < max(RandTorcs));
TargetIndex = cell(1,length(RefNumTemp));
for cnt1=1:length(NotShamTrials)
    TargetIndex{NotShamTrials(cnt1)} = 1+floor(rand(1)*par.TargetMaxIndex);
end

Target=get(par.TargetHandle);
if ~isempty(Target) && strcmpi(Target.descriptor, 'TarDurTone')
RandTarFrqs = linspace(Target.Frequencies(1),Target.Frequencies(2),TotalTrials);
o = set(o,'RandTarFrqs',RandTarFrqs(randperm(TotalTrials)));
end

%pick torcs randomly, without replacment, from possible torcs
RandIndex = randperm(par.ReferenceMaxIndex);
for cnt1=1:length(RefNumTemp)
    RefTrialIndex {cnt1} = RandIndex (1:RefNumTemp(cnt1));
    RandIndex (1:RefNumTemp(cnt1)) = [];
end

o = set(o,'TargetIndices',TargetIndex);
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'NumberOfTrials',TotalTrials);
exptparams.TrialObject = o;

