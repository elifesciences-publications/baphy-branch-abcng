%function dms_summ(animal,startdate,phys);

baphy_set_path

if ~exist('animal','var'),
   animal='Cassandra';
end
if ~exist('startdate','var'),
   startdate='2011-04-01'
end
if ~exist('phys','var'),
   phys=0;
end
if ~exist('HWSetup','var'),
   HWSetup=[2 4]
   %HWSetup=[1 3]
end
if ~exist('runclass','var'),
   runclass='AMD';
end


HWSetupString='(';
for ii=1:length(HWSetup),
    HWSetupString=[HWSetupString,num2str(HWSetup(ii)),','];
end
HWSetupString(end)=')';
if phys==0,
   phys_str=' AND gDataRaw.training';
elseif phys==1,
   phys_str=' AND not(gDataRaw.training)';
else,
   phys_str='';
end

dbopen;

if strcmp(computer,'PCWIN'),
   resppathbase='/auto/data/';
   %resppathbase='M:\';
else
   resppathbase='/auto/data/';
end

if ~isempty(HWSetup),
    sql=['SELECT gDataRaw.*',...
         ' FROM (gDataRaw INNER JOIN gCellMaster',...
         ' ON gDataRaw.masterid=gCellMaster.id)',...
         ' INNER JOIN gPenetration ON gCellMaster.penid=gPenetration.id',...
         ' INNER JOIN gData ON (gData.rawid=gDataRaw.id AND gData.name="HWSetup")',...
         ' WHERE gPenetration.animal like "',animal,'"',...
         ' AND gPenetration.pendate >= "',startdate,'"',...
         ' AND not(gDataRaw.bad)',...
         ' AND gDataRaw.runclass="',runclass,'" AND corrtrials>0',...
         ' AND gDataRaw.resppath like "',resppathbase,'%"',...
         ' AND gData.value in ',HWSetupString,...
         phys_str,...
         ' ORDER BY pendate,gCellMaster.siteid,gDataRaw.id'];
elseif phys==0 || strcmp(animal,'bom'),
   sql=['SELECT gDataRaw.*',...
        ' FROM (gDataRaw INNER JOIN gCellMaster',...
        ' ON gDataRaw.masterid=gCellMaster.id)',...
        ' INNER JOIN gPenetration ON gCellMaster.penid=gPenetration.id',...
        ' WHERE gPenetration.animal like "',animal,'"',...
        ' AND gPenetration.pendate >= "',startdate,'"',...
        ' AND not(gDataRaw.bad)',...
        ' AND gDataRaw.runclass="DMS" AND corrtrials>0',...
        ' AND gDataRaw.resppath like "',resppathbase,'%"',...
        phys_str,...
        ' ORDER BY pendate,gCellMaster.siteid,gDataRaw.id'];
else
   sql=['SELECT gDataRaw.*',...
        ' FROM (gDataRaw INNER JOIN gCellMaster',...
        ' ON gDataRaw.masterid=gCellMaster.id)',...
        ' INNER JOIN gPenetration ON gCellMaster.penid=gPenetration.id',...
        ' LEFT JOIN gData ON gData.rawid=gDataRaw.id',...
        ' WHERE gPenetration.animal like "',animal,'"',...
        ' AND gPenetration.pendate >= "',startdate,'"',...
        ' AND not(gDataRaw.bad)',...
        ' AND (gData.name="Overlay_Ref_Tar" AND gData.value=0)',...
        ' AND gDataRaw.runclass="DMS" AND corrtrials>0',...
        ' AND gDataRaw.resppath like "',resppathbase,'%"',...
        phys_str,...
        ' ORDER BY pendate,gCellMaster.siteid,gDataRaw.id'];
end
rawdata=mysql(sql);
filecount=length(rawdata);
session=0;

%rawdata=rawdata(1:10);

DI=zeros(filecount,1);
DIerr=zeros(filecount,1);
peaklatidx=zeros(filecount,1);
peaklat=zeros(filecount,1);
peakrate=zeros(filecount,1);
randrate=zeros(filecount,1);
randerr=zeros(filecount,1);
dist_atten_final=zeros(filecount,1);
reftarreldB=zeros(filecount,1);
avg_triallen=zeros(filecount,1);
avg_distlen=zeros(filecount,1);
session=zeros(filecount,1);

trials=cat(1,rawdata.trials);
corrtrials=cat(1,rawdata.corrtrials);
tsession=0;

fprintf('%d matching records...\n',filecount);
for rridx=1:filecount,
   fprintf('rridx=%d: %s\n',rridx,rawdata(rridx).parmfile);
   
   if rridx==1 | rawdata(rridx-1).masterid~=rawdata(rridx).masterid,
      tsession=tsession+1;
   end
   
   mfile=[rawdata(rridx).resppath rawdata(rridx).parmfile];
   [parm,perf]=dbReadData(rawdata(rridx).id);
   
   %if ~isfield(perf,'DI'),
   if ~isfield(perf,'DI'),
      perf.DI=0.5;
      perf.DI_err=0.5;
   end
   if ~isfield(perf,'Peak_Lat'),
      dms_di(mfile);
      [parm,perf]=dbReadData(rawdata(rridx).id);
      jpegpath=[BEHAVIOR_CHART_PATH lower(animal) filesep datestr(now,'yyyy')];
      jpegfile=[basename(mfile(1:end-1)) 'jpg'];
      set(gcf,'PaperOrientation','portrait','PaperPosition',[0.5 0.5 10 7.5])
      print('-djpeg',[jpegpath filesep jpegfile]);
      close(gcf);
   end
   
   if isfield(perf,'Peak_Lat'),
       DI(rridx)=perf.DI;
       DI_err(rridx)=perf.DI_err;
       peaklatidx(rridx)=perf.Peak_Lat_Bin;
       peaklat(rridx)=perf.Peak_Lat;
       peakrate(rridx)=perf.Peak_Resp_Count;
       randrate(rridx)=perf.Peak_Resp_Count_Rand;
       randerr(rridx)=perf.Peak_Resp_Count_Err.*2;
       session(rridx)=tsession;
       avg_triallen(rridx)=parm.Avg_Trial_Len;
       dist_atten_final(rridx)=parm.Ref_Atten_Final;
       reftarreldB(rridx)=parm.Ref_Atten_Final-parm.Tar_Atten;
   else
       disp('does this ever run?')
       keyboard
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

       tonecount=exptparams.tonecount;
       count=length(exptparams.bstat);

       if size(exptparams.bstat{1},2)>1 & ...
               ~(isfield(exptparams,'use_lick') & exptparams.use_lick),
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
       stimstepsize=exptparams.refmean;
       
       altoutcomes=zeros(count,tonecount+1);
       altmaybes=zeros(count,tonecount+1);
       if isempty(exptparams.bstat{count}),
          exptparams.bstat{count}=zeros(size(exptparams.bstat{count-1}));
       end
       
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
               try
                   touch=exptparams.bstat{trialidx}(firsttargbin:end,bstatidx);
               catch
                   disp('touch time err');
                   keyboard
               end
               releasebin=min(find(diff(touch)>0));
               if isempty(releasebin) & (touch(1)==1 | berror(trialidx)<=1),
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
                               reltime-ttones(ii)+ttones(1)<=...
                               exptparams.startwin+exptparams.respwin;
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

       score_old=sprintf('correct: %.1f%%, rand: %.1f +/- %.1f%%\n',...
           corrcount./count.*100,mean(rcorrcount)./count.*100,...
           std(rcorrcount./count).*100);
       score=sprintf('correct: %.1f%% rnd: %.1f+/-%.1f%% time: %.1f%%\n',...
           altcorrect(targidx(1))*100,mean(altcorrect([1:targidx-1 targidx+1:tonecount]))*100,...
           std(altcorrect([1:targidx-1 targidx+1:tonecount])).*100,altcorrect(end).*100);

       disp([basename(globalparams.mfilename) ': ' score]);

       sfigure(1);
       clf

       subplot(2,1,1);
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


       x=linspace(-1,5,35);
       subplot(2,1,2);
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

       drawnow;

       peaklatidx(rridx)=min(find(nrt==max(nrt)));
       peaklat(rridx)=x(peaklatidx(rridx));
       peakrate(rridx)=nrt(peaklatidx(rridx));
       randrate(rridx)=mrandrt(peaklatidx(rridx));
       randerr(rridx)=srandrt(peaklatidx(rridx));
       session(rridx)=tsession;
       avg_distlen(rridx)=exptparams.nolick+exptparams.nolickstd./2;
       avg_triallen(rridx)=exptparams.nolicksilence+avg_distlen(rridx);
       dist_atten_final(rridx)=exptparams.dist_atten_final;

       if globalparams.rawid>0,
           tperf=[];
           tperf.Peak_Lat_Bin=min(find(nrt==max(nrt)));
           tperf.Peak_Lat=round(x(tperf.Peak_Lat_Bin).*100)./100;
           tperf.Peak_Resp_Count=nrt(tperf.Peak_Lat_Bin);
           tperf.Peak_Resp_Count_Rand=round(mrandrt(tperf.Peak_Lat_Bin).*100)./100;
           tperf.Peak_Resp_Count_Err=round(srandrt(tperf.Peak_Lat_Bin)./2.*100)./100;
           dbWriteData(globalparams.rawid,tperf,1,1);
           tparm=[];
           tparm.HWSetup=globalparams.HWSetup;
           dbWriteData(globalparams.rawid,tparm,0,1);
       end
   end
end

correctfrac=corrtrials./trials;

peakfrac=(peakrate-randrate)./(randerr+(randerr==0)).*2;

sesspeakfrac=zeros(max(session),1);
sesscorrectfrac=zeros(max(session),1);
sessavg_triallen=zeros(max(session),1);
sessdist_atten_final=zeros(max(session),1);
sessreftarreldB=zeros(max(session),1);
sessDI=zeros(max(session),1);
for hh=1:max(session),
   sesspeakfrac(hh)=(mean(peakrate(session==hh))-...
                     mean(randrate(session==hh)))./...
       mean(randerr(session==hh)).*2;
   
   sesscorrectfrac(hh)=mean(corrtrials(session==hh))./...
       mean(trials(session==hh));
   sessavg_triallen(hh)=mean(avg_triallen(session==hh));
   sessdist_atten_final(hh)=mean(dist_atten_final(session==hh));
   sessreftarreldB(hh)=mean(reftarreldB(session==hh));
   sessDI(hh)=mean(DI(session==hh));
end

plotfrac=sesspeakfrac;
plotfrac(plotfrac>8)=8;

figure;
clf
subplot(4,1,1);
plot([1 length(plotfrac)],[2 2],'r--','LineWidth',2);
hold on
%plot([1 length(plotfrac)],[3 3],'g--','LineWidth',2);
plot(plotfrac,'LineWidth',2);
hold off
ylabel('peak resp rate (stdev above random)');
title(animal);
a=axis;
axis([0 length(plotfrac)+1 -1 10]);

%legend('p<0.05');

subplot(4,1,2);
plot(sessDI);
ylabel('DI');

subplot(4,1,3);
plot(sessavg_triallen);
ylabel('average trial len (sec)');

subplot(4,1,4);
plot(sessdist_atten_final);
ylabel('distracter atten (dB)');
xlabel('day');

fullpage portrait

drawnow;
