% function [rS,STrialIdx,rL,LTrialIdx]=loadmapdata(mfile,spikechans[=all],
%                                              lfpchans[=[]],trials[=all]);
%
% reads EVP V3 files
% rS: spike data
% STrialIdx: the index of the start of each trial in the spike data
% rL: LFP data
% LTrialIdx: the index of the start of each trial in the LFP data
%
% created SVD 2005-11-07
%
function [rs,strialidx,rl,ltrialidx]=loadmapdata(mfile,spikechans,lfpchans,trials);

global C_r C_raw C_lfp_raw C_mfilename C_ENABLE_CACHING

if isempty(C_ENABLE_CACHING),
    C_ENABLE_CACHING=1;
end

LoadMFile(mfile);

ferret = globalparams.Ferret;
mode   = globalparams.Physiology;
electrodes = globalparams.NumberOfElectrodes;
chan=electrodes;

if ~isfield(globalparams,'rawfilecount'),
    disp('assuming 1 map file per trial');
    globalparams.rawfilecount=max(cat(1,exptevents.Trial));
end

if ~exist('spikechans','var'),
   spikechans=1:chan;
end
if ~exist('lfpchans','var'),
   lfpchans=[];
end
if ~exist('trials','var'),
   trials=1:globalparams.rawfilecount;
end
if max(trials)>globalparams.rawfilecount,
    warning('trial specified that is outside range of existing map files');
    trials=trials(trials<=globalparams.rawfilecount);
end

[mfilepath,fname,mext]  = fileparts(globalparams.mfilename);
savefname = fname;

trialdir=mfilepath;

numchannel = chan;
schanname={};
lchanname={};
for i = 1:numchannel
    schanname{i} = ['SPK',num2str(i)];
    lchanname{i} = ['LFP',num2str(i)];
end;

% "daq" is alphaomega files (map files)
daqfpath = [trialdir filesep 'raw' filesep];
daqfname = fname;
daqextn = '.map';
if ~exist([daqfpath daqfname '001' daqextn],'file'),
    % maybe its a old format, when we stored the .map files in tmp
    % directory:
    daqfpath = [trialdir filesep 'tmp' filesep];
end

% only reset cache if evp filename has changed
if ~strcmp(C_mfilename,basename(mfile)) | isempty(C_raw),
    C_mfilename=mfile;
    C_evpfilename=globalparams.evpfilename;
    C_raw={};
    C_lpf_raw={};
    C_r={};
    fprintf('%s: Creating raw data cache for %s\n',mfilename,mfile);
end

% create output matrices
rs=[];
rl=[];
strialidx=[];
ltrialidx=[];

if C_ENABLE_CACHING & length(C_raw)>=max(trials) & ~isempty(C_raw{max(trials)}),
    
    fprintf('loading from cached MAP files\n');
    
    % ie, contents of evp file were already saved in C_raw
    for trialnum=trials(:)',
       strialidx=[strialidx; length(rs)+1];
       ltrialidx=[ltrialidx; length(rl)+1];
       
       rs=cat(1,rs,C_raw{trialnum}(:,spikechans));
       rl=cat(1,rl,C_lfp_raw{trialnum}(:,lfpchans));
    end
else
    for trialnum = trials,
        evpdaq=sprintf('%s%s%03d.map',daqfpath,daqfname,trialnum);
        fprintf('loading from %s\n',evpdaq);
        
        sdata=0;
        ldata=0;
        try
            fileinfo = mapread(evpdaq,'datainfo');
            spikesamplerate=fileinfo.SampleRate;
            
            % read whole file
            sdata = [mapread(evpdaq,'Channels',{schanname{:}},'DataFormat','Native')];
            ldata = [mapread(evpdaq,'Channels',{lchanname{:}},'DataFormat','Native')];
        catch 
            warning(sprintf('MAP file for trial %d is BAD!!!!!!!!!!!!!!!!!!!',trialnum));
        end
        
        if ~iscell(sdata) sdata = {sdata};end
        C_raw{trialnum}=cat(2,sdata{:});
        if ~iscell(ldata) ldata = {ldata};end
        C_lfp_raw{trialnum}=cat(2,ldata{:});
        
        strialidx=[strialidx; length(rs)+1];
        ltrialidx=[ltrialidx; length(rl)+1];
        
        rs=cat(1,rs,C_raw{trialnum}(:,spikechans));
        rl=cat(1,rl,C_lfp_raw{trialnum}(:,lfpchans));
    end
end

rs=double(rs);
rl=double(rl);

return

[fid,sError]=fopen(filename,'r','l');
if fid<0,
   error('cannot open file');
end

header=fread(fid,10,'uint32');
spikechancount=header(2);
auxchancount=header(3);
trialcount=header(6);

if header(1)~=EVPVERSION || sum(header(7:10))>0,
   error('invalid evp version');
end

if ~exist('spikechans','var'),
   spikechans=1:spikechancount;
end
if ~exist('auxchans','var'),
   auxchans=[];
end
if ~exist('trials','var'),
   trials=1:header(6);
end

if spikechancount<max(spikechans),
   error('invalid spike channel');
end
if auxchancount<max(auxchans),
   error('invalid aux channel');
end
if trialcount<max(trials),
   error('invalid trial range');
end

rs=[];
ra=[];
strialidx=[];
atrialidx=[];
if length(spikechans)==0;
    spikechansteps=spikechancount;
else
    spikechansteps=diff([0; spikechans(:); spikechancount+1])-1;
end
if length(auxchans)==0;
    auxchansteps=auxchancount;
else
    auxchansteps=diff([0; auxchans(:); auxchancount+1])-1;
end

% try to load from cache
if C_ENABLE_CACHING & ...
        (~strcmp(basename(C_evpfilename),basename(filename)) | ~exist('C_raw','var')),
    C_evpfilename=filename;
    C_mfilename=strrep(filename,'.evp','');
    C_raw={};
    C_r={};
    fprintf('%s: Creating evp cache for %s\n',mfilename,filename);
end

% try to load from map files... faster?
[pp,bb]=fileparts(filename);
mappath=[pp,filesep,'tmp',filesep];
if ENABLE_MAP_READ & length(auxchans)==0 & exist([mappath sprintf([bb '%.3d.map'],trials(1))],'file'),
    if trials(1)==1,
        disp('loading from MAPs');
    end
    for i = 1:spikechancount
        channame{i} = ['SPK',num2str(i)];
    end
    
    for trialnum=1:length(trials),
        trialnum=trials(trialnum);
        evpdaq=[mappath sprintf([bb '%.3d.map'],trialnum)];
        
        data = [mapread(evpdaq,'Channels',channame,'DataFormat','Native')];
        
        if ~iscell(data) data = {data};end
        if C_ENABLE_CACHING,
            C_raw{trialnum}=cat(2,data{:});
        end
        strialidx=[strialidx; length(rs)+1];
        rs=cat(1,rs,double(C_raw{trialnum}(:,spikechans)));
    end
    
elseif C_ENABLE_CACHING & length(auxchans)==0 & ...
        length(C_raw)>=max(trials) & ~isempty(C_raw{max(trials)}),
    
    % ie, contents of evp file were already saved in C_raw
    for trialnum=trials(:)',
       strialidx=[strialidx; length(rs)+1];
       atrialidx=[atrialidx; length(ra)+1];
       
       rs=cat(1,rs,C_raw{trialnum}(:,spikechans));
    end
    rs=double(rs);
else
    
    for trialnum=1:max(trials),
        drawnow;
        
        trhead=fread(fid,2,'uint32');
        ts=[];
        ta=[];
        if ismember(trialnum,trials),

            for ii=1:length(spikechans),
                if spikechansteps(ii)>0,
                    fseek(fid,trhead(1)*2*spikechansteps(ii),0);
                end
                ts=[ts fread(fid,trhead(1),'short')];
            end
            if spikechansteps(length(spikechans)+1)>0,
                fseek(fid,trhead(1)*2*spikechansteps(length(spikechans)+1),0);
            end
            for ii=1:length(auxchans),
                fseek(fid,trhead(1)*2*auxchansteps(ii),0);
                ta=[ta fread(fid,trhead(2),'short')];
            end
            fseek(fid,trhead(2)*2*auxchansteps(length(auxchans)+1),0);
            strialidx=[strialidx; length(rs)+1];
            atrialidx=[atrialidx; length(ra)+1];
            rs=cat(1,rs,ts);
            ra=cat(1,ra,ta);
        else
            % jump to start of next trial
            fseek(fid,(trhead(1)*spikechancount+trhead(2)*auxchancount)*2,0);
        end
    end
end

fclose(fid);
