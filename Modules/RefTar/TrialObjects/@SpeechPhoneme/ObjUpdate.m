function o = ObjUpdate (o);
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
    reffs = get(ref,'SamplingRate');
else
    reffs = 0;
end
if ~isempty(tar)
    tar = ObjUpdate(tar);
    o = set(o,'TargetHandle',tar);
    o = set(o,'TargetClass',class(tar));
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
    tarfs = get(tar,'SamplingRate');
else
    o = set(o,'TargetClass','None');
    tarfs = 0;
end
o = set(o,'SamplingRate', max(reffs,tarfs));
% Also, set the runclass:
runclass = 'PHD';
o = set(o,'RunClass', runclass);
