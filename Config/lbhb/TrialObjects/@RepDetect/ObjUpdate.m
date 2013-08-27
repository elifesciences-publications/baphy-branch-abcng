function o = ObjUpdate (o)
%
% For RefTar Object, ObjUpdate does the following:
% run ObjUpdate for Reference and Target objectds

% Nima, november 2005
ref = get(o,'ReferenceHandle');
tar = get(o,'TargetHandle');
if ~isempty(ref)
    ref = ObjUpdate(ref);
    o = set(o,'ReferenceHandle',ref);
    o = set(o,'ReferenceClass',class(ref));
    o = set(o,'ReferenceMaxIndex',get(ref,'MaxIndex'));
    RefSamplingRate=get(ref,'SamplingRate');
else
   % this should never execute
    RefSamplingRate=0;
    o = set(o,'ReferenceClass','None');
end
if ~isempty(tar)
    tar = ObjUpdate(tar);
    o = set(o,'TargetHandle',tar);
    o = set(o,'TargetClass',class(tar));
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
    if isfield(get(tar),'NumOfEvPerTar')
        o = set(o,'NumOfEvPerTar',get(tar,'NumOfEvPerTar'));
    end
    TarSamplingRate=get(tar,'SamplingRate');
else
    TarSamplingRate=0;
    o = set(o,'TargetClass','None');
end

% make sure SamplingRate is high enough for everyone
TrialSamplingRate = max([RefSamplingRate, TarSamplingRate, get(o,'SamplingRate')]);
o=set(o,'SamplingRate',TrialSamplingRate);

% Also, set the runclass.  Maybe can skip this?
%o = set(o,'RunClass', RunClassTable(ref,tar));

% finally, generate o.Sequences:
par=get(o);
TargetIdx=par.TargetIdx;
TrialCount=par.NumberOfTrials;
ReferenceCountFreq=par.ReferenceCountFreq;
ReferenceCountFreq=ReferenceCountFreq./sum(ReferenceCountFreq);

if ~TrialCount || isempty(TargetIdx) || strcmp(par.ReferenceClass,'None'),
    o=set(o,'Sequences',{});
    o=set(o,'SequenceCategories',[]);
    return
end

RefPool=[];
RefDuringTarPool=[];
TarIdxSet=[];
TargetIdxFreq=ones(size(TargetIdx))./length(TargetIdx);
for ii=1:length(TargetIdxFreq),
  TarIdxSet=cat(2,TarIdxSet,ones(1,TrialCount.*TargetIdxFreq(ii)).*TargetIdx(ii));
end
TarIdxSet=shuffle(TarIdxSet);
Sequences=cell(TrialCount,1);
SequenceCategories=zeros(1,TrialCount);

for TrialIdx=1:TrialCount
   refcount=find(rand>[0 cumsum(ReferenceCountFreq)], 1, 'last' )-1;
   ThisSequence=zeros(refcount+par.TargetRepCount,2);
   for rr=1:refcount,
      if isempty(RefPool)
         RefPool=shuffle(1:par.ReferenceMaxIndex);
      end
      ThisSequence(rr,:)=RefPool(1:2);
      RefPool=RefPool(3:end);
   end
   for tt=1:par.TargetRepCount,
      if isempty(RefDuringTarPool)
         RefDuringTarPool=shuffle(1:par.ReferenceMaxIndex);
      end
      ThisSequence(refcount+tt,:)=...
         [TarIdxSet(TrialIdx) RefDuringTarPool(1)];
      RefDuringTarPool=RefDuringTarPool(2:end);
   end
   Sequences{TrialIdx}=ThisSequence;
   SequenceCategories(TrialIdx)=refcount;
end

o=set(o,'Sequences',Sequences);
o=set(o,'SequenceCategories',SequenceCategories);
