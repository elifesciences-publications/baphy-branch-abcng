function [mdrsum,mfr1,mfr2,mft1,mft2]=RDT_sim(cellid);
% function [mdrsum,mfr1,mfr2,mft1,mft2]=RDT_sim(cellid);
% 
% mfr1= FF for [target id , behavior state (active=1, passive=2)]
%
% first useful cell: oys022b-a1
%cellid='oys022b-a1';
cellfiledata=dbgetscellfile('cellid',cellid,'runclass','RDT',...
                            'behavior','active');
cellfiledata2=dbgetscellfile('cellid',cellid,'runclass','RDT',...
                             'Trial_Mode','RdtWithSingle');
%close all
for active=1, %0:1,
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

    [r,params]=load_RDT_by_trial(parmfile,spikefile,options); 

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
    
     % measure reference-in-target distances
     sb=round(options.rasterfs*0.04+5):...
        round(options.rasterfs.*(0.04+params.SampleDur)+5);
     refidx=setdiff(1:params.SampleCount,params.TargetIdx);
     mdr=zeros(params.SampleCount,3);
     ndr=zeros(params.SampleCount,3);
     for rr=1:20
        if ismember(rr,refidx),
           r2=params.r_raster{rr,1};
           r1=params.r_raster{rr,3};
           rt=params.r_raster{rr,5};  % ref stream during target
        else
           r2=params.r_raster{rr,1};
           r1=params.r_raster{rr,3};
           rt=params.r_raster{rr,2};  % tar stream in dual-stream condition
        end
        
        for kk=1:size(rt,2),
            % mdr(: 1) : tar in noise versus isolated sample
            for jj=1:size(r1,2),
                %cc=cc+1;mdr(rr,1)=mdr(rr,1)+std(rt(sb,kk)-r1(sb,jj));
                ndr(rr,1)=ndr(rr,1)+1;
                if std(rt(sb,kk))>0 && std(r1(sb,jj)),
                   mdr(rr,1)=mdr(rr,1)+xcov(rt(sb,kk),r1(sb,jj),0,'coeff');
                end
            end
            %for jj=1:size(r2,2),
            %    %cc1=cc1+1;mdr(rr,2)=mdr(rr,2)+std(rt(sb,kk)-r2(sb,jj));
            %    ndr(rr,2)=ndr(rr,2)+1;
            %    if std(rt(sb,kk))>0 && std(r2(sb,jj)),
            %       mdr(rr,2)=mdr(rr,2)+xcov(rt(sb,kk),r2(sb,jj),0,'coeff');
            %    end
            %end
        end
        for kk=1:size(r2,2),
            % mdr(: 2) : ref in noise versus isolated sample
            for jj=1:size(r1,2),
                ndr(rr,2)=ndr(rr,2)+1;
                if std(r2(sb,kk))>0 && std(r1(sb,jj)),
                   mdr(rr,2)=mdr(rr,2)+xcov(r2(sb,kk),r1(sb,jj),0,'coeff');
                end
            end
        end
        for kk=1:size(r1,2),
            for jj=kk+1:size(r1,2),
                ndr(rr,3)=ndr(rr,3)+1;
                if std(r1(sb,kk))>0 && std(r1(sb,jj)),
                   mdr(rr,3)=mdr(rr,3)+xcov(r1(sb,kk),r1(sb,jj),0,'coeff');
                end
            end
        end
     end
     mdr=mdr./ndr;
     mmax=max(mdr(:));
     mmin=min(mdr(:));
     subplot(3,2,2);
     plot([mmin mmax],[mmin mmax],'k--');
     hold on
     plot(mdr(:,3),mdr(:,1),'k.');
     plot(mdr(params.TargetIdx,3),mdr(params.TargetIdx,1),'ro');
     axis square equal
     xlabel('r1 reliability');
     ylabel('t2 vs r1 sim');
     hold off

     subplot(3,2,4);
     plot([mmin mmax],[mmin mmax],'k--');
     hold on
     plot(mdr(:,3),mdr(:,2),'k.');
     plot(mdr(params.TargetIdx,3),mdr(params.TargetIdx,2),'ro');
     axis square equal
     xlabel('r1 reliability');
     ylabel('t2 vs r2 sim');
     hold off
     
     subplot(3,2,6);
     plot([mmin mmax],[mmin mmax],'k--');
     hold on
     plot(mdr(:,2),mdr(:,1),'k.');
     plot(mdr(params.TargetIdx,2),mdr(params.TargetIdx,1),'ro');
     axis square equal
     xlabel('r2 vs r1 sim');
     ylabel('t2 vs r1 sim');
     hold off
     
     drawnow
     
     kidx=find(min(ndr(refidx,:),[],2)>10 & mdr(refidx,3)>mean(mdr(params.TargetIdx,3)));
     fprintf('Rt vs r1/r2/rr: %.3f / %.3f / %.3f\n', nanmean(mdr(refidx(kidx),:),1));
     fprintf('T1 vs r1/r2/rr: %.3f / %.3f / %.3f\n', (mdr(params.TargetIdx(1),:)));
     fprintf('T2 vs r1/r2/rr: %.3f / %.3f / %.3f\n', (mdr(params.TargetIdx(2),:)));
     mdrsum=[mdr(params.TargetIdx(1),:) nanmean(mdr(refidx(kidx),:),1);
             mdr(params.TargetIdx(2),:) nanmean(mdr(refidx(kidx),:),1)];
     
end
