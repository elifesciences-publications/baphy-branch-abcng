function [evplocal,mfilelocal]=evpmakelocal(filename)
% function [evplocal,mfilelocal]=evpmakelocal(filename)
%
% check for existence and copy to local disk (and unzip) if necessary

global BAPHYDATAROOT LOCAL_DATA_ROOT LOCAL_DATA_LIMIT
global MYSQL_BIN_PATH

savepwd=pwd; % remember current directory

if strcmpi(filename(end-3:end),'.tgz'),
  % don't append ".evp"
elseif ~strcmpi(filename(end-3:end),'.evp')
    filename = [filename '.evp'];
end
copytoseil=0;
if ~exist(filename,'file') && exist([filename,'.gz']),
   filename=[filename,'.gz'];
elseif onseil==1 && ~exist(filename,'file'),
   filename=strrep(filename,'/homes/svd/data/','/auto/data/')
   
   copytoseil=1;
   
elseif ~exist(filename,'file'),
   disp('evp file not found');  evplocal=[];    mfilelocal=[];
   return
end

% when requesting spike data for remote files, cache a local copy
LocalDir=strrep(fileparts(filename),BAPHYDATAROOT,LOCAL_DATA_ROOT);
if ~exist(LocalDir,'dir'),
   [localparent1,newparent1]=fileparts(LocalDir);
   if ~exist(localparent1,'dir'),
      [localparent2,newparent2]=fileparts(localparent1);
      if ~exist(localparent2,'dir'),
         [localparent3,newparent3]=fileparts(localparent2);
         mkdir(localparent3,newparent3);
      end
      mkdir(localparent2,newparent2);
   end
   mkdir(localparent1,newparent1);
end  
LocalDir=[LocalDir filesep];

if strcmp(filename((end-8):end),'001.1.evp'),
   %uncompressed MANTA.  Don't make local copy.  Just pass remote
   %evp and m-file name
   evplocal=filename;
   [pp,bb]=fileparts(filename);
   remotemfilepath=fileparts(fileparts(pp));
   dd=dir([remotemfilepath filesep strrep(bb,'.001.1','') '*.m']);
   if ~isempty(dd),
      mfilelocal=[remotemfilepath filesep dd(1).name];
    else
      error('remote m file not found');
   end
   
elseif strcmp(filename((end-3):end),'.tgz'),
   % compressed MANTA
   [pp,bb]=fileparts(filename);
   remotemfilepath=fileparts(pp);
   dd=dir([remotemfilepath filesep bb '*.m']);
   if ~isempty(dd),
      tmfilein=[remotemfilepath filesep dd(1).name];
      mpathlocal=[fileparts(fileparts(LocalDir)) filesep];
      mfilelocal=[mpathlocal dd(1).name];
      tevpfilein=strrep(tmfilein,'.m','.evp');
   else
      error('remove m file not found');
   end
   
   dd=dir([LocalDir bb filesep '*.evp']);
   if ~isempty(dd),
      evplocal=[LocalDir bb filesep dd(1).name];
   else
      disp('copying mfile to local data root');
      if exist([tevpfilein '.gz'],'file'),
         gunzip([tevpfilein '.gz'],mpathlocal);
      else
         w=copyfile(tevpfilein,mpathlocal);
      end
      w=copyfile(tmfilein,mfilelocal);
      % force update of timestamp on mfile. ridiculous, but it works.
      tfid=fopen(mfilelocal,'a');
      fprintf(tfid,'\n');
      fclose(tfid);
      
      disp('untarring local copy of tgz compressed MANTA-generated evp');
      cd(pp);
      
      if  strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64'),
         cmd=[MYSQL_BIN_PATH 'gzip -dck ' basename(filename) ' > ' ...
              LocalDir filesep bb '.tar'];
      else
         % removed "k" flag --what does it do in windows??
         cmd=[MYSQL_BIN_PATH 'gzip -dc ' basename(filename) ' > ' ...
              LocalDir filesep bb '.tar'];
      end
      [w,s]=unix(cmd);
      
      cd(LocalDir);
      cmd=[MYSQL_BIN_PATH 'tar -xf ' bb '.tar'];
      [w,s]=unix(cmd);
      [w,s]=unix(['chmod a+rx ',bb]);
      [w,s]=unix(['chmod u+w ',bb]);
      [w,s]=unix(['chmod a+r ',bb,filesep,'*']);
      [w,s]=unix(['chmod u+w ',bb,filesep,'*']);
      dd=dir([LocalDir bb filesep '*.evp']);
      evplocal=[LocalDir bb filesep dd(1).name];
      delete([bb '.tar']);
      cd(savepwd);
   end
elseif (strcmpi(filename(1:3),'m:\') || ...
        strcmpi(filename(1:10),'/auto/data') || ...
        strcmpi(filename(1:8),'/Volumes')),
   % Not MANTA. ie, alpha-omega system
   if strcmpi(filename(end-2:end),'.gz')
      zippedevp=1;
      evplocal=[LocalDir basename(filename(1:end-3))];
      tmfilein=strrep(filename,'.evp.gz','.m');
   else
      zippedevp=0;
      evplocal=[LocalDir basename(filename)];
      tmfilein=strrep(filename,'.evp','.m');
   end
   
   mfilelocal=strrep(evplocal,'.evp','.m')
   
   dd2=dir(filename);
   dd=dir(evplocal);
   
   if length(dd)>0, %  & dd(1).bytes==dd2(1).bytes,
      disp('evpmakelocal: local copy already exists');
   else
      dd=dir(LOCAL_DATA_ROOT);
      while (onseil==1 || strcmpi(LOCAL_DATA_ROOT,[tempdir 'evpread' filesep])) && length(dd)>8,
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
         if dd(ssi(1)).isdir     %pby added this switch because of dead loop problem @1/31/2013
             rmdir([LOCAL_DATA_ROOT dd(ssi(1)).name],'s'); else
             delete([LOCAL_DATA_ROOT dd(ssi(1)).name]); 
         end
         if dd(ssi(2)).isdir
             rmdir([LOCAL_DATA_ROOT dd(ssi(2)).name],'s'); else
             delete([LOCAL_DATA_ROOT dd(ssi(2)).name]); 
         end
         
         dd=dir(LOCAL_DATA_ROOT);
         temp2 = length(dd);
         if temp1==temp2, 
            % if the program can not delete the file, one reason can be
            % its still open.
            fclose('all');
         end
      end
      if onseil && ~exist(filename,'file'),
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
         % force update of timestamp on mfile. seems ridiculous,
         % but it works.
         tfid=fopen(mfilelocal,'a');
         fprintf(tfid,'\n');
         fclose(tfid);
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
elseif strcmp(filename((end-2):end),'.gz'),
   disp('gunzipping local evp file');
   gunzip(filename);
   evplocal=strrep(filename,'.gz','');
else
   evplocal=filename;
end
