% function globalparams=dms_plot_ext(exptparams,events,count);
%
% extended dms behavior analysis
%
function globalparams=dms_plot_ext(exptparams,exptevents,count);

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

tonecount=exptparams.tonecount;
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

if isfield(exptparams,'dur'),
    stimstepsize=exptparams.dur+exptparams.gapdur;
else
    stimstepsize=exptparams.refmean+exptparams.ReferenceObject.PreStimSilence+...
        exptparams.ReferenceObject.PostStimSilence;
end

if isfield(exptparams,'distobject') & ~exptparams.distobject
    targlat=ceil(targlat./stimstepsize).*stimstepsize;
end

altoutcomes=zeros(count,tonecount+1);
altmaybes=zeros(count,tonecount+1);

for trialidx=1:count,
    
    ttarg=evtimes(exptevents,['Stim,',tstring{targidx(trialidx)},'*'],trialidx);
    [ttones,ttr,tnames]=evtimes(exptevents,['Stim*'],trialidx);
    
    if length(ttarg)==length(ttones),
        cuetrial(trialidx)=1;
        targlat(trialidx)=0;
    end
    
    if length(ttones)>0,
        firsttargbin=round(ttones(1).*exptparams.bfs);
        if firsttargbin==0,
            firsttargbin=1;
        end
        touch=exptparams.bstat{trialidx}(firsttargbin:end,bstatidx);
        
        releasebin=min(find(diff(touch)>0));
        if firsttargbin>length(touch),
            releasebin=inf;
        elseif isempty(releasebin) && (touch(1)==1 || berror(trialidx)<=1),
            releasebin=0;
        elseif isempty(releasebin),
            releasebin=inf;
        end
    else
        releasebin=-inf;
    end
    resptime(trialidx)=releasebin./exptparams.bfs;
    triallen(trialidx)=size(exptparams.bstat{trialidx},1)./exptparams.bfs;
    
    if ~cuetrial(trialidx),
        reltime=releasebin./exptparams.bfs;
        for ii=1:length(ttones),
            if ttones(ii)-ttones(1)>=exptparams.nolick,
                tt=strsep(tnames{ii},',',1);
                tt=deblank(tt{2});
                tt=find(strcmp(tt,tstring));
                
                %tt=double(tt(1))-'A'+1;
                
                altmaybes(trialidx,tt)=1;
                if reltime-ttones(ii)+ttones(1)>exptparams.startwin & ...
                        reltime-ttones(ii)+ttones(1)<=exptparams.startwin+exptparams.respwin;
                    % would've been correct response if this tone were the target
                    altoutcomes(trialidx,tt)=1;
                end
            end
        end
        
        if max(ttones)-ttones(1)>exptparams.nolick,
            altmaybes(trialidx,end)=1;
            if reltime>exptparams.nolick+exptparams.nolickstd-exptparams.respwin/2 & ...
                    reltime<=exptparams.nolick+exptparams.nolickstd+exptparams.respwin/2,
                altoutcomes(trialidx,end)=1;
            end
        end
    end
end
targstep=round(targlat./stimstepsize);


% remove cue trials
berror(find(cuetrial))=4;

start_respwin=exptparams.startwin;
stop_respwin=exptparams.startwin+exptparams.respwin;

berror2=berror.*0;
berror2(resptime-start_respwin<targlat)=1;
berror2(resptime-stop_respwin>targlat)=2;
berror2(berror==3)=3;
berror2(berror==4)=4;

corrcount=sum(resptime-start_respwin>targlat & resptime-stop_respwin<targlat);
try
    altcorrect=sum(altoutcomes)./(sum(altmaybes)+(sum(altmaybes)==0));
catch
    altcorrect=sum(altoutcomes).*0;
end


Nrand=50;
rcorrcount=zeros(Nrand,1);
for jj=1:Nrand,
    [xx,ii]=sort(rand(size(resptime)));
    rcorrcount(jj)=sum(resptime(ii)-start_respwin>targlat & ...
        resptime(ii)-stop_respwin<targlat);
end

score=sprintf('correct: %.1f%%, rand: %.1f +/- %.1f%%\n',...
    corrcount./count.*100,mean(rcorrcount)./count.*100,...
    std(rcorrcount./count).*100);
%score=sprintf('correct: %.1f%% rnd: %.1f+/-%.1f%% time: %.1f%%\n',...
%    altcorrect(targidx(1))*100,mean(altcorrect([1:targidx-1 targidx+1:tonecount]))*100,...
%    std(altcorrect([1:targidx-1 targidx+1:tonecount])).*100,altcorrect(end).*100);

disp([basename(globalparams.mfilename) ': ' score]);

figure

subplot(2,2,1);
bm=[(1:count)' sortrows([berror2 targlat resptime targstep])];
plot(bm(bm(:,2)==0,3),bm(bm(:,2)==0,1),'b.');
hold on
plot(bm(bm(:,2)==0,4),bm(bm(:,2)==0,1),'bx');

plot(bm(bm(:,2)==1,3),bm(bm(:,2)==1,1),'r.');
plot(bm(bm(:,2)==1,4),bm(bm(:,2)==1,1),'rx');

plot(bm(bm(:,2)==2,3),bm(bm(:,2)==2,1),'k.');
plot(bm(bm(:,2)==2,4),bm(bm(:,2)==2,1),'kx');
hold off

ht=title(basename(globalparams.mfilename));
set(ht,'Interpreter','none');


subplot(2,2,2);
cc=cumsum(exptparams.res(:,2)==0)./(1:length(exptparams.res(:,2)))';
Navg=10;
cc2=conv((exptparams.res(:,2)==0),ones(Navg,1)./Navg);
cc2=cc2(1:end-Navg+1);
plot(cc);
hold on
plot(cc2,'g');
hold off
ylabel('frac correct');
xlabel('trial');
legend('cum','mvg');
legend boxoff

subplot(2,2,3);
correct=(berror==0);
fa=(berror==1);
miss=(berror==2);
tfrac=zeros(max(targidx),3);
for tidx=1:max(targidx),
    matchidx=find(targidx==tidx);
    if length(matchidx)>0,
        tfrac(tidx,1)=sum(correct(matchidx));%./length(matchidx);
        tfrac(tidx,2)=sum(fa(matchidx));%./length(matchidx);
        tfrac(tidx,3)=sum(miss(matchidx));%./length(matchidx);
    end
end
bar(tfrac);
xlabel('target idx');
ylabel('frac correct');
legend('ht','fa','ms');
legend boxoff

subplot(2,2,4);

x=linspace(-1,5,35);
rt=resptime-targlat;
[nrt]=hist(rt(~isinf(rt)),x);
[ntt]=hist(resptime(~isinf(resptime)),x);
randrt=zeros(100,length(x));
for ii=1:100,
    trt=resptime-shuffle(targlat);
    randrt(ii,:)=hist(trt(~isinf(trt)),x);
end
mrandrt=mean(randrt);
srandrt=std(randrt).*2;

errorshade(x,mrandrt,srandrt,[1 1 1].*0.75,[1 1 1].*0.75);
hold on
hl=plot(x,[nrt' ntt']);
hold off

legend(hl,{'resp time target','resp time trial'});
legend boxoff
xlabel('time after target/trial (s)');
ylabel('count');
axis ([x(1) x(end) 0 max([nrt(:);ntt(:)]).*1.6]);

if 0
    subplot(2,2,2);

    %[nresp,x]=hist(resptime(~isinf(resptime+targlatency)& berror2<4));
    rt=resptime-targlatency;
    [nresp0]=hist(rt(~isinf(rt)& berror2==0),x);
    [nresp1]=hist(rt(~isinf(rt)& berror2==1),x);
    [nresp2]=hist(rt(~isinf(rt)& berror2==2),x);
    bar(x,[nresp0' nresp1' nresp2'],'stacked');
    
    title('reaction time (after target)');
    
    subplot(2,2,4);
    [ntarg0]=hist(resptime(~isinf(resptime+targlat)& berror2==0),x);
    [ntarg1]=hist(resptime(~isinf(resptime+targlat)& berror2==1),x);
    [ntarg2]=hist(resptime(~isinf(resptime+targlat)& berror2==2),x);
    bar(x,[ntarg0' ntarg1' ntarg2'],'stacked');
    legend('hit','FA','miss');
    
    title('reaction time (after trial)');
elseif 0
    subplot(2,2,2);
    cla
    %x=linspace(-0.1,2.5,25);

    moststeps=max(targstep);
    mm0=zeros(moststeps+1,1);
    mm=zeros(moststeps+1,1);
    for ii=0:moststeps,
        offset=0;
        %offset=stimstepsize.*ii;
        useidx=find(bm(:,5)==ii & ~isinf(bm(:,4)));
        hold on;

        if length(useidx)>1,
            mm0(ii+1)=mean(bm(useidx,4));
            ss=std(bm(useidx,4));
            plot([mm0(ii+1)-ss mm0(ii+1)+ss]-offset,[ii ii],'b:');
        end

        useidx=find(bm(:,5)==ii & ~isinf(bm(:,4)) & bm(:,2)==0);
        if length(useidx)>0,
            mm(ii+1)=mean(bm(useidx,4));
            plot(mm(ii+1)-offset,ii,'kx');
        end
        if length(useidx)>1,
            mm(ii+1)=mean(bm(useidx,4));
            ss=std(bm(useidx,4));
            plot([mm(ii+1)-ss mm(ii+1)+ss]-offset,[ii ii],'k');
        end

        plot(ii.*stimstepsize+start_respwin+[0 0]-offset,[-0.5 0.5]+ii,'k:');
        plot(ii.*stimstepsize+stop_respwin+[0 0]-offset,[-0.5 0.5]+ii,'k:');
        %plot((ii-1).*stimstepsize+start_respwin+[0 0]-offset,[-0.25 0.25]+ii,'r:');
        %plot((ii-1).*stimstepsize+stop_respwin+[0 0]-offset,[-0.25 0.25]+ii,'r:');
        %plot((ii+1).*stimstepsize+start_respwin+[0 0]-offset,[-0.25 0.25]+ii,'r:');
        %plot((ii+1).*stimstepsize+stop_respwin+[0 0]-offset,[-0.25 0.25]+ii,'r:');

    end
    %plot(mm0,0:moststeps,'r:')
    hold off
    axis tight
    ylabel('target lat (tonecount)');
    xlabel('time after trial start');


end

% moved this functionality to baphy.m
%jpegfile=[mfile(1:end-1) 'jpg'];
%fprintf('printing to %s\n',jpegfile);
%print('-djpeg',jpegfile);

set(gcf,'PaperOrientation','landscape','PaperPosition',[0.5 0.5 10 7.5])

if globalparams.rawid>0,
    disp('Saving extended performance data to cellDB...');
    tperf=[];
    tperf.Peak_Lat_Bin=min(find(nrt==max(nrt(find(x>=0)))));
    tperf.Peak_Lat=round(x(tperf.Peak_Lat_Bin).*100)./100;
    tperf.Peak_Resp_Count=nrt(tperf.Peak_Lat_Bin);
    tperf.Peak_Resp_Count_Rand=round(mrandrt(tperf.Peak_Lat_Bin).*100)./100;
    tperf.Peak_Resp_Count_Err=round(srandrt(tperf.Peak_Lat_Bin)./2.*100)./100;
    dbWriteData(globalparams.rawid,tperf,1,1);
end

