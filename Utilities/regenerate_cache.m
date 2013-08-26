
dbopen;

sql=['SELECT * FROM gDataRaw WHERE cellid="por063a" and not(bad)'...
     ' ORDER BY id'];
datafiles=mysql(sql);

global USECOMMONREFERENCE
USECOMMONREFERENCE=1;

for ii=1:length(datafiles),
    tmppath=[datafiles(ii).resppath,'tmp',filesep];
    bname=strrep(datafiles(ii).respfileevp,'.evp','');
    
    dnames=dir([tmppath,bname,'.001.1.elec*.mat']);
    for jj=1:length(dnames),
        if isempty(findstr(dnames(jj).name,'sig0')),
            fprintf('deleting %s\n',dnames(jj).name);
            delete([tmppath dnames(jj).name]);
            
        end
    end
    LoadMFile([datafiles(ii).resppath,datafiles(ii).parmfile]);
    
    % unzip evp data locally
    [pp,bb,ee]=fileparts(globalparams.evpfilename);
    bbpref=strsep(bb,'_');
    bbpref=bbpref{1};
    checkrawevp=[pp filesep 'raw' filesep bbpref filesep bb '.001.1' ee];
    if exist(checkrawevp,'file'),
        evpfile=checkrawevp;
    end
    checktgzevp=[pp filesep 'raw' filesep bbpref '.tgz'];
    if exist(checktgzevp,'file'),
        evpfile=evpmakelocal(checktgzevp);
    end
    
    if ~exist(evpfile,'file'),
        [bb,pp]=basename(mfile);
        evpfile=[pp basename(evpfile)];
    end

    for jj=1:globalparams.NumberOfElectrodes,
        cachefile=cacheevpspikes(evpfile,jj,[-4 4 -3.8 3.8 -3.5 3.5]);
        for kk=1:length(cachefile),
            copyfile(cachefile{kk},tmppath);
        end
    end
end
