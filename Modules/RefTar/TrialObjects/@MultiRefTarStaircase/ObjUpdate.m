function o = ObjUpdate (o)
%
% For RefTar Object, ObjUpdate does the following:
% run ObjUpdate for Reference and Target objectds

% Nima, november 2005
ref = get(o,'ReferenceHandle');
tar = get(o,'TargetHandle');
SR=get(o,'SamplingRate');
if ~isempty(ref)
    ref = ObjUpdate(ref);
    o = set(o,'ReferenceHandle',ref);
    o = set(o,'ReferenceClass',class(ref));
    o = set(o,'ReferenceMaxIndex',get(ref,'MaxIndex'));
    SR=max(SR,get(ref,'SamplingRate'));
end
if ~isempty(tar)
    tar = ObjUpdate(tar);
    o = set(o,'TargetHandle',tar);
    o = set(o,'TargetClass',class(tar));
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
    SR=max(SR,get(tar,'SamplingRate'));
else
    o = set(o,'TargetClass','None');
end

% Also, set the runclass:
o = set(o,'RunClass', RunClassTable(ref,tar));
o = set(o,'SamplingRate',SR);
