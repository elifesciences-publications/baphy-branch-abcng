function [exptparams] = RandomizeSequence (o, exptparams, globalparams, repetition, RepOrTrial)
%Randomizing trial sequence for TrialObject. 
% always use MaxRefNumPerTrial == 1;
% always use one protection zone;

% By Ling Ma, 10/2006

if nargin<5, RepOrTrial = 1;end   % default is its a trial call
if nargin<4, repetition = 1;end
% streaming is not an adaptive learning, so we don't change anything
% for each trial, we do it once for the entire repetition. So, if its
% trial call, return:
if ~RepOrTrial, return; end
% if ~RepOrTrial,
%     if (isfield(exptparams,'Performance'))&& (~strcmp(exptparams.Performance(end).ThisTrial,'Hit'))%----added by Ling Ma
%         curtrial = repetition % "repetition" here actually is current trial in this repetition when "RepOrTrial" is 0;
%         TrialIndex = get(o, 'TrialIndices');
%         TrialIndices = [TrialIndex(1:curtrial-1,:);TrialIndex(curtrial,:);TrialIndex(curtrial:end,:)];
%         ReferenceIdx = get(o, 'ReferenceIdx');
%         ii = sum(TrialIndex(1:curtrial-1,1))+1:sum(TrialIndex(1:curtrial,1));
%         ReferenceIdx = [ReferenceIdx(1:ii(1)-1,:);ReferenceIdx(ii,:);ReferenceIdx(ii,:);ReferenceIdx(ii(end)+1:end,:)];
%         ReferenceIndices = get(o, 'ReferenceIndices');
%         ReferenceIndices = {ReferenceIndices{1:curtrial-1},ReferenceIndices{curtrial},ReferenceIndices{curtrial:end}};
%         
%         o = set(o,'TrialIndices',TrialIndices);
%         o = set(o,'ReferenceIdx',ReferenceIdx);
%         o = set(o,'ReferenceIndices',ReferenceIndices);
%         o=set(o,'NumberOfTrials',size(TrialIndices,1));
%         exptparams.TrialObject= o;
%     end
%     return;
% end

% trial length always==1;
% referance randomization;
MaxRefNumPerTrial=get(o,'MaxRefNumPerTrial');
refmax=get(o,'ReferenceMaxIndex');
% lookuptable = [];
refhandle = get(o,'ReferenceHandle'); 
% stimlistcnt = get(refhandle,'StimListCnt');
% while isempty(lookuptable)||length(lookuptable)<refmax
lookuptable=[randperm(refmax)'];
%         lookuptable=[lookuptable;[1,2,1,2,1,2,1,2]];
% end

% o = set(o,'Lookuptable',lookuptable);
trcnt = refmax;

%----- target randomization
% taridx = [];
% tarmax=get(o,'TargetMaxIndex');
% while length(taridx)<refmax
%    taridx = [taridx;randperm(tarmax)'];
% end
% 
% % trialidx = [temp,temp2(:),tarindex(:)]; %c1-trial length;c2-trial number;
% % % c3-dynamic/static for target only;c4-target list index;
% 
% taridx = taridx(1:refmax);
taridx = lookuptable;
trialidx = [ones(refmax,2),taridx];
o = set(o,'TargetIdx',taridx);
o=set(o,'TrialIndices',trialidx); %c1-trial length; c2-dynamic/static for target only; c3-target list index;
o=set(o,'ReferenceIdx',[lookuptable,ones(refmax,1)]); %c1-stim list index for reference; c2-dynamic/static for reference;
tt=[];
for cnt1 = 1:size(trialidx,1)
    tt{cnt1} = zeros(1,trialidx(cnt1,1));
end
o=set(o,'ReferenceIndices',tt);            
o=set(o,'NumberOfTrials',trcnt);
exptparams.TrialObject= o;
%----------------------------- subfunction -------------------------------
function idx = findvector(matrix,vector)
% by Ling Ma, 06/2006.

idx = [];
for i = 1:length(vector)
    idx = [idx; find(matrix==vector(i))];
end



