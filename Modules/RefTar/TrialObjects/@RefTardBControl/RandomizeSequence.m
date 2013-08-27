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
ControlMode= get(o,'ControlMode');
if RepOrTrial == 0, 
    if strcmpi(ControlMode,'Random')
        if strcmpi(exptparams.BehaveObjectClass, 'PunishTarget');
            dBAtten= get(o,'dBAttenuation');
            if dBAtten(RepIndex)<-5
               exptparams.BehaveObject = set(exptparams.BehaveObject,'ShockDuration', 0);
            else
               %ShockDuration= get(exptparams.BehaveObject, 'ShockDuration');
               exptparams.BehaveObject = set(exptparams.BehaveObject,'ShockDuration', 0.2) ;
            end
        end
    end
    return;
end
% read the trial parameters
par = get(o);
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
            load LastLookup;
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
if strcmpi(ControlMode,'Random')
    dBRange= get(o, 'dBRange');
    permnum= ceil(TotalTrials/length(dBRange));
    permutations= []; 
    for a= 1:permnum
        permutations= [permutations, randperm(length(dBRange))];
    end
    dBAttenuation= dBRange(permutations(1:TotalTrials));
else%%% Use this option to have two different SNRs in one trial with specific proportion for each. 
    dBRange= get(o, 'dBRange');
    Percentages= get(o,'Percentages');
    SNRVals=zeros(1,TotalTrials) ;
    if length(dBRange)==1;
        SNRVals(1:end)= dBRange(1);               
    elseif length(dBRange)==2;
        SNRVals(1:round(TotalTrials*Percentages(1)))= dBRange(1);
        SNRVals(round(TotalTrials*Percentages(1))+1:end)= dBRange(2);        
    else
        % START svd modified 2010-04-09
        sidx=shuffle(1:length(dBRange));
        dBRange=dBRange(sidx);
        Percentages=Percentages(sidx);
        shuffidx=shuffle(1:TotalTrials);
        sumpct=[0 round(cumsum(Percentages)*TotalTrials)];
        
        for ii=1:length(Percentages),
            ss=sumpct(ii)+1;
            ee=sumpct(ii+1);
            SNRVals(shuffidx(ss:ee))=dBRange(ii);
        end
        
        % this is old and doesn't seem to work:
        %SNRVals(1:round(TotalTrials*Percentages(1)))= dBRange(1);
        %SNRVals(round(TotalTrials)+1:round(TotalTrials*Percentages(2)))= dBRange(2); 
        %SNRVals(round(TotalTrials*Percentages(2))+1:end)= dBRange(3);        

        % END svd modified 2010-04-09
    end
    
    dBAttenuation= SNRVals(randperm(length(SNRVals)));
end
o = set(o,'dBAttenuation', dBAttenuation);
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'TargetIndices',TargetIndex);
o = set(o,'NumberOfTrials',TotalTrials);
exptparams.TrialObject= o;
if exist('LastLookup','var')
    LastLookup = LastLookup+TotalTrials;
    tt = what(class(o));
    save ([tt.path filesep 'LastLookup.mat'],'LastLookup');
end