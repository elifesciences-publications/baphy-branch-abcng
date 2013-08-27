function [exptparams] = RandomizeSequence (o, exptparams, globalparams, RepIndex, RepOrTrial)
% Function Trial Sequence is one of the methods of class ReferenceTarget
% This function is responsible for producing the random sequence of
% references, targets, trials and etc.

% Nima Mesgarani, October 2005
if nargin<4, RepOrTrial = 0;end   % default is its a trial call
if nargin<3, RepIndex = 1;end
% ReferenceTarget is not an adaptive learning, so we don't change anything
% for each trial, we do it once for the entire repetition. So, if its
% trial, return:
if RepOrTrial == 0, return; end
% read the trial parameters
par = get(o);
% if strcmpi(exptparams.
NumRef = par.NumberOfRefPerTrial(:);
IsLookup = isempty(NumRef) | ~isnumeric(NumRef);
% for now, lets assume Lookup table:
IsLookUp = 1;
%
if IsLookup
    if strcmpi(par.TargetClass,'none'),
        tr=get(get(exptparams.TrialObject,'ReferenceHandle'));
        if isfield(tr,'RefRepCount'),
            NumRef=tr.RefRepCount;
        else
            NumRef=1;
        end
    else
        LookupTable = [3 4 7 3 2 7 3 1 4 1 5 7 2 1 6 4 7 2 1 7 2 5 1 3 2 1 7 4 7 5 6];
        if ~exist('LastLookup.mat','file')
            LastLookup = 1;
        else
            tt = what(class(o));
            load ([tt.path filesep 'LastLookup.mat']);
        end
        NumRef = circshift(LookupTable(:), LastLookup);
    end
end
temp = [];
ReferenceMaxIndex = par.ReferenceMaxIndex;
% here, we try to specify the real number of references per trial, and
% determine how many trials are needed to cover all the references. If its
% a detect case, its easy. Add from NumRef to trials until the sum of
% references becomes equal to maxindex.
% in discrim, if its not sham, the number of references per trial is added
% by one because one reference goes into target.
while sum(temp) < ReferenceMaxIndex      % while not all the references are covered
    if isempty(NumRef)  % if not and if NumRef is empty just finish it
        temp = [temp ReferenceMaxIndex-sum(temp)]; % temp holds the number of references in each trial
        %     elseif sum(temp)+NumRef(1)+(IsDiscrim & ~IsSham(1)) <= ReferenceMaxIndex % can we add NumRef(1)?
    elseif sum(temp)+NumRef(1) <= ReferenceMaxIndex % can we add NumRef(1)?
        temp = [temp NumRef(1)]; % if so, add it and circle NumRef
        NumRef = circshift (NumRef, -1);
    else
        NumRef(1)=[]; % otherwise remove this number from NumRef
    end
end
if ~IsLookup  % if its a lookup table, dont randomize, if not randomize them
    RefNumTemp = temp(randperm(length(temp))); % randomized number of references in each trial
else
    RefNumTemp = temp;
end
% Lets specify which trials are sham:
TotalTrials = length(RefNumTemp);
if (get(o,'NumberOfTarPerTrial') ~= 0) && (~strcmpi(get(o,'TargetClass'),'None'))
    if ~IsLookup
        NotShamNumber = floor((100-par.ShamPercentage) * TotalTrials / 100); % how many shams do we have??
        allTrials  = randperm(TotalTrials); %
        NotShamTrials = allTrials (1:NotShamNumber);
    else
        NotShamTrials = find(RefNumTemp < max(LookupTable));
    end
    TargetIndex = cell(1,length(RefNumTemp));
    for cnt1=1:length(NotShamTrials)
        TargetIndex{NotShamTrials(cnt1)} = 1+floor(rand(1)*par.TargetMaxIndex);
    end
else
    TargetIndex = [];
end
% at this point, we know how many references in each trial we have. If its
% a detect case, we just need to choose randomly from references and put
% them in the trial. But in discrim case, we put one index in the target
% also, if its not a sham.
% Now generate random sequences for each trial
RandIndex = randperm(par.ReferenceMaxIndex);
for cnt1=1:length(RefNumTemp)
    RefTrialIndex {cnt1} = RandIndex (1:RefNumTemp(cnt1));
    RandIndex (1:RefNumTemp(cnt1)) = [];
end
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'TargetIndices',TargetIndex);
o = set(o,'NumberOfTrials',TotalTrials);
% the following line eliminates the first prestim silence.
% if get(exptparams.BehaveObject,'ExtendedShock')
%     o = set(o,'NoPreStimForFirstRef',1);
% end

%Here we select the roving levels
RoveRefs = get(o,'RoveRefs');
RovingRangedB = get(o,'RovingRangedB');

if RoveRefs == 0
    if length(RovingRangedB) == 1
        RoveLevelsdB = repmat(RovingRangedB,1,TotalTrials);
    else
        RoveLevelsdB = randsample(RovingRangedB,TotalTrials,'true');
    end
    
else
    for i = 1:length(RefTrialIndex)
        RoveLevelsdB{1,i} = randsample(RovingRangedB,length(RefTrialIndex{1,i})+1,'true');
        
    end
end


o = set(o,'RoveLevelsdB',RoveLevelsdB);

exptparams.TrialObject = o;
if exist('LastLookup','var')
    LastLookup = LastLookup+TotalTrials;
    tt = what(class(o));
    save ([tt.path filesep 'LastLookup.mat'],'LastLookup');
end

