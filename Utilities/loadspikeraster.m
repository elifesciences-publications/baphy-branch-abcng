function [r,tags,trialset,exptevents,sortextras]=...
  loadspikeraster(spkfile,channel,unit,rasterfs,includeprestim,tag_masks,psthonly,sorter)
% function [r,tags,trialset,exptevents,sortextras]=loadspikeraster(spkfile,options)
%
% load spike raster from sorted spike (.spk.mat) file
%
% inputs:
%  spkfile - name of .spk.mat file generated using meska
%
%  options - structure can contain the following fields:
%   channel - electrode channel (default 1)
%   unit - unit number (default 1)
%   rasterfs in Hz (default 1000)
%   includeprestim - raster includes silent period before stimulus onset
%   tag_masks - cell array of strings to filter tags, eg,
%             {'torc','reference'} or {'target'}.  AND logic.  default ={}
%   psthonly - shape of r (default -1, see below)
%   sorter - preferentially load spikes sorted by sorter.  if not
%            sorted by sorter, just take primary sorting
%   lfpclean - [0] if 1, remove MSE prediction of spikes (single
%              trial) predicted by LFP
%   includeincorrect - if 1, load all trials, not just correct (default 0)
%
% returns:
%   r is (psthonly==-1) time X nsweeps X nrec matrix
%        (psthonly==0) time*nrec X nsweeps X matrix
%        (psthonly==1) time*nrec X 1 vector, averaged nsweeps
%   tags (if baphy_fmt, the event name assocated with each rec)
%
% TO DO : check logic for choosing most recent primary sort!  Currently
%         just taking the first entry in the sorter list!!!
%
% old syntax (before 2007-10-03). still backward compatible:
% function [r,tags,trialset,exptevents]=loadspikeraster(spkfile,channel,unit,rasterfs,includeprestim,tag_masks,psthonly,sorter)
%    (options variable should now contain all the parameters)
%
% created SVD 2005-08-12
% modified SVD 2006-02-25  -- baphy_fmt support.  arbitrary trial length,
%                             use event tags for unwrapping into raster
% modified SVD 2006-08-11  -- added tag_mask event tag filter.
% modified SVD 2007-10-03  -- changed parameter input form.

trialset = [ ];
% the user has passed the mfilename, parse it here.
if iscell(spkfile)   mfile = spkfile{2}; spkfile = spkfile{1};
else                   mfile = []; end

%% PARSE PARAMETERS
if ~exist('channel','var')
   options=[]; options.channel=1; stimidx=[];
elseif isstruct(channel),
   options=channel;
   channel=getparm(options,'channel',1);
   unit=getparm(options,'unit',1);
   rasterfs=getparm(options,'rasterfs',1000);
   includeprestim=getparm(options,'includeprestim',0);
   if ~isfield(options,'tag_masks'),
      tag_masks={};
   elseif isnumeric(options.tag_masks),
      psthonly=options.tag_masks;
      tag_masks={};
   else
      tag_masks=options.tag_masks;
   end
   psthonly=getparm(options,'psthonly',-1);
   sorter=getparm(options,'sorter','');
   includeincorrect=getparm(options,'includeincorrect',0);
   mua=getparm(options,'mua',0);
   lfpclean=getparm(options,'lfpclean',0);
   stimidx=getparm(options,'stimidx',[]);
   spikeshape=getparm(options,'spikeshape',0);
else
   options=[];
   if ~exist('channel','var')              channel=1;    end
   if ~exist('unit','var')                    unit=1;         end
   if ~exist('rasterfs','var')              rasterfs=1000;  end
   if ~exist('includeprestim','var')    includeprestim=0;    end
   if ~exist('tag_masks','var')          tag_masks={}; 
   elseif isnumeric(tag_masks)        psthonly=tag_masks; tag_masks={}; end
   if ~exist('psthonly','var')             psthonly=-1;   end
   if ~exist('sorter','var')                 sorter='';    end
   if ~exist('spikeshape','var')         spikeshape = 0; end
   includeincorrect=0;  mua=0;  lfpclean=0; stimidx=[];
end

fprintf('%s: loading %s chan=%d unit=%d rasterfs=%d Hz\n',...
        mfilename,(spkfile),channel,unit,rasterfs);

% ADAPT FILENAME
if ~strcmp(spkfile(end-3:end),'.mat')   spkfile=[spkfile '.mat']; end
spkfile = LF_copyForSeil(spkfile);


%% LOAD SPIKEFILE
spikeinfop = load(spkfile);

%% SPECIAL CODE FOR MODEL CELLS
if isfield(spikeinfop,'sortextras') && length(spikeinfop.sortextras)>=channel,
   sortextras=spikeinfop.sortextras{channel};
else
   sortextras=[];
end
if psthonly==1 && isfield(spikeinfop,'sortextras') && ...
      isfield(spikeinfop.sortextras{1},'psth'),
   r=spikeinfop.sortextras{1}.psth;
   return
end

%% OLD FORMAT SPK FILE
if ~isfield(spikeinfop,'baphy_fmt') | ~spikeinfop.baphy_fmt
    if ~isempty(mfile)
        % if mfile is available, pass it on
        spkfile = {spkfile,mfile};
    end
    disp('running loadspikeraster_oldfmt');
    if length(includeprestim)==1,
       adjustps=includeprestim;
    else
       adjustps=0;
    end
    r=loadspikeraster_oldfmt(spkfile,channel,unit,rasterfs,[1 1]-adjustps,psthonly);
    tags={};
    if length(includeprestim)>1,
       r=cat(1,zeros(round(includeprestim(1).*rasterfs),size(r,2),size(r,3)),...
             r,...
             zeros(round(includeprestim(2).*rasterfs),size(r,2),size(r,3)));
    end
    trialset=[];
    exptevents=[];
    return
end

exptevents=spikeinfop.exptevents;
if strfind(lower(spikeinfop.fname),'mts')              %add by PBY at July 26, 2007
    if length(tag_masks)>0 && length(tag_masks{1})>=16 && strcmp(tag_masks{1}(1:16),'SPECIAL-COLLAPSE') 
        exptevents=baphy_mts_evt_merge(exptevents,1);  %merge TORC and TS togather
    else
        exptevents=baphy_mts_evt_merge(exptevents);    %do not merge with TORC 
    end
end   %

mf=rasterfs;          % output samples per sec
mfOld=spikeinfop.rate;  % input samples per sec
spikefs=spikeinfop.rate;

if isempty(spikeinfop.sortinfo{channel}),
    warning([mfilename,': channel>channels!']);
    r=[];
    tags={};
    return
end
if isempty(sorter),
   sortidx=1;
else
   ii=1;
   sortidx=1;
   for ii=length(spikeinfop.sortinfo{channel}):-1:1,
      if strcmpi(sorter,spikeinfop.sortinfo{channel}{ii}(1).sorter)
         sortidx=ii;
      end
   end
   fprintf('sortidx=%d, sorter=%s\n',...
           sortidx,spikeinfop.sortinfo{channel}{sortidx}(1).sorter);
end
units=spikeinfop.sortinfo{channel}{sortidx}(1).Ncl;

if unit>units,
    warning([mfilename,': unit>units!']);
    r=[ ];
    tags={};
    return
end

%% GET SPIKE TIMES
if mua==1,
   disp('loading all threshold events');
   
   rawSpikes=[];
   tt=spikeinfop.sortextras{channel}.spiketimes;
   ts=[spikeinfop.sortextras{channel}.trialstartidx; max(tt)+1];
   
   for trialidx=1:(length(ts)-1),
      ttt=tt(find(tt>=ts(trialidx) & tt<ts(trialidx+1)))-ts(trialidx)+1;
      rawSpikes=cat(2,rawSpikes,[ones(1,length(ttt)).*trialidx;ttt']);
   end
elseif mua==2,
   disp('loading all sorted spikes');
   rawSpikes=[];
   for uu=1:length(spikeinfop.sortinfo{channel}{sortidx}),
      rawSpikes=cat(2,rawSpikes,...
                    spikeinfop.sortinfo{channel}{sortidx}(uu).unitSpikes);
   end
else
   rawSpikes = ...
       spikeinfop.sortinfo{channel}{sortidx}(unit).unitSpikes;
end

%% GET SPIKE SHAPES
if spikeshape 
  SpikeShape = spikeinfop.sortinfo{channel}{sortidx}(unit).Template(:,unit);
  sortextras.SpikeShape = SpikeShape;
end
  
cellid=basename(spkfile);
if strcmp(cellid(1:3),'c02') || strcmp(cellid(1:3),'c03') || ...
      strcmpi(cellid(1),'J') ||...
      (strcmpi(cellid(1),'o') && ~strcmp(cellid(1:3),'oni')),
   disp('old file: shifting responses forward 15 ms');
   rawSpikes(2,:)=rawSpikes(2,:)+mfOld.*0.015;
   rawSpikes=rawSpikes(:,find(rawSpikes(2,:)>0));
end

% guess evpfile name in case we want to load licks
[evpb,evpp]=basename(spikeinfop.fname);
ff=findstr(evpp,spkfile);
if ~isempty(ff),
    evpfile=[spkfile(1:(ff-1)),spikeinfop.fname];
else
    evpfile='';
end

%figure out run class
rc=strsep(basename(spkfile),'.',1);
rc=strsep(rc{1},'_');
runclass=rc{end};


% figure out the tag for each different stimulus 
% 2013-08-07 -- SVD moved to separate function so that it can be
% shared with loadspikeraster.m
[eventtime,evtrials,Note,eventtimeoff,tags]= ...
    loadeventfinder(exptevents,tag_masks,includeprestim,...
                    runclass,evpfile);

% $$$ % figure out the tag for each different stimulus
% $$$ if length(tag_masks)>0 & length(tag_masks{1})>=12 & strcmp(tag_masks{1}(1:12),'SPECIAL-LICK'),
% $$$     disp('SPECIAL TAGS: Loading lick data...');
% $$$     
% $$$     [spikechancount,auxchancount,trialcount,spikefs,auxfs,lfpchancount,lfpfs]=...
% $$$         evpgetinfo(evpfile);
% $$$     [dummy1,dummy2,lickdata,atrialidx]=evpread(evpfile,[],1);
% $$$     atrialidx=cat(1,atrialidx,length(lickdata)+1);
% $$$     
% $$$     licktotalcount=length(find(diff(lickdata)));
% $$$     if licktotalcount>500,
% $$$         disp('only using 500 licks');
% $$$     end
% $$$     
% $$$     eventtime=[];
% $$$     evtrials=[];
% $$$     eventtimeoff=[];
% $$$     for trialidx=1:trialcount,
% $$$         lrange=atrialidx(trialidx):(atrialidx(trialidx+1)-1);
% $$$         licktime=find(diff(lickdata(lrange)))./auxfs;
% $$$         
% $$$         % remove licks too close to start of trial
% $$$         licktime=licktime(find(licktime>0.4));
% $$$         
% $$$         % only use last lick from each trial if requested
% $$$         if strcmp(tag_masks{1},'SPECIAL-LICK-LAST') & length(licktime)>0,
% $$$             licktime=licktime(end);
% $$$         elseif strcmp(tag_masks{1},'SPECIAL-LICK-FIRST') & length(licktime)>0,
% $$$             licktime=licktime(1);
% $$$         elseif length(licktime)>1 & licktotalcount>500,
% $$$             keepidx=round(linspace(1,length(licktime),...
% $$$                 round(500./licktotalcount.*length(licktime))));
% $$$             licktime=licktime(keepidx);
% $$$         end
% $$$         eventtime=cat(1,eventtime,licktime-0.4);
% $$$         eventtimeoff=cat(1,eventtimeoff,licktime+0.4);
% $$$         evtrials=cat(1,evtrials,ones(size(licktime)).*trialidx);
% $$$     end
% $$$     if strcmp(tag_masks{1},'SPECIAL-LICK-LAST') & length(licktime)>0,
% $$$         tags={'LASTLICK,LASTLICK'};
% $$$     else
% $$$         tags={'LICK,LICK'};
% $$$     end
% $$$     Note=cell(length(eventtime),1);
% $$$     for ii=1:length(eventtime),
% $$$         Note{ii}=tags{1};
% $$$     end
% $$$ elseif length(tag_masks)>0 & strcmp(tag_masks{1},'SPECIAL-TRIAL'),
% $$$     disp('SPECIAL TAGS: Loading trial by trial...');
% $$$     
% $$$     [eventtime,evtrials,Note]=evtimes(exptevents,['TRIALSTART']);
% $$$     [eventtimeoff,evtrials]=evtimes(exptevents,['TRIALSTOP']);
% $$$     tags={Note{1}};
% $$$ elseif length(tag_masks)>0 & length(tag_masks{1})>=16 & ...
% $$$        strcmp(tag_masks{1}(1:16),'SPECIAL-COLLAPSE'),
% $$$     disp('SPECIAL TAGS: Collapsing over references and/or targets...');
% $$$     
% $$$     % find all events that match masks
% $$$     if isempty(strfind(spkfile,'SWC'))
% $$$         tm=strsep(tag_masks{1},'-',1);
% $$$         split_incorrect=0;
% $$$         switch tm{3},
% $$$             case 'REFERENCE',
% $$$                 tags={'Reference,Reference'};
% $$$             case 'TARGET',
% $$$                 tags={'Target,Target'};
% $$$             case 'ORDER',
% $$$                 tags={'Ref1,Ref1','RefN,RefN','Target,Target'};
% $$$             case 'SPLIT',
% $$$                 tags={'Reference,Reference','Hit,Hit','Miss,Miss'};
% $$$                 split_incorrect=1;
% $$$             otherwise
% $$$                 tags={'Reference,Reference','Target,Target'};
% $$$         end
% $$$     else
% $$$         tm=strsep(tag_masks{1},'-',1);
% $$$         split_incorrect=0;
% $$$         tags={'Reference,Reference','Target,Target','Distractor,Distractor'};
% $$$         
% $$$     end
% $$$     
% $$$     
% $$$     % use fixed Pre- and PostStimSilence
% $$$     if sum(includeprestim)==1 && length(includeprestim)==1,
% $$$        [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PreStim*'],1);
% $$$        if length(eventtime)>0,
% $$$           PreStimSilence=eventtimeoff(1)-eventtime(1);
% $$$           if PreStimSilence==0,
% $$$              PreStimSilence=0.1;  % force something non-zero
% $$$           end
% $$$           [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PostStim*'],1);
% $$$           PostStimSilence=eventtimeoff(end)-eventtime(end);
% $$$        else
% $$$           PreStimSilence=0.1;
% $$$           PostStimSilence=0.1;
% $$$        end
% $$$        includeprestim=[PreStimSilence PostStimSilence];
% $$$     end
% $$$     
% $$$     % figure out when each event to be rastered started and stopped
% $$$     [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['Stim*']);
% $$$     if sum(includeprestim)>0 & length(includeprestim)>1,
% $$$         eventtime=eventtime-includeprestim(1);        % ie, minus PreStimSilence
% $$$         eventtimeoff=eventtimeoff+includeprestim(2); % ie, plus PostStimSilence
% $$$     end
% $$$     
% $$$     % check for discrim arrangement, ie, if every other post-stim
% $$$     % silence is zero
% $$$     if ~isempty(strfind(spkfile,'DIS')) || ~isempty(strfind(spkfile,'CLK'))
% $$$         [xx2,gg,hh,yy2]=evtimes(exptevents,['PostStim*']);
% $$$         dd=yy2-xx2;
% $$$         if (sum(dd(1:2:end)>0)==0 & sum(dd(2:2:end)==0)==0)
% $$$             eventtime=eventtime(1:2:end);
% $$$             evtrials=evtrials(1:2:end);
% $$$             eventtimeoff=eventtimeoff(2:2:end);
% $$$             Note={Note{1:2:end}};
% $$$         end
% $$$     end
% $$$     
% $$$     keepidx=find(~strcmp(Note,'STIM,ON'));
% $$$     eventtime=eventtime(keepidx);
% $$$     evtrials=evtrials(keepidx);
% $$$     Note={Note{keepidx}};
% $$$     eventtimeoff=eventtimeoff(keepidx);
% $$$     
% $$$     if ~isempty(strfind(spkfile,'SWC'))
% $$$         tempmfilename = spikeinfop.sortinfo{channel}{1}.mfilename;
% $$$         LoadMFile(tempmfilename);
% $$$         ShockTar = exptparams.TrialObject.ShockTar;
% $$$         
% $$$         TarOrDis=[];
% $$$         for cnt1 = 1:length(exptevents)
% $$$             if strcmpi(exptevents(cnt1).Note,'TRIALSTART') == 0 && ...
% $$$                     strcmpi(exptevents(cnt1).Note,'TRIALSTOP') == 0
% $$$                 [Type, StimName, StimRefOrTar] = ParseStimEvent (exptevents(cnt1));
% $$$                 if strcmpi(Type,'Stim');
% $$$                     if strcmpi(StimRefOrTar,'Target')
% $$$                             if exptevents(cnt1).Rove{1} == ShockTar
% $$$                                 TarOrDis = [TarOrDis; 1];
% $$$                             else
% $$$                                 TarOrDis = [TarOrDis; 0];
% $$$                             end
% $$$                     elseif strcmpi(StimRefOrTar,'Reference')
% $$$                         TarOrDis = [TarOrDis; nan];
% $$$                     end
% $$$                 end
% $$$             end
% $$$         end
% $$$     end
% $$$     
% $$$     
% $$$     for ii=1:length(eventtime),
% $$$         if strfind(upper(Note{ii}),'TARG'),
% $$$             if split_incorrect,
% $$$                 [shockstart]=evtimes(exptevents,'BEHAVIOR,SHOCKON',evtrials(ii));
% $$$                 if length(shockstart)>0,
% $$$                     Note{ii}='Miss,Miss';
% $$$                 else
% $$$                     Note{ii}='Hit,Hit';
% $$$                 end
% $$$             else
% $$$                 if isempty(strfind(spkfile,'SWC'))
% $$$                     Note{ii}='Target,Target';
% $$$                 else                    
% $$$                     if TarOrDis(ii) == 1
% $$$                      Note{ii}='Target,Target';
% $$$                     else
% $$$                      Note{ii}='Distractor,Distractor';
% $$$                     end
% $$$                 end
% $$$             end
% $$$         end
% $$$         if strfind(upper(Note{ii}),', REF'),
% $$$            if strcmpi(tm{3},'ORDER'),
% $$$               if ii==1 || evtrials(ii)>evtrials(ii-1),
% $$$                  Note{ii}='Ref1,Ref1';
% $$$               else
% $$$                  Note{ii}='RefN,RefN';
% $$$               end
% $$$            else
% $$$               Note{ii}='Reference,Reference';
% $$$            end
% $$$         end
% $$$     end
% $$$     
% $$$     % remove duplicate events (for overlaid stim, eg VTL)
% $$$     keepidx=find([1;(diff(eventtime)~=0 | diff(evtrials)~=0)]);
% $$$     eventtime=eventtime(keepidx);
% $$$     eventtimeoff=eventtimeoff(keepidx);
% $$$     evtrials=evtrials(keepidx);
% $$$     Note={Note{keepidx}}';
% $$$ else
% $$$     % use fixed Pre- and PostStimSilence
% $$$     if sum(includeprestim)==1 && length(includeprestim)==1,
% $$$        [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PostStim*']);
% $$$        if length(eventtime)>0,
% $$$            ii=length(Note);
% $$$            while ~isempty(findstr(lower(Note{ii}),' target')) && ii>2,
% $$$                ii=ii-1;
% $$$            end
% $$$            
% $$$           PostStimSilence=eventtimeoff(ii)-eventtime(ii);
% $$$        else
% $$$           PostStimSilence=0.1;
% $$$        end          
% $$$        
% $$$        [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PreStim*']);
% $$$        if length(eventtime)>0,
% $$$           PreStimSilence=eventtimeoff(1)-eventtime(1);
% $$$        else          
% $$$           PreStimSilence=0.1;
% $$$        end
% $$$        includeprestim=[PreStimSilence PostStimSilence];
% $$$     end
% $$$     
% $$$     % figure out when each event to be rastered started and stopped
% $$$     [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['Stim*']);
% $$$     if ~isempty(tag_masks) && strcmpi(tag_masks{1},'Reference'),
% $$$         validevents=ones(size(eventtime));
% $$$         for ee=1:length(eventtime),
% $$$             if ~isempty(findstr(Note{ee},', Target')) && ...
% $$$                     ~isempty(findstr(Note{ee},'Stim ,')),
% $$$                 ff=find(eventtimeoff>eventtime(ee) & evtrials==evtrials(ee));
% $$$                 for gg=ff(:)',
% $$$                     if gg==ee || eventtime(gg)>eventtime(ee),
% $$$                         validevents(gg)=0;
% $$$                     elseif eventtimeoff(gg)>eventtime(ee),
% $$$                         eventtimeoff(gg)=eventtime(ee);
% $$$                     end
% $$$                 end
% $$$             end
% $$$         end
% $$$         eventtime=eventtime(find(validevents));
% $$$         evtrials=evtrials(find(validevents));
% $$$         Note={Note{find(validevents)}}';
% $$$         eventtimeoff=eventtimeoff(find(validevents));
% $$$         if sum(1-validevents)>0
% $$$             fprintf('removed %d/%d invalid target overlap events\n',...
% $$$                     sum(1-validevents),length(validevents));
% $$$         end
% $$$     end
% $$$     if sum(includeprestim)>0 & length(includeprestim)>1,
% $$$         eventtime=eventtime-includeprestim(1);        % ie, minus PreStimSilence
% $$$         eventtimeoff=eventtimeoff+includeprestim(2); % ie, plus PostStimSilence
% $$$     end
% $$$     
% $$$     tags=evunique(exptevents,['Stim*']);
% $$$     
% $$$     tgoodidx=zeros(size(tags));
% $$$     for ii=1:length(tags),
% $$$         b=strsep(tags{ii},',',1);
% $$$         if isempty(findstr(b{2},'StimSilence')),
% $$$             tgoodidx(ii)=1;
% $$$         end
% $$$     end
% $$$     tags={tags{find(tgoodidx)}};
% $$$     
% $$$     % alternative, method that doesn't work anymore
% $$$     % tags=spikeinfop.StimTagNames;
% $$$     
% $$$     for jj=1:length(tag_masks),
% $$$         ttfind=(strfind(upper(tags),upper(tag_masks{jj})));
% $$$         tt2=[];
% $$$         for ii=1:length(ttfind),
% $$$             if ~isempty(ttfind{ii}),
% $$$                 tt2=[tt2 ii];
% $$$             end
% $$$         end
% $$$         tags={tags{tt2}};
% $$$     end
% $$$ end

% define output raster matrix
referencecount=length(tags);
r=nan*zeros(1,1,referencecount);

% figure out the time that each trial started and stopped
[starttimes,starttrials]=evtimes(exptevents,'TRIALSTART');
[stoptimes,stoptrials]=evtimes(exptevents,'TRIALSTOP');
[shockstart,shocktrials,sn,shockstop]=evtimes(exptevents,'BEHAVIOR,SHOCKON');

trialcount=max(starttrials);

[hittime,hittrials]=evtimes(exptevents,'OUTCOME,MATCH');
if isempty(hittrials),
    [hittime,hittrials]=evtimes(exptevents,'BEHAVIOR,PUMPON*');
end

if isfield(options,'trialfrac'),
   if length(options.trialfrac)==2,
      trialrange=round(trialcount.*options.trialfrac(1)):...
          round(trialcount.*options.trialfrac(2));
      td=diff(options.trialfrac);
   else
      trialrange=1:round(trialcount.*options.trialfrac);
      td=options.trialfrac;
   end
   fprintf('trial frac=%.2f, keeping %d/%d trials\n',...
           td,trialrange(end),trialcount);
elseif isfield(options,'trialrange'),
   trialrange=options.trialrange;
elseif ~includeincorrect && length(hittrials)>0,
   %disp('including only correct trials.');
   trialrange=hittrials(:)';

elseif length(hittrials)>0,
   lasttrial=trialcount; % hittrials(round(length(hittrials).*0.85));
   if lasttrial<60,
      lasttrial=min(60,trialcount);
   end
   trialrange=1:lasttrial;
   fprintf('stopping at trial %d/%d\n',lasttrial,trialcount);
else
   trialrange=1:trialcount;
end

if lfpclean
   % fit LFP-spike filter here
   
    % guess evpfile name to load LFP
    [evpb,evpp]=basename(spikeinfop.fname);
    evpp=strrep(evpp,'\',filesep);
    
    ff=findstr(evpp,spkfile);
    if ~isempty(ff),
       evpfile=[spkfile(1:(ff-1)),strrep(spikeinfop.fname,'\',filesep)];
    else
       error('evpfile not known');
    end
    %[spikechancount,auxchancount,trialcount,spikefs,...
    % auxfs,lfpchancount,lfpfs]=evpgetinfo(evpfile);
    %[dum1,dum2,dum3,dum4,rL,ltrialidx]=...
    %    evpread(evpfile,[],[],[],channel);
    
    [rL,ltrialidx,lfpfs,spikefs]=evplfp(evpfile,channel);
    ltrialidx=cat(1,ltrialidx,length(rL)+1);
    
    lr=[];
    sr=[];
    
    %for each trial
    for ii=1:trialcount,

       lstart=ltrialidx(ii);
       lstop=ltrialidx(ii+1)-1;
       
       lthistrial=resample(rL(lstart:lstop),rasterfs.*100,lfpfs.*100);
       expectedspikebins=length(lthistrial)./rasterfs.*spikefs;
       thistrialidx=find(rawSpikes(1,:)==ii);
       if ~isempty(thistrialidx),
          sthistrial=histc(rawSpikes(2,thistrialidx),0:spikefs/rasterfs:...
                       (expectedspikebins+spikefs/rasterfs))';
       else
          sthistrial=zeros(size(0:spikefs/rasterfs:(expectedspikebins+spikefs/rasterfs)))';
       end
       
       mm=min(length(sthistrial),length(lthistrial));
       cleantrialidx(ii)=length(lr)+1;
       lr = cat(1,lr,lthistrial(1:mm));
       sr = cat(1,sr,sthistrial(1:mm));
    end
    cleantrialidx(trialcount+1)=length(lr)+1;
    
    IR_LEN=20;
    fprintf('computing cross-corr...\n');
    bootcount=16;
    bootstep=length(lr)./bootcount;
    xc=zeros(IR_LEN.*2+1,bootcount);
    ac=zeros(IR_LEN.*2+1,bootcount);
    for bb=1:bootcount,
       bidx=[1:round((bb-1).*bootstep) round(bb.*bootstep+1):length(lr)];
       
       xc(:,bb)=xcov(lr(bidx),sr(bidx),IR_LEN,'unbiased');
       ac(:,bb)=xcov(lr(bidx),lr(bidx),IR_LEN,'unbiased');
    end
    
    fft_xc = fft(xc);
    fft_ac = fft(ac);
    
    h_fft = fft_xc./fft_ac;
    mm=abs(mean(h_fft,2));
    ee=abs(std(h_fft,0,2)).*sqrt(bootcount-1);
    
    h_fft=mean(h_fft,2);
    
    sigrat=2;
    smd=mm./(ee+eps.*(ee==0)) ./ sigrat;

    smd=(1-smd.^(-2));
    smd=smd.*(smd>0);
    smd(find(isnan(smd)))=0;
    h_fft=h_fft.*smd;

    %h_fft(mm./ee<2,:)=0;
    
    h_re = fftshift(real(ifft(h_fft)));
    %h_re = h_re - mean(h_re);
    h = h_re .* hann(IR_LEN*2+1);
    
    out_spikes= conv2(lr, h,'same');
    
    if sum(abs(out_spikes))>0,
       
       gg=sr'*out_spikes./(out_spikes'*out_spikes);
       
       output_clean = sr - gg.*out_spikes;
    
       fprintf('lfp spike pred xc: %.3f\n',xcov(out_spikes,sr,0,'coeff'));
    else
       disp('no significant LFP-spike filter');
       output_clean=sr;
    end
    %keyboard
    
end


trialset=zeros(1,referencecount);
for trialidx=trialrange,
    starttime=starttimes(find(starttrials==trialidx));
    stoptime=stoptimes(find(stoptrials==trialidx));
    expectedspikebins=(stoptime-starttime)*spikefs;
    
    if (size(rawSpikes,1)>0),
       thistrialidx=find(rawSpikes(1,:)==trialidx);
    else
       thistrialidx=[];
    end
    
    % bin whole trial into a raster
    if lfpclean,
       % remove activity predicted by LFP here
       raster=output_clean(cleantrialidx(trialidx):(cleantrialidx(trialidx+1)-1))';
    elseif isempty(thistrialidx),
       raster=zeros(size(0:spikefs/rasterfs:(expectedspikebins+spikefs/rasterfs)));
    else
       if 1 || rasterfs>=100,
          raster=histc(rawSpikes(2,thistrialidx),0:spikefs/rasterfs:...
                       (expectedspikebins+spikefs/rasterfs));
       else
          %disabled svd 2010-04-20
          %smooth before downsample
          raster=histc(rawSpikes(2,thistrialidx),0:spikefs/1000:...
                       (expectedspikebins+spikefs/1000));
          raster=resample(raster,rasterfs,1000);
       end
    end
    
    shockhappened=find(shocktrials==trialidx);
    for tt=1:length(shockhappened),
       shockidx=shockhappened(tt);
       fprintf('trial %d: nan-ing shock %.1f-%.1f sec\n',...
               trialidx,shockstart(shockidx),shockstop(shockidx)+0.15);
       raster(round(shockstart(shockidx).*rasterfs):...
              round((shockstop(shockidx)+0.15).*rasterfs))=nan;
    end
    
    % figure out the start and stop time of each event during the trial
    % and place the corresponding spikes in the raster.
    evidxthistrial=find(evtrials==trialidx);
    
    for evidx=evidxthistrial(:)',
        %bb=strsep(Note{evidx},',',1);
        %bb=strtrim(bb{2});
        bb=Note{evidx};
        % figure out which event slot this is
        refidx=find(strcmp(tags,bb));
        
        % if it doesn't match one of the expected tags then skip it (eg, a
        % target when we only want references)
        if ~isempty(refidx),
            repidx=min(find(sum(~isnan(r(:,:,refidx)))==0));
            if isempty(repidx),
                repidx=size(r,2)+1;
            end
            rlen=(eventtimeoff(evidx)-eventtime(evidx))*rasterfs;
            
            % make sure the raster matrix is big enough for the next event
            if size(r,1)<rlen | repidx>size(r,2) | refidx>size(r,3),
                r((size(r,1)+1):round(rlen),:,:)=nan;
                r(:,(size(r,2)+1):repidx,:)=nan;
            end
            
            startbin=round(eventtime(evidx)*rasterfs);
            stopbin=round(eventtimeoff(evidx)*rasterfs);
            if eventtime(evidx)<=0 && length(raster)<stopbin,
               rl=length(raster)-startbin;
               missingbins=-startbin;
               r(1:missingbins,repidx,refidx)=nan;
               r((missingbins+1):rl,repidx,refidx)=raster(1:end);
            elseif eventtime(evidx)<=0,
               missingbins=-startbin;
               r(1:missingbins,repidx,refidx)=nan;
               r((missingbins+1):(stopbin-startbin),repidx,refidx)=...
                   raster(1:stopbin);
            elseif length(raster)>=stopbin,
                % actually put the responses in the output raster matrix
                r(1:(stopbin-startbin),repidx,refidx)=raster((startbin+1):stopbin);
            else
               rl=length(raster)-startbin;
               r(1:rl,repidx,refidx)=raster((startbin+1):end);
            end
            trialset(repidx,refidx)=trialidx;
           
        end
    end
    drawnow;
end

extraidx=length(spikeinfop.sortextras{channel}.StimTagNames);
if (length(tag_masks)==0 || length(tag_masks{1})<8 || ...
    ~strcmp(tag_masks{1}(1:8),'SPECIAL-')) && ...
       (length(tag_masks)==0 || length(tag_masks{1})<6 || ...
        ~strcmp(upper(tag_masks{1}((end-5):end)),'TARGET')) && ...
       (length(tag_masks)==0 || length(tag_masks{1})<4 || ...
        ~strcmp(upper(tag_masks{1}((end-3):end)),'TARG')) && ...
       isfield(spikeinfop,'sortextras') && ...
       isempty(strfind(spikeinfop.fname,'_FTC')) && ...
       isempty(strfind(spikeinfop.fname,'_CCH')) && ...
       isempty(strfind(spikeinfop.fname,'_AMN')) && ...
       isempty(strfind(spikeinfop.fname,'_MTS')) && ...
       isempty(strfind(spikeinfop.fname,'_ALM')) && ...
       isempty(strfind(spikeinfop.fname,'_AMN')) && ...
       isempty(strfind(spikeinfop.fname,'_PHD')),
   maptoidx=zeros(1,length(tags));
   for ii=1:length(tags),
      tt=strsep(tags{ii},',',1);
      if length(tt)==4 && strcmp(tt{4},' Reference'),
         % special case, put comma in string descriptor! arg!
         tt{2}=[tt{2} ',' tt{3}];
         tt={tt{1},tt{2},tt{4}};
      end
      if isnumeric(tt{2}),
          tt=num2str(tt{2});
      else
          tt=strtrim(tt{2});
      end
      matchidx=find(strcmp(tt,spikeinfop.sortextras{channel}.StimTagNames));
      if isempty(matchidx),
          matchidx=strmatch(tt,spikeinfop.sortextras{channel}.StimTagNames);
      end
      if isempty(matchidx) && ~isempty(strfind(spikeinfop.fname,'_SPT')),
         tt2=strrep(tt,'SPORC','TORC');
         matchidx=strmatch(tt2,spikeinfop.sortextras{channel}.StimTagNames);
      end
      
      if ~isempty(matchidx),
         maptoidx(ii)=matchidx(1);
      else
         extraidx=extraidx+1;
         maptoidx(ii)=extraidx;
         % disp('loadspikeraster.m: stimtagnames/tags mismatch! tacking on end');
      end
   end
   
   if 1,
       newr=nan*ones(size(r,1),size(r,2),extraidx);
       newtags=cell(1,extraidx);
       newtrialset=zeros(size(trialset,1),extraidx);
       for ttt=1:length(maptoidx),
           newr(:,:,maptoidx(ttt))=r(:,:,ttt);
           newtags{maptoidx(ttt)}=tags{ttt};
           newtrialset(:,maptoidx(ttt))=trialset(:,ttt);
       end
       r=newr;
       tags=newtags;
       trialset=newtrialset;
   else
       %old method... stimulus idx not lined up properly if full rep not completed.
       [ttt,mapidx]=sort(maptoidx);
       r=r(:,:,mapidx);
       tags={tags{mapidx}};
       trialset=trialset(:,mapidx);
   end
end

if ~isempty(stimidx),
   r(:,:,setdiff(1:size(r,3),stimidx))=nan;
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

function spkfile = LF_copyForSeil(spkfile)

% special code for copying temp files over to seil cluster
ss_stat=onseil;
if ss_stat && ~exist(spkfile,'file'),

   trin=spkfile;
   if ss_stat==1,
       disp('mapping file to seil');
       trout=strrep(trin,'/auto/data/','/homes/svd/data/');
   elseif ss_stat==2,
       trout=trin;
   end
   
   [bb,pp]=basename(trout);
   if strcmp(bb(1:5),'model') && ss_stat~=2,
      disp('model cell, forcing recopy of response');
      ['\rm ' trout]
      unix(['\rm ' trout]);
   end
   if ~exist(trout,'file'),
       if ss_stat==2,
           disp('mapping file to OHSU');
       end
      unix(['mkdir -p ',pp]);
      ['scp svd@bhangra.isr.umd.edu:',trin,' ',pp]
      unix(['scp svd@bhangra.isr.umd.edu:',trin,' ',pp]);
   end
   spkfile=trout;
end
