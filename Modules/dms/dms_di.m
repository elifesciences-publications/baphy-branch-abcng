% function globalparams=dms_plot_ext(exptparams,events,count);
%
% extended dms behavior analysis -- revised to use Pingbo's
% discrimination index (DI)
%
% created 2008-07-16 SVD, ripped off of dms_plot_ext.m
%
function globalparams=dms_di(exptparams,exptevents,count);

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

if size(exptparams.bstat{1},2)>1 && ...
      ~(isfield(exptparams,'use_lick') && exptparams.use_lick),
    % backwards compatible with old ver dms
    bstatidx=2;
else
    bstatidx=1;
end

targlat=exptparams.res(:,1);
berror=exptparams.res(:,2);
targidx=exptparams.res(:,5);
tstring=exptparams.tstring;
if length(targidx)<count,
    count=length(targidx);
end
resptime=zeros(count,1);
triallen=zeros(count,1);
cuetrial=zeros(count,1);
size(resptime)
if isfield(exptparams,'dur'),
    stimstepsize=exptparams.dur+exptparams.gapdur;
else
    stimstepsize=exptparams.refmean+...
        exptparams.ReferenceObject.PreStimSilence+...
        exptparams.ReferenceObject.PostStimSilence;
end
if isfield(exptparams,'distobject') & ~exptparams.distobject
    targlat=ceil(targlat./stimstepsize).*stimstepsize;
end

TargNoteSet=evunique(exptevents,'*TARG*');
keepidx=[];
for jj=1:length(TargNoteSet),
    if ~isempty(findstr(TargNoteSet{jj},'Stim ,')),
        keepidx=[keepidx jj];
    end
end
TargNoteSet={TargNoteSet{keepidx}}

newtargidx=zeros(size(targidx));
for ii=1:length(targidx),
    if berror(ii)==1,
        % false alarm
        TargNote='NONE PLAYED';
        newtargidx(ii)=0;
    else
        TargNote=evunique(exptevents,'*TARG*',ii);
        keepidx=[];
        for jj=1:length(TargNote),
            if ~isempty(findstr(TargNote{jj},'Stim ,')),
                keepidx=[keepidx jj];
            end
        end
        if isempty(keepidx),
            TargNote='NONE PLAYED';
            newtargidx(ii)=0;
        else
            TargNote=TargNote{keepidx(1)};
            newtargidx(ii)=find(strcmp(TargNoteSet,TargNote));
            fprintf('%3d (%2d):  %2d-->%2d  %s\n',ii,berror(ii),targidx(ii),newtargidx(ii),TargNote);
        end
    end
end
for ii=1:length(TargNoteSet),
    tt=strsep(TargNoteSet{ii},',',1);
    TargNoteSet{ii}=strtrim(tt{2});
end

altoutcomes=zeros(count,tonecount+1);
altmaybes=zeros(count,tonecount+1);

earliesttargettime=min(targlat);
validstimtime=[];
validstimtype=[];
validrt=[];

for trialidx=1:count,
    
    ttarg=evtimes(exptevents,['Stim , ',tstring{targidx(trialidx)},'*'],...
                  trialidx);
    % find all real stim events (ie, not "STIM,ON" events)
    [ttones,ttr,tnames]=evtimes(exptevents,['Stim ,*'],trialidx);
    
    if isempty(ttarg),
       % backwards compatibility
       ttarg=evtimes(exptevents,['Stim,',tstring{targidx(trialidx)},'*'],...
                     trialidx);
    end
    if isempty(ttones),
       % backwards compatibility
       % find all real stim events (ie, not "STIM,ON" events)
       [ttones,ttr,tnames]=evtimes(exptevents,['Stim,*'],trialidx);
    end
    
    %if length(ttarg)==length(ttones),
    %    cuetrial(trialidx)=1;
    %    targlat(trialidx)=0;
    %end
    
    if length(ttones)>0,
        % figure out time of first stimulus
        firststimbin=round(ttones(1).*exptparams.bfs);
        if firststimbin==0,
            firststimbin=1;
        end
        
        % excise lick data from before first stimulus
        touch=exptparams.bstat{trialidx}(firststimbin:end,bstatidx);
        
        releasebin=min(find(diff(touch)>0));
        if isempty(releasebin) && ...
              (length(touch)==0 || touch(1)==1 || berror(trialidx)<=1),
            releasebin=0;
        elseif isempty(releasebin),
            releasebin=inf;
        end
        
        ttarg=ttarg-ttones(1);
        ttones=ttones-ttones(1);
        if isempty(ttarg),
           ttarg=-1;
        else
           ttarg=ttarg(1);
        end
        ttones=unique(ttones);
    else
        releasebin=-inf;
    end
    
    reltime=releasebin./exptparams.bfs;
    resptime(trialidx)=reltime;
    triallen(trialidx)=size(exptparams.bstat{trialidx},1)./exptparams.bfs;
    
    % find first stim occuring in valid range (ie, at least as late
    % as the earliest target time)
    firststimidx=min(find(ttones+0.001>=earliesttargettime));
    
    % last stim occuring before response. on correct trials, this
    % should be the target. on FA trials, this should be a reference
    laststimidx=max(find(ttones+exptparams.startwin<resptime(trialidx)+0.001));
    
    if ~isempty(laststimidx),
       saverange=firststimidx:laststimidx;
       validstimtime=[validstimtime;ttones(saverange)];
       validstimtype=[validstimtype;ttones(saverange(:))==ttarg];
       validrt=[validrt;ones(length(saverange),1).*reltime];
       
       if length(validstimtype)~=length(validrt),
          trialidx
       end
    end
end
targstep=round(targlat./stimstepsize);

% remove cue trials
berror(find(cuetrial))=4;

start_respwin=exptparams.startwin;
stop_respwin=exptparams.startwin+exptparams.respwin;

berror2=berror.*0;  % 0=hit
berror2(resptime-start_respwin<targlat)=1;  % 1=FA
berror2(resptime-stop_respwin>targlat)=2;   % 2=miss
berror2(berror==3)=3;  % timeout, trial didn't start
berror2(berror==4)=4;  % cue trial, skip

% mark all misses at end as cue trials and skip
mm=max(find(berror~=2));
berror2((mm+1):end)=4;

corrcount=sum(berror2==0);

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

disp([basename(globalparams.mfilename) ': ' score]);

stepcount=50;

hitcount=sum(berror2==0);
facount=sum(berror2==1);

if ~isempty(validstimtime),
   
   [di,hits,fas,tsteps]=compute_di(validstimtime,validrt,validstimtype,...
                                   stop_respwin,stepcount);
   jackcount=20;
   jack_di=zeros(jackcount,1);
   for jj=1:jackcount,
      excludeidx=(0:jackcount:(length(validstimtime)-jackcount))+jj;
      useidx=setdiff(1:length(validstimtime),excludeidx);
      
      jack_di(jj)=compute_di(validstimtime(useidx),validrt(useidx),...
                             validstimtype(useidx),stop_respwin,stepcount);
   end
   
   di_err=std(jack_di).*sqrt(jackcount);
else
   di=0.5;
   di_err=0.5;
   hits=0;
   fas=0;
   tsteps=0;
end

% total number of targets presented, ie, one for each hit and miss trial
targcount=sum(validstimtype==1);
% total number of references = total stim minus targcount
refcount=sum(validstimtype==0);

fprintf('hits: %d FAs: %d\n',hitcount,facount);
fprintf('target count: %d  reference count: %d\n',targcount,refcount);
fprintf('DI: %.3f +/- %.3f\n',di,di_err);

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
axis([0 max([bm(:,3);bm(~isinf(bm(:,4)),4)])+0.2 -1 max(find(bm(:,2)<=2))+2])


subplot(3,2,2);
cc=cumsum(exptparams.res(:,2)==0)./(1:length(exptparams.res(:,2)))';
Navg=10;
cc2=conv(double(exptparams.res(:,2)==0),ones(Navg,1)./Navg);
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
correct=(berror2==0);
fa=(berror2==1);
miss=(berror2==2);
tfrac=zeros(max(newtargidx),3);
for tidx=1:max(targidx),
    matchidx=find(newtargidx==tidx);
    if length(matchidx)>0,
        tfrac(tidx,1)=sum(correct(matchidx));%./length(matchidx);
        tfrac(tidx,2)=sum(miss(matchidx));%./length(matchidx);
        tfrac(tidx,3)=sum(fa(matchidx));%./length(matchidx);
    end
end
if size(tfrac,1)==1,
   tfrac=cat(1,tfrac,zeros(size(tfrac)));
end
barh(tfrac);
xlabel('frac correct');
legend('ht','ms','fa');
legend boxoff
title(sprintf('h: %d m: %d fa: %d',sum(berror==0),sum(berror==2),sum(berror==1)));
for ii=1:length(TargNoteSet),
    h=text(0.2,ii,TargNoteSet{ii},'VerticalAlignment','bottom','FontSize',8);
end


subplot(3,2,4);

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
axis ([x(1) x(end) 0 max([nrt(:);ntt(:)]).*1.6+1]);

subplot(3,2,6);
cla
plot(tsteps,[hits fas]);
ylabel('cumm resp prob');
xlabel('time after last stim');
legend('hits','FAs','location','northwest');
legend boxoff
title(sprintf('DI: %.3f +/- %.3f\n',di,di_err));

set(gcf,'PaperOrientation','landscape','PaperPosition',[1.75 0.5 7.5 7.5])

if globalparams.rawid>0,
    disp('Saving extended performance data to cellDB...');
    tperf=[];
    tperf.Peak_Lat_Bin=min(find(nrt==max(nrt(find(x>=0)))));
    tperf.Peak_Lat=round(x(tperf.Peak_Lat_Bin).*100)./100;
    tperf.Peak_Resp_Count=nrt(tperf.Peak_Lat_Bin);
    tperf.Peak_Resp_Count_Rand=round(mrandrt(tperf.Peak_Lat_Bin).*100)./100;
    tperf.Peak_Resp_Count_Err=round(srandrt(tperf.Peak_Lat_Bin)./2.*100)./100;
    tperf.DI=di;
    tperf.DI_err=di_err;
    dbWriteData(globalparams.rawid,tperf,1,1);
end

