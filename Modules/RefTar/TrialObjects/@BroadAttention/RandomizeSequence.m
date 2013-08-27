function [exptparams] = RandomizeSequence (o, exptparams, globalparams, repetition, RepOrTrial)
%Randomizing trial sequence for TrialObject.
% By Ling Ma, 3/2008

if nargin<5, RepOrTrial = 1;end   % default is its a trial call
if nargin<4, repetition = 1;end
% streaming is not an adaptive learning, so we don't change anything
% for each trial, we do it once for the entire repetition. So, if its
% trial call, return:
% if ~RepOrTrial, return; end
if ~RepOrTrial,
    %     if (isfield(exptparams,'Performance'))&& (~strcmp(exptparams.Performance(end).ThisTrial,'Hit'))%----added by Ling Ma
    %         curtrial = repetition; % "repetition" here actually is current trial in this repetition when "RepOrTrial" is 0;
    %         TrialIndex = get(o, 'TrialIndices');
    %         TrialIndices = [TrialIndex(1:curtrial-1,:);TrialIndex(curtrial,:);TrialIndex(curtrial:end,:)];
    %
    %         o = set(o,'TrialIndices',TrialIndices);
    %         o=set(o,'NumberOfTrials',size(TrialIndices,1));
    %         exptparams.TrialObject= o;
    %     end
    return;
end
%%%------------------------------final version of code;
% % trial length randomization
% refmax=get(o,'ReferenceMaxIndex');
% TrialIndices = [];
% TrialIndices(:,1) = randperm(refmax)';
% TrialIndices(:,2) = ones(refmax,1);
% TrialIndices(:,3) = ones(refmax,1);
% % add randomization of intensity;
% reldB = get(o,'dBAttRef2Tar'); %c1-c2:dB attenuation ref2tar;c3:% of c1;
% if length(reldB)>1
%     num_att1 = round(refmax*reldB(3));
%     num_att2 = refmax-num_att1;
%     intensity = [reldB(1)*ones(num_att1,1); reldB(2)*ones(num_att2,1)];
% %     TrialIndices(:,4) = shuffle(intensity);
%     TrialIndices(:,4) = intensity;
% end
%%%%------------------------------

o = set(o, 'repetition', exptparams.TotalRepetitions+1);

objectHandle = get(o);
referenceHandle = get(objectHandle.ReferenceHandle);
targetHandle = get(objectHandle.TargetHandle);
if isempty(targetHandle)
    staticHandle = referenceHandle;
else
    staticHandle = targetHandle;
end
if staticHandle.DynamicorStatic == 0
    currentseed = round(datenum(date) + get(o, 'repetition'));
    rand('seed',currentseed);
end

refmax=get(o,'ReferenceMaxIndex');
if isempty(targetHandle)
    tarmax = 1;
else
    tarmax= get(o,'TargetMaxIndex');
end
refid = repmat(1:refmax,1,tarmax);
refid = refid(:);
tarid = repmat(1:tarmax,refmax,1);
tarid = tarid(:);
TrialIndices = [refid,tarid];

% add randomization of intensity;
reldB = get(o,'dBAttRef2Tar');
dBnum = length(reldB);
if length(reldB)>1
    dBid = repmat(1:dBnum,size(TrialIndices,1),1);
    dBid = dBid(:);
    trid = repmat(TrialIndices,dBnum,1);
    TrialIndices = [trid,dBid];
end

lightbehavior = get(o, 'LightShift');
lighttype = length(lightbehavior);
if length(lightbehavior)>1
    lighttypeid = repmat(1:lighttype,size(TrialIndices,1),1);
    lighttypeid = lighttypeid(:);
    trid = repmat(TrialIndices,lighttype,1);
    TrialIndices = [trid,lighttypeid];
end

[y,ii] = sort(rand(size(TrialIndices,1),1));
TrialIndices = TrialIndices(ii,:);

o=set(o,'TrialIndices',TrialIndices); %c1-trial length; c2-target list index;c3-AttRef2Tar;
o=set(o,'NumberOfTrials',size(TrialIndices,1));
exptparams.TrialObject= o;