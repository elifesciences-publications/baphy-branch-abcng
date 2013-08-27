% function dms_show_licks(mfile/exptparams,events,count);
%
% extended dms behavior analysis
%
function dms_show_licks(exptparams,exptevents,count);

if ~isstruct(exptparams),
    mfile=exptparams;
    clear exptparams
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

%if bstatidx==2,
%    % backwards compatible with old ver dms
%    targlat=exptparams.res(:,1)-exptparams.isi;
%else
    targlat=exptparams.res(:,1);
%end
stimstepsize=exptparams.dur+exptparams.gapdur;
if ~exptparams.distobject
    targlat=ceil(targlat./stimstepsize).*stimstepsize;
end

ttlsec=2.0;
targset=unique(exptparams.targidx0);
tonetriglick=zeros(exptparams.bfs*ttlsec,tonecount,length(targset));
ttlcount=zeros(exptparams.bfs*ttlsec,tonecount,length(targset));
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
        resp=exptparams.bstat{trialidx}(:,bstatidx);
        ttargidx=find(targidx(trialidx)==targset);
        for ii=1:length(ttones),
            tt=strsep(tnames{ii},',',1);
            tt=deblank(tt{2});
            tt=min(find(strcmp(tt,tstring)));
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
    end
end

figure
pcol={'r','b','k','g','c','r--','b--','k--','g--','c--','r:','b:','k:','g:','c:'};
ttcount=0;
for jj=1:length(targset),
    subplot(length(targset),1,jj);
    if sum(sum(ttlcount(:,:,jj)))>0,
        flabels={};
        for ii=1:min([tonecount length(pcol)]),
            flabels{ii}=num2str(exptparams.freqs(ii));
            
            if exist('smooth','file'),
                hp=plot((1:length(tonetriglick))./exptparams.bfs,...
                    smooth(tonetriglick(:,ii,jj)./(ttlcount(:,ii,jj)+(ttlcount(:,ii,jj)==0)),3),...
                    pcol{ii});
            else
                hp=plot((1:length(tonetriglick))./exptparams.bfs,...
                    (tonetriglick(:,ii,jj)./(ttlcount(:,ii,jj)+(ttlcount(:,ii,jj)==0))),...
                    pcol{ii});
            end
            if targset(jj)==ii,
                set(hp,'LineWidth',1.5);
            end
            hold on
            
            xp=(length(tonetriglick)+1)./exptparams.bfs+0.1+(ii-1)./tonecount.*0.5;
            plot([xp xp],[0.3 1.1],pcol{ii});
            if ii==1 | ii==round(tonecount/3) | ii==round(tonecount*2/3) | ii==tonecount,
                ht=text(xp,0.25,flabels{ii});
                set(ht,'HorizontalAlignment','right','Rotation',90);
            end
        end
        hold off
        axis([0 (length(tonetriglick)+1)./exptparams.bfs+0.6 -0.1 1.1]);
        ylabel(['targ=',flabels{targset(jj)}]);
        %legend(flabels);
    end
    if jj==1 & exist('mfile','var'),
        ht=title(sprintf('%s: lickrate (%d trials)',mfile,count));
        set(ht,'Interpreter','none');
    end
end
xlabel('time after tone (s)');
