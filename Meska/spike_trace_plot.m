function spike_trace_plot;

global SPKRAW UNITMEAN UNITSTD UNITCOUNT XAXIS PCC PCS SPIKESET UPROJ 
global SPKCLASS SPKCOUNT KCOL C0 CELLIDS EXTRAS EVENTTIMES NEWSNR FILEDATA

TR_COL=[0 0 0; 0.7 0.7 0.7];
SPIKE_SF=64;

trialoffset=405;
trialcount=10;
trialcount2=100;
[chancount,auxchancount,TrialCount,SpikeFs]=evpgetinfo(FILEDATA.evpfile);
[rS,STrialIdx]=evpread(FILEDATA.evpfile,FILEDATA.channel,[],...
                       trialoffset+(1:trialcount2));
STrialIdx(end+1)=length(rS)+1;
sigthresh=-EXTRAS.sigma.*EXTRAS.sigthreshold./SPIKE_SF;

trialbins=EXTRAS.trialstartidx(trialoffset+1)-...
          EXTRAS.trialstartidx(trialoffset+trialcount2)+1;
eventidx=find(EVENTTIMES>=EXTRAS.trialstartidx(trialoffset+1) &...
              EVENTTIMES<EXTRAS.trialstartidx(trialoffset+trialcount2+1));
eventtimes=(EVENTTIMES(eventidx)- ...
            EXTRAS.trialstartidx(1+trialoffset)+1)./SpikeFs;
spkclass=SPKCLASS(eventidx);

[stim,stimparam]=loadstimfrombaphy(FILEDATA.parmfile,[],[],'gamma264',500,100,0,1);

stimset=zeros(trialcount,1);
for trialidx=1:trialcount,
    [~,~,Note]=evtimes(EXTRAS.exptevents,'Stim*',trialidx+trialoffset);
    tags=strsep(Note{1},',');
    tag=strtrim(tags{2});
    stimset(trialidx)=find(strcmp(tag,stimparam.tags));
end

figure
subplot(3,2,1);

apair1=[1 1 2];
apair2=[2 3 3];
k=size(UNITMEAN,3);

uu=1;
%testrange=round(linspace(1,length(SPIKESET),2000));
u1=apair1(uu);
u2=apair2(uu);

PLOT_RAND=1;
trand=round(rand(500,1)*(length(rS)-20))+10;
st=XAXIS(1):XAXIS(2);
SP_RAND=zeros(length(st),length(trand));
UP_RAND=zeros(length(trand),2);
for ii=1:length(trand),
    SP_RAND(:,ii)=rS(trand(ii)+st);
    UP_RAND(ii,:)=PCS(:,1:2)'*SP_RAND(:,ii);
end
%keyboard
%for jj=max(SPKCLASS):-1:1,
%    spmatch=find(SPKCLASS==jj);
for jj=2:-1:1,
    if jj==1,
        spmatch=eventidx(find(spkclass==jj));
    else
        spmatch=eventidx(find(spkclass~=jj));
    end
    if length(spmatch)>0
        testrange=spmatch(round(linspace(1,length(spmatch),...
                                         round(1200/max(SPKCLASS)))));
        
        if PLOT_RAND && jj==2,
            plot(UP_RAND(:,u1),UP_RAND(:,u2),'.','Color',TR_COL(jj,:));
        else
            plot(UPROJ(testrange,u1),UPROJ(testrange,u2),'.','Color',TR_COL(jj,:));
        end
        hold on
    end
end
a=[mean(UPROJ(:,u1))-std(UPROJ(:,u1)).*4 ...
   mean(UPROJ(:,u1))+std(UPROJ(:,u1)).*4 ...
   mean(UPROJ(:,u2))-std(UPROJ(:,u2)).*4 ...
   mean(UPROJ(:,u2))+std(UPROJ(:,u2)).*4];
plot([a(1) a(2)],[0 0],'k--');
plot([0 0],[a(3) a(4)],'k--');
hold off

for ii=1:UNITCOUNT,
    x0=PCS(:,u1)'*UNITMEAN(:,ii);
    xs=PCS(:,u1)'*UNITSTD(:,ii);
    y0=PCS(:,u2)'*UNITMEAN(:,ii);
    ys=PCS(:,u2)'*UNITSTD(:,ii);
    %ht=text(x0,y0,num2str(ii));
    %set(ht,'Color',[1 0 0]);
end

xm=mean(UPROJ(:,u1));
ym=mean(UPROJ(:,u2));
xs=std(UPROJ(:,u1));
ys=std(UPROJ(:,u2));

axis(a);
%axis tight
aa=axis;

%axis([max([aa(1) xm-xs.*5]) min([aa(2) xm+xs.*5]) ...
%      max([aa(3) ym-ys.*5]) min([aa(4) ym+ys.*5])]);

title(sprintf('PCs %d vs %d',u1,u2));



classcount=max(SPKCLASS);
plotcount=max([UNITCOUNT+1 classcount]);
a=[];

yoff=0.1;
ysp=(1-yoff.*1.5)./plotcount;
yh=ysp.*0.75;
if yh>0.4,
    yh=0.4;
end

subplot(3,2,2);

% cummulative spike display
NEWSNR=zeros(classcount,1);
st=(XAXIS(1):XAXIS(2))./20000;
lstr={};
hl=zeros(2,1);
for jj=2:-1:1,
    %if jj==1,
        spmatch=eventidx(find(spkclass==jj));
        %else
        %    spmatch=eventidx(find(spkclass~=jj));
        %end
    
    newunitmean=mean(SPIKESET(:,spmatch),2);
    newunitstd=std(SPIKESET(:,spmatch),0,2);
    
    if length(spmatch)>0,
        testidx=spmatch(round(linspace(1,length(spmatch),50)));
        if PLOT_RAND && jj==2,
            tl=plot(st,SP_RAND./SPIKE_SF,'Color',TR_COL(jj,:));
        else
            tl=plot(st,SPIKESET(:,testidx)./SPIKE_SF,'Color',TR_COL(jj,:));
        end
        hl(jj)=tl(1);
    end
    hold on
    if jj==k,
        plot(st([1 end]),-EXTRAS.sigma.*EXTRAS.sigthreshold./SPIKE_SF.*[1 1],'k--');
    end
    lstr{jj}=sprintf('%d:%d',jj,length(spmatch));
end
hold off
legend(hl,lstr,'Location','SouthEast');
legend boxoff

[pp,bb]=fileparts(FILEDATA.evpfile);
title(bb,'Interpreter','None');


for trialidx=1:trialcount,
    
    trialbins=EXTRAS.trialstartidx(trialidx+1)-EXTRAS.trialstartidx(trialidx)+1;
    eventidx=find(EVENTTIMES>=EXTRAS.trialstartidx(trialidx+trialoffset) &...
                  EVENTTIMES<EXTRAS.trialstartidx(trialidx+trialoffset+1));
    eventtimes=(EVENTTIMES(eventidx)- ...
                EXTRAS.trialstartidx(trialidx+trialoffset)+1)./SpikeFs;
    spkclass=SPKCLASS(eventidx);
    
    r=rS(STrialIdx(trialidx)+(1:trialbins))./SPIKE_SF;
    tt=(1:trialbins)'./SpikeFs;
    
    subplot(ceil(trialcount.*1.5),2,ceil(trialcount./2)*2+trialidx*2-1);
    imagesc(stim(:,:,stimset(trialidx)));
    axis xy
    axis off
    
    subplot(ceil(trialcount.*1.5),2,ceil(trialcount./2)*2+trialidx*2);
    plot(tt,r,'k-','LineWidth',0.5);
    
    hold on;
    %for jj=(classcount):-1:1,
    %    if sum(spkclass==jj)>0,
    %        plot(eventtimes(spkclass==jj),sigthresh,'o','Color',KCOL{jj});
    %    end
    %end
    for jj=1 % 2:-1:1,
        if jj==1,
           spmatch=find(spkclass==jj);
        else
             spmatch=find(spkclass~=jj & spkclass<max(SPKCLASS));
         end
          if ~isempty(spmatch),
              plot(eventtimes(spmatch),sigthresh,'o','Color',KCOL{jj});
          end
    end
    hold off
    axis tight
    set(gca,'YTick',[]);
    if trialidx<trialcount, set(gca,'XTick',[]); end
    ylabel(sprintf('Trial %d',trialidx+trialoffset));
    
    
end
xlabel('Time (sec)');
fullpage portrait

