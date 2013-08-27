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
    [w,e] = waveform(ref,1);
    o = set(o,'NumOfEvPerRef',length(e));
    RefSamplingRate=get(ref,'SamplingRate');
else
    RefSamplingRate=0;
end
if ~isempty(tar)
    tar = ObjUpdate(tar);
    o = set(o,'TargetHandle',tar);
    o = set(o,'TargetClass',class(tar));
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
    [w,e] = waveform(tar,1);
    o = set(o,'NumOfEvPerTar',length(e));
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

% Also, set the runclass:
o = set(o,'RunClass', RunClassTable(ref,tar));

% finally, generate o.Sequences:
par=get(o);
Count=par.ReferenceMaxIndex;
TarIdx=1:par.TargetCount;
DisIdx=(1:par.DistracterCount)+par.TargetCount;
NonTarIdx=(par.TargetCount+1):Count;
NonTarCount=length(NonTarIdx);
OtherIdx=(par.TargetCount+par.DistracterCount+1):Count;
OtherCount=length(OtherIdx);

if ~Count,
    o=set(o,'Sequences',{});
    o=set(o,'SequenceCategories',[]);
    return
end

% 1
FixTarOnlySeq=cell(1,par.TargetCount*par.TarNestedReps);
for tt=1:par.TargetCount,
    for ii=1:par.TarNestedReps,
        FixTarOnlySeq{ii+(tt-1).*par.TarNestedReps}=...
            ones(par.SamplesPerTrial,1).*TarIdx(tt);
    end
end

% 2
DistracterSetCount=100;
DistracterReps=ceil(DistracterSetCount.*par.SamplesPerTrial./NonTarCount);
DistracterSets=zeros(NonTarCount,DistracterReps);
for ii=1:DistracterReps,
    DistracterSets(:,ii)=shuffle(NonTarIdx');
end
DistRandSets=10;
FixTarVarDisSeq=cell(1,par.TargetCount*DistRandSets*par.TarNestedReps);
cc=0;
for tt=1:par.TargetCount,
    for dd=1:DistRandSets
        for ii=1:par.TarNestedReps,
            cc=cc+1;
            FixTarVarDisSeq{cc}=...
                [ones(par.SamplesPerTrial,1).*TarIdx(tt) ...
                DistracterSets((dd-1).*par.SamplesPerTrial+(1:par.SamplesPerTrial)')];
        end
    end
end

% 3
FixTarFixDisSeq=cell(1,par.TargetCount*par.DistracterCount*par.TarNestedReps);
cc=0;
for tt=1:par.TargetCount,
    for dd=1:par.DistracterCount
        for ii=1:par.TarNestedReps,
            cc=cc+1;
            FixTarFixDisSeq{cc}=...
                [ones(par.SamplesPerTrial,1).*TarIdx(tt) ...
                 ones(par.SamplesPerTrial,1).*DisIdx(dd)];
        end
    end
end

% 4
VarDisOnlySeq=cell(1,DistracterSetCount);
for dd=1:DistracterSetCount,
    VarDisOnlySeq{dd}=...
        DistracterSets((dd-1).*par.SamplesPerTrial+(1:par.SamplesPerTrial)');
end

% 5
FixDisOnlySeq=cell(1,par.DistracterCount*par.TarNestedReps);
for tt=1:par.DistracterCount,
    for ii=1:par.TarNestedReps,
        FixDisOnlySeq{ii+(tt-1).*par.TarNestedReps}=...
            ones(par.SamplesPerTrial,1).*DisIdx(tt);
    end
end

% 6
VVSetCount=100;
VVReps=ceil(VVSetCount.*par.SamplesPerTrial./par.ReferenceMaxIndex);
VVSets=zeros(par.ReferenceMaxIndex,VVReps,2);
for ii=1:VVReps,
    for jj=1:2,
        VVSets(:,ii,jj)=shuffle(1:par.ReferenceMaxIndex)';
    end
end
VVSets=reshape(VVSets,par.ReferenceMaxIndex.*VVReps,2);
VarTarVarDisSeq=cell(1,VVSetCount);
for dd=1:VVSetCount
    VarTarVarDisSeq{dd}=...
        [VVSets((dd-1).*par.SamplesPerTrial+(1:par.SamplesPerTrial),1) ...
        VVSets((dd-1).*par.SamplesPerTrial+(1:par.SamplesPerTrial),2)];
end

Sequences={FixTarOnlySeq{:} FixTarVarDisSeq{:} FixTarFixDisSeq{:}  ...
    VarDisOnlySeq{:} FixDisOnlySeq{:} VarTarVarDisSeq{:}};
SequenceCategories=[ones(size(FixTarOnlySeq)) ones(size(FixTarVarDisSeq)).*2 ...
    ones(size(FixTarFixDisSeq)).*3 ones(size(VarDisOnlySeq)).*4 ...
    ones(size(FixDisOnlySeq)).*5 ones(size(VarTarVarDisSeq)).*6];
o=set(o,'Sequences',Sequences);
o=set(o,'SequenceCategories',SequenceCategories);


