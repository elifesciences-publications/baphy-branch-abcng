function O = ObjUpdate (O)
% Run ObjUpdate for Reference and Target objectds
%
% BE, 2010/7

Ref = get(O,'ReferenceHandle');
Tar = get(O,'TargetHandle');
if ~isempty(Ref)
  Ref = ObjUpdate(Ref);
  O = set(O,'ReferenceHandle',Ref);
  O = set(O,'ReferenceClass',class(Ref));
  O = set(O,'ReferenceMaxIndex',get(Ref,'MaxIndex'));
else
  O = set(O,'ReferenceClass','None');
end
if ~isempty(Tar)
  Tar = ObjUpdate(Tar);
  O = set(O,'TargetHandle',Tar);
  O = set(O,'TargetClass',class(Tar));
  O = set(O,'TargetMaxIndex',get(Tar,'MaxIndex'));
else
  O = set(O,'TargetClass','None');
end

O = set(O,'RunClass', RunClassTable(Ref,Tar));
