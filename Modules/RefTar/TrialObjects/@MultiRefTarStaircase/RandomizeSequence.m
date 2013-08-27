function [exptparams] = RandomizeSequence (o, exptparams, globalparams, RepIndex, RepOrTrial)
% Function Trial Sequence is one of the methods of class ReferenceTarget
% This function is responsible for producing the random sequence of
% references, targets in each trial. Called at the beginning of each
% repetition.
%
% SVD 2011-06-06, ripped off of Reference Target
%

if nargin<4, RepOrTrial = 0; end   % default is its a trial call
if nargin<3, RepIndex = 1; end

% read the trial parameters
par = get(o);

ReferenceMaxIndex = par.ReferenceMaxIndex;
TargetMaxIndex = par.TargetMaxIndex;
RefTarFlipFreq=par.RefTarFlipFreq;
ReferenceCountFreq=par.ReferenceCountFreq./sum(par.ReferenceCountFreq);
RefIdx=ifstr2num(par.RefIdx);
TarIdx=ifstr2num(par.TarIdx);
TargetIdxFreq=ifstr2num(par.TargetIdxFreq);

% If specified, only use Ref/Tar Indices entered by user.  Or use all of them
% by default.
RefIdx=RefIdx(RefIdx<=ReferenceMaxIndex);
if isempty(RefIdx),
   RefIdx=1:ReferenceMaxIndex;
end
if isempty(TargetIdxFreq),
  TargetIdxFreq=1;
elseif length(TargetIdxFreq)>TargetMaxIndex,
  TargetIdxFreq=TargetIdxFreq(1:TargetMaxIndex);
end
if sum(TargetIdxFreq)==0,
  TargetIdxFreq(:)=1;
end
TargetIdxFreq=TargetIdxFreq./sum(TargetIdxFreq);

if isfield(exptparams,'TotalTrials'),
    TotalTrials=exptparams.TotalTrials;
else
    TotalTrials=0;
end
% if Trial (ie, RepOrTrial==0), evaluate outcome of last trial and adjust
% trial sequence accodingly
if RepOrTrial == 0,
   trialidx=exptparams.InRepTrials;
   %cat(2,par.TargetIndices{trialidx:end})
   if strcmpi(exptparams.BehaveObjectClass,'Passive') || ...
      strcmpi(exptparams.Performance(end).ThisTrial,'Hit'),
   % either passive or last trial was correct. either way, we don't need
   % to adjust anything
   
   else
      % was either a false alarm or miss, need to repeat current trial
      
      fprintf('Error trial: repeating and incrementing the rep trials from %d to %d\n',...
         par.NumberOfTrials,par.NumberOfTrials+1);
      o=set(o,'ReferenceIndices',...
         {par.ReferenceIndices{1:trialidx} par.ReferenceIndices{trialidx:end}});
      NewTargetIndices={par.TargetIndices{1:trialidx} par.TargetIndices{trialidx:end}};
      if strcmpi(exptparams.Performance(end).ThisTrial,'Miss'),
         NewTargetIndex=find(rand>[0 cumsum(TargetIdxFreq)], 1, 'last' );
         fprintf('Missed last target.  Repeating same reference with targetidx=%d\n',NewTargetIndex);
         NewTargetIndices{trialidx+1}=NewTargetIndex;
      end
      o=set(o,'TargetIndices',NewTargetIndices);
      o=set(o,'SingleRefDuration',...
         [par.SingleRefDuration(1:trialidx) par.SingleRefDuration(trialidx:end)]);
      o=set(o,'NumberOfTrials',par.NumberOfTrials+1);
      exptparams.TrialObject = o;
   end
   if ~strcmpi(exptparams.BehaveObjectClass,'Passive') && par.UpdateSnrStep,
      ff=find(par.TarSnr==min(par.RelativeTarRefdB)); % find all trials with min SNR
      Hit=cat(1,exptparams.Performance(ff).Hit);
      FA=cat(1,exptparams.Performance(ff).FalseAlarm);
      Hit=Hit(FA==0); % only consider misses versus hits (exlcude FA trials)
      if length(Hit)>=par.UpdateSnrFrequency && mean(Hit)>par.UpdateSnrHR,
         fprintf('%d/%d hits at SNR %d\n',...
            sum(Hit),length(Hit),par.RelativeTarRefdB(end));
         NewSNR=par.RelativeTarRefdB(end)-par.UpdateSnrStep;
         par.RelativeTarRefdB=cat(2,par.RelativeTarRefdB,NewSNR);
         o=set(o,'RelativeTarRefdB',par.RelativeTarRefdB);
         exptparams.TrialObject = o;
         fprintf('Adding tar snr %d to the mix\n',NewSNR);
      end
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
   RefIdxSet=[RefIdxSet shuffle(RefIdx)];
end


% make a big pool of targets with appropriate fraction of each type. Pool
% of targets carries over across Reference repetitions (in par.TarIdxSet)
% to ensure even sampling.
TargetCount=50;
TarIdx=[];
for ii=1:length(TargetIdxFreq),
  TarIdx=cat(2,TarIdx,ones(1,TargetCount.*TargetIdxFreq(ii)).*ii);
end
TargetCount=length(TarIdx);
TarIdxSet=par.TarIdxSet;

RefIdxSetFlip=shuffle(TarIdx);
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
       if trialidx==1 && RepIndex==1,
          % ie first trials, force frequency target for first 5 trials
          tmaxidx=find(TargetIdxFreq==max(TargetIdxFreq),1);
          ff=find(TarIdx==tmaxidx);
          dd=1; ii=0;
          while ~isempty(dd>0) && ii<10,
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
    if isempty(par.SingleRefSegmentLen) || par.SingleRefSegmentLen==0,
      refcount=max(find(rand>[0 cumsum(ReferenceCountFreq)]));
      SingleRefDuration(trialidx)=0;
    else
      refcount=1;
      SingleRefDuration(trialidx)=par.SingleRefSegmentLen.*...
        max(find(rand>[0 cumsum(ReferenceCountFreq)]));
    end
    
    if ~flipthistrial,
      
      if refcount>length(RefIdxSet),
          refcount=length(RefIdxSet);
      end
      RefTrialIndex{trialidx}=RefIdxSet(1:refcount);
      RefIdxSet=RefIdxSet((refcount+1):end);
      
      % add extra reference if overlap ref tar.      
      if strcmpi(par.OverlapRefTar,'Yes')
         RefTrialIndex{trialidx}=...
            cat(2,RefTrialIndex{trialidx},ceil(rand*length(RefIdx)));
      end
      
      % commented out: this code repeats the same reference
      %RefTrialIndex{trialidx}=repmat(RefIdxSet(1),[1,refcount]);
      %RefIdxSet=RefIdxSet(2:end);
      if refcount<length(ReferenceCountFreq),
        TargetIndex{trialidx}=TarIdxSet(1);
        TarIdxSet=TarIdxSet(2:end);
      else
        TargetIndex{trialidx}=[];
      end
      
    else
      
      if refcount>length(RefIdxSetFlip),
        refcount=length(RefIdxSetFlip);
      end
      RefTrialIndex{trialidx}=RefIdxSetFlip(1:refcount);
      RefIdxSetFlip=RefIdxSetFlip((refcount+1):end);
      
      % add extra reference if overlap ref tar.      
      if strcmpi(par.OverlapRefTar,'Yes')
         RefTrialIndex{trialidx}=...
            cat(2,RefTrialIndex{trialidx},ceil(rand*length(TarIdx)));
      end
      
      % commented out: this code repeats the same reference
      %RefTrialIndex{trialidx}=repmat(RefIdxSetFlip(1),[1,refcount]);
      %RefIdxSetFlip=RefIdxSetFlip(2:end);
      if refcount<length(ReferenceCountFreq),
        TargetIndex{trialidx}=TarIdxSetFlip(1);
          TarIdxSetFlip=TarIdxSetFlip(2:end);
        else
          TargetIndex{trialidx}=[];
        end
    end
    
    fprintf('Trial %d: Ref=%s Tar=%s\n',TotalTrials+trialidx,...
        mat2str(RefTrialIndex{trialidx}),mat2str(TargetIndex{trialidx}));
end
TotalTrials=trialidx;
if TotalTrials>length(SingleRefDuration),
  warning('TotalTrials>length(SingleRefDuration)');
end
% save results back to the TrialObject
o = set(o,'FlipFlag',FlipFlag);
o = set(o,'ReferenceIndices',RefTrialIndex);
o = set(o,'TargetIndices',TargetIndex);
o = set(o,'TarIdxSet',TarIdxSet);
o = set(o,'NumberOfTrials',TotalTrials);
o = set(o,'SingleRefDuration',SingleRefDuration);
exptparams.TrialObject = o;
