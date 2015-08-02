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
      if trialcount>=max(trials),
%                       bHumbug=[0.995386247699319  -5.972013278489225  14.929576915653460  -19.905899769726052  14.929576915653460  -5.972013278489225  0.995386247699319 ];
%         aHumbug = [ 1.000000000000000  -5.990446012819222  14.952579842917430  -19.905857198474035  14.906552701679249  -5.953623115411301  0.990793782108932  ];
%          LHumbug = length(bHumbug)-1;
%      Raw=double(data.rl)'; 
% % IVHumbug = zeros(LHumbug,size(Raw,2)); 
%         [Raw] = filter(bHumbug,aHumbug,Raw);
%         lfpout(:,lidx)=Raw;
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
      if isempty(findstr(computer,'PCWIN')),
          w=unix(['mkdir -p ' pp filesep 'tmp']);
      elseif ~exist([pp filesep 'tmp'],'dir'),
          mkdir(pp,'tmp');
      end
      save(cachefile,'rl','ltrialidx','spikechancount','auxchancount',...
           'trialcount','spikefs','auxfs','lfpchancount','lfpfs');
      lfpout(:,lidx)=rl;
   end
end

% keep only requested trials
if exist('trials','var') && ~isempty(trials),
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
