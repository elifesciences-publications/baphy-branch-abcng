function [exptparams] = RandomizeSequence (o, exptparams, globalparams, RepIndex, RepOrTrial)
% Function Trial Sequence is one of the methods of class ReferenceTarget
% This function is responsible for producing the random sequence of
% references, targets in each trial. Called at the beginning of each
% repetition.
%
% SVD 2011-06-06, ripped off of Reference Target
%

if nargin<4, RepOrTrial = 0;end   % default is its a trial call
if nargin<3, RepIndex = 1;end

% read the trial parameters
par = get(o);

ReferenceMaxIndex = par.ReferenceMaxIndex;
ReferenceCountFreq=par.ReferenceCountFreq./sum(par.ReferenceCountFreq);
RefIdx=ifstr2num(par.RefIdx);
TargetIdxFreq=ifstr2num(par.TargetIdxFreq);

% If specified, only use Ref/Tar Indices entered by user.  Or use all of them
% by default.
RefIdx=RefIdx(RefIdx<=ReferenceMaxIndex);
if isempty(RefIdx),
   RefIdx=1:ReferenceMaxIndex;
end
TarIdx=cat(2,ifstr2num(par.Tar1Index),ifstr2num(par.Tar2Index));
TargetMaxIndex=length(TarIdx);
if isempty(TargetIdxFreq),
  TargetIdxFreq=1;
elseif length(TargetIdxFreq)>TargetMaxIndex,
  TargetIdxFreq=TargetIdxFreq(1:TargetMaxIndex);
end
if sum(TargetIdxFreq)==0,
  TargetIdxFreq(:)=1;
end
TargetIdxFreq=TargetIdxFreq./sum(TargetIdxFreq);

% if Trial (ie, RepOrTrial==0), evaluate outcome of last trial and adjust
% trial sequence accodingly
if RepOrTrial == 0 && ~strcmpi(exptparams.BehaveObjectClass,'Passive'), 
  if strcmpi(exptparams.BehaveObjectClass,'Passive') || ...
      strcmpi(exptparams.Performance(end).ThisTrial,'Hit'),
    % either passive or last trial was correct. either way, we don't need
    % to adjust anything
    
  else
    % was either a false alarm or miss, need to repeat current trial
    
    TrialIndex=exptparams.InRepTrials;
    fprintf('Error trial: repeating and incrementing the rep trials from %d to %d\n',...
      par.NumberOfTrials,par.NumberOfTrials+1);
    o=set(o,'ReferenceIndices',...
      cat(2,...
      cat(1,{par.ReferenceIndices{1:TrialIndex,1}}',{par.ReferenceIndices{TrialIndex:end,1}}'),...
      cat(1,{par.ReferenceIndices{1:TrialIndex,2}}',{par.ReferenceIndices{TrialIndex:end,2}}')));
    NewTargetIndices={par.TargetIndices{1:TrialIndex} par.TargetIndices{TrialIndex:end}};
    if strcmpi(exptparams.Performance(end).ThisTrial,'Miss'),
      NewTargetIndex=find(rand>[0 cumsum(TargetIdxFreq)], 1, 'last' );
      fprintf('Missed last target.  Repeating same reference with targetidx=%d\n',NewTargetIndex);
      NewTargetIndices{TrialIndex+1}=NewTargetIndex;
    end
    o=set(o,'TargetIndices',NewTargetIndices);
    o=set(o,'SingleRefDuration',...
      [par.SingleRefDuration(1:TrialIndex) par.SingleRefDuration(TrialIndex:end)]);
    o=set(o,'NumberOfTrials',par.NumberOfTrials+1);
    exptparams.TrialObject = o;
  end
  
  return; 
end

% make a big pool of targets with appropriate fraction of each type
TargetCount=50;
TarIdx=[];
for ii=1:length(TargetIdxFreq),
  TarIdx=cat(2,TarIdx,ones(1,TargetCount.*TargetIdxFreq(ii)).*ii);
end

ReferenceCount=length(RefIdx);
TargetCount=length(TarIdx);

% if Count of ref or tar is less than 10, repeat so that it's
% closer to 10.  not really a "repetition" any more, but this
% allows full length trials.
if 10./ReferenceCount>=2,
   repcount=floor(10./ReferenceCount);
else
   repcount=1;
end
RefIdxSet1=[];
RefIdxSet2=[];
for ii=1:repcount,
   RefIdxSet1=[RefIdxSet1 shuffle(RefIdx)];
   RefIdxSet2=[RefIdxSet2 shuffle(RefIdx)];
end
TarIdxSet=[];  %intialized below

TrialIndex=0;
RefTrialIndex={};
TargetIndex={};

while ~isempty(RefIdxSet1),
  
    TrialIndex=TrialIndex+1;
    
    % create a set of possible targets if none are remaining
    if isempty(TarIdxSet),
        TarIdxSet=shuffle(TarIdx);
    end
    
    % choose number of references for this trial
    if isempty(par.SingleRefSegmentLen) || par.SingleRefSegmentLen==0,
        refcount=max(find(rand>[0 cumsum(ReferenceCountFreq)]));
        SingleRefDuration(TrialIndex)=0;
    else
        refcount=1;
        SingleRefDuration(TrialIndex)=par.SingleRefSegmentLen.*...
            max(find(rand>[0 cumsum(ReferenceCountFreq)]));
    end
    
    
    if refcount>length(RefIdxSet1),
        refcount=length(RefIdxSet1);
    end
    RefTrialIndex{TrialIndex,1}=RefIdxSet1(1:refcount);
    RefTrialIndex{TrialIndex,2}=RefIdxSet2(1:refcount);
    RefIdxSet1=RefIdxSet1((refcount+1):end);
    RefIdxSet2=RefIdxSet2((refcount+1):end);
    
    if refcount<length(ReferenceCountFreq),
        TargetIndex{TrialIndex}=TarIdxSet(1);
        TarIdxSet=TarIdxSet(2:end);
    else
        TargetIndex{TrialIndex}=[];
    end
end
TotalTrials=TrialIndex;
if TotalTrials>length(SingleRefDuration),
  warning('TotalTrials>length(SingleRefDuration)');
end
% save results back to the TrialObject
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'TargetIndices',TargetIndex);
o = set(o,'NumberOfTrials',TotalTrials);
o = set(o,'SingleRefDuration',SingleRefDuration);
exptparams.TrialObject = o;
