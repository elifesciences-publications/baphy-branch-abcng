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
RandTorcs = 1:1;
w = exppdf(RandTorcs,mean(RandTorcs));
NumRef=randsample(RandTorcs,100,'true',w)';

% pick torcs for this trial that sum up to par.ReferenceMaxIndex
RefNumTemp = [];
if ~strcmp(par.ReferenceClass,'SDWMNoise')
ReferenceMaxIndex = par.ReferenceMaxIndex;
else
  par.ReferenceMaxIndex = 5;
  ReferenceMaxIndex = 5;
end

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

safe = par.Safe;

TrialTypePr = get(par.TargetHandle);
TnTnPr=TrialTypePr.TnTnPr;
TnTrPr=TrialTypePr.TnTrPr;
TrTrPr=TrialTypePr.TrTrPr;
TrTnPr=TrialTypePr.TrTnPr;
TrialTypePr = [TnTnPr TnTrPr TrTrPr TrTnPr];
UnSpecPrIndex = find(TrialTypePr == 0);
SpecPrIndex = find(TrialTypePr > 0);
SpecPr = sum(TrialTypePr(SpecPrIndex));
UnSpecPr = (1-SpecPr)/length(UnSpecPrIndex);
TrialTypePr(UnSpecPrIndex) = UnSpecPr;

RefTarOrder=[];
TorcOrTone=[];
for cnt1 = 1:1000;
    TrialTypes_temp1=[];
    if sum(TrialTypePr) ~= 0
    for i = 1:3
        TrialTypes_temp1 = [TrialTypes_temp1 randsample(1:4,1,'true',TrialTypePr)];
    end
    else
        for i = 1:3
        TrialTypes_temp1 = [TrialTypes_temp1 randsample(1:4,1,'false')];
    end
    end
    
    TrialTypes_temp2=[];
    for i = 1:length(TrialTypes_temp1)
        switch TrialTypes_temp1(i)
            case 1
                TrialTypes_temp2 = [TrialTypes_temp2; 1 1];
            case 2
                TrialTypes_temp2 = [TrialTypes_temp2; 1 2];
            case 3
                TrialTypes_temp2 = [TrialTypes_temp2; 2 2];
            case 4
                TrialTypes_temp2 = [TrialTypes_temp2; 2 1];
        end
    end
    RefTarOrder_temp=TrialTypes_temp2(:,1);
    TorcOrTone_temp=TrialTypes_temp2(:,2);
    
    if sum(RefTarOrder_temp == [1; 1; 1]) == 3
        RefTarOrder_temp = [RefTarOrder_temp; 2];
    elseif sum(RefTarOrder_temp == [2; 2; 2]) == 3
        RefTarOrder_temp = [RefTarOrder_temp; 1];
    end
    RefTarOrder = [RefTarOrder; RefTarOrder_temp];
    
    if sum(TorcOrTone_temp == [1; 1; 1]) == 3
        TorcOrTone_temp = [TorcOrTone_temp; 2];
    elseif sum(TorcOrTone_temp == [2; 2; 2]) == 3
        TorcOrTone_temp = [TorcOrTone_temp; 1];
    end
    TorcOrTone = [TorcOrTone; TorcOrTone_temp];
    
    if length(RefTarOrder)> length(RefNumTemp) && length(TorcOrTone)> length(RefNumTemp)
        break
    end
end
RefTarOrder = RefTarOrder(1:length(RefNumTemp))'
o = set(o,'RefTarOrder',RefTarOrder);
if safe == 0
    TorcOrTone = TorcOrTone(1:length(RefNumTemp))';
else
    TorcOrTone=RefTarOrder;
end
o = set(o,'TorcOrTone',TorcOrTone);

TotalTrials = length(RefNumTemp);

Target=get(par.TargetHandle);
RandTarFrqs = randsample([Target.Frequencies(1):500:Target.Frequencies(2)],TotalTrials,'true');
o = set(o,'RandTarFrqs',RandTarFrqs);

ITI = randsample([1:.25:1.5],300,'true');
o = set(o,'ITI',ITI);

%pick torcs randomly, without replacment, from possible torcs
RandIndex = randperm(par.ReferenceMaxIndex);
TargetIndices={};
for cnt1=1:length(RefNumTemp)
    RefTrialIndex {cnt1} = RandIndex (1:RefNumTemp(cnt1));
    RandIndex (1:RefNumTemp(cnt1)) = [];
    TargetIndices{cnt1} = 1;
end

o = set(o,'TargetIndices',TargetIndices);
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'NumberOfTrials',TotalTrials);
o = set(o,'RepIndex',RepIndex);
exptparams.TrialObject = o;

