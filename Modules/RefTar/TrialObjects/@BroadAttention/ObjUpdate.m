function o = ObjUpdate (o)
% For RefTar Object, ObjUpdate does the following:
% run ObjUpdate for Reference and Target objectds
% by Ling Ma, 10/2006, modified from pingbo
ref = get(o,'ReferenceHandle');
tar = get(o,'TargetHandle');
if ~isempty(ref)
    ref = ObjUpdate(ref);
    o = set(o,'ReferenceHandle',ref);
    o = set(o,'ReferenceClass',class(ref));
    o = set(o,'ReferenceMaxIndex',get(ref,'MaxIndex'));
end
if ~isempty(tar)
    tar = ObjUpdate(tar);
    o = set(o,'TargetHandle',tar);
    o = set(o,'TargetClass',class(tar));
    o = set(o,'TargetMaxIndex',get(tar,'MaxIndex'));
else
    o = set(o,'TargetClass','None');
end

%determine runclass
%reference only, using masktone
if isempty(tar)
    runclass = 'MSK';
else
    runclass = 'BFG';
end
o = set(o, 'RunClass', runclass);
    
    


