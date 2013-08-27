function [exptparams] = RandomizeSequence(o, exptparams, globalparams, repetition, RepOrTrial);
%Randomizing trial sequence for TrialObject.
%
if nargin<4, RepOrTrial = 0;end   % default is its a trial call
if nargin<3, repetition = 3;end
% Streaming is not an adaptive learning, so we don't change anything
% for each trial, we do it once for the entire repetition. So, if its
% trial, return:
% if ~RepOrTrial, return; end
if ~RepOrTrial,
%     if (isfield(exptparams,'Performance'))&& (~strcmp(exptparams.Performance(end).ThisTrial,'Hit'))%----added by Ling Ma
%         curtrial = repetition % "repetition" here actually is current trial in this repetition when "RepOrTrial" is 0;
%         TrialIndex = get(o, 'TrialRandom');
%         TrialIndices = [TrialIndex(1:curtrial-1,:);TrialIndex(curtrial,:);TrialIndex(curtrial:end,:)];
%       
%         o = set(o,'TrialRandom',TrialIndices);
%         o=set(o,'NumberOfTrials',size(TrialIndices,1));
%         exptparams.TrialObject= o;
%     end
    return;
end

%%%--------------------------final version of code;
% trialidx=get(o,'TrialIndices');
% numoftrial=size(trialidx,1);
% trialidx=trialidx(randperm(numoftrial),:);
% o=set(o,'NumberOfTrials',numoftrial);
% % add randomization of intensity;
% reldB = get(o,'dBAttRef2Tar'); %c1-c2:dB attenuation ref2tar;c3:% of c1;
% if length(reldB)>1
%     num_att1 = round(numoftrial*reldB(3));
%     num_att2 = numoftrial-num_att1;
%     intensity = [reldB(1)*ones(num_att1,1); reldB(2)*ones(num_att2,1)];
%     trialidx(:,3) = shuffle(intensity);
% end
%%%----------------------------
%%%------------add randomization of intensity; 
% reldB = get(o,'dBAttRef2Tar'); %c1-c2:dB attenuation ref2tar;c3:% of c1;
% idx = get(o,'idx');
% if isempty(idx)
%     trnum = get(o,'ReferenceMaxIndex');
%     trid = repmat(1:trnum,length(reldB),1);
%     idx = [trid(:)'; repmat(reldB,1,trnum)];
%     [y,ii] = sort(rand(size(idx(1,:))));
%     idx = idx(:,ii);
% end

trialidx=get(o,'TrialIndices');
numoftrial=size(trialidx,1);
o=set(o,'NumberOfTrials',numoftrial);
trialrandom = trialidx(randperm(numoftrial),:);
% trialrandom(:,3) = trialrandom(:,2); 
% trialrandom(:,2) = ones(numoftrial,1);

% trialidx(:,[1,3]) = idx(:,1:numoftrial)';
% idx = circshift(idx,[0,-numoftrial]);
% o = set(o,'idx',idx);

o=set(o,'TrialRandom',trialrandom);%c1:ref length list; c2:tar length list; c3: dBAttRef2Tar;
o=set(o,'CurrentReps',repetition);
exptparams.TrialObject= o;
