% function lickdata=dms_count_licks(mfile,ttlsec[=2]);
%
% extended dms behavior analysis
%
function lickdata=dms_count_licks(mfile,ttlsec);

LoadMFile(mfile);
if ~isfield(exptparams,'bstat') | isempty(exptparams.bstat),
   disp('Loading bar data from aux file...')
   if ~exist(globalparams.evpfilename,'file'),
      [bb,pp]=basename(globalparams.evpfilename);
      globalparams.evpfilename=[pp 'tmp' filesep bb];
   end
   [SpikeCount,AuxCount,TrialCount, Spikefs, Auxfs]=...
       evpgetinfo(globalparams.evpfilename);
   [rS,STrialIdx,rA,ATrialIdx]=evpread(globalparams.evpfilename,[],1:2);
   ATrialIdx=[ATrialIdx(:);length(rA)+1];
   for ii=1:TrialCount,
      tra=rA(ATrialIdx(ii):(ATrialIdx(ii+1)-1),[1 2]);
      if length(tra)>0,
         exptparams.bstat{ii}=round(resample(tra,exptparams.bfs,Auxfs));
      else
         exptparams.bstat{ii}=[];
      end
   end
end
if ~exist('ttlsec','var'),
   ttlsec=2.0;
end

tonecount=length(exptparams.freqs);
count=length(exptparams.bstat);

if size(exptparams.bstat{1},2)>1 & ~(isfield(exptparams,'use_lick') & exptparams.use_lick),
    % backwards compatible with old ver dms
    bstatidx=2;
else
    bstatidx=1;
end

berror=exptparams.res(:,2);
targidx=exptparams.res(:,5);
tstring=exptparams.tstring;

resptime=zeros(count,1);
triallen=zeros(count,1);
cuetrial=zeros(count,1);

targlat=exptparams.res(:,1);
stimstepsize=exptparams.dur+exptparams.gapdur;
if ~exptparams.distobject
    targlat=ceil(targlat./stimstepsize).*stimstepsize;
end

targset=unique(exptparams.targidx0);
for ii=1:tonecount,
   flabels{ii}=num2str(exptparams.freqs(ii));
end

resptime=-inf.*ones(count,1);
tonetriglick=zeros(exptparams.bfs*ttlsec,tonecount,length(targset));
ttlcount=zeros(exptparams.bfs*ttlsec,tonecount,length(targset));
rttime=linspace(-0.75,3.25,30);
rt=zeros(length(rttime),2,length(targset));
rtcount=zeros(length(targset),1);
for trialidx=1:count,
    
    ttarg=evtimes(exptevents,['Stim,',tstring{targidx(trialidx)},'*'],trialidx);
    [ttones,ttr,tnames]=evtimes(exptevents,['Stim*'],trialidx);
    
    if length(ttarg)>=length(ttones),
        cuetrial(trialidx)=1;
        targlat(trialidx)=0;
    elseif length(ttarg)>0,
        targlat(trialidx)=ttarg(1);
    end
    
    if length(ttones)>0,
        firsttargbin=round(ttones(1).*exptparams.bfs);
        if firsttargbin==0,
            firsttargbin=1;
        end
        touch=exptparams.bstat{trialidx}(firsttargbin:end,bstatidx);
        
        releasebin=min(find(diff(touch)>0));
        if isempty(releasebin) & (touch(1)==1 | berror(trialidx)<=1),
            releasebin=0;
        elseif isempty(releasebin),
            releasebin=inf;
        end
    else
        releasebin=0;
    end
    resptime(trialidx)=releasebin./exptparams.bfs;
    
    if length(ttones)>0,
        resp=exptparams.bstat{trialidx}(:,bstatidx);
        ttargidx=find(targidx(trialidx)==targset);
        for ii=1:length(ttones),
            tt=strsep(tnames{ii},',',1);
            tt=deblank(tt{2});
            tt=find(strcmp(tt,tstring));
            if ~isempty(tt),
                ttstart=round(ttones(ii).*exptparams.bfs);
                if ttstart==0,
                    ttstart=1;
                end
                ttstop=round((ttones(ii)+ttlsec).*exptparams.bfs)-1;
                if ttstop>length(resp),
                    ttstop=length(resp);
                end
                tonetriglick(1:(ttstop-ttstart+1),tt,ttargidx)=...
                    tonetriglick(1:(ttstop-ttstart+1),tt,ttargidx) + ...
                    resp(ttstart:ttstop);
                ttlcount(1:(ttstop-ttstart+1),tt,ttargidx)=...
                    ttlcount(1:(ttstop-ttstart+1),tt,ttargidx)+1;
            end
        end
        if ~isinf(resptime(trialidx)),
           rrresp=resptime(trialidx)-targlat(trialidx);
           rt(:,1,ttargidx)=rt(:,1,ttargidx)+hist(rrresp,rttime)';
           rt(:,2,ttargidx)=rt(:,2,ttargidx)+hist(resptime(trialidx),rttime)';
           rtcount(ttargidx)=rtcount(ttargidx)+1;
        end
    end
end

lickdata.siteid=globalparams.SiteID;
lickdata.tonetriglick=tonetriglick;
lickdata.ttlcount=ttlcount;
lickdata.flabels=flabels;
lickdata.targset=targset;
lickdata.ttltime=(1./exptparams.bfs):(1./exptparams.bfs):ttlsec;
lickdata.rt=rt;
lickdata.rtcount=rtcount;
lickdata.rttime=rttime;
lickdata.count=count;
