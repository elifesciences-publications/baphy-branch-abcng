%[muaout,strialidx]=evpmua(evpfile,chans,rasterfs,trials);
%
function [muaout,strialidx]=evpmua(evpfile,chans,rasterfs,trials);

[pp,bb,ee]=fileparts(evpfile);

muaout=[];
for lidx=1:length(chans),
   
   if ~isempty(pp),
      pp=[pp filesep];
   end
   cachefile = [pp 'tmp' filesep bb '.chan' ...
                num2str(chans(lidx)) '.fs' num2str(rasterfs) '.mua.mat'];
   
   fprintf('evpmua: cache file=%s\n',cachefile);
   
   if exist(cachefile),
      data=load(cachefile);
      muaout(:,lidx)=data.rs;
      strialidx=data.strialidx;
      trialcount=data.trialcount;
   else
      fprintf('not found. generating from evp...\n');
      [spikechancount,auxchancount,trialcount,...
       spikefs,auxfs,lfpchancount,lfpfs]=evpgetinfo(evpfile);
      [brs,bstrialidx]=evpread(evpfile,chans(lidx),[],[],[]);
      
      FILTER_ORDER = 400;
      f_bp = firls(FILTER_ORDER,[0 550/spikefs 600/spikefs 3000/spikefs 3500/spikefs 1],[0 0 1 1 0 0]);
      f_lp = firls(FILTER_ORDER,[0 450/spikefs 500/spikefs 1],[1 1 0 0]);
      dsstep=spikefs./rasterfs;
      
      trialcount=length(bstrialidx);
      strialidx=zeros(size(bstrialidx));
      rs=[];
      bstrialidx=[bstrialidx;length(brs)+1];
      
      for tt=1:trialcount,
          %tt
          s=brs(bstrialidx(tt):(bstrialidx(tt+1)-1));
          
          rSmua = conv(s, f_bp);
          rSmua = rSmua(round(FILTER_ORDER/2)+1:round(FILTER_ORDER/2)+length(s));
          rSmua = rSmua.^2;
          rSmua = conv(rSmua, f_lp);
          rSmua = rSmua(round(FILTER_ORDER/2)+1:round(FILTER_ORDER/2)+length(s));
          rSmua = sqrt(abs(rSmua));
          
          rSmua=rSmua(round(dsstep./2:dsstep:length(rSmua)));
          
          strialidx(tt)=length(rs)+1;
          rs=[rs;rSmua];
      end
      
      w=unix(['mkdir -p ' pp filesep 'tmp']);
      save(cachefile,'rs','rasterfs','strialidx','spikechancount',...
           'auxchancount',...
           'trialcount','spikefs','auxfs','lfpchancount','lfpfs');
      muaout(:,lidx)=rs;
   end
end

% keep only requested trials
if exist('trials','var') && ~isempty(trials),
   keepidx=zeros(length(muaout),1);
   strialidx0=zeros(length(trials),1);
   for tt=1:length(trials),
      strialidx0(tt)=sum(keepidx)+1;
      
      if tt<trialcount,
         keepidx(strialidx(trials(tt)):(strialidx(trials(tt+1))-1))=1;
      else
         keepidx(strialidx(trials(tt)):end)=1;
      end
   end
   muaout=muaout(find(keepidx),:);
   strialidx=strialidx0;
end
