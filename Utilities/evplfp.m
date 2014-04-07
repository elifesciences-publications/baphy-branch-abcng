%[lfpout,ltrialidx]=evplfp(evpfile,lfpchans,trials);
%
function [lfpout,ltrialidx,lfpfs,spikefs]=evplfp(evpfile,lfpchans,trials,options)

global USECOMMONREFERENCE

if isempty(USECOMMONREFERENCE) || ~USECOMMONREFERENCE,
   commstr='.NOCOM';
else
   commstr='';
end

[pp,bb,ee]=fileparts(evpfile);
Pos = find(bb=='.');
switch length(Pos) % Stephen Style Fix for EVP detection :)
  case 2; EVPVersion = 5; 
  case 0; EVPVersion = 4; 
  otherwise error('Unknown EVP Version');
end

switch EVPVersion
  case 5; pp = pp(1:strfind(pp,'raw')-2);
  otherwise
end

lfpout=[];
for lidx=1:length(lfpchans),
   
   if ~isempty(pp)
      pp=[pp filesep];
   end
   cachefile=[pp 'tmp' filesep bb '.chan' ...
              num2str(lfpchans(lidx)) '.fs' num2str(options.rasterfs) ...
              commstr '.lfp.mat'];
   cachefile=strrep(cachefile,[filesep 'raw' filesep],filesep);
   
   fprintf('evplfp: cache file=%s\n',cachefile);
   
   if exist(cachefile,'file'),
      data=load(cachefile);
      trialcount=data.trialcount;
      if trialcount==max(trials),
          lfpout(:,lidx)=data.rl;
          ltrialidx=data.ltrialidx;
          lfpfs=data.lfpfs;
          spikefs=data.spikefs;
      end
   end
   
   if ~exist(cachefile,'file') || trialcount<max(trials),
      fprintf('not found. generating from evp...\n');
      [spikechancount,auxchancount,trialcount,spikefs,auxfs,lfpchancount,lfpfs]=evpgetinfo(evpfile);
      [~,~,~,~,rl,ltrialidx]=evpread(evpfile,'spikeelecs',[],'lfpelecs',lfpchans(lidx),'SRlfp',options.rasterfs);
      
      % downsample prior to saving cache file
      if isfield(options,'rasterfs') && options.rasterfs<lfpfs,
         ltrialidx=ceil(ltrialidx*options.rasterfs./lfpfs);
         rl=resample(rl,options.rasterfs,lfpfs);
      end
      lfpout(:,lidx)=rl;
      
      if isempty(findstr(computer,'PCWIN')),
          w=unix(['mkdir -p ' pp filesep 'tmp']);
      elseif ~exist([pp filesep 'tmp'],'dir'),
          mkdir(pp,'tmp');
      end
      save(cachefile,'rl','ltrialidx','spikechancount','auxchancount',...
           'trialcount','spikefs','auxfs','lfpchancount','lfpfs');
   end
end

% keep only requested trials
if exist('trials','var') && ~isempty(trials) && length(trials)<length(ltrialidx),
   keepidx=zeros(length(lfpout),1);
   ltrialidx0=zeros(length(trials),1);
   for tt=1:length(trials),
      ltrialidx0(tt)=sum(keepidx)+1;
      
      if trials(tt)<trialcount,
         keepidx(ltrialidx(trials(tt)):(ltrialidx(trials(tt)+1)-1))=1;
      else
         keepidx(ltrialidx(trials(tt)):end)=1;
      end
   end
   lfpout=lfpout(find(keepidx),:);
   ltrialidx=ltrialidx0;
end
