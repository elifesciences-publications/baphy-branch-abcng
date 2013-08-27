function [exptparams] = RandomizeSequence(o, exptparams, globalparams, repetition, RepOrTrial);
%Randomizing trial sequence for TrialObject.
%
if nargin<4, RepOrTrial = 0;end   % default is its a trial call
if nargin<3, repetition = 3;end
% Streaming is not an adaptive learning, so we don't change anything
% for each trial, we do it once for the entire repetition. So, if its
% trial, return:
if ~RepOrTrial, return; end

shamrate=get(o,'ShamPercentage')/100;
shamIndex=get(o,'ShamIndex');
if repetition==1
    shamnum=0;
else
    shamnum=get(o,'ShamTrialNum');
end
if shamnum>length(shamIndex)
    shamnum=shamnum-length(shamIndex);  %in case of using up all sham sequence
end
    
trialidx=get(o,'TrialIndices');
numoftrial=get(o,'NumberOfTrials');
trialidx=trialidx(randperm(numoftrial),:);
% while shamrate>shamnum/(numoftrial*repetition)
%     shamnum=shamnum+1;
%     shamtrial=shamIndex(shamnum);
%     tem=find(trialidx(:,1)==shamtrial);
%     tem=tem(randperm(length(tem)));
%     trialidx(tem(1),2)=0;
% end
% for cnt1 = 1:length(temp) ctemp{cnt1} = temp(cnt1);end
% o=set(o,'TargetIndices',ctemp);
% o=set(o,'ShamTrialNum',shamnum);
o=set(o,'TrialRandom',trialidx);
o=set(o,'CurrentReps',repetition);
exptparams.TrialObject= o;
