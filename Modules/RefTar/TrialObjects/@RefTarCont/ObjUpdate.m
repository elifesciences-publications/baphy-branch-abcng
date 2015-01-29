function O = ObjUpdate (O)
% Run ObjUpdate for Reference and Target objectds
%
% BE, 2010/7

Ref = get(O,'ReferenceHandle');
Tar = get(O,'TargetHandle');

if ( ( isstr( get(O,'ReplaySession') ) && ~strcmp(get(O,'ReplaySession'),'') ) || ~isempty( get(O,'ReplaySession') ) ) &&...
    ( ( isstr(get(O,'TrialIndexLst')) && strcmp(get(O,'TrialIndexLst'),'[]') ) || isempty(get(O,'TrialIndexLst')) )
  if get(O,'ReinsertTrials')~=0
    error('Conflict ReinsertTrials vs. ReplaySession')
  else
    global globalparams
    globalparamsBU = globalparams;
    if isfield(globalparams,'mfilename')      
      Path2PreviousM = globalparamsBU.mfilename;
      LastSlashIndex = findstr(Path2PreviousM,'\'); LastSlashIndex = LastSlashIndex(end);
      Path2PreviousM = Path2PreviousM(1:LastSlashIndex);
      CurPath = pwd;
      cd(Path2PreviousM);
      run(get(O,'ReplaySession'));
      cd(CurPath);
      IniSeed = exptparams.TrialObject.TargetHandle.IniSeed;
      Tar = set(Tar,'IniSeed',IniSeed);
      TrialIndexLst = exptparams.TrialObject.TrialIndexLst;
      O = set(O,'TrialIndexLst',TrialIndexLst);
      if ~isempty( strfind('_a_' , globalparams.mfilename) )
        O = set(O,'PreviousSessionIndex',[exptparams(1).Performance(:).TargetIndices]);
      else
        T = Events2Trials('Events',exptevents,'Stimclass','TMG','Runclass','TMG');        
        O = set(O,'PreviousSessionIndex',cell2mat(T.Index));
      end
      globalparams = globalparamsBU;
    end
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
