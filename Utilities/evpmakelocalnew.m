function [evplocal,mfilelocal]=evpmakelocal(filename)
% check for existence and copy to local disk (and unzip) if necessary
%
% Current strategy:
% - get a local or remote filename
% - check whether it is already local
% - make a copy if necessary
% 
% Conceptually it should rather be:
% - Get Identifier of a recording
% - Check locally whether data is present
% - If not make a local copy

global NET_DATA_ROOT NET_DATA_ROOT LOCAL_DATA_LIMIT MYSQL_BIN_PATH
LocalDir=LOCAL_DATA_ROOT;

% DETECT WHICH CONDITION WE ARE IN
[Path,Filename,Ext] = fileparts(filename);  copytoseil=0;
switch ispc % GENERATE FULL PATH
  case 1; if Path(2)~=':'; Path = [pwd,Path]; end
  case 0; if Path(1)~='/'; Path = [pwd,Path]; end
end

% CHECK WHETHER DATA IS LOCAL OR REMOTE
if ~isempty(strfind(Path,NET_DATA_ROOT)) Location = 'remote';
else Location =  'local'; end

switch Ext
  case 'tgz'; Condition = 'tarball'; % compressed tarball from MANTA
  case {'','evp'}; Ext = 'evp'; % add evp extension if empty
    if ~exist(filename,'file') && exist([filename,'.gz']),
      filename=[filename,'.gz']; % append ending if evp does not exist
      Condition = 'gzipped';
    elseif onseil && ~exist(filename,'file') % try alternate location on seil
      filename=strrep(filename,'/homes/svd/data/','/auto/data/');
      copytoseil=1; 
    end
  case 'gz'; Condition = 'gzipped'
  otherwise error('Fileending not recognized');
end

if ~exist(filename,'file') disp('evp file not found'); evplocal=[]; mfilelocal=[]; return; end

% WORK THROUGH CONDITIONS
switch Location
  case 'local'; % data is already local
    switch Ext
      case 'evp'; evplocal=filename;
      case 'gz';  gunzip(filename); evplocal = filename(1:end-3);
    end
    
  case 'remote' % data is remote and needs to be copied
    switch Condition
      case 'alphaomega' % ALPHA OMEGA DATA
        if strcmpi(filename(end-2:end),'.gz')
          zippedevp=1;
          evplocal=[NET_DATA_ROOT basename(filename(1:end-3))];
          tmfilein=strrep(filename,'.evp.gz','.m');
        else
          zippedevp=0;
          evplocal=[NET_DATA_ROOT basename(filename)];
          tmfilein=strrep(filename,'.evp','.m');
        end
        
        mfilelocal=strrep(evplocal,'.evp','.m');
        
        dd2=dir(filename);
        dd=dir(evplocal);
        
        if length(dd)>0, %  & dd(1).bytes==dd2(1).bytes,
          disp('evpmakelocal: local copy already exists');
        else
          dd=dir(NET_DATA_ROOT);
          while (onseil && length(dd)>8) || length(dd)>40,
            % delete oldest cached file to save disk space
            disp('evpmakelocal: cleaning out old cached evp files');
            dset=zeros(length(dd),1);
            for ii=1:length(dd),
              if ~strcmp(dd(ii).name,'.'),
                dset(ii)=datenum(dd(ii).date);
              else
                dset(ii)=datenum(now)+10000;
              end
            end
            temp1 = length(dd);
            % delete two most recent files, presumably evp and
            % corresponding parmfile (.m)
            
            [ssd,ssi]=sort(dset);
            delete([NET_DATA_ROOT dd(ssi(1)).name]);
            delete([NET_DATA_ROOT dd(ssi(2)).name]);
            
            dd=dir(NET_DATA_ROOT);
            temp2 = length(dd);
            if temp1==temp2,
              % if the program can not delete the file, one reason can be
              % its still open.
              fclose('all');
            end
          end
          if onseil
            
            disp('evpmakelocal: creating local copy of evp');
            disp(['scp svd@bhangra.isr.umd.edu:',filename,' ',evplocal]);
            [w,s]=unix(['scp svd@bhangra.isr.umd.edu:',filename,' ',evplocal]);
            
            disp(['scp svd@bhangra.isr.umd.edu:',tmfilein,' ',mfilelocal]);
            [w2,s2]=unix(['scp svd@bhangra.isr.umd.edu:',tmfilein,' ',mfilelocal]);
            if w,
              
              disp(['scp svd@bhangra.isr.umd.edu:',filename,'.gz ',...
                evplocal,'.gz']);
              [w,s]=unix(['scp svd@bhangra.isr.umd.edu:',filename,'.gz ',...
                evplocal,'.gz']);
              if ~w,
                unix(['gunzip -f ',evplocal,'.gz']);
              end
            end
          else
            w=copyfile(tmfilein,mfilelocal);
            if zippedevp,
              disp('evpmakelocal: unzipping evp to local copy');
              outfile=gunzip(filename,tempdir);
              if iscell(outfile),
                outfile=strrep(outfile{1},'/',filesep);
              end
              movefile(outfile,evplocal);
            else
              disp('evpmakelocal: creating local copy of evp');
              copyfile(filename,evplocal);
            end
          end
        end
        
      case 'tarball' % compressed MANTA archive
        % CREATE LOCAL DIRECTORY IF NECESSARY
        if ~strcmp(LOCAL_DATA_DIR,tempdir) % WITH HIRARCHY
          targetDir = strrep(Path,NET_DATA_DIR,LOCAL_DATA_DIR];
        else % WITHOUT HIRARCHY
          targetDir = [LOCAL_DATA_DIR,'evpread',filesep];
        end
        if exist(targetDir) && ~isempty(dir([targetDir,'']))
          
        else
          mkdirAll(targetDir);
          localdecompress([targetDir,targetDir);
          evplocal = fullfile([targetDir,filename]);
        
          dd=dir([LocalDir bb filesep '*.evp']);
          evplocal=[LocalDir bb filesep dd(1).name];
        end
    end
    
  otherwise error('Fileformat & Condition not recognized.');
end

