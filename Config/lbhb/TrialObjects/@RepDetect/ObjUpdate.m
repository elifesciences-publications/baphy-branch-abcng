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

