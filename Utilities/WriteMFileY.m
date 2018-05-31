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
if exist(globalparams.mfilename,'file') & (exist('force_overwrite','var') & ~force_overwrite),
    fid = fopen(fname,'w');
    Append_exptevents = 1;
elseif ~exist(fname,'file') | (exist('force_overwrite','var') & force_overwrite),
    fid = fopen(fname,'w');
    Append_exptevents = 0;
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
if ~Append_exptevents
    if ~isempty(exptevents),
        AddToMFile(fname,'exptevents',exptevents);
    end
else
    mfileID = fopen(globalparams.mfilename);
    contents = textscan(mfileID,'%s','delimiter','\n','BufSize',8191);
    contents = contents{1};
    fclose(mfileID);
    StartTag_exptevents = find(~cellfun(@isempty,strfind(contents,'% ''exptevents'' is a struct:')))+2;
    EndTag_exptevents  = length(contents)-4;
    fid = fopen(fname, 'A');  % Uppercase 'A' for buffering!
    fprintf(fid,'\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
    fprintf(fid,'%% ''%s'' is a %s: ','exptevents', class(exptevents));
    fprintf(fid,'\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
    for LineNum = StartTag_exptevents:EndTag_exptevents
        fprintf(fid,[contents{LineNum} '\n']);
    end
    fclose(fid);
    
    LocTrial = strfind(contents{EndTag_exptevents-1},'Trial');
    if isempty(LocTrial)
        error('cannot correctly append new trials')
    else
        LastCopiedTrial = str2num(contents{EndTag_exptevents-1}((LocTrial+8):(end-1))); 
    end
    eventNum = length(exptevents);
    while exptevents(eventNum).Trial~=LastCopiedTrial
        eventNum = eventNum-1;
    end
    eventNum = eventNum+1;
    AddToMFile(fname,'exptevents',exptevents,eventNum:length(exptevents),1);
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