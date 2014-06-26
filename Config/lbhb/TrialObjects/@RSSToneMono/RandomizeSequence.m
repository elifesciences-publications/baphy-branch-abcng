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
TargetMaxIndex = par.TargetMaxIndex;
ReferenceCountFreq=par.ReferenceCountFreq./sum(par.ReferenceCountFreq);
TargetIdxFreq=ifstr2num(par.TargetIdxFreq);
CatchIdxFreq=ifstr2num(par.CatchIdxFreq);

RefIdx=1:ReferenceMaxIndex;
if isempty(TargetIdxFreq),
    TargetIdxFreq=1;
elseif length(TargetIdxFreq)>TargetMaxIndex,
    TargetIdxFreq=TargetIdxFreq(1:TargetMaxIndex);
end
if sum(TargetIdxFreq)==0,
    TargetIdxFreq(:)=1;
end
TargetIdxFreq=TargetIdxFreq./sum(TargetIdxFreq);

if isempty(CatchIdxFreq),
    CatchIdxFreq=0;
end

if isfield(exptparams,'TotalTrials'),
    TotalTrials=exptparams.TotalTrials;
else
    TotalTrials=0;
end
% if Trial (ie, RepOrTrial==0), evaluate outcome of last trial and adjust
% trial sequence accodingly
if RepOrTrial == 0,
    trialidx=exptparams.InRepTrials;
    
    if strcmpi(exptparams.BehaveObjectClass,'Passive') || ...
            strcmpi(exptparams.Performance(end).ThisTrial,'Hit') ||...
            strcmpi(exptparams.Performance(end).ThisTrial,'Corr.Rej.'),
        % either passive or last trial was correct. either way, we don't need
        % to adjust anything
        
    else
        % was either a false alarm or miss, need to repeat current trial
        
        fprintf('Error trial: repeating and incrementing the rep trials from %d to %d\n',...
            par.NumberOfTrials,par.NumberOfTrials+1);
        o=set(o,'ReferenceIndices',...
            {par.ReferenceIndices{1:trialidx} par.ReferenceIndices{trialidx:end}});
        NewTargetIndices={par.TargetIndices{1:trialidx} par.TargetIndices{trialidx:end}};
        NewCatchIndices={par.CatchIndices{1:trialidx} par.CatchIndices{trialidx:end}};
        NewCatchSeg=[par.CatchSeg(1:trialidx); par.CatchSeg(trialidx:end)];
        if strcmpi(exptparams.Performance(end).ThisTrial,'Miss') && ~isempty(par.TargetIndices{trialidx}),
            NewTargetIndex=find(rand>[0 cumsum(TargetIdxFreq)], 1, 'last' );
            fprintf('Missed last target.  Repeating same reference with targetidx=%d\n',NewTargetIndex);
            NewTargetIndices{trialidx+1}=NewTargetIndex;
        end
        o=set(o,'TargetIndices',NewTargetIndices);
        o=set(o,'CatchIndices',NewCatchIndices);
        o=set(o,'CatchSeg',NewCatchSeg);
        o=set(o,'SingleRefDuration',...
            [par.SingleRefDuration(1:trialidx) par.SingleRefDuration(trialidx:end)]);
        o=set(o,'NumberOfTrials',par.NumberOfTrials+1);
        exptparams.TrialObject = o;
    end
    
    return;
end


% if Count of ref or tar is less than 10, repeat so that it's
% closer to 10.  not really a "repetition" any more, but this
% allows full length trials.
ReferenceCount=length(RefIdx);
if 10/ReferenceCount>=2,
   repcount=floor(10./ReferenceCount);
else
   repcount=1;
end
RefIdxSet=[];
for ii=1:repcount,
   RefIdxSet=[RefIdxSet RefIdx];
end


% make a big pool of targets with appropriate fraction of each type. Pool
% of targets carries over across Reference repetitions (in par.TarIdxSet)
% to ensure even sampling.
TargetCount=50;
TarIdx=[];
for ii=1:length(TargetIdxFreq),
  TarIdx=cat(2,TarIdx,ones(1,round(TargetCount.*TargetIdxFreq(ii))).*ii);
end
TarIdxSet=par.TarIdxSet;

% same for catch targets
CatchCount=max(50,ReferenceCount);
CatchIdx=[];
for ii=1:length(CatchIdxFreq),
    CatchIdx=cat(2,CatchIdx,ones(1,round(CatchCount.*CatchIdxFreq(ii))).*ii);
end
CatchIdxSet=par.CatchIdxSet;
bCatchTrial=zeros(CatchCount,1);
bCatchTrial(1:round(sum(CatchIdxFreq).*CatchCount))=1;
bCatchTrial=shuffle(bCatchTrial);

trialidx=0;
RefTrialIndex={};
TargetIndex={};
CatchIndex={};
CatchSeg=[];
while ~isempty(RefIdxSet)
  
    trialidx=trialidx+1;
    
    % create a set of possible targets if none are remaining
    if isempty(TarIdxSet),
       if trialidx==1 && RepIndex==1,
          % ie first trials, force frequency target for first 5 trials
          tmaxidx=find(TargetIdxFreq==max(TargetIdxFreq),1);
          ff=find(TarIdx==tmaxidx);
          dd=1; ii=0;
          while ~isempty(dd) && ii<10,
              ii=ii+1;
              if par.CueTrialCount>0 && ~TotalTrials,
                  TarIdxSet=[TarIdx(ff(1:par.CueTrialCount)) shuffle(TarIdx)];
              else
                  TarIdxSet=shuffle(TarIdx);
              end
              dd=find(diff([TarIdxSet 0])==0 & TarIdxSet~=TarIdxSet(1));
          end
       else
          TarIdxSet=shuffle(TarIdx);
       end
    end
    if isempty(CatchIdxSet),
        CatchIdxSet=shuffle(CatchIdx);
    end
    
    % choose number of references for this trial
    CatchIndex{trialidx}=[];
    CatchSeg(trialidx,1)=0;
    if trialidx<par.CueTrialCount && ~TotalTrials,
        CueTrial=1;
        trcf=ReferenceCountFreq(1:(end-1));
        trcf=trcf./sum(trcf);
        refsegcount=find(rand>[0 cumsum(trcf)], 1, 'last' );
    else
        CueTrial=0;
        refsegcount=find(rand>[0 cumsum(ReferenceCountFreq)], 1, 'last' );
        
        % catch stim only possible in non-cue trials
        if rand<sum(CatchIdxFreq),
            % this trial gets a catch stimulus
            CatchIndex{trialidx}=CatchIdxSet(1);
            CatchIdxSet=CatchIdxSet(2:end);
            if refsegcount<max(find(ReferenceCountFreq>0)),
                refsegcount=refsegcount+1;
            end
            CatchSeg(trialidx,1)=refsegcount-ceil(rand*3);
        end
    end
    
    if isempty(par.SingleRefSegmentLen) || par.SingleRefSegmentLen==0,
        refcount=refsegcount;
        SingleRefDuration(trialidx)=0;
    else
        refcount=1;
        SingleRefDuration(trialidx)=par.SingleRefSegmentLen.*refsegcount;
    end
    
    if refcount>length(RefIdxSet),
        refcount=length(RefIdxSet);
    end
    RefTrialIndex{trialidx}=RefIdxSet(1:refcount);
    RefIdxSet=RefIdxSet((refcount+1):end);
    
    if refsegcount<length(ReferenceCountFreq),
        TargetIndex{trialidx}=TarIdxSet(1);
        TarIdxSet=TarIdxSet(2:end);
        
        % add extra "junk" reference if overlap ref tar.
        if strcmpi(par.OverlapRefTar,'Yes') &&...
                (isempty(par.SingleRefSegmentLen) || par.SingleRefSegmentLen==0)
            RefTrialIndex{trialidx}=...
                cat(2,RefTrialIndex{trialidx},ceil(rand*length(RefIdx)));
        end
    else
        TargetIndex{trialidx}=[];
    end
    
    fprintf('Trial %d: Ref=%s Tar=%s Catch=%s\n',TotalTrials+trialidx,...
        mat2str(RefTrialIndex{trialidx}),mat2str(TargetIndex{trialidx}),...
        mat2str(CatchIndex{trialidx}));
end
TotalTrials=trialidx;
if TotalTrials>length(SingleRefDuration),
  warning('TotalTrials>length(SingleRefDuration)');
end
% save results back to the TrialObject
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'TargetIndices',TargetIndex);
o = set(o,'CatchIndices',CatchIndex);
o = set(o,'CatchSeg',CatchSeg);
o = set(o,'TarIdxSet',TarIdxSet);
o = set(o,'CatchIdxSet',CatchIdxSet);
o = set(o,'NumberOfTrials',TotalTrials);
o = set(o,'SingleRefDuration',SingleRefDuration);
exptparams.TrialObject = o;
