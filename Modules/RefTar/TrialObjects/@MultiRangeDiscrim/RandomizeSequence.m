function [exptparams] = RandomizeSequence (o, exptparams, globalparams, repetition, RepOrTrial)
%Randomizing trial sequence for TrialObject.
%
if nargin<5, RepOrTrial = 1;end   % default is its a trial call
if nargin<4, repetition = 1;end
% ToneSequence is not an adaptive learning, so we don't change anything
% for each trial, we do it once for the entire repetition. So, if its
% trial call, return:
if ~RepOrTrial, return; end

o=ObjUpdate(o);
tindex0=get(o,'RefIndices');
tindex0=tindex0(randperm(size(tindex0,1)),:);
[tindex,ok]=no_more_than3(tindex0,0,3);  %no more than 3 consecutive S- trial
if ~ok,
    [tindex,ok]=no_more_than3(flipud(tindex),0,3);
end
[tindex,ok]=no_more_than3(tindex,2,2); %%no more than 2 consecutive S+ trial
if ~ok,
    [tindex,ok]=no_more_than3(flipud(tindex),2,2);
end

o=set(o,'TrialIndices',tindex);
if nargin==1
    exptparams=o; else
    exptparams.TrialObject= o; end

%========================
function [tindex,ok]=no_more_than3(tindex,N,lm);
temp=0;ok=1;
for i=1:size(tindex,1)
    thistrial=tindex(i,:);
    if tindex(i,2)==N
        temp=temp+1;
    else
        temp=0; end
    if temp>lm
        n=find(tindex(i+1:end,2)~=N);
        if ~isempty(n)
        tindex(i,:)=tindex(n(1)+i,:);
        tindex(n(1)+i,:)=thistrial;
        temp=0;
        else
            ok=0;
            break;
        end
    end    
end




