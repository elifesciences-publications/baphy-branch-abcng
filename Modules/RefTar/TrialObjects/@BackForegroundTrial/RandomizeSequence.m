function [exptparams] = RandomizeSequence (o, exptparams, globalparams, repetition, RepOrTrial)
%Randomizing trial sequence for TrialObject.
% By Ling Ma, 3/2008

if nargin<5, RepOrTrial = 1;end   % default is its a trial call
if nargin<4, repetition = 1;end
% streaming is not an adaptive learning, so we don't change anything
% for each trial, we do it once for the entire repetition. So, if its
% trial call, return:
% if ~RepOrTrial, return; end

repeatFlag = get(o,'CorrectTrial');
currentRepeatTime = get(o,'repeatTime');
repeatBound = get(o,'RepeatBound');

if ~RepOrTrial,
    if repeatFlag
        if repeatFlag&&(isfield(exptparams,'Performance'))&& (~strcmp(exptparams.Performance(end).ThisTrial,'Hit'))&&(currentRepeatTime < repeatBound)
            curtrial = repetition; % "repetition" here actually is current trial in this repetition when "RepOrTrial" is 0;
            TrialIndex = get(o, 'TrialIndices');
            TrialIndices = [TrialIndex(1:curtrial-1,:);TrialIndex(curtrial,:);TrialIndex(curtrial:end,:)];
            
            o = set(o,'TrialIndices',TrialIndices);
            o = set(o,'NumberOfTrials',size(TrialIndices,1));
            o = set(o,'repeatTime',currentRepeatTime + 1);
            exptparams.TrialObject= o;
        else
            exptparams.TrialObject.repeatTime = 0;
        end
    end
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
refmax=get(o,'ReferenceMaxIndex');
tarmax= get(o,'TargetMaxIndex');

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

[y,ii] = sort(rand(size(TrialIndices,1),1));
TrialIndices = TrialIndices(ii,:);

o=set(o,'TrialIndices',TrialIndices); %c1-trial length; c2-target list index;c3-AttRef2Tar;
o=set(o,'NumberOfTrials',size(TrialIndices,1));
exptparams.TrialObject= o;



