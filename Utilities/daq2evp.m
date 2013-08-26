% function trialcount=daq2evp(parmfile,rawpath,force_regen)
function trialcount=daq2evp(parmfile,rawpath,forceregen)
% 
% This function transfers raw spike data from daq files to evp
% files.
%

if nargin<2
    error('Syntax: daq2evp(parmfile,rawpath)');
end;
if ~exist('forceregen','var'),
    forceregen=0;
end
fname=basename(parmfile);

load([parmfile '.res.mat']);
Count = length(TrialState);
clear TrialState;

load([parmfile '.par.mat']);

f1 = 310;
f2 = 8000;
fprintf('Bandpass filtering raw signal: rate=%d  f1=%.0f  f2=%.0f...\n',rate,f1,f2)
f1 = f1/FS.AI*2;
f2 = f2/FS.AI*2;
[b,a] = ellip(4,.5,20,[f1 f2]);


for i = 1:Count
    disp(['Analysing file #: ' num2str(i)]);
    if i==1
        daqfname = [rawpath filesep fname '.daq.tmp'];
    else
        daqfname = [rawpath filesep fname '.daq0' num2str(i-1) '.tmp'];
    end
    touchdata = daqread(daqfname,'Channels',{'Touch'});
    evpdata = daqread(daqfname,'Channels',{'Spike'},'DataFormat','native');
    evpdata = double(evpdata);
    evpdata = filtfilt(b,a,evpdata);
    
    keyboard
    
end;






LoadMFile(mfile); % load globalparams, exptparams, and events

ferret = globalparams.Ferret;
mode   = globalparams.Physiology;
electrodes = globalparams.NumberOfElectrodes;
chan=electrodes;

[mfilepath,fname,mext]  = fileparts(globalparams.mfilename);
savefname = fname;
trialdir=mfilepath;

numchannel = chan;
channame={};
for i = 1:numchannel
    channame{i} = ['SPK',num2str(i)];
end;
lfpchanname={};
for i = 1:numchannel
    lfpchanname{i} = ['LFP',num2str(i)];
end;

if ~isfield(globalparams,'rawfilecount'),
    warning('assuming 1 map file per trial');
    globalparams.rawfilecount=max(cat(1,exptevents.Trial));
end
% daq is alpha omega files (map files)
daqfpath = [trialdir filesep 'raw' filesep];
daqfname = fname;
daqextn = '.map';
if ~exist([daqfpath daqfname '001' daqextn],'file'),
    % maybe its a old format, when we stored the .map files in tmp
    % directory:
    daqfpath = [trialdir filesep 'tmp' filesep];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% remove the following line's comment
FS.AI = globalparams.HWparams.fsAI;

% Record Order
%warning ('record order obsolete since saving evps in order acquired');
%ord   = [trialdir filesep fname '.tlst.mat'];

if globalparams.tempevpfile(1)=='\',
    globalparams.tempevpfile=['.' globalparams.tempevpfile];
end
if exist(globalparams.tempevpfile,'file'),
    [spikechancount,auxchancount,trialcount]=evpgetinfo(globalparams.tempevpfile);
elseif exist(globalparams.evpfilename),
    [spcount,auxcount,trialcount]=evpgetinfo(globalparams.evpfilename);
    return
else
    warning('temp evp not found.  no aux data available!');
    auxchancount=0;
end
if ~exist(globalparams.evpfilename,'file'),
    fprintf('Creating evp file %s...\n',basename(globalparams.evpfilename));
    oldtrialcount=0;
elseif forceregen
    disp('full evp regeneration forced');
    delete(globalparams.evpfilename);
    oldtrialcount=0;
else
    [oldspcount,oldauxcount,oldtrialcount]=evpgetinfo(globalparams.evpfilename);
    if (oldspcount~=length(channame)) | (oldauxcount~=auxchancount),
        warning('Channel count mismatch! Overwriting existing evp file.');
        delete(globalparams.evpfilename);
        oldtrialcount=0;
    elseif oldtrialcount==trialcount,
        fprintf('Evp file %s is already complete.\n',basename(globalparams.evpfilename));
        return
    else
        fprintf('Appending existing evp file %s...\n',basename(globalparams.evpfilename));
    end
end

% load lick/microphone data. don't cache!
if auxchancount>0
    C_ENABLE_CACHING=0;
    [rs,ridx,alllickdata,licktrialidx]=evpread(globalparams.tempevpfile,[],...
        1:auxchancount,(oldtrialcount+1):globalparams.rawfilecount);
    C_ENABLE_CACHING=1;
    licktrialidx=[licktrialidx;length(alllickdata)+1];
else
    licktrialidx=[];
end

% only reset cache if evp filename has changed
if ~strcmp(C_evpfilename,globalparams.evpfilename) | isempty(C_raw),
    C_mfilename=mfile;
    C_evpfilename=globalparams.evpfilename;
    C_raw={};
    C_r={};
    fprintf('%s: Creating evp cache for %s\n',mfilename,mfile);
end

trialcount=globalparams.rawfilecount;
for trialnum = (oldtrialcount+1):globalparams.rawfilecount,
    evpdaq=sprintf('%s%s%03d.map',daqfpath,daqfname,trialnum);
    
    if trialnum==oldtrialcount+1,
        try
            fileinfo = mapread(evpdaq,'datainfo',channame{1});
            spikesamplerate=fileinfo.SampleRate;
        catch
            disp('no spike data');
            spikesamplerate=1;
        end
        try
            lfileinfo = mapread(evpdaq,'datainfo',lfpchanname{1});
            lfpsamplerate=lfileinfo.SampleRate;
            lfpexists=1;
            %disp('found lfp data');
        catch
            disp('no lfp data');
            spikesamplerate=1;
            lfpexists=0;
            lfpsamplerate=0;
        end
    end
    
    % read whole file
    try,
        data = [mapread(evpdaq,'Channels',channame,'DataFormat','Native')];
        if ~iscell(data) data = {data};end
        for ii=1:length(data),
            if isempty(data{ii}) & ii<length(data),
                data{ii}=data{ii+1}.*0;
            elseif isempty(data{ii}),
                data{ii}=data{1}.*0;
            end
        end
    
        if lfpexists,
            ldata = [mapread(evpdaq,'Channels',lfpchanname,'DataFormat','Native')];
            if ~iscell(ldata) ldata = {ldata};end
            for ii=1:length(ldata),
                if isempty(ldata{ii}) & ii<length(ldata),
                    ldata{ii}=ldata{ii+1}.*0;
                elseif isempty(ldata{ii}),
                    ldata{ii}=ldata{1}.*0;
                end
            end
            lfpoutdata=cat(2,ldata{:});
        else
            lfpoutdata=[];
        end
        outdata=cat(2,data{:});
    catch
        warning('error on mapread! trial has no data!');
        outdata=zeros(1,numchannel);
        lfpoutdata=zeros(1,numchannel);
    end
    
    C_raw{trialnum}=outdata;
    C_lfp{trialnum}=lfpoutdata;
    % nima modified the following line, because the index was out of bound:
    if auxchancount>0,
        lickdata=alllickdata(licktrialidx(trialnum-oldtrialcount):(licktrialidx(trialnum-oldtrialcount+1)-1),:);
    else
        lickdata=[];
    end
    evpwrite(globalparams.evpfilename,outdata,lickdata,spikesamplerate,FS.AI,lfpoutdata,lfpsamplerate);
end
