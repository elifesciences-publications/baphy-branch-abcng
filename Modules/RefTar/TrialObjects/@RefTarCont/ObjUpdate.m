function O = ObjUpdate (O)
% Run ObjUpdate for Reference and Target objectds
%
% BE, 2010/7

Ref = get(O,'ReferenceHandle');
Tar = get(O,'TargetHandle');

if ~isempty( get(O,'ReplaySession') ) && isempty(get(O,'TrialIndexLst'))
    if get(O,'ReinsertTrials')~=0
        error('Conflict ReinsertTrials || ReplaySession')
    else
        global globalparams
        globalparamsBU = globalparams;
        Path2PreviousM = globalparamsBU.mfilename;
        LastSlashIndex = findstr(Path2PreviousM,'\'); LastSlashIndex = LastSlashIndex(end);
        Path2PreviousM = Path2PreviousM(1:LastSlashIndex);
        Path2PreviousM = [Path2PreviousM get(O,'ReplaySession')];
        run(Path2PreviousM);
        Tar.IniSeed = get(o,'IniSeed');
        TrialIndexLst = 0;
        O = set(O,'TrialIndexLst',TrialIndexLst);
        globalparams = globalparamsBU;
    end
end


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
