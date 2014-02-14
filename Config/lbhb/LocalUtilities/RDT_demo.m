cellid='oys027b-c1'; % has two behavior sessions. single unit, low spont,facilitation
%cellid='oys027b-c2'; % has two behavior sessions. multiunit.
%cellid='oys027c-c1'; % single unit, low spont. 
%cellid='oys027c-c2'; % multiunit.
%cellid='oys028a-c2';
%cellid='oys028a-c1'; % single unit. Interesting dynamics here too. Reliable responses.
%cellid='oys033a-a1'; % single unit. Interesting dynamics, but not very responsive.
%cellid='oys033a-b1'; % multiunit. Interesting response.
%cellid='oys033b-a1'; % multiunit. Resp to both target. (compare 12). high spont.
%cellid='oys033b-b1'; % single unit. Not super responsive cell (compare 12). low spont.
%cellid='oys033c-a1';
%cellid='oys033c-b1'; % single unit, very cool resp. (compare 12). resp to tar2 inhibitory.
%cellid='oys034b-a1'; % singel unit. High spont. Inhbitory resp?
%cellid='oys034c-b1'; % multiunit. nothing. Weird STRF and basically no resp.
%cellid='oys034c-a2';
%cellid='oys034d-a1';
%cellid='oys034d-a2';
%cellid='oys024c-a1';

close all

% go to cell db to find active and passive data for this cell
cellfiledata=dbgetscellfile('cellid',cellid,'runclass','RDT',...
                            'behavior','active');
cellfiledata2=dbgetscellfile('cellid',cellid,'runclass','RDT',...
                             'Trial_Mode','RandAndRep');
active=1;
if active,
    fidx=1;
    parmfile=[cellfiledata(fidx).stimpath cellfiledata(fidx).stimfile];
    spikefile=[cellfiledata(fidx).path cellfiledata(fidx).respfile];
else
    if strcmpi(cellfiledata2(1).behavior,'passive'),
        uidx=1;
    elseif strcmpi(cellfiledata2(end).behavior,'passive'),
        uidx=length(cellfiledata2);
    else
        uidx=1;
    end
    parmfile=[cellfiledata2(uidx).stimpath cellfiledata2(uidx).stimfile];
    spikefile=[cellfiledata2(uidx).path cellfiledata2(uidx).respfile];
end

options.rasterfs=100;
options.channel=cellfiledata(1).channum;
options.unit=cellfiledata(1).unit;
options.resp_shift=0.0;

% r=response (time X trialcount), only for correct trials
[r,params]=load_RDT_by_trial(parmfile,spikefile,options); 


if 1,
    % load the stimulus spectrogram
    options.filtfmt='gamma';
    options.chancount=30;
    s=loadstimbytrial(parmfile,options);
    
    % extract only correct trials, which should match size(r,2)
    % and only save mixed stream stimululs spectrogram s(:,:,:,3)
    s=s(:,:,params.CorrectTrials,3);
    
    %trialidx=4;
    %goodbins=find(~isnan(s(1,:,trialidx)));
    %clf
    %subplot(2,1,1);
    %imagesc(s(:,goodbins,trialidx));
    %axis xy;
    %subplot(2,1,2);
    %plot(r(goodbins,trialidx));
else
    s=[];
end

% load narf STRF if exists
%narf_modelname='gtSNS30_log2_wc03_dep1perchan_siglog100_fit05';
narf_modelname='gtSNS30_log2_wc03_fir_siglog100_fit05';
strfs=get_strf_from_model(262,{cellid},{narf_modelname});
if ~isempty(strfs{1}),
    strf=strfs{1};
else
    strf=[];
end



rrefall=[];
rtar1solo=[];
rtar1=[];
rtar2solo=[];
rtar2=[];
TargetStartBin=params.TargetStartBin(params.CorrectTrials);
ThisTarget=params.ThisTarget(params.CorrectTrials);
BigSequenceMatrix=params.BigSequenceMatrix(:,:,params.CorrectTrials);
singleTrial=squeeze(BigSequenceMatrix(1,2,:)==-1);
TarRepCount=params.SamplesPerTrial-max(TargetStartBin)+1;
TarDur=params.PreStimSilence+TarRepCount.*params.SampleDur;
TarBins=round(params.rasterfs.*TarDur);

TarStartTime=params.SampleStarts(TargetStartBin);

for tt=1:length(TargetStartBin),
    if TargetStartBin(tt)>0,
        tarstart=round((TargetStartBin(tt)-1).*params.SampleDur.*params.rasterfs+1);
        tar=nan(size(r,1),1);
        tar(1:TarBins)=r(tarstart-1+(1:TarBins),tt);
        if ThisTarget(tt)==params.TargetIdx(1) && ...
                BigSequenceMatrix(1,2,tt)==-1,
            rtar1solo=cat(2,rtar1solo,tar);
        elseif ThisTarget(tt)==params.TargetIdx(1),
            rtar1=cat(2,rtar1,tar);
        elseif ThisTarget(tt)==params.TargetIdx(2) && ...
                BigSequenceMatrix(1,2,tt)==-1,
            rtar2solo=cat(2,rtar2solo,tar);
        elseif ThisTarget(tt)==params.TargetIdx(2),
            rtar2=cat(2,rtar2,tar);
        else
            %disp('no target match??');
        end
        refend=tarstart-1+round(params.rasterfs.*params.PreStimSilence);
    else
        refend=size(r,1);
    end
    ref=nan(size(r,1),1);
    ref(1:refend)=r(1:refend,tt);
    rrefall=cat(2,rrefall,ref);
end

rref1solo=[];
rref1=[];
rref2solo=[];
rref2=[];
singleTrial=squeeze(BigSequenceMatrix(1,2,:)==-1);
for bb=2:params.SamplesPerTrial,
    br=params.SampleStarts(bb):params.SampleStops(bb);
    ff=find((TargetStartBin<0 | bb<TargetStartBin) &...
            singleTrial & ...
            squeeze(BigSequenceMatrix(bb,1,:)==params.TargetIdx(1)));
    rref1solo=cat(2,rref1solo,r(br,ff));
    ff=find((TargetStartBin<0 | bb<TargetStartBin) &...
            ~singleTrial & ...
            squeeze(BigSequenceMatrix(bb,1,:)==params.TargetIdx(1)));
    rref1=cat(2,rref1,r(br,ff));
    ff=find((TargetStartBin<0 | bb<TargetStartBin) &...
            singleTrial & ...
            squeeze(BigSequenceMatrix(bb,1,:)==params.TargetIdx(2)));
    rref2solo=cat(2,rref2solo,r(br,ff));
    ff=find((TargetStartBin<0 | bb<TargetStartBin) &...
            ~singleTrial & ...
            squeeze(BigSequenceMatrix(bb,1,:)==params.TargetIdx(2)));
    rref2=cat(2,rref2,r(br,ff));
end
zb=zeros(round(params.rasterfs.*params.PreStimSilence),1);
rref1solo=cat(1,zb,repmat(nanmean(rref1solo,2),[TarRepCount 1]));
rref1=cat(1,zb,repmat(nanmean(rref1,2),[TarRepCount 1]));
rref2solo=cat(1,zb,repmat(nanmean(rref2solo,2),[TarRepCount 1]));
rref2=cat(1,zb,repmat(nanmean(rref2,2),[TarRepCount 1]));


figure(1);
clf
subplot(3,1,1);
tt=(1:TarBins)./params.rasterfs-params.PreStimSilence;
plot(tt,nanmean(rrefall(1:TarBins,:),2),'LineWidth',2,'Color',[0.6 0.6 1]);
title([cellid ' -- reference']);
aa1=axis;

subplot(3,1,2);
if ~isempty(rtar1solo),
    plot(tt,rref1solo(1:TarBins),'b-');
    hold on
    plot(tt,rref1(1:TarBins),'LineWidth',2,'Color',[0.6 0.6 1]);
    plot(tt,nanmean(rtar1solo(1:TarBins,:),2),'Color',[0.5 0 0]);
    plot(tt,nanmean(rtar1(1:TarBins,:),2),'LineWidth',2,'Color',[0.5 0 0]);
    hold off
    aa=axis;
    legend('ref1','ref2','tar1','tar2');
else
    plot(tt,[nanmean(rtar1(1:TarBins,:),2)]);
end
title(sprintf('target #%d',params.TargetIdx(1)));
aa2=axis;


subplot(3,1,3);
if ~isempty(rtar2solo),
    plot(tt,rref2solo(1:TarBins),'b-');
    hold on
    plot(tt,rref2(1:TarBins),'LineWidth',2,'Color',[0.6 0.6 1]);
    plot(tt,nanmean(rtar2solo(1:TarBins,:),2),'Color',[0.5 0 0]);
    plot(tt,nanmean(rtar2(1:TarBins,:),2),'LineWidth',2,'Color',[0.5 0 0]);
    hold off
    %plot(tt,[nanmean(rtar2solo(1:TarBins,:),2) nanmean(rtar2(1:TarBins,:),2)...
    %         rref2solo(1:TarBins) rref2(1:TarBins)]);
    legend('ref1','ref2','tar1','tar2');
else
    plot(tt,[nanmean(rtar2(1:TarBins,:),2)]);
end
title(sprintf('target #%d',params.TargetIdx(2)));
aa3=axis;
aamax=[aa1(1:2) 0 max([aa1(4) aa2(4) aa3(4)])];

for ii=1:3,
    subplot(3,1,ii);
    axis(aamax);
end

ccmatrix=cell(length(params.TargetIdx),1);
msematrix=cell(length(params.TargetIdx),1);
for ii=1:length(params.TargetIdx),
    targetidx=params.TargetIdx(ii);
    r_avg=squeeze(params.r_avg(:,targetidx,:));
    
    stim2=intersect(params.r_second{targetidx,1},params.r_second{targetidx,2});
    ri2=find(ismember(params.r_second{targetidx,1},stim2));
    nr2=length(ri2);
    r2=params.r_raster{targetidx,1}(:,ri2);
    ti2=find(ismember(params.r_second{targetidx,2},stim2));
    nt2=length(ti2);
    t2=params.r_raster{targetidx,2}(:,ti2);
    
    %nr1=size(params.r_raster{targetidx,3},2);
    %r1=mean(params.r_raster{targetidx,3}(:,round(linspace(1,nr1,nr2))),2);
    %nt1=size(params.r_raster{targetidx,4},2);
    %t1=mean(params.r_raster{targetidx,4}(:,round(linspace(1,nt1,nr2))),2);
    r1=params.r_raster{targetidx,3};
    % t1 includes t1 and r2
    t1=[params.r_raster{targetidx,3} params.r_raster{targetidx,4}];
    
    mr1=mean(r1,2);
    vr1=var(r1,0,2);
    fr1=vr1./mr1./options.rasterfs;
    fr1(mr1==0)=1;
    mr2=mean(r2,2);
    vr2=var(r2,0,2);
    fr2=vr2./mr2./options.rasterfs;
    fr2(mr2==0)=1;
    mt1=mean(t1,2);
    vt1=var(t1,0,2);
    ft1=vt1./mt1./options.rasterfs;
    ft1(mt1==0)=1;
    mt2=mean(t2,2);
    vt2=var(t2,0,2);
    ft2=vt2./mt2./options.rasterfs;
    ft2(mt2==0)=1;
        
    sb=round(options.rasterfs*0.04+5):...
       round(options.rasterfs.*(0.02+params.SampleDur)+5);
    mdt2r2=zeros(size(t2,2)*size(r2,2),1);
    mdt2r1=zeros(size(t2,2)*size(r1,2),1);
    mdt2t1=zeros(size(t2,2)*size(t1,2),1);
    mdr2r1=zeros(size(r2,2)*size(r1,2),1);
    mdr2t1=zeros(size(r2,2)*size(t1,2),1);
    cc=0;
    cc1=0;
    cc2=0;
    for kk=1:size(t2,2),
        for jj=1:size(r2,2),
            cc=cc+1;mdt2r2(cc)=std(t2(sb,kk)-r2(sb,jj));
        end
        for jj=1:size(r1,2),
            cc1=cc1+1;mdt2r1(cc1)=std(t2(sb,kk)-r1(sb,jj));
        end
        for jj=1:size(t1,2),
            cc2=cc2+1;mdt2t1(cc2)=std(t2(sb,kk)-t1(sb,jj));
        end
    end
    cc=0;
    cc1=0;
    for kk=1:size(r2,2),
        for jj=1:size(r1,2),
            cc=cc+1;mdr2r1(cc)=std(r2(sb,kk)-r1(sb,jj));
        end
        for jj=1:size(t1,2),
            cc1=cc1+1;mdr2t1(cc1)=std(r2(sb,kk)-t1(sb,jj));
        end
    end
    
    fprintf('(active=%d taridx=%d) ',active,targetidx);
    fprintf('MD: t2r2=%.2f t2r1=%.2f t2t1=%.2f r2r1=%.2f r2t1=%.2f\n',...
            mean(mdt2r2),mean(mdt2r1),mean(mdt2t1),...
            mean(mdr2r1),mean(mdr2t1));
    
    targetidx=params.TargetIdx(ii);
    
    % exact pair analysis
    ref2pairs=params.r_second{targetidx,1};
    tar2pairs=params.r_second{targetidx,2};
    
    olappairs=intersect(unique(ref2pairs),unique(tar2pairs));
    rmatch=zeros(size(params.r_raster{1,1},1),4,length(olappairs));
    for jj=1:length(olappairs),
        ff=find(params.r_second{targetidx,1}==olappairs(jj));
        rmatch(:,1,jj)=nanmean(params.r_raster{targetidx,1}(:,ff),2);
        ff=find(params.r_second{targetidx,2}==olappairs(jj));
        rmatch(:,2,jj)=nanmean(params.r_raster{targetidx,2}(:,ff),2);
    end
    if ~isempty(params.r_raster{targetidx,3}),
        rmatch(:,3,1)=nanmean(params.r_raster{targetidx,3},2);
        rmatch(:,4,1)=nanmean(params.r_raster{targetidx,4},2);
    end
    
    r_raster_match={};
    ff=find(ismember(params.r_second{targetidx,1},olappairs));
    r_raster_match{1}=params.r_raster{targetidx,1}(:,ff);
    ff=find(ismember(params.r_second{targetidx,2},olappairs));
    r_raster_match{2}=params.r_raster{targetidx,2}(:,ff);
    
    ccmatrix{ii}=zeros(5,5);
    msematrix{ii}=zeros(5,5);
    N=200;
    for jj=1:5,
        for kk=jj:5,
            cc=zeros(N,1);
            mm=zeros(N,1);
            if jj==3,jjalt=5;else jjalt=jj-1; end
            if kk==3,kkalt=5;else kkalt=kk-1; end
            v1=zeros(size(sb(:)));
            v2=zeros(size(sb(:)));
            for nn=1:N
                if jj<3 && kk<3,
                    t1=ceil(rand*size(r_raster_match{jj},2));
                    t2=ceil(rand*(size(r_raster_match{kk},2)-1));
                    if t2<=t1;t2=t2+1; end
                    v1=r_raster_match{jj}(sb,t1);
                    v2=r_raster_match{kk}(sb,t2);
                elseif jj<3,
                    t1=ceil(rand*size(r_raster_match{jj},2));
                    t2=ceil(rand.*size(params.r_raster{targetidx,kkalt},2));
                    v1=r_raster_match{jj}(sb,t1);
                    if ~isempty(params.r_raster{targetidx,kkalt})
                        v2=params.r_raster{targetidx,kkalt}(sb,t2);
                    end
                else
                    t1=ceil(rand*size(params.r_raster{targetidx,jjalt},2));
                    t2=ceil(rand*(size(params.r_raster{targetidx,kkalt},2)-1));
                    if t2>=t1, t2=t2+1; end
                    if ~isempty(params.r_raster{targetidx,jjalt})
                        v1=params.r_raster{targetidx,jjalt}(sb,t1);
                    end
                    if ~isempty(params.r_raster{targetidx,kkalt})
                        v2=params.r_raster{targetidx,kkalt}(sb,t2);
                    end
                end
                cc(nn)=xcov(v1,v2,0,'coeff');
                mm(nn)=std(v1-v2)./100;
            end
            ccmatrix{ii}(jj,kk)=nanmean(cc);
            msematrix{ii}(jj,kk)=nanmean(mm);
       end
    end
    
    % sub in alternative calculations for mr2 and tr2
    mr2=mean(rmatch(:,1,:),3);
    tr2=mean(rmatch(:,2,:),3);
    
    figure;
    subplot(3,2,1);
    tt=((1:size(params.r_avg,1))-6+0.5)./options.rasterfs;
    
    plot(tt,mr2,'LineWidth',2,'Color',[0.6 0.6 1]);
    hold on
    plot(tt,mt2,'LineWidth',2,'Color',[0.5 0 0]);
    plot(tt,mr1,'b-');
    plot(tt,mt1,'Color',[0.5 0 0]);
    aa=axis;
    plot([0 0],aa(3:4),'g--');
    plot([0 0]+params.SampleDur,aa(3:4),'g--');
    mm=nanmean(params.r_avg(:));
    plot(tt([1 end]),[mm mm],'g--');
    hold off
    axis tight
    legend('ref2','tar2','ref1','tar1');
    title(sprintf('cell %s %s',...
                  cellid,basename(parmfile)),'Interpreter','none');
    
    subplot(3,2,2);
    raster=cat(2,params.r_raster{targetidx,1:4});
    imagesc(tt,1:size(raster,2),raster');
    hold on
    aa=axis;
    cc=0;
    for jj=1:3,
        cc=cc+size(params.r_raster{targetidx,jj},2);
        plot(aa(1:2),[cc+0.5 cc+0.5],'g--');
    end
    plot([0 0],aa(3:4),'g--');
    plot([0 0]+params.SampleDur,aa(3:4),'g--');
    hold off
    %colormap(1-gray);
    title(sprintf('raster - targetid: %d',targetidx),'Interpreter','none');
    
    
    if ~isempty(strf) && length(strf)>1,
        subplot(3,2,3);
        imagesc((1:size(strf,2)-1)*10,1:size(strf,1),strf,...
                [-1 1].*max(abs(strf(:))));
        axis xy
        title(strf);
        
        aa=axis;
        yy=get(gca,'YTick');
        set(gca,'YTickLabel',[]);
        ff=round(2.^linspace(log2(200),log2(20000),size(strf,1)));
        for kk=1:length(yy),
            text(aa(1),yy(kk),num2str(ff(yy(kk))),'HorizontalAlignment','right');
        end
    end
    if ~isempty(s),
        subplot(3,2,4);
        
        ff=min(find(ThisTarget==targetidx &...
                    squeeze(BigSequenceMatrix(1,2,:))==-1));
        startbin=params.SampleStarts(TargetStartBin(ff));
        stopbin=params.SampleStops(TargetStartBin(ff));
        imagesc((1:(stopbin-startbin+1)).*10,1:size(s,1),...
                log2(s(:,startbin:stopbin,ff,1)));
        axis xy
        title(sprintf('target sample %d',targetidx));
        
        aa=axis;
        yy=get(gca,'YTick');
        set(gca,'YTickLabel',[]);
        ff=round(2.^linspace(log2(200),log2(20000),size(s,1)));
        for kk=1:length(yy),
            text(aa(1),yy(kk),num2str(ff(yy(kk))),'HorizontalAlignment','right');
        end
    end
    
    sl={'r2','t2','rt','r1','t1'};
    subplot(3,2,5);
    imagesc(msematrix{ii},[0 1].*max(abs(msematrix{ii}(:))));
    axis square
    axis off
    for kk=1:5,
        text(kk,5.5,sl{kk},'VerticalAlign','top','HorizontalAlignment','center');
        text(0.5,kk,sl{kk},'HorizontalAlignment','right');
    end
    title('MSE');
    colorbar
    
    subplot(3,2,6);
    imagesc(ccmatrix{ii},[0 1].*max(abs(ccmatrix{ii}(:))));
    axis square
    axis off
    for kk=1:5,
        text(kk,5.5,sl{kk},'VerticalAlign','top','HorizontalAlignment','center');
        text(0.5,kk,sl{kk},'HorizontalAlignment','right');
    end
    title('cross-corr');
    colorbar
    
    
    if 0
        subplot(3,2,3);
        plot(tt,fr2,'b-');
        hold on
        plot(tt,ft2,'r-');
        plot(tt,fr1,'b-','LineWidth',2);
        plot(tt,ft1,'r-','LineWidth',2);
        aa=axis;
        plot([0 0],aa(3:4),'g--');
        plot([0 0]+params.SampleDur,aa(3:4),'g--');
        mm=nanmean(params.r_avg(:));
        plot(tt([1 end]),[0 0],'g--');
        hold off
        axis tight
        title(sprintf('FF: r1=%.3f r2=%.3f t1=%.3f t2=%.3f',...
                      nanmean(fr1(sb)),nanmean(fr2(sb)),...
                  nanmean(ft1(sb)),nanmean(ft2(sb))));
    end
    
    mfr1(ii,2-active)=nanmean(fr1(sb));
    mfr2(ii,2-active)=nanmean(fr2(sb));
    mft1(ii,2-active)=nanmean(ft1(sb));
    mft2(ii,2-active)=nanmean(ft2(sb));
end

if 0,
    cellfiledata=dbgetscellfile('runclass','RDT');
    for fidx=1:length(cellfiledata),
        parmfile=[cellfiledata(fidx).stimpath cellfiledata(fidx).stimfile];
        spikefile=[cellfiledata(fidx).path cellfiledata(fidx).respfile];
        options.rasterfs=100;
        options.channel=cellfiledata(1).channum;
        options.unit=cellfiledata(1).unit;
        options.resp_shift=0.0;
        
        % load the stimulus spectrogram
        options.filtfmt='gamma';
        options.chancount=30;
        s=loadstimbytrial(parmfile,options);
    end
end
