function [exptparams] = RandomizeSequence (o, exptparams, globalparams, RepIndex, RepOrTrial)
% Function Trial Sequence is one of the methods of class ReferenceTone
% This function is responsible for producing the random sequence of
% references, Tones, trials and etc.

% Nima Mesgarani, October 2005
if nargin<4, RepOrTrial = 0;end   % default is its a trial call
if nargin<3, RepIndex = 1;end

% read the trial parameters
par = get(o);

% generate exponential distribution of number of torcs
RandTorcs = 1:1;
w = exppdf(RandTorcs,mean(RandTorcs));
NumRef=1;

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

%pick torcs randomly, without replacment, from possible torcs
RandIndex = randperm(par.ReferenceMaxIndex);
TargetIndices={};
for cnt1=1:length(RefNumTemp)
    RefTrialIndex {cnt1} = RandIndex (1:RefNumTemp(cnt1));
    RandIndex (1:RefNumTemp(cnt1)) = [];
end


%%%%Target

if strcmpi(get(o,'TargetClass'),'None') == 0
    % generate exponential distribution of number of torcs
    RandTorcs = 1:1;
    w = exppdf(RandTorcs,mean(RandTorcs));
    NumTar=1;
    
    % pick torcs for this trial that sum up to par.ReferenceMaxIndex
    TarNumTemp = [];
    TargetMaxIndex = par.TargetMaxIndex;
    while sum(TarNumTemp) < TargetMaxIndex      % while not all the Targets are covered
        if isempty(NumTar)  % if not and if NumTar is empty just finish it
            TarNumTemp = [TarNumTemp TargetMaxIndex-sum(TarNumTemp)]; % TarNumTemp holds the number of Tarerences in each trial
        elseif sum(TarNumTemp)+NumTar(1) <= TargetMaxIndex % can we add NumRef(1)?
            TarNumTemp = [TarNumTemp NumTar(1)]; % if so, add it and circle NumTar
            NumTar = circshift (NumTar, -1);
        else
            NumTar(1)=[]; % otherwise remove this number from NumTar
        end
    end
    
    %pick torcs randomly, without replacment, from possible torcs
    RandIndex = randperm(par.TargetMaxIndex);
    for cnt1=1:length(TarNumTemp)
        TarTrialIndex {cnt1} = RandIndex (1:TarNumTemp(cnt1));
        RandIndex (1:TarNumTemp(cnt1)) = [];
    end
    
else
    TarTrialIndex=[];
end

TotalTrials = length(RefTrialIndex);

o = set(o,'TargetIndices',TarTrialIndex);
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'NumberOfTrials',TotalTrials);
exptparams.TrialObject = o;
