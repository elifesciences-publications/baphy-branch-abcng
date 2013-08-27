
if 0,
    cellid='por016e-a1'; SNS_Plot;
    cellid='por017c-a1'; SNS_Plot;
    cellid='por020a-a1'; SNS_Plot;
    cellid='por021b-a1'; SNS_Plot;
    cellid='por022a-a1'; SNS_Plot;
    cellid='por023a-a1'; SNS_Plot;
    cellid='por028d-a1'; SNS_Plot;
    cellid='por053a-02-1'; SNS_Plot;
end

datapath='/auto/users/svd/data/SNS/';

datafile=[datapath,cellid,'.mat']
LOADFROMDB=1;

if LOADFROMDB | ~exist(datafile,'file'),
    cellfiledata=dbgetscellfile('runclass','SNS','cellid',cellid);
    
    parmfile=[cellfiledata(1).stimpath cellfiledata(1).stimfile];
    spikefile=[cellfiledata(1).path cellfiledata(1).respfile];
    
    options=[];
    options.rasterfs=100;
    
    [r,TrialCategory,TarIdx,DisIdx,BigSequenceMatrix,exptparams,Trial2Seq]= ...
        LoadSNS(parmfile,spikefile,options);
    
    disp('saving preloaded data for later');
    save(datafile,'r','TrialCategory','TarIdx', ...
          'DisIdx','BigSequenceMatrix','exptparams');
    
    copyfile([parmfile '.m'],[datapath 'raw' filesep]);
    copyfile(spikefile,[datapath 'raw' filesep]);
    
else
    disp('using pre-loaded data');
    load(datafile);
end

CellCount=size(r,4);
SamplesPerTrial=exptparams.TrialObject.SamplesPerTrial;
PreStimSilence=(exptparams.TrialObject.PreTrialSilence);
PostStimSilence=(exptparams.TrialObject.PostTrialSilence);
SampleDur=(exptparams.TrialObject.ReferenceHandle.Duration);
SampleStarts=round(((0:SamplesPerTrial).*SampleDur+PreStimSilence).*options.rasterfs)+1;
SampleStops=SampleStarts+round(SampleDur.*options.rasterfs)-1;

TarSet=unique(TarIdx(TarIdx>0));
DisSet=unique(DisIdx(DisIdx>0));

ComboCount=length(TarSet)*length(DisSet);

% 1 FixTarOnlySeq
% 2 FixTarVarDisSeq
% 3 FixTarFixDisSeq
% 4 VarDisOnlySeq
% 5 FixDisOnlySeq
% 6 VarTarVarDisSeq

bcm=repmat(permute(TrialCategory,[2 3 1]),[SamplesPerTrial 1]);
MinRep=4;
catset=[1 2 3 6];
CatCount=length(catset);

close all
for cid=1:CellCount
    figure;
    tc=0;
    rTarAlone=zeros(round(SampleDur.*options.rasterfs),max(TarSet));
    for tt=TarSet(:)',
        tc=tc+1;
        
        soloreptar=find(bcm==1 & BigSequenceMatrix(:,1,:)==tt);
        reptar=find(bcm==2 & BigSequenceMatrix(:,1,:)==tt);
        nreptar=find(bcm==6 & (BigSequenceMatrix(:,1,:)==tt | BigSequenceMatrix(:,2,:)==tt));
        
        soloslot=mod((soloreptar-1),SamplesPerTrial)+1;
        solotrial=floor((soloreptar-1)./SamplesPerTrial)+1;
        repslot=mod((reptar-1),SamplesPerTrial)+1;
        reptrial=floor((reptar-1)./SamplesPerTrial)+1;
        nrepslot=mod((nreptar-1),SamplesPerTrial)+1;
        nreptrial=floor((nreptar-1)./SamplesPerTrial)+1;
        
        solorep=zeros(diff(SampleStarts(1:2)),SamplesPerTrial);
        rrep=zeros(diff(SampleStarts(1:2)),SamplesPerTrial);
        rnrep=zeros(diff(SampleStarts(1:2)),SamplesPerTrial);
        for sl=1:SamplesPerTrial,
            ff=find(soloslot==sl);
            solorep(:,sl)=mean(nanmean(r(SampleStarts(sl):(SampleStarts(sl+1)-1),:,solotrial(ff),cid),2),3);
            ff=find(repslot==sl);
            rrep(:,sl)=mean(nanmean(r(SampleStarts(sl):(SampleStarts(sl+1)-1),:,reptrial(ff),cid),2),3);
            ff=find(nrepslot==sl);
            rnrep(:,sl)=mean(nanmean(r(SampleStarts(sl):(SampleStarts(sl+1)-1),:,nreptrial(ff),cid),2),3);
        end
        
        subplot(max(TarSet)+1,2,tc*2-1);
        plot([rrep(:) rnrep(:) solorep(:)]);
        aa=axis;
        hold on
        for jj=1:SamplesPerTrial,
            plot([0 0]+SampleDur*options.rasterfs*jj,[0 aa(4)],'k--');
        end
        hold off
        ht=title(sprintf('%s - cell %d - tar %d', ...
                         basename(parmfile),cid,tt));
        set(ht,'Interpreter','none');
        
        subplot(max(TarSet)+1,2,tc*2);
        plot([mean(rrep(:,MinRep:end),2) ...
              mean(rnrep(:,MinRep:end),2) ...
              mean(solorep(:,MinRep:end),2)],'LineWidth',2);
        legend('RepTar','RandBoth','SoloTar');
        
        excltrials=find(TrialCategory~=1);
        ff=(BigSequenceMatrix(:,:,:)==tt);
        ff(:,:,excltrials)=0;
        ff(1:(MinRep-1),:,:)=0;
        ff=squeeze(sum(ff,2));
        [sl,tr]=find(ff);
        tmat=zeros(size(rTarAlone,1),length(sl));
        for ii=1:length(sl),
            tmat(:,ii)=nanmean(r(SampleStarts(sl(ii)): ...
                      (SampleStarts(sl(ii)+1)-1),:,tr(ii),cid),2);
        end
        rTarAlone(:,tt)=mean(tmat,2);
        rTarAlone(:,tt)=rTarAlone(:,tt)-mean(rTarAlone(:,tt));
        
    end
    
    % 1 FixTarOnlySeq
    % 2 FixTarVarDisSeq
    % 3 FixTarFixDisSeq
    % 4 VarDisOnlySeq
    % 5 FixDisOnlySeq
    % 6 VarTarVarDisSeq
    SampleCount=exptparams.TrialObject.ReferenceHandle.Count;
    
    rmean=zeros(round(SampleDur.*options.rasterfs),SampleCount,CatCount);
    rerr=zeros(round(SampleDur.*options.rasterfs),SampleCount,CatCount);
    CC=zeros(CatCount,4);
    
    for catidx=1:CatCount,
        excltrials=find(TrialCategory~=catset(catidx));
        for tt=1:SampleCount,
            ff=(BigSequenceMatrix(:,:,:)==tt);
            ff(:,:,excltrials)=0;
            ff(1:(MinRep-1),:,:)=0;
            ff=squeeze(sum(ff,2));
            [sl,tr]=find(ff);
            if ~isempty(sl),
                tmat=zeros(size(rmean,1),length(sl));
                for ii=1:length(sl),
                    tmat=cat(2,tmat,r(SampleStarts(sl(ii)): ...
                             (SampleStarts(sl(ii)+1)-1),:,tr(ii),cid));
                    %if catidx==1,
                    %    tmat(:,ii)=nanmean(r(SampleStarts(sl(ii)): ...
                    %        (SampleStarts(sl(ii)+1)-1),1,tr(ii),cid),2);
                    %else
                    %    tmat(:,ii)=r(SampleStarts(sl(ii)): ...
                    %        (SampleStarts(sl(ii)+1)-1),1,tr(ii),cid);
                    %end
                end
                tmat=tmat(:,find(~isnan(tmat(1,:))));
                rmean(:,tt,catidx)=mean(tmat,2);
                rerr(:,tt,catidx)=std(tmat,0,2);%./sqrt(size(tmat,2));
                
                tmat=tmat-repmat(mean(tmat),[size(tmat,1) 1]);
                if tt==1,
                    CC(catidx,1)=mean(rTarAlone(:,1)'*tmat)./...
                        var(rTarAlone(:,1))./length(rTarAlone);
                    CC(catidx,2)=mean(rTarAlone(:,2)'*tmat)./var(rTarAlone(:,2))./length(rTarAlone);
                else
                    CC(catidx,3)=mean(rTarAlone(:,1)'*tmat)./var(rTarAlone(:,1))./length(rTarAlone);
                    CC(catidx,4)=mean(rTarAlone(:,2)'*tmat)./var(rTarAlone(:,2))./length(rTarAlone);
                end
            end
            
            if tt==1,
                fprintf('cid=%d tt=%d catidx=%d n=%d\n',...
                        cid,tt,catidx,size(tmat,2));
            end
        end
        %subplot(3,2,catidx);
        %errorbar(rmean(:,1:2,catidx),rerr(:,1:2,catidx));
        %title(sprintf('cid=%d, catidx=%d',cid,catset(catidx)));
        
    end
    
    subplot(max(TarSet)+1,2,max(TarSet)*2+1);
    plot(CC);
    legend('1,1','2,1','1,2','2,2');
    xlabel('single -- rep -- RDctl -- rand');
end


options.filtfmt='specgram';
fullstim=loadstimbytrial(parmfile,options);
stim=zeros(size(fullstim,1),size(r,1),max(Trial2Seq),...
           size(fullstim,4));
for jj=1:max(Trial2Seq),
    tridx=find(Trial2Seq==jj,1);
    stim(:,:,jj,:)=fullstim(:,1:size(r,1),tridx,:);
end

PreBins=round(PreStimSilence.*options.rasterfs);
PostBins=round(PostStimSilence.*options.rasterfs);

fb=SampleStarts(1);
lb=SampleStarts(end)-1;

% stim0 is summed stimulus (both noise streams)
randtrials=find(ismember(TrialCategory,[4 6]));
stim0=stim(:,fb:lb,randtrials,3);
r0=permute(squeeze(nanmean(r(fb:lb,:,randtrials,:),2)),[1 3 2]);

reptrials=find(ismember(TrialCategory,[1 2 3]));
test_r0=permute(squeeze(nanmean(r(fb:lb,:,reptrials,:),2)),[1 3 2]);
[teststim,xcperchan]=quick_recon(r0,stim0,test_r0);

val_stim=stim(:,fb:lb,reptrials,:);
chancount=size(stim,1);

xcval=zeros(chancount,length(reptrials),3);
xcvalearly=zeros(chancount,length(reptrials),3);
eb=30;
for cc=1:chancount,
    for tt=1:length(reptrials),
        tp=mean(teststim(cc,:,tt,:),4);
        for bb=1:3,
            xcvalearly(cc,tt,bb)=...
                xcov(tp(1:eb),val_stim(cc,1:eb,tt,bb),0,'coeff');
            xcval(cc,tt,bb)=...
                xcov(tp(eb+1:end),val_stim(cc,eb+1:end,tt,bb),0,'coeff');
        end
    end
end

ff1=find(TrialCategory(reptrials)==2 & TarIdx(reptrials)==1);
ff2=find(TrialCategory(reptrials)==2 & TarIdx(reptrials)==2);
figure;
stimsets={'Tar','Dis','Both'};
for bb=1:3,
    subplot(4,2,bb*2-1);
    plot(xcval(:,ff1,bb));
    axis([0 chancount+1 -0.2 1]);
    title(sprintf('%s tar %d - %s',cellid,1,stimsets{bb}));
    
    subplot(4,2,bb*2);
    plot(xcval(:,ff2,bb));
    axis([0 chancount+1 -0.2 1]);
    title(sprintf('tar %d - %s',2,stimsets{bb}));
end
subplot(4,2,7);
plot(xcval(:,ff1,1)-xcval(:,ff1,3));
hold on;
plot(mean(xcval(:,ff1,1)-xcval(:,ff1,3),2),'k-','LineWidth',2);
plot(mean(xcvalearly(:,ff1,1)-xcvalearly(:,ff1,3),2),'g--','LineWidth',2);
hold off
axis([0 chancount+1 -0.5 0.5]);
title('Target 1 - Tar-Both');

subplot(4,2,8);
plot(xcval(:,ff2,1)-xcval(:,ff2,3));
hold on;
plot(mean(xcval(:,ff2,1)-xcval(:,ff2,3),2),'k-','LineWidth',2);
plot(mean(xcvalearly(:,ff2,1)-xcvalearly(:,ff2,3),2),'g--','LineWidth',2);
hold off
axis([0 chancount+1 -0.5 0.5]);
title('Target 2 - Tar-Both');

print('-dpng',['~/data/SNS/results/',cellid,'.png']);


return


