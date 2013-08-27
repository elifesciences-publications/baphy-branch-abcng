function [exptparams] = RandomizeSequence (o, exptparams, globalparams, Index, RepOrTrial)
% Function Trial Sequence is one of the methods of class ReferenceTarget
% This function is responsible for producing the random sequence of
% references, targets, trials and etc.

% Nima Mesgarani, April 2006

if nargin<4, RepOrTrial = 0;end   % default is its a trial call
if nargin<3, Index = 1;end
% if SafeRate is lower than 75% throw in a sham trial:
if ~RepOrTrial,
    return; % disable it for now:
    SF= 0;
    if isfield(exptparams,'Performance')
        SF = exptparams.Performance(end).SafeRate;
    end
    if SF < 75
        RefTrialIndex = get(o,'RefTrialIndex');
        RefTrialIndex{Index} = repmat(RefTrialIndex{cnt1}(1),[1 7]); % make it sham
        TarTrialIndex{Index} = [];
    end
end
% preparing the naive recording: here
if ~isempty(strfind(globalparams.Physiology,'Yes')) && ~isempty(strfind(globalparams.Physiology,'Passive'))
    %
    RefObj = get(o,'ReferenceHandle');
    RefObj = set(RefObj,'Speakers','f106,f108,m111,m114');
    RefObj = set(RefObj,'CVs','ba,sa,ta,ma,ka,fa,pa,na,xa,ga,va,za,da');
    RefObj = set(RefObj,'CVs','sa,ta,xa,pa,ka');
    RefObj = set(RefObj,'SNRs','60');
    RefObj = set(RefObj,'PreStimSilence',.4);
    RefObj = set(RefObj,'PostStimSilence',[.2 .3]);
    o = set(o,'ReferenceHandle',RefObj);
    SNRs = [-9 -6 -3 0 100];
    maxInd = get(RefObj,'maxindex');
    PhnPerTrial = 4;
    TrialIndex = 1;
    for cnt2 = 1:length(SNRs)
        Ind = randperm(maxInd);
        for cnt1 = 1:ceil(maxInd/PhnPerTrial)
            RefTrialIndex{TrialIndex} = Ind(1:PhnPerTrial);
            %             RefTrialIndex{TrialIndex,2} = SNRs(cnt2);
            TrialSNRs{TrialIndex} = SNRs(cnt2);
            TrialIndex = TrialIndex+1;
            Ind(1:PhnPerTrial) = [];
        end
    end
    % three noise condition, so repeat the RefTrialIndex
    RandOrd = randperm(length(RefTrialIndex));
    RefTrialIndex = RefTrialIndex(RandOrd);
    TrialSNRs = TrialSNRs(RandOrd);
    o = set(o,'ReferenceIndices',RefTrialIndex);
    o = set(o,'TrialSNRs',TrialSNRs);
    o = set(o,'TargetIndices',[]);
    o = set(o,'NumberOfTrials',length(RefTrialIndex));
    return;
end
%
TrialPath = fileparts(which(class(o)));
if 0 && exist([TrialPath filesep globalparams.Ferret '_LastPhonemes.mat'],'file')
    load ([TrialPath filesep globalparams.Ferret '_LastPhonemes.mat']);
    % one of the variables in LastPhonemes.mat is LastPhonemeDate which says
    % when it was used. if its the same day, dont change the phoneme
    % otherwise increase it by one:
    if ~strcmpi(LastDate, date)
        LastRefPhoneme = LastRefPhoneme + 1;
        TarPhonemeCount = 0;
    end
    if LastRefPhoneme > get(o,'ReferenceMaxIndex'), LastRefPhoneme = 1;end
    if LastRefPhoneme == LastTarPhoneme, LastTarPhoneme = LastTarPhoneme +1; end
    if LastTarPhoneme > get(o,'TargetMaxIndex'), LastTarPhoneme = 1;end
else
    LastRefPhoneme = 1;
    LastTarPhoneme = 2;
    LastLookup = 1;
    TarPhonemeCount = 0;
end
RefPhoneme = LastRefPhoneme;
RefObj = get(o,'ReferenceHandle');
if strcmpi(get(o,'AdaptiveLearning'),'Random')
    temp = get(RefObj,'CVs');
%     CVs= {'ba','sa','ta','ma','ka','fa','pa','na','xa','ga','va','za','da'};
    CVs= {'sa','ta','xa','pa','ka'};
    RefPhoneme = find(strcmpi(CVs,temp));
end
if strcmpi(get(o,'AdaptiveLearning'),'Yes')
    if isfield(exptparams, 'Performance') && exptparams.Performance(end).RecentDiscriminationRate > 40 ...
            || (TarPhonemeCount>1)
        if isfield(exptparams,'Performance')
            if ~isfield(exptparams.Performance,'IneffectiveRate')
                LastTarPhoneme = LastTarPhoneme + 1;
            elseif exptparams.Performance(end).IneffectiveRate<70,
                LastTarPhoneme = LastTarPhoneme + 1;
            end
        end
        if LastTarPhoneme > get(o,'TargetMaxIndex'), LastTarPhoneme = 1; end
        if LastTarPhoneme == RefPhoneme, LastTarPhoneme = LastTarPhoneme+1; end
        if LastTarPhoneme > get(o,'TargetMaxIndex'), LastTarPhoneme = 1; end
        TarPhonemeCount = 0;
    end
    TarPhoneme = LastTarPhoneme;
    TarPhonemeCount = TarPhonemeCount + 1;
elseif strcmpi(get(o,'AdaptiveLearning'),'No')
    if isfield(exptparams, 'Performance') && exptparams.Performance(end).RecentDiscriminationRate > 40 ...
            || (TarPhonemeCount>0)
        if isfield(exptparams,'Performance')
            if ~isfield(exptparams.Performance,'IneffectiveRate')
                LastTarPhoneme = LastTarPhoneme + 1;
            elseif exptparams.Performance(end).IneffectiveRate<70,
                LastTarPhoneme = LastTarPhoneme + 1;
            end
        end
        if LastTarPhoneme > get(o,'TargetMaxIndex'), LastTarPhoneme = 1; end
        if LastTarPhoneme == RefPhoneme, LastTarPhoneme = LastTarPhoneme+1; end
        if LastTarPhoneme > get(o,'TargetMaxIndex'), LastTarPhoneme = 1; end
        TarPhonemeCount = 0;
    end
    TarPhoneme = LastTarPhoneme;
    TarPhonemeCount = TarPhonemeCount + 1;
    TarPhoneme = min(TarPhoneme,get(o,'TargetMaxIndex'));
else
    TarPhoneme = 1;
    TarPhonemeCount = 1;
end

% negative reinforcement has sham trials, but positive one does not have
% sham:
if strcmpi(get(o,'TrainingMode'),'negative')
    NumRef = [7 6 4 3 7 2 1 3 4 1 5 7 2 3 1; ...
        7 5 6 4 2 7 1 5 2 4 1 2 7 3 1];
else
    NumRef = [2 1 3 6 1 4 3 1 3 2 1 5 2 1 2;
        1 2 4 3 1 5 3 4 6 1 2 2 1 2 6];
    % temporarily:
end
NumRef = min(get(o,'MaxNumberOfRef'),NumRef);
NumRef = NumRef(LastLookup, :);
TotalTrials = exptparams.TrialBlock;
if strcmpi(get(o,'AdaptiveLearning'),'Random') % generate 36 trials, 12*3
%     NumRef = [7 6 2 3 5 2 1 3 4 1 5 7 2 3 1 ...
%         7 1 6 2 4 6 1 5 2 4 1 2 7 3 1 4 2 5 1 4 3 6 2 1 3];
% the new training has 5 phonemes (ptksx) and 5 noise level make it 25
% trials:
    NumRef = [7 5 1 3 1 2 4 1 3 2 4 3 1 4 2 3 2 7 1 6 1 2];
    NumRef = NumRef(1:TotalTrials);
    NumShams = length(find(NumRef==max(NumRef)));
end
LastLookup = LastLookup + 1;
if LastLookup>2, LastLookup = 1; end
maxRef = get(o,'maxNumberOfRef');
SNRs = get(o,'SNRs');
temp = SNRs;
temp = repmat(temp,[TotalTrials/length(SNRs) 1]);
temp = temp(:)';
randord = randperm(length(temp));
temp = temp(randord);
if strcmpi(get(o,'AdaptiveLearning'),'Random')
    TarPhoneme = 1:5;  % 13 - 1 phonemes as target
    TarPhoneme(RefPhoneme)=[];
    TarPhoneme = repmat(TarPhoneme,[1 length(SNRs)]);
    randord = randperm(TotalTrials-NumShams);
    TarPhoneme = TarPhoneme(randord);
    % snrs
    temp = SNRs;
    temp = repmat(temp,[(TotalTrials-NumShams)/length(SNRs) 1]);
    temp = temp(:)';
    temp = temp(randord);
    ind1=1;
end
for cnt1 = 1:length(temp), TrialSNRs{cnt1}=temp(cnt1);end
for cnt1 = 1:TotalTrials
    RefTrialIndex{cnt1} = repmat(RefPhoneme, [1 NumRef(cnt1)]);
    % TEMPORARILY DISABLE THE SHAM
%     if NumRef(cnt1)<maxRef % this is a target trial
        if strcmpi(get(o,'AdaptiveLearning'),'Random')
            TarTrialIndex{cnt1} = TarPhoneme(ind1);
            TrialSNRs{cnt1}     = temp(ind1);
            ind1 = ind1+1;
        else
            TarTrialIndex{cnt1} = TarPhoneme;
        end
%     else
%         TarTrialIndex{cnt1} = [];
%         TrialSNRs{cnt1}     = SNRs(ceil(rand(1)*length(SNRs)));
%     end
end
LastRefPhoneme = RefPhoneme;
LastTarPhoneme = TarPhoneme;
LastDate = date;
save ([TrialPath filesep globalparams.Ferret '_LastPhonemes.mat'],...
    'LastRefPhoneme','LastTarPhoneme','TarPhonemeCount','LastDate','LastLookup');
% preparing the name of this trial block and some comments:
Names = get(get(o,'TargetHandle'),'CVs');
Names = strrep(Names,'a,','');
TrialBlockName = [get(o,'TrialBlockName') Names(TarPhoneme)];
TrialBlockName = [];
Comment = {['RelativedB: ' num2str(get(o,'RelativeRefTardB'))], ['Ref: ' get(get(o,'ReferenceHandle'),'Speakers') ' ' Names(RefPhoneme) ...
    ' Tar: ' get(get(o,'TargetHandle'),'Speakers') ' ' TrialBlockName]};
o = set(o,'Comment',Comment);
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'TargetIndices',TarTrialIndex);
o = set(o,'NumberOfTrials',TotalTrials);
o = set(o,'TrialBlockName',TrialBlockName);
o = set(o,'TrialSNRs',TrialSNRs);
exptparams.TrialObject= o;