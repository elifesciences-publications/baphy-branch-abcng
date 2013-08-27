function o = ObjUpdate (o);
%
% For RefTar Object, ObjUpdate does the following:
% run ObjUpdate for Reference and Target objectds

% Nima, november 2005
ref = get(o,'ReferenceHandle');
tar = get(o,'TargetHandle');
reinforcer=get(o,'Reinforcement');
% if strcmp(reinforcer,'Positive')
%     o=set(o,'ShamPercentage',0); end
fs=[];
if ~isempty(tar)
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
    o=set(o,'TargetClass',class(tar));
    fs=[fs get(tar,'SamplingRate')];
else
    o = set(o,'TargetMaxIndex',[]);
end
if ~isempty(ref)
    o = set(o,'ReferenceMaxIndex',get(ref,'MaxIndex'));
    o=set(o,'ReferenceClass',class(ref));
    fs=[fs get(ref,'SamplingRate')];
end
if length(fs)>0
    o=set(o,'SamplingRate',max(fs));
end
if ~isempty(tar) & ~isempty(ref)
    ref=set(ref,'SamplingRate',max(fs));
    tar=set(tar,'SamplingRate',max(fs));
%     if strcmp(reinforcer,'Positive')
%         TARcomplexnum=get(tar,'ComplexNum');
%         REFcomplexnum=get(ref,'ComplexNum');
%         ref=set(ref,'ComplexNum',round(REFcomplexnum/TARcomplexnum)*TARcomplexnum); end    
    if strcmp(get(ref,'Type'),'referenceBB') & ~strcmp(get(tar,'Type'),'targetBB')
        tar=set(tar,'Type','targetBB');
    elseif strcmp(get(ref,'Type'),'referenceAA') & ~strcmp(get(tar,'Type'),'targetAA')
        tar=set(tar,'Type','targetAA');
    end
    ref=ObjUpdate(ref);
    tar=ObjUpdate(tar);
    
    TrialIdx=[];
    MaxRef=get(o,'ReferenceMaxIndex');
    MaxTar=get(o,'TargetMaxIndex');
    for i=1:MaxTar
        for j=1:MaxRef
            TrialIdx=[TrialIdx;j i];
        end
    end
%     shamidx=get(o,'ShamIndex');
%     if length(shamidx)==0
%         for i=1:10
%             shamidx=[shamidx randperm(MaxRef)];
%         end
%         shamidx=shamidx(:);
%         o=set(o,'ShamIndex',shamidx);
%     end
    o=set(o,'TrialIndices',TrialIdx);
%     o=set(o,'NumberOfTrials',size(TrialIdx,1));
    o=set(o,'ReferenceHandle',ref);
    o=set(o,'TargetHandle',tar);
elseif isempty(ref) | isempty(tar)
%     o=set(o,'ShamIndex',[]);
    o=set(o,'TrialIndices',[]);
    o=set(o,'TrialRandom',[]);
end

    
    



