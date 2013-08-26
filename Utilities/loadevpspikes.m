% function [spikebin,trial,r]=loadevpspikes(mfile,channel,sigthreshold,trials)
%
% load evp and threshold to find candidate spike events.
% need to figure out how to deal with partially created cache files!
%
% created SVD 2006-07-14
%
function [spikebin,trial,r]=loadevpspikes(mfile,channel,sigthreshold,trials)

global C_r C_raw C_mfilename C_rasterfs C_sigthreshold

if ~exist('channel','var'),
    channel=1;
end
if ~exist('sigthreshold','var'),
    sigthreshold=4;
end

if ~strcmp(basename(C_mfilename),basename(mfile)),
    C_mfilename=mfile;
    C_rasterfs=0;
    C_sigthreshold=sigthreshold;
    C_raw={};
    C_r={};
end

[bb,pp]=basename(mfile);
LoadMFile(mfile);
if strcmpi(exptparams.runclass,'mts')              %add by PBY at July 26, 2007
    if length(tag_masks)>0 && length(tag_masks{1})>=16 && strcmp(tag_masks{1}(1:16),'SPECIAL-COLLAPSE') 
        exptevents=baphy_mts_evt_merge(exptevents,1);  %merge TORC and TS togather
    else
        exptevents=baphy_mts_evt_merge(exptevents);    %do not merge with TORC 
    end
end   %

evpfile = globalparams.evpfilename;
cachefile = [pp 'tmp' filesep basename(evpfile) '.cache.mat'];

if exist(cachefile),
    fprintf('loading cache file: %s\n',cachefile);
    % don't load monster r matrix if not necessary
    if nargout<3,
        load(cachefile,'rsig','trial','spikebin','mfile','timestamp','spikefs',...
            'spikechancount','trialcount');
    else
        load(cachefile);
    end
else
    if ~exist(evpfile,'file'),
        evpfile=[pp basename(evpfile)];
    end
    if ~exist(evpfile,'file'),
        error('evp file not found');
    end
    
    [spikechancount,auxchancount,trialcount,spikefs,auxfs]=...
        evpgetinfo(evpfile);
    
    % setup parameters for filtering the raw trace to extract spike times
    f1 = 310; f2 = 8000;
    f1 = f1/spikefs*2;
    f2 = f2/spikefs*2;
    [b,a] = ellip(4,.5,20,[f1 f2]);
    FilterParams = [b;a];
    
    % define output raster matrix
    spikebin=cell(spikechancount,1);
    trial=cell(spikechancount,1);
    r=cell(spikechancount,1);
    rsig=cell(spikechancount,1);
    
    % figure out the time that each trial started and stopped
    [starttimes,starttrials]=evtimes(exptevents,'TRIALSTART');
    [stoptimes,stoptrials]=evtimes(exptevents,'TRIALSTOP');
    [shockstart,shocktrials]=evtimes(exptevents,'BEHAVIOR,SHOCKON');
    xaxis=[-10 20];
    st=xaxis(1):xaxis(2);
    big_rs=[];
    for chanidx=1:spikechancount,
        for trialidx=1:trialcount,
            starttime=starttimes(find(starttrials==trialidx));
            stoptime=stoptimes(find(stoptrials==trialidx));
            expectedspikebins=(stoptime-starttime)*spikefs;

            % get the raw evp data for this trial
            if length(C_raw)>=trialcount & ~isempty(C_raw{trialidx}),
                % the raw evp has been cached
                rs=double(C_raw{trialidx}(:,chanidx));
            else
                rs=evpread(evpfile,chanidx,[],trialidx);
            end
            if length(rs)<expectedspikebins,
                warning(sprintf('Trial %d: length < expected!\n',trialidx));
                %rs((length(rs)+1):expectedspikebins)=0;
            end
            shockhappened=find(shocktrials==trialidx);
            if ~isempty(shockhappened) & length(rs)>ceil(shockstart(shockhappened(1)).*spikefs),
                fprintf('Trial %d: removing shock period\n',trialidx);
                rs=rs(1:ceil(shockstart(shockhappened(1))*spikefs));
            end

            % filter and threshold to identify spike times
            rs=rs(:);
            rs=filtfilt(FilterParams(1,:),FilterParams(2,:),-rs);

            sigmatch=zeros(size(rs));
            sigmin=2.5;

            trsig=rs./std(rs);
            tspikebin=find(trsig>sigmin);

            % remove events too close to beginning and end of vector
            tspikebin=tspikebin(find(tspikebin>-xaxis(1)));
            tspikebin=tspikebin(find(tspikebin<=length(rs)-xaxis(2)));

            trsig=trsig(tspikebin);
            
            tr=zeros(length(st),length(tspikebin));
            for jj=1:length(tspikebin),
                tr(:,jj)=rs(tspikebin(jj)+st);
            end
            
            if length(tspikebin)~=size(tr,2),
                warning('spikebin/r size mismatch!!!');
                keyboard
            end
            spikebin{chanidx}=cat(1,spikebin{chanidx},tspikebin,0);
            trial{chanidx}=cat(1,trial{chanidx},ones(length(tspikebin),1).*trialidx,0);
            r{chanidx}=cat(2,r{chanidx},tr,zeros(size(tr(:,1))));
            rsig{chanidx}=cat(1,rsig{chanidx},trsig,0);
        end
    end
    timestamp=datestr(now);
    fprintf('saving cache file: %s\n',cachefile);
    save(cachefile,'r','rsig','trial','spikebin','mfile','timestamp','spikefs',...
        'spikechancount','trialcount');

end

if ~exist('trials','var'),
    trials=1:trialcount;
end

useidx=find(ismember(trial{channel},[0;trials(:)]));

rsig=rsig{channel}(useidx);
spikebin=spikebin{channel}(useidx);
trial=trial{channel}(useidx);

rs=rsig>sigthreshold;

spikeidx=find(rs & (diff([0;rs])>0 | diff([0;spikebin]~=1)));

rsig=rsig(spikeidx);
spikebin=spikebin(spikeidx);
trial=trial(spikeidx);

if exist('r','var'),
    r=r{channel}(:,useidx);
    r=r(:,spikeidx);
end  


