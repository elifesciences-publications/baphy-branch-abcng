% function [r,tags,trialset,exptevents]=loadevpraster(mfile,options)
%
% inputs:
%  mfile - baphy parameter file name
%  options - struction can contain the following fields:
%   channel - electrode channel (default 1)
%   unit - unit number (default 1)
%   rasterfs in Hz (default 1000)
%   includeprestim - raster includes silent period before stimulus onset
%   tag_masks - cell array of strings to filter tags, eg,
%       {'torc','reference'} or {'target'}. AND logic. default ={}.
%       Some special values:
%       SPECIAL-TRIAL
%       SPECIAL-COLLAPSE-REFERENCE
%          -TARGET, -BOTH
%          -ORDER
%       SPECIAL-LICK
%   psthonly - shape of r (default -1, see below)
%   sorter - preferentially load spikes sorted by sorter.  if not
%            sorted by sorter, just take primary sorting
%   includeincorrect - if 1, load all trials, not just correct (default 0)
%
% load evp, identify spike events by thresholding derivative, extract
% responses relative to each Stim* event
% rasterfs - if 0, use defaults: 1000 for evp data, LFP sampling rate for LFP
% tag_masks - cell array of filters that must appear in tags to be included in output raster (eg, {'TORC'} will only return responses associated with torc events
% lfp - set to 1 to return LFP data instead of evp raster
%           (downsampled to rasterfs)
%         - if 2, load lick data (ignore channel)
% mua - set to 1 to return MUA (instantaneous energy) instead of evp raster
%
% 2007-10-04: changed SVD, altered syntax to allow for arbitary number of
%             options. old syntax still works:
% function [r,tags,trialset,exptevents]=loadevpraster
% 2006-01-13 : added caching to speed evp loading during online analysister(mfile,channel,rasterfs,sigthreshold,...
%                  includeprestim,tag_masks,lfp)s.
%
% created SVD 2005-12-01
%
function [r,tags,trialset,exptevents]=loadevpraster(mfile,channel,rasterfs,...
             sigthreshold,includeprestim,tag_masks,lfp,trialrange)

global C_r C_raw C_mfilename C_rasterfs C_sigthreshold

%
% SORT OF HORRIBLY COMPLICATED CODE FOR DEALING WITH TWO DIFFERENT
% WAYS OF PASSING PARAMETERS. SORRY! SVD 2008-01-01
%
if ~exist('channel','var'),
    options=[];
    options.channel=1;
    verbose = 1;
elseif isstruct(channel),
   options=channel;
   channel=getparm(options,'channel',1);
   sigthreshold=getparm(options,'sigthreshold',4);
   rasterfs=getparm(options,'rasterfs',1000);
   includeprestim=getparm(options,'includeprestim',1);
   tag_masks=getparm(options,'tag_masks',{});
   psthonly=getparm(options,'psthonly',-1);
   lfp=getparm(options,'lfp',0);
   mua=getparm(options,'mua',0);
   verbose=getparm(options,'verbose',1);
   trialrange=getparm(options,'trialrange',[]);
   includeincorrect=getparm(options,'includeincorrect',0);
   lfp_clean=getparm(options,'lfp_clean',0);
   rawtrace=getparm(options,'rawtrace',0);
else
   if ~exist('channel'),
      channel=1;
   end
   if ~exist('sigthreshold','var'),
      sigthreshold=4;
   end
   if ~exist('rasterfs','var'),
      rasterfs=1000;
   end
   if ~exist('includeprestim','var'),
      includeprestim=0;
   end
   if ~exist('tag_masks','var'),
      tag_masks={};
   elseif isnumeric(tag_masks),
      psthonly=tag_masks;
      tag_masks={};
   end
   if ~exist('psthonly','var'),
      psthonly=-1;
   end
   if ~exist('lfp','var'),
      lfp=0;
   end
   if ~exist('trialset','var'),
      trialset=[];
   end
   includeincorrect=0;
   lfp_clean=0;
   mua=0;
end
if ~exist('verbose','var') verbose = 1; end

if ~isempty(findstr(mfile,'spk.mat')),
    disp('converting spk.mat filename to m-filename');
    mfile=strrep(mfile,'.spk.mat','.m');
    mfile=strrep(mfile,'/sorted/','/');
end

%
% DONE SETTING/CHECKING PARAMETER VALUES
%

tic;  % start timing
if verbose 
  fprintf('loadevpraster: loading %s channel=%d auxflag=%d mua=%d\n',...
        basename(mfile),channel,lfp,mua);
end

LoadMFile(mfile);
if strcmpi(exptparams.runclass,'mts')              %add by PBY at July 26, 2007
    if ~isempty(tag_masks) && length(tag_masks{1})>=16 && strcmp(tag_masks{1}(1:16),'SPECIAL-COLLAPSE') 
        exptevents=baphy_mts_evt_merge(exptevents,1);  %merge TORC and TS togather
    else
        exptevents=baphy_mts_evt_merge(exptevents);    %do not merge with TORC 
    end
end
evpfile = globalparams.evpfilename;

if lfp==2,
   % load from tmp file if exists. much faster.
   [bb,pp]=basename(evpfile);
   tevpfile=[pp 'tmp' filesep bb];
   if exist(tevpfile,'file'),
      evpfile=tevpfile;
   end
end


[pp,bb,ee]=fileparts(evpfile);
bbpref=strsep(bb,'_');
bbpref=bbpref{1};
checkrawevp=[pp filesep 'raw' filesep bbpref filesep bb '.001.1' ee];
if exist(checkrawevp,'file'),
  evpfile=checkrawevp;
end
checktgzevp=[pp filesep 'raw' filesep bbpref '.tgz'];
if exist(checktgzevp,'file'),
  evpfile=checktgzevp;
  if lfp>0,
      evpfile=evpmakelocal(checktgzevp);
  end
end

if ~exist(evpfile,'file'),
    [bb,pp]=basename(mfile);
    evpfile=[pp basename(evpfile)];
end

if ~exist(evpfile,'file') && ~exist([evpfile '.gz'],'file'),
   [bb,pp]=basename(evpfile);
   tevpfile=[pp 'tmp/' bb];
   ss_stat=onseil;
   if lfp==2 && ss_stat,
      trin=[tevpfile ' ' tevpfile '.gz'];
      if ss_stat==1,
          disp('mapping file to seil');
          sublocalstring='/homes/svd/data/';
      elseif ss_stat==2,
          disp('mapping file to OHSU');
          sublocalstring='/auto/data/';
      end
      trout=strrep(tevpfile,'/auto/data/',sublocalstring);
      trout=strrep(trout,'/homes/svd/data/',sublocalstring);
      %trout=strrep(tevpfile,'/auto/data/','/homes/svd/data/');
      [bb,pp]=basename(trout);
      if strcmp(bb(1:5),'model'),
         disp('model cell, forcing recopy of response');
         ['\rm ' trout]
         unix(['\rm ' trout]);
      end
      if ~exist(trout,'file'),
         unix(['mkdir -p ',pp]);
         ['scp svd@bhangra.isr.umd.edu:',trin,' ',pp]
         unix(['scp svd@bhangra.isr.umd.edu:',trin,' ',pp]);
      end
      evpfile=trout
      if ~exist(evpfile,'file') && ~exist([evpfile '.gz'],'file'),
         error('evp file not found');
      end
   elseif (lfp==1 || mua==1) && onseil,
      disp('loadevpraster: lfp on seil: deferring evp check til later');
   else
      error('evp file not found');
   end
end

if lfp_clean,
   evpfile=lfpclean(evpfile,channel,lfp_clean,1);
   channel=1;
end

% check to see if loading same evp file as cached data
%C_mfilename
%mfile
if ~strcmp(basename(C_mfilename),basename(mfile)),
    C_mfilename=mfile;
    C_rasterfs=rasterfs;
    C_sigthreshold=sigthreshold;
    C_raw={};
    C_r={};
elseif size(C_r,2)>=channel & ~isempty(C_r{1,channel}) & C_sigthreshold==sigthreshold,
    disp('Using cached PSTH.');
elseif ~isempty(C_raw) & size(C_raw{1},2)>=channel,
    C_sigthreshold=sigthreshold;
    C_r={};
    disp('Using cached EVP.');
else
    C_mfilename=mfile;
    C_rasterfs=rasterfs;
    C_sigthreshold=sigthreshold;
    C_raw={};
    C_r={};
end

if verbose disp('loadevpraster: getting header info'); end
[spikechancount,auxchancount,trialcount,spikefs,auxfs,lfpchancount,lfpfs]=...
    evpgetinfo(evpfile);
evpv=evpversion(evpfile);
if evpv==5,
   lfpfs=1000;
end

if (~exist('rasterfs','var') | rasterfs==0) & lfp==1,
    rasterfs=floor(lfpfs);
    if evpv==5,
       rasterfs=1000;
    end
elseif (~exist('rasterfs','var') | rasterfs==0) & lfp==2,
    rasterfs=floor(auxfs);
elseif (~exist('rasterfs','var') | rasterfs==0),
    rasterfs=1000;
end

if (lfp==1 & lfpchancount<channel) | (~lfp & spikechancount<channel),
    disp('ERROR: channel does not exist');
    r=[];
    tags={};
    return
end

% filter disabled SVD 2006-08-03
% setup parameters for filtering the raw trace to extract spike times
%f1 = 310; f2 = 8000;
%f1 = f1/spikefs*2;
%f2 = f2/spikefs*2;
%[b,a] = ellip(4,.5,20,[f1 f2]);
%FilterParams = [b;a];

tcorr=0;
for tt=1:length(tag_masks),
   if strcmpi(tag_masks{tt},'SPECIAL-CORRECT'),
      if verbose disp('excluding shock trials'); end
      tcorr=tt;
   end
end
if tcorr,
   tag_masks={tag_masks{[1:(tcorr-1) (tcorr+1):end]}};
   exclude_error_trials=1;
else
   exclude_error_trials=0;
end

% figure out the tag for each different stimulus 
% 2013-08-07 -- SVD moved to separate function so that it can be
% shared with loadspikeraster.m
[eventtime,evtrials,Note,eventtimeoff,tags]= ...
    loadeventfinder(exptevents,tag_masks,includeprestim,...
                    exptparams.runclass,evpfile);

if verbose fprintf('%s tags sorted: %.1f sec\n',mfilename,toc); end

% define output raster matrix
referencecount=length(tags);
r=nan*zeros(1,1,referencecount);

repcounter=zeros(referencecount,1);
big_rs=[];

% figure out the time that each trial started and stopped
[starttimes,starttrials]=evtimes(exptevents,'TRIALSTART');
[ontimes,ontrials]=evtimes(exptevents,'STIM,ON');
[stoptimes,stoptrials]=evtimes(exptevents,'TRIALSTOP');
[shockstart,shocktrials,shocknotes,shockstop]=...
    findshockevents(exptevents,exptparams);
[hittime,hittrials]=evtimes(exptevents,'OUTCOME,MATCH');
if isempty(hittrials),
    [hittime,hittrials]=evtimes(exptevents,'BEHAVIOR,PUMPON*');
%    [hittime,hittrials]=evtimes(exptevents,'BEHAVIOR,PUMP*');
end
if trialcount<1 || ~globalparams.ExperimentComplete,
    trialcount=exptevents(end).Trial;
end
if ~exist('trialrange','var') || isempty(trialrange),
    if ~includeincorrect && ~isempty(hittrials),
        disp('including only correct trials.');
        trialrange=hittrials(:)';
    else
        trialrange=1:trialcount;
    end
else
    trialrange=trialrange(trialrange<=trialcount);
    trialrange=trialrange(:)';
end
if exclude_error_trials,
   trialrange=setdiff(trialrange,shocktrials);
end

trialset=[];
for trialidx=trialrange,
   starttime=starttimes(starttrials==trialidx);
   stoptime=stoptimes(stoptrials==trialidx);
   expectedspikebins=(stoptime-starttime)*spikefs;
   bb=basename(mfile);
   if (strcmp(bb(1:3),'lim') || strcmp(bb(1:3),'dnb') ||...
       strcmp(bb(1:3),'ama')) && ~isempty(ontimes) && ...
         ontimes(ontrials==trialidx)>starttime,
      disp('Shifting spike times by ontimes-starttimes');
      adjusttime=ontimes(trialidx)-starttimes(trialidx);
      evidxthistrial=find(evtrials==trialidx);
      eventtime(evidxthistrial)=eventtime(evidxthistrial)-adjusttime;
      eventtimeoff(evidxthistrial)=eventtimeoff(evidxthistrial)-adjusttime;
      
   else
      adjusttime=0;
   end
    
   if lfp==1,
      
        if isempty(big_rs),
            %[rs0,strialidx0,rs,atrialidx,big_rs,strialidx]=evpread(evpfile,[],[],trialidx:trialcount,channel);
            [big_rs,strialidx]=evplfp(evpfile,channel,trialidx:trialcount,options);
            strialidx=[zeros(trialidx-1,1); strialidx; length(big_rs)+1];
        end
        
        rs=(big_rs(strialidx(trialidx):(strialidx(trialidx+1)-1)));
        % resample, but don't scale--unlike spike counts, where the
        % resampled signal is muliplied by fsin/fsout
        raster=rs; % already resampled?? resample(rs,rasterfs.*100,lfpfs.*100);
        %keyboard
        
        if lfp==0, % lfp~=2,
           shockhappened=find(shocktrials==trialidx);
           for tt=1:length(shockhappened),
              shockidx=shockhappened(tt);
              if verbose
                fprintf('trial %d: zeroing shock %.1f-%.1f sec\n',...
                      trialidx,shockstart(shockidx),shockstop(shockidx)+0.3);
              end
              raster(round(shockstart(shockidx).*rasterfs):...
                     round((shockstop(shockidx)+0.3).*rasterfs))=0;
           end
        end
    elseif rawtrace==1,

        % read the raw data from the evp file
        if isempty(big_rs),
            [~,~,~,spikefs]=evpgetinfo(evpfile);
            [big_rs,strialidx]=evpread(evpfile,channel,[],trialidx:trialcount);
            strialidx=[zeros(trialidx-1,1); strialidx; length(big_rs)+1];
        end
        
        raster=resample(...
            double(big_rs(strialidx(trialidx):(strialidx(trialidx+1)-1))),...
            rasterfs,spikefs);
        
        shockhappened=find(shocktrials==trialidx);
        for tt=1:length(shockhappened),
            shockidx=shockhappened(tt);
            if verbose
            fprintf('trial %d: zeroing shock %.1f-%.1f sec\n',...
                    trialidx,shockstart(shockidx),shockstop(shockidx)+0.3);
            end
            raster(round(shockstart(shockidx).*rasterfs):...
                   round((shockstop(shockidx)+0.3).*rasterfs))=0;
        end
        
    elseif mua==1,

        if isempty(big_rs),
            %[rs0,strialidx0,rs,atrialidx,big_rs,strialidx]=evpread(evpfile,[],[],trialidx:trialcount,channel);
            [big_rs,strialidx]=evpmua(evpfile,channel,rasterfs,trialidx:trialcount);
            strialidx=[zeros(trialidx-1,1); strialidx; length(big_rs)+1];
        end
        
        raster=(big_rs(strialidx(trialidx):(strialidx(trialidx+1)-1)));
        
        shockhappened=find(shocktrials==trialidx);
        for tt=1:length(shockhappened),
            shockidx=shockhappened(tt);
            if verbose
            fprintf('trial %d: zeroing shock %.1f-%.1f sec\n',...
                    trialidx,shockstart(shockidx),shockstop(shockidx)+0.3);
            end
            raster(round(shockstart(shockidx).*rasterfs):...
                   round((shockstop(shockidx)+0.3).*rasterfs))=0;
        end
        
     elseif lfp>=2,
       channel=lfp-1;  % force lick
       if isempty(big_rs),
          [rs0,strialidx0,big_rs,atrialidx]=...
              evpread(evpfile,[],channel,trialidx:trialcount);
          atrialidx=[zeros(trialidx-1,1); atrialidx; length(big_rs)+1];
       end
       rs=(big_rs(atrialidx(trialidx):(atrialidx(trialidx+1)-1)));
       filtersize=round(auxfs./rasterfs);
       if filtersize<1,
           raster=resample(rs,rasterfs.*10,auxfs.*10).*auxfs./rasterfs;
       else
          smfilt=ones(filtersize,1)./filtersize;
          raster=conv2(rs,smfilt,'same');
          raster=raster(round((auxfs./rasterfs./2):(auxfs./rasterfs):end));
       end
    elseif size(C_r,2)>=channel & size(C_r,1)>=trialcount & ...
           ~isempty(C_r{trialidx,1}),
        % the raster has been successfully cached. just use it.
        raster=C_r{trialidx,channel};
    elseif (globalparams.ExperimentComplete && length(trialrange)>5) || sigthreshold==0,
        
        % generate/use cachefile that already has spike events extracted from evp
        % for this channel/sigthreshold
        if isempty(big_rs),
            if globalparams.HWSetup==3 || globalparams.HWSetup==11,
                %for SPR2: use 1.0 shockNaNwindow addby py@6/25/2013
                cachefile=cacheevpspikes(evpfile,channel,sigthreshold,0,0,1.0);
            else
                cachefile=cacheevpspikes(evpfile,channel,sigthreshold);
            end
            big_rs=load(cachefile);
            
            if verbose 
                fprintf('%s big_rs loaded: %.1f sec\n',mfilename,toc);
            end
        end
        
        thistrialidx=find(big_rs.trialid==trialidx);
        spikeevents=big_rs.spikebin(thistrialidx);
        
        hithappened=find(hittrials==trialidx);
        if 0 && ~isempty(hittime),
            disp('Removing reward period');
            spikeevents=spikeevents(hittime(hithappened(1))*spikefs);
        end
        
        if isempty(spikeevents),
            raster=zeros(size(0:spikefs/rasterfs:(expectedspikebins+spikefs/rasterfs)));
        else
            raster=histc(spikeevents,0:spikefs/rasterfs:(expectedspikebins+spikefs/rasterfs));
        end
        
        if lfp~=2,
           shockhappened=find(shocktrials==trialidx);
           for tt=1:length(shockhappened),
              shockidx=shockhappened(tt);
              if verbose
              fprintf('trial %d: nan-ing shock %.1f-%.1f sec\n',...
                      trialidx,shockstart(shockidx),shockstop(shockidx)+0.3);
              end
              raster(round(shockstart(shockidx).*rasterfs):...
                     round((shockstop(shockidx)+0.3).*rasterfs))=nan;
           end
        end
        C_r{trialidx,channel}=raster;
    else
        % need to regenerate the raster. maybe used the cached raw evp?
        
        if length(C_raw)>=trialcount & ~isempty(C_raw{trialidx}),
            % the raw evp has been cached
            rs=double(C_raw{trialidx}(:,channel));
            
        elseif 0,
            % just load the damn evp data one trial at a time from disk this
            % is very slow
            rs=evpread(evpfile,channel,[],trialidx);
            
        else
            % experimental: load entire evp at once to speed things up.
            % unfortunately it doesn't speed things up that much.
            if isempty(big_rs),
                [big_rs,strialidx]=evpread(evpfile,channel,[], ...
                                           trialidx:trialcount);
                %[big_rs,strialidx]=loadmapdata(evpfile,channel,[],trialidx:trialcount);
                strialidx=[zeros(trialidx-1,1); strialidx; length(big_rs)+1];
                
                if verbose fprintf('%s big_rs loaded: %d trials, %.1f sec\n',mfilename,length(strialidx)-1,toc); end
            end
            
            rs=big_rs(strialidx(trialidx):(strialidx(trialidx+1)-1));
        end
        if length(rs)<expectedspikebins,
            warning('length(rs)<expectedspikebins! padding tail with zeros.');
            rs((length(rs)+1):expectedspikebins)=0;
        end
        shockhappened=find(shocktrials==trialidx);
        if ~isempty(shockhappened) && length(rs)>ceil(shockstart(shockhappened(1)).*spikefs),
            disp('Removing shock period');
            %rs=rs(1:ceil(shockstart(shockhappened(1))*spikefs));
            winstart=ceil(shockstart(shockhappened(1))*spikefs);
            winstop=min(ceil((shockstop(shockhappened(1))+0.5)*spikefs),length(rs));
            rs(winstart:winstop)=nan;
        end
        hithappened=find(hittrials==trialidx);
        if 0 & ~isempty(hittime) & length(rs)>ceil(hittime(hithappened(1)).*spikefs),
            disp('Removing reward period');
            rs=rs(1:ceil(hittime(hithappened(1))*spikefs));
        end
        %if length(rs)./spikefs>stoptime,
        %    rs=rs(1:ceil(stoptime*spikefs));
        %end
        
        % filter and threshold to identify spike times
        rs=-rs(:);
        % disabling the filter:
%         rs=filtfilt(FilterParams(1,:),FilterParams(2,:),rs);
%         rs = rs - mean(rs);
        rs=[0;diff(rs>(sigthreshold*nanstd(rs)))>0];
        
        % bin the data
        spikeevents=find(rs);
        
        if isempty(spikeevents),
            raster=zeros(size(0:spikefs/rasterfs:(length(rs)+spikefs/rasterfs)));
        else
            raster=histc(spikeevents,0:spikefs/rasterfs:(length(rs)+spikefs/rasterfs));
        end
        C_r{trialidx,channel}=raster;
    end
    
    % figure out the start and stop time of each event during the trial
    % and place the corresponding spikes in the raster.
    
    evidxthistrial=find(evtrials==trialidx);
    for evidx=evidxthistrial(:)',
        % figure out which event slot this is
        refidx=find(strcmp(tags,Note{evidx}));
        
        % if it doesn't match one of the expected tags then skip it (eg, a
        % target when we only want references)
        if ~isempty(refidx),
            repidx=min(find(sum(~isnan(r(:,:,refidx)))==0));
            if isempty(repidx),
                repidx=size(r,2)+1;
            end
            rlen=(eventtimeoff(evidx)-eventtime(evidx))*rasterfs;
            % make sure the raster matrix is big enough for the next event
            if size(r,1)<rlen || repidx>size(r,2) || refidx>size(r,3),
                r((size(r,1)+1):round(rlen),:,:)=nan;
                r(:,(size(r,2)+1):repidx,:)=nan;
            end
            %if ~isempty(findstr(Note{evidx},'TORC')),
            %    disp([num2str(trialidx) '  ' num2str(refidx) '  ' Note{evidx}]);
            %end
            if length(raster)>=round(eventtimeoff(evidx)*rasterfs),
                % actually put the responses in the output raster matrix
                if round(eventtime(evidx)*rasterfs+1)<1,
                    r(1:(-round(eventtime(evidx)*rasterfs)),repidx,refidx)=-1;
                    r((-round(eventtime(evidx)*rasterfs)+1):(round(eventtimeoff(evidx)*rasterfs)-round(eventtime(evidx)*rasterfs)),repidx,refidx)=...
                        raster(1:round(eventtimeoff(evidx)*rasterfs));
                else
                    r(1:(round(eventtimeoff(evidx)*rasterfs)-round(eventtime(evidx)*rasterfs)),repidx,refidx)=...
                        raster(round(eventtime(evidx)*rasterfs+1):round(eventtimeoff(evidx)*rasterfs));
                end
            elseif round(eventtime(evidx)*rasterfs)>0
               rl=length(raster)-round(eventtime(evidx)*rasterfs+1)+1;
               r(1:rl,repidx,refidx)=raster(round(eventtime(evidx)*rasterfs+1):end);
            else
               rl=length(raster);
               r(-round(eventtime(evidx)*rasterfs)+(1:rl),repidx,refidx)=raster;
            end
            trialset(repidx,refidx)=trialidx;
        end
    end
    if mod(trialidx,20)==0,
        %drawnow;
        if verbose
        fprintf('%s trial %d: %.1f sec\n',mfilename,trialidx,toc);
        end
    end
end

if ~lfp,
   r(r==-1)=nan;
end

StimTagNames=exptparams.TrialObject.ReferenceHandle.Names;
extraidx=length(StimTagNames);
if (isempty(tag_masks) || length(tag_masks{1})<8 || ...
    ~strcmp(tag_masks{1}(1:8),'SPECIAL-')) && ...
       (isempty(tag_masks) || length(tag_masks{1})<6 || ...
        ~strcmpi(tag_masks{1}((end-5):end),'TARGET')) && ...
       (isempty(tag_masks) || length(tag_masks{1})<4 || ...
        ~strcmpi(tag_masks{1}((end-3):end),'TARG')) && ...
       isempty(strfind(mfile,'_FTC')) && ...
       isempty(strfind(mfile,'_CCH')) && ...
       isempty(strfind(mfile,'_MTS')) && ...
       isempty(strfind(mfile,'_ALM')) && ...
       isempty(strfind(mfile,'_PHD')),
%       isempty(strfind(mfile,'_AMN')) && ...
   maptoidx=zeros(1,length(tags));
   for ii=1:length(tags),
      tt=strsep(tags{ii},',',1);
      %if ~isempty(strfind(mfile,'_RHY')),
      %    tt=strsep(strtrim(tt{2}),' ');
      %    tt=tt{end};
      %else
      if isnumeric(tt{2}),
          tt=num2str(tt{2});
      else
          tt=strtrim(tt{2});
      end
      
      matchidx=find(strcmp(tt,StimTagNames));
      if isempty(matchidx),
          matchidx=strmatch(tt,StimTagNames);
      end
      if isempty(matchidx) && ~isempty(strfind(mfile,'_SPT')),
         tt2=strrep(tt,'SPORC','TORC');
         matchidx=strmatch(tt2,StimTagNames);
      end
      
      if length(matchidx)==1,
         maptoidx(ii)=matchidx;
      else
         extraidx=extraidx+1;
         maptoidx(ii)=extraidx;
         %disp('loadspikeraster.m: stimtagnames/tags mismatch! tacking on end');
      end
   end
   
   if length(maptoidx)>max(maptoidx),
      % multiple tags map to a single one.
      repcount=squeeze(sum(sum(~isnan(r))>0,2));
      maxreps=zeros(max(maptoidx),1);
      for ii=1:max(maptoidx),
         ff=find(maptoidx==ii);
         maxreps(ii)=sum(repcount(ff));
      end
      maxreps=max(maxreps);
      newr=ones(size(r,1),maxreps,max(maptoidx)).*nan;
      newtags=cell(1,max(maptoidx));
      for ii=1:max(maptoidx),
         ff=find(maptoidx==ii);
         newtags{ii}=tags{ff(1)};
         
         tr=r(:,:,ff);
         tr=tr(:,:);
         ff=find(sum(~isnan(tr))>0);
         tr=tr(:,ff);
         newr(:,1:size(tr,2),ii)=tr;
      end
      r=newr;
      tags=newtags;
      
   else
      [ttt,mapidx]=sort(maptoidx);
      
      r=r(:,:,mapidx);
      % why was this next line commented out????? very confusing! and incorrect.
      % You have to sort the tags to match the order of stimuli in the raster!
      tags={tags{mapidx}};  
      trialset=trialset(:,mapidx);
   end
end

if psthonly==-1,
   % do nothing?
   
elseif psthonly,
   % time/record all in one long vector, averaged over reps
   r=nanmean(permute(r,[2 1 3]));
   r=r(:);
else
   % time/record X rep
   r=permute(r,[1 3 2]);
   r=reshape(r,size(r,1)*size(r,2),size(r,3));
end

return


% code for generating example stimulus waveform:
Ref=Torc;
Ref=set(Ref,'PreStimSilence',ifstr2num(exptparams.RefTarObject.ReferenceHandle.PreStimSilence));
Ref=set(Ref,'PosStimSilence',ifstr2num(exptparams.RefTarObject.ReferenceHandle.PosStimSilence));
Ref=set(Ref,'Duration',ifstr2num(exptparams.RefTarObject.ReferenceHandle.Duration));
Ref=set(Ref,'FrequencyRange',(exptparams.RefTarObject.ReferenceHandle.FrequencyRange));
Ref=set(Ref,'Rates',(exptparams.RefTarObject.ReferenceHandle.Rates));
Ref=ObjUpdate(Ref);
[w,stimfs]=waveform(Ref,10);
w=[zeros(stimfs*get(Ref,'PreStimSilence'),1);
    w;
    zeros(stimfs*get(Ref,'PosStimSilence'),1)];
wresamp=resample(w,spikefs,stimfs);


