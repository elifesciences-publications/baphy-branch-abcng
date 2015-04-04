function flush_data_to_server(sFrom,sTo,Verbose,NotificationEmail)
% function flush_data_to_server(sFrom,sTo);
%
% utility to copy baphy data files from the local machine to a central file
% server.  Also update cellDB to point those files to the new location.
%
% called by baphy_remote or the command line
%
% created SVD 2006-05-30
% updated BE 2012

if ~exist('sFrom','var') || isempty(sFrom) sFrom = MD_getDir('Kind','archive','DB',0); end
if ~exist('sTo','var') || isempty(sTo) sTo = MD_getDir('Kind','archive','DB',1); end
if ~exist('Verbose','var') Verbose = 0; end
if ~exist('NotificationEmail','var') NotificationEmail = 'boubenec@ens.fr'; end

global VERBOSE; VERBOSE = Verbose;
global BAPHY_LAB

%% COLLECTING RECORDING FROM DATABASE
fprintf('FLUSHING from %s to %s...\n',sFrom,sTo);
DataPath=lower(strrep(sFrom,filesep,'/'));
Fields = 'parmfile,cellid,resppath,respfileevp,training,id,trials,bad';
SQL=['SELECT ',Fields,' FROM gDataRaw WHERE resppath like "',DataPath,'%"',...
  ' AND not(cellid like "tst%") AND not(cellid like "Test%") AND not(parmfile like "%Test%") AND not(bad) order by masterid'];
RecsDB=mysql(SQL);
fprintf('Found %d recordings matching the FROM directory.\n',length(RecsDB));

%% MODIFY PATHS FOR CERTAIN COMPUTERS
Ind = [];
for i=1:length(RecsDB)
  if exist(RecsDB(i).resppath,'dir') 
    Ind(end+1) = i; 
    RecsDB(i) = LF_evalScript(RecsDB(i));
  end
end
RecsDB = RecsDB(Ind);

OldPath=pwd; FlushMessages = {}; Sep = filesep;

%% FIND EMPTY TRIAL COUNTS AND SET TO BAD 
% (ASSUMING THAT NO M-FILE AND AN UNFINISHED REP MAKE IT LIKELY IT  WAS AN ERROR)
% USER CAN PREVENT THIS BY SETTING THE TRIAL COUNT TO SOMETHING NON-NULL
if ~isempty(RecsDB) && ~strcmpi(BAPHY_LAB,'lbhb') && ~strcmpi(BAPHY_LAB,'yale')

  Trials = {RecsDB.trials}; Ind = cellfun(@isempty,Trials);
  RecsBAD = RecsDB(Ind);
  for i=1:length(RecsBAD)
     fprintf(['Setting [ ',n2s(sum(Ind)),' ] Recordings without finished repetition to ''BAD''\n']);
     R = mysql(['UPDATE gDataRaw SET bad=1 WHERE id=',n2s(RecsBAD(i).id),'']);
  end
  RecsDB = RecsDB(~Ind);
end

%% LOOP OVER DATASETS (RECORDINGS/TRAININGS)
for ii=1:length(RecsDB),
  ErrorOccured=0; ErrorMessage=[]; % INITIALIZE ERROR STATE
  
  % one iteration per parmfile/gDataRaw entry
  MFileBase=RecsDB(ii).parmfile;
  fprintf(['\n',repmat('-',1,25),' < ',MFileBase,' >',repmat('-',1,25),'\n\n']);
  
  MFile=[strrep(RecsDB(ii).resppath,'/',Sep) MFileBase];
  if (MFile(2)==':') MFile(1)=upper(MFile(1)); end
  MFile=strrep(MFile,[Sep Sep],Sep);
  MFileRemote=strrep(MFile,MFile(1:length(sFrom)),sTo);
  
  %% TRY TO CONVERT ALPHA DATA TO EVP
  try
    if exist(MFile,'file') && length(MFileBase)>=1 && (MFile(1)<'0' || MFileBase(1)>'9'),
      clear exptparams globalparams exptevents
      if VERBOSE fprintf('Loading M-File %s...\n',basename(MFile)); end
      LoadMFile(MFile);
      if ~isempty(findstr('Yes',globalparams.Physiology)) && ...
          ~sum(globalparams.HWSetup==[7,8,10,12]) && ...
          (~isfield(globalparams.HWparams,'DAQSystem') || ...
              strcmp(globalparams.HWparams.DAQSystem,'AO')),
        alpha2evp(MFile);
      end
    end
  catch ME
    ErrorMessage = ['Error: ',strtrim(ME.message)];
    ErrorOccured = 1;
    if VERBOSE keyboard; end
  end
  
  %% FIX cellDB
  if isempty(RecsDB(ii).trials) && exist('globalparams','var'),
     fprintf('fixing celldb entries for possibily crashed baphy file\n');
     dbSaveBaphyData(globalparams,exptparams);
  end
  
  %% COPY FILES (BUT CHECK IF NECESSARY)
  if ~ErrorOccured % continue to end if error already occured
    if exist(MFile,'file')
      if VERBOSE fprintf('transferring %s --> %s\n',MFile,MFileRemote); end
      [bdest,DestPath]=basename(MFileRemote);
      if ~exist(DestPath,'dir')  mkdir(DestPath); end
      if ~exist([DestPath Sep 'tmp'],'dir'),
        mkdir([DestPath Sep 'tmp']);
      end
      
      [MFilePath,MFileName]=fileparts(MFile);
      EVPFile=[MFilePath Sep MFileName '.evp'];
      
      try
        
        %% COPY FILES IN BASE DIRECTORY
        if ~isempty(findstr('Yes',globalparams.Physiology))
          % gzip local file before copying
          if VERBOSE disp(['compressing before copy to server: ',EVPFile]); end
          EVPFileZip=evpcompress(EVPFile);
          if exist(EVPFileZip,'file'),
            if exist(EVPFile,'file')  delete(EVPFile); end
            copyfile(EVPFileZip,DestPath);
          elseif exist(EVPFile), 
             % this happens for MANTA systems where evp doesn't actually
             % get compressed
            copyfile(EVPFile,DestPath);
          end
        elseif exist(EVPFile,'file')  copyfile(EVPFile,DestPath);
        else          warning(['training: no evp file? ',EVPFile]);
        end
        
        %% COPY TMP FILES
        TmpFileGlob=[MFilePath Sep 'tmp' Sep MFileName '*'];
        TmpFiles=dir(TmpFileGlob);
        DestTmpPath = [DestPath, 'tmp', Sep];
        LocalTmpPath = [MFilePath, Sep, 'tmp', Sep];
        if VERBOSE fprintf(['Copying Tmp-Files [ ',escapeMasker(LocalTmpPath),' => ',escapeMasker(DestTmpPath),' ] \n']); end
        for fileidx=1:length(TmpFiles),
          TmpFile=[LocalTmpPath TmpFiles(fileidx).name];
          copyfile(TmpFile,DestTmpPath);
        end
        
        DestRawPath =[DestPath 'raw' Sep];
        DestRawPathTrue=DestRawPath;
        %% COPY FILES IN RAW DIRECTORY
        if ~isempty(findstr('Yes',globalparams.Physiology))
          if ~exist(DestRawPath,'dir') mkdir(DestRawPath); end
          
          LocalRawPath=[MFilePath Sep 'raw' Sep];
          % EXTRACT IDENTIFIER (up to Recording) FROM MFILE NAME
          tmp=strsep(MFileName,'_'); Identifier=tmp{1};
          RawLocalGlob = [LocalRawPath,Identifier,'*'];
          
          RawFiles=dir(RawLocalGlob);
          if ~isempty(RawFiles)
            if RawFiles(1).isdir % EVP5 FORMAT
              for fileidx=1:length(RawFiles),
                % COMPRESS DIRECTORIES (EVP5 FORMAT)
                cRawFile = RawFiles(fileidx).name;
                if strcmp(lower(cRawFile),'tmp') continue; end % SKIP TMP DIRECTORY
                if VERBOSE fprintf(['Copying/Zipping Raw-Files [ ',escapeMasker([LocalRawPath,cRawFile]),' => ',escapeMasker(DestRawPath),' ] \n']); end
                localcompress([DestRawPath,cRawFile,'.tgz'],[LocalRawPath Sep cRawFile]);
                DestRawPathTrue=[DestRawPath,cRawFile,Sep];
              end
            else % ALPHA OMEGA BASED FORMAT
              if VERBOSE disp('Copying Raw Files'); end
              % COPY FILES DIRECTLY
              if VERBOSE,
                disp(['tar-zipping during copy to server: ',DestRawPath,MFileName,'.tgz']);
              end
              cd(LocalRawPath);
              tMFileName=['i' MFileName(2:end) '*'];  % ALPHAOMEGA FILES ("i" prefixed)
              AOFiles=dir(tMFileName);
              FileList={RawFiles.name AOFiles.name};
              tar([DestRawPath,MFileName,'.tgz'],FileList);
              DestRawPathTrue=DestRawPath;
            end
          else
            fprintf(['WARNING : Files not found for :',escapeMasker(RawLocalGlob),'\n']);
          end
        else
          DestRawPath=''; DestRawPathTrue='';
        end
        
        %% LAST: COPY MFILE
        % so that it won't try to update database without this happening.
        if VERBOSE fprintf(['Copying M-File [ ',escapeMasker(MFile),' => ',escapeMasker(DestPath),' ] \n']); end
        copyfile(MFile,DestPath);
      catch ME
        ErrorMessage = ['Error : ',strtrim(ME.message)];
        ErrorOccured = 1;
        if VERBOSE keyboard; end
      end
    else
      ErrorOccured = 1;
      ErrorMessage = ['Warning : m-File does not exist at ORIGIN (BAD or on other computer)'];
    end
  end
  
  %% UPDATE DB TO REFLECT DESTINATION AS NEW LOCATION
  if ~ErrorOccured
    if exist(MFileRemote,'file')
    
      [MFileRemoteName,MFileRemotePath]=basename(MFileRemote);
     EVPFileBase=basename(RecsDB(ii).respfileevp);
      if VERBOSE disp('Moving Location in CellDB'); end
      SQL=['UPDATE gDataRaw SET resppath="',MFileRemotePath,'",',...
        'parmfile="',MFileRemoteName,'",',...
        'respfile="',DestRawPathTrue,'",',...
        'respfileevp="',EVPFileBase,'"',...
        ' WHERE id=',num2str(RecsDB(ii).id)];
      mysql(SQL);
    else
      ErrorOccured = 1;
      ErrorMessage = ['Warning : m-File already exists at DESTINATION (Mark BAD!)'];
    end
  end
  
  % COLLECT ERROR MESSAGES
  if ErrorOccured Message = ErrorMessage; else Message = ' OK'; end
  FlushMessages{end+1} = LF_createFlushMessage(MFile,Message);
  
end % RECORDING LOOP

%% SEND AN EMAIL WITH WHAT HAS FLUSHED AND WHAT HASN'T
if ~isempty(NotificationEmail)
  WinVersion = evalc('! ver');
  Pos = strfind(WinVersion,'[Version ');
  WinVersion = str2num(WinVersion(Pos+9:Pos+11));
  if WinVersion >=6 % JAVA FRAME WORK FOR SENDING MAILS NOT AVAIL. BEFORE WIN7
    
    HF_sendEmail('To',NotificationEmail,...
        'Subject',['Flush Results from ',HF_getHostname],'Body',FlushMessages);
  end
end

fprintf('\n< FLUSH FINISHED >\n'); cd(OldPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FlushMessage = LF_createFlushMessage(ParmFile,Message)
FlushMessage = [Message,' : ',ParmFile];

function DBEntry = LF_evalScript(DBEntry)

switch lower(HF_getHostname)
  case 'deepthought';
    NetPath = 'D:/Data/';
    LocalPath = MD_getDir('Kind','archive','DB',0);
    LocalPath(LocalPath=='\') = '/';
    SQL = ['UPDATE gDataRaw SET ',...
      'resppath=replace(resppath,"',NetPath,'","',LocalPath,'"), ',...
      'respfile=replace(respfile,"',NetPath,'","',LocalPath,'") ',...
      'WHERE parmfile like "',DBEntry.cellid,'%" AND not(bad);'];
   R = mysql(SQL);
   DBEntry.resppath = strrep(DBEntry.resppath,NetPath,LocalPath);
   DBEntry.respfileevp = strrep(DBEntry.respfileevp,NetPath,LocalPath);
   if ~R error('Something went wrong while executing the SQL command.'); end
  otherwise
end