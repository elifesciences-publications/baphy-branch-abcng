function o = ObjUpdate (o);
% For RefTar Object, ObjUpdate does the following:
% run ObjUpdate for Reference and Target objectds
% by Ling Ma, 10/2006, modified from pingbo

ref = get(o,'ReferenceHandle');
tar = get(o,'TargetHandle');
% torc=get(o,'Torc');
isi=get(o,'InterStimInterval');
refnum=get(o,'MaxRefNumPerTrial');
fs = [];

if ~isempty(tar)
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
    o=set(o,'TargetClass',class(tar));
    fs=[fs get(tar,'SamplingRate')];
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
    StaticPercent = get(o,'StaticPercent');
       
    o=set(o,'ReferenceHandle',ref);
    o=set(o,'TargetHandle',tar);
%     if length(get(o,'TrialIndices'))==0
%         o=randomizesequence(o);  end
elseif isempty(ref) | isempty(tar)
        o=set(o,'TrialIndices',[]);
end



    
    


