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

% no adaptive learning in WM
if RepOrTrial == 0, return; end

ReferenceMaxIndex = par.ReferenceMaxIndex;
TargetMaxIndex = par.TargetMaxIndex;
RefTarFlipFreq=par.RefTarFlipFreq;
ReferenceCountFreq=par.ReferenceCountFreq./sum(par.ReferenceCountFreq);
RefIdx=ifstr2num(par.RefIdx);
TarIdx=ifstr2num(par.TarIdx);

% If specified, only use Ref/Tar Indices entered by user.  Or use all of them
% by default.
RefIdx=RefIdx(RefIdx<=ReferenceMaxIndex);
if isempty(RefIdx),
   RefIdx=1:ReferenceMaxIndex;
end
TarIdx=TarIdx(TarIdx<=TargetMaxIndex);
if isempty(TarIdx),
   TarIdx=1:TargetMaxIndex;
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
RefIdxSet=[];
for ii=1:repcount,
   RefIdxSet=[RefIdxSet shuffle(RefIdx)];
end
TarIdxSet=[];  %intialized below

if 10./TargetCount>=2,
   fliprepcount=floor(10./TargetCount);
else
   fliprepcount=1;
end
RefIdxSetFlip=[];
for ii=1:fliprepcount,
   RefIdxSetFlip=[RefIdxSetFlip shuffle(TarIdx)];
end
TarIdxSetFlip=[];  %intialized below

trialidx=0;
FlipFlag=[];
RefTrialIndex={};
TargetIndex={};

while (RefTarFlipFreq<=0.5 && ~isempty(RefIdxSet)) || ...
    (RefTarFlipFreq>=0.5 && ~isempty(RefIdxSetFlip))
  
    trialidx=trialidx+1;
    
    % create a set of possible targets if none are remaining
    if isempty(TarIdxSet),
        TarIdxSet=shuffle(TarIdx);
    end
    if isempty(TarIdxSetFlip),
        TarIdxSetFlip=shuffle(RefIdx);
    end
    
    % choose whether to flip target and reference for this trial
    flipthistrial=(rand>(1-RefTarFlipFreq));
    if flipthistrial && isempty(RefIdxSetFlip),
      flipthistrial=0;
    end
    FlipFlag=[FlipFlag flipthistrial];
    
    % choose number of references for this trial
    refcount=max(find(rand>[0 cumsum(ReferenceCountFreq)]));
    
    if ~flipthistrial,
      
      % commented out code for different reference in each trial position
      %if refcount>length(RefIdxSet),
      %    refcount=length(RefIdxSet);
      %end
      %RefTrialIndex{trialidx}=RefIdxSet(1:refcount);
      %RefIdxSet=RefIdxSet((refcount+1):end);
      
      % this code repeats the same reference
      RefTrialIndex{trialidx}=repmat(RefIdxSet(1),[1,refcount]);
      RefIdxSet=RefIdxSet(2:end);
      if refcount<length(ReferenceCountFreq),
        TargetIndex{trialidx}=TarIdxSet(1);
        TarIdxSet=TarIdxSet(2:end);
      else
        TargetIndex{trialidx}=[];
      end
      
    else
      
%         if refcount>length(RefIdxSetFlip),
%             refcount=length(RefIdxSetFlip);
%         end
%         RefTrialIndex{trialidx}=RefIdxSetFlip(1:refcount);
%         RefIdxSetFlip=RefIdxSetFlip((refcount+1):end);

        RefTrialIndex{trialidx}=repmat(RefIdxSetFlip(1),[1,refcount]);
        RefIdxSetFlip=RefIdxSetFlip(2:end);
        if refcount<length(ReferenceCountFreq),
          TargetIndex{trialidx}=TarIdxSetFlip(1);
          TarIdxSetFlip=TarIdxSetFlip(2:end);
        else
          TargetIndex{trialidx}=[];
        end
    end
end
TotalTrials=trialidx;

% save results back to the TrialObject
o = set(o,'FlipFlag',FlipFlag);
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'TargetIndices',TargetIndex);
o = set(o,'NumberOfTrials',TotalTrials);
exptparams.TrialObject = o;
