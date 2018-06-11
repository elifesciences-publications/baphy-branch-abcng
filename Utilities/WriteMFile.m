function WriteMFile(globalparams,exptparams,exptevents,force_overwrite)
% function WriteMFile(globalparams,exptparams,exptevents,force_overwrite[=0])
%
% inputs:
% XXXXparams==[] means don't write that variable. %
% force_overwrite=0 (append) by default
%
% Nima, Stephen , January 2006
%

% write it to temp folder on local machine, then move it to the permanent
% folder:
fname = globalparams.tempMfile;
if ~exist(fname,'file') | (exist('force_overwrite','var') & force_overwrite),
    fid = fopen(fname,'w');
else
    fid = fopen(fname,'a');
end
fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
fprintf(fid,'%% STARTING WRITE/APPEND\n');
fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
fprintf(fid,'MFileDone=0;\n');
fclose(fid);

if ~isempty(globalparams),
    AddToMFile(fname,'globalparams',globalparams);
end
if ~isempty(exptparams),
    AddToMFile(fname,'exptparams',exptparams);
end
if ~isempty(exptevents),
    AddToMFile(fname,'exptevents',exptevents);
end

fid = fopen(fname,'a');
fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
fprintf(fid,'%% DONE WRITE/APPEND\n');
fprintf(fid,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
fprintf(fid,'MFileDone=1;\n');
fclose(fid);
% now move it:
if ~strcmp(globalparams.tempMfile, globalparams.mfilename),
  try
    movefile(globalparams.tempMfile, globalparams.mfilename);
  catch   % added by Yves because fid was not closed correctly before this point; 2013/10
    fclose('all')
    movefile(globalparams.tempMfile, globalparams.mfilename);
  end   
end

% Check if .mat file exists, if so, delete it
[Path,Name,Ext] = fileparts(globalparams.mfilename);
MatFile = [Path,filesep,'tmp',filesep,Name,'.mat'];
if exist(MatFile,'file')  delete(MatFile); end