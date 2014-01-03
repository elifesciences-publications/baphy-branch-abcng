
cellids={'oys022b-a1','oys022b-b1','oys022b-b2','oys022b-c1',...
         'oys022c-a1','oys022c-c1',...
         'oys023a-a1','oys023a-b1',...
         'oys024c-a1','oys024c-a2',...
         'oys025b-a1','oys025b-b1'};
mfr1=[];
mfr2=[];
mft1=[];
mft2=[];
for cc=1:length(cellids),
    cellid=cellids{cc};
    [a,b,c,d]=RDT_sim(cellid);
    mfr1=cat(1,mfr1,a);
    mfr2=cat(1,mfr2,b);
    mft1=cat(1,mft1,c);
    mft2=cat(1,mft2,d);
end

return

    
% first useful cell: oys022b-a1
cellid='oys022b-a1';
active=0;

cellfiledata2=dbgetscellfile('cellid',cellid,'runclass','RDT',...
                             'Trial_Mode','RdtWithSingle');
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
options.rasterfs=40;
options.channel=cellfiledata(1).channum;
options.unit=cellfiledata(1).unit;
options.resp_shift=0.0;

[r,params]=load_RDT_by_trial(parmfile,spikefile,options); 

close all
for ii=1:length(params.TargetIdx),
    targetidx=params.TargetIdx(ii);
    r_avg=squeeze(params.r_avg(:,targetidx,:));

    stim2=intersect(params.r_second{targetidx,1},params.r_second{targetidx,2});
    ri2=find(ismember(params.r_second{targetidx,1},stim2));
    nr2=length(ri2);
    r2=mean(params.r_raster{targetidx,1}(:,ri2),2);
    ti2=find(ismember(params.r_second{targetidx,2},stim2));
    nt2=length(ti2);
    t2=mean(params.r_raster{targetidx,2}(:,ti2),2);
    
    %nr1=size(params.r_raster{targetidx,3},2);
    %r1=mean(params.r_raster{targetidx,3}(:,round(linspace(1,nr1,nr2))),2);
    %nt1=size(params.r_raster{targetidx,4},2);
    %t1=mean(params.r_raster{targetidx,4}(:,round(linspace(1,nt1,nr2))),2);
    r1=mean(params.r_raster{targetidx,3},2);
    % t1 includes t1 and r2
    t1=mean([params.r_raster{targetidx,3} params.r_raster{targetidx,4}],2);
   
    figure;
    subplot(3,1,1);
    tt=((1:size(params.r_avg,1))-6+0.5)./options.rasterfs;
    plot(tt,r2,'b-');
    hold on
    plot(tt,t2,'r-');
    plot(tt,r1,'b-','LineWidth',2);
    plot(tt,t1,'r-','LineWidth',2);
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
    
    subplot(3,1,2);
    plot(tt,r2-r1,'b-');
    hold on
    plot(tt,t2-r1,'r-');
    aa=axis;
    plot([0 0],aa(3:4),'g--');
    plot([0 0]+params.SampleDur,aa(3:4),'g--');
    mm=nanmean(params.r_avg(:));
    plot(tt([1 end]),[0 0],'g--');
    hold off
    axis tight
    legend('r2-r1','t2-r1');
    sb=round(options.rasterfs*0.04+5):...
       round(options.rasterfs.*(0.02+params.SampleDur)+5);
    title(sprintf('MSE: t2-r1=%.2f t2-r2=%.2f t2-t1=%.2f r2-r1=%.2f r2-t1=%.2f',...
                  std(t2(sb)-r1(sb)),...
                  std(t2(sb)-r2(sb)),...
                  std(t2(sb)-t1(sb)),...
                  std(r2(sb)-r1(sb)),...
                  std(r2(sb)-t1(sb))));
    %title(sprintf('XC: t2,r1=%.3f t2,t1=%.3f r2,r1=%.3f r2,t1=%.3f',...
    %              xcorr(t2(sb)-mm,r1(sb)-mm,0,'coeff'),...
    %              xcorr(t2(sb)-mm,t1(sb)-mm,0,'coeff'),...
    %              xcorr(r2(sb)-mm,r1(sb)-mm,0,'coeff'),...
    %              xcorr(r2(sb)-mm,t1(sb)-mm,0,'coeff')));
    
    subplot(3,1,3);
    raster=cat(2,params.r_raster{targetidx,1:4});
    imagesc(raster');
    hold on
    aa=axis;
    cc=0;
    for ii=1:3,
        cc=cc+size(params.r_raster{targetidx,ii},2);
        plot(aa(1:2),[cc+0.5 cc+0.5],'b--');
    end
    hold off
    colormap(1-gray);
end

