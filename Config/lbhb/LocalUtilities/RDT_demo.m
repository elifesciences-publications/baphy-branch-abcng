cellid='oys031b-a1';
close all

% go to cell db to find active and passive data for this cell
cellfiledata=dbgetscellfile('cellid',cellid,'runclass','RDT',...
                            'behavior','active');
cellfiledata2=dbgetscellfile('cellid',cellid,'runclass','RDT',...
                             'Trial_Mode','RdtWithSingle');
active=1;
if active,
    parmfile=[cellfiledata(1).stimpath cellfiledata(1).stimfile];
    spikefile=[cellfiledata(1).path cellfiledata(1).respfile];
else
    if strcmpi(cellfiledata2(end).behavior,'passive'),
        uidx=length(cellfiledata2);
    elseif strcmpi(cellfiledata2(1).behavior,'passive'),
        uidx=1;
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

% load the stimulus spectrogram
options.filtfmt='gamma';

if 0,
    s=loadstimbytrial(parmfile,options);
    
    % extract only correct trials, which should match size(r,2)
    % and only save mixed stream stimululs spectrogram s(:,:,:,3)
    s=s(:,:,params.CorrectTrials,3);
    
    trialidx=4;
    goodbins=find(~isnan(s(1,:,trialidx)));
    clf
    subplot(2,1,1);
    imagesc(s(:,goodbins,trialidx));
    axis xy;
    subplot(2,1,2);
    plot(r(goodbins,trialidx));
end


rrefall=[];
rtar1solo=[];
rtar1=[];
rtar2solo=[];
rtar2=[];
TargetStartBin=params.TargetStartBin(params.CorrectTrials);
ThisTarget=params.ThisTarget(params.CorrectTrials);
BigSequenceMatrix=params.BigSequenceMatrix(:,:,params.CorrectTrials);
TarRepCount=params.SamplesPerTrial-max(TargetStartBin)+1
TarDur=params.PreStimSilence+TarRepCount.*params.SampleDur+...
       params.PostStimSilence;
TarBins=round(params.rasterfs.*TarDur);
for tt=1:length(TargetStartBin),
    tarstart=round((TargetStartBin(tt)-1).*params.SampleDur.*params.rasterfs);
    refend=tarstart-1+round(params.rasterfs.*params.PreStimSilence);
    ref=nan(size(r,1),1);
    ref(1:refend)=r(1:refend,tt);
    rrefall=cat(2,rrefall,ref);
    
    tarstart=tarstart;
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
        disp('no target match??');
    end
    
end


figure(1);
clf
subplot(3,1,1);
tt=(1:TarBins)./params.rasterfs-params.PreStimSilence;
plot(tt,nanmean(rrefall(1:TarBins,:),2));

title('reference');

subplot(3,1,2);
plot(tt,[nanmean(rtar1solo(1:TarBins,:),2) nanmean(rtar1(1:TarBins,:),2)]);
title(sprintf('target #%d',params.TargetIdx(1)));

subplot(3,1,3);
plot(tt,[nanmean(rtar2solo(1:TarBins,:),2) nanmean(rtar2(1:TarBins,:),2)]);
title(sprintf('target #%d',params.TargetIdx(2)));
legend('solo-stream','2-stream');


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
    
    figure;
    subplot(3,2,1);
    tt=((1:size(params.r_avg,1))-6+0.5)./options.rasterfs;
    plot(tt,mr2,'b-');
    hold on
    plot(tt,mt2,'r-');
    plot(tt,mr1,'b-','LineWidth',2);
    plot(tt,mt1,'r-','LineWidth',2);
    aa=axis;
    plot([0 0],aa(3:4),'g--');
    plot([0 0]+params.SampleDur,aa(3:4),'g--');
    mm=nanmean(params.r_avg(:));
    plot(tt([1 end]),[mm mm],'g--');
    
    hold off
    axis tight
    legend('ref2','tar2','ref1','tar1');
    title(sprintf('cell %s %s targetid: %d',...
                  cellid,basename(parmfile),targetidx),'Interpreter','none');
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
    %title(sprintf('MSE: t2-r1=%.2f t2-r2=%.2f t2-t1=%.2f r2-r1=%.2f r2-t1=%.2f',...
    %              std(t2(sb)-r1(sb)),...
    %              std(t2(sb)-r2(sb)),...
    %              std(t2(sb)-t1(sb)),...
    %              std(r2(sb)-r1(sb)),...
    %              std(r2(sb)-t1(sb))));
    title(sprintf('FF: r1=%.3f r2=%.3f t1=%.3f t2=%.3f',...
                  nanmean(fr1(sb)),nanmean(fr2(sb)),...
                  nanmean(ft1(sb)),nanmean(ft2(sb))));
    
    subplot(3,2,5);
    raster=cat(2,params.r_raster{targetidx,1:4});
    imagesc(raster');
    hold on
    aa=axis;
    cc=0;
    for jj=1:3,
        cc=cc+size(params.r_raster{targetidx,jj},2);
        plot(aa(1:2),[cc+0.5 cc+0.5],'b--');
    end
    hold off
    colormap(1-gray);
    
    mfr1(ii,2-active)=nanmean(fr1(sb));
    mfr2(ii,2-active)=nanmean(fr2(sb));
    mft1(ii,2-active)=nanmean(ft1(sb));
    mft2(ii,2-active)=nanmean(ft2(sb));
end

