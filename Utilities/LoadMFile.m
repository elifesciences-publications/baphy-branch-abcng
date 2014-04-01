% function LoadMFile(mfile)
%
% load baphy parameters from mfile into current workspace
%
% SVD 2005-11-20
%
function LoadMFile(mfile)

global CLEAR_MFILE_AFTER_LOAD BAPHYDATAROOT

if isempty(CLEAR_MFILE_AFTER_LOAD),
    CLEAR_MFILE_AFTER_LOAD=1;
end

if strcmp(computer,'PCWIN') Sep = '\'; else Sep = '/'; end

% special code for copying temp files over to seil cluster
ss_stat=onseil;
if ss_stat && ~exist([mfile '.m'],'file') && ~exist(mfile,'file') && ...
        strcmpi(mfile(1:4),BAPHYDATAROOT(1:4)),
   trin=mfile
   if ~strcmp(trin((end-1):end),'.m'),
      trin=[trin '.m'];
   end
   if ss_stat==1,
       disp('mapping file to seil');
       trout=strrep(trin,'/auto/data/','/homes/svd/data/');
   else
       trout=trin;
   end
   
   [bb,pp]=basename(trout);
   if strcmp(bb(1:5),'model'),
      disp('model cell, forcing recopy of response');
      ['\rm ' trout]
      unix(['\rm ' trout]);
   end
   if ~exist(trout,'file'),
       if ss_stat==2,
           disp('mapping file to OHSU');
       end
      unix(['mkdir -p ',pp]);
      ['scp svd@bhangra.isr.umd.edu:',trin,' ',pp]
      unix(['scp svd@bhangra.isr.umd.edu:',trin,' ',pp]);
   end
   mfile=trout;
end

[pp,bb]=fileparts(mfile);

% change to directory of m-file temporarily to run it
tpwd=pwd;
if ~isempty(pp),
   cd(pp);
else
   pp=pwd;
end

% error if the mfile is not locked, so check first:
if mislocked(bb)
    munlock(bb);
end
%clear(bb);

% SAVING FOR LOADING EFFICIENCY (benglitz)
if ~exist(['.',filesep,'tmp'],'dir') mkdir('tmp'); end
MatFile = ['tmp',Sep,bb,'.mat'];
MatFileInfo = dir(MatFile);
MFileInfo = dir([bb,'.m']);

if ~isempty(MatFileInfo) && ...
      datenum(MatFileInfo.date) > datenum(MFileInfo.date)
  evalin('caller',['load ',MatFile]);
else
    % only save matfile if experiment is complete (ie, not during online
    % analysis)
    evalin('caller','clear exptevents');
    evalin('caller',bb);
    if evalin('caller','exist(''globalparams'',''var'') && isfield(globalparams,''ExperimentComplete'') && globalparams.ExperimentComplete'),
    if ~exist('tmp','file') mkdir('tmp'); end
    if ~evalin('caller','exist(''exptevents'',''var'')') evalin('caller','exptevents = [];'); end
    evalin('caller',['save tmp',Sep,bb,'.mat globalparams exptparams exptevents']);
  end
end

% check if old (daqpc) mfile, in which case, don't continue
if evalin('caller','~exist(''globalparams'',''var'')')
    disp(['NOTE: ' bb ' is an old format m-file']);
    cd(tpwd);
    return
end

if evalin('caller','exist(''events'',''var'')')
    warning('old events renamed exptevents');
    evalin('caller','exptevents=events;');
end
if ~evalin('caller',['strcmpi(''',mfile,''',globalparams.mfilename)']),
    evalin('caller','TTT_oldbase=[pcfileparts(globalparams.mfilename) ''\''];');
    evalin('caller',['globalparams.mfilename=strrep(globalparams.mfilename,TTT_oldbase,''',[pp filesep],''');']);
    evalin('caller',['globalparams.evpfilename=strrep(globalparams.evpfilename,TTT_oldbase,''',[pp filesep],''');']);
    evalin('caller',['globalparams.tempevpfile=strrep(globalparams.tempevpfile,[TTT_oldbase ''tmp\''],''',[pp filesep 'tmp' filesep],''');']);
    evalin('caller','clear TTT_oldbase');
end

% change back to working directory
cd(tpwd);
if CLEAR_MFILE_AFTER_LOAD,
    clear(bb);
end
