function check_map_registration(parmfile)

if exist(parmfile,'dir'),
   parmdir=[parmfile filesep];
   dd=dir([parmdir '*.m']);
   for ii=1:length(dd),
     check_map_registration([parmdir dd(ii).name]);
   end
   return
end
     
disp([mfilename ': checking ' parmfile '...']);
LoadMFile(parmfile);
trialcount=globalparams.rawfilecount;

[pp,bb]=fileparts(parmfile);
daqfpath=[pp filesep 'raw' filesep];
daqfname=bb;
daqextn='.map';
tmppath=[pp filesep 'tmp' filesep];
tmpextn='*.sig*.mat';
if exist([daqfpath daqfname sprintf('%03d',trialcount+1) daqextn],'file') && ...
        ~exist([daqfpath daqfname sprintf('%03d',trialcount+2) daqextn],'file'),
    disp([parmfile ': map file count mismatch!']);
    
    td=dir([tmppath bb tmpextn]);
    if ~isempty(td),
      disp(['deleting tmp cache files:']);
      for ii=1:length(td),
        disp([tmppath td(ii).name])
        delete([tmppath td(ii).name]);
      end
    end
    alpha2evp(parmfile,1);
end
