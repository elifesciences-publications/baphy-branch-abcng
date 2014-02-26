    

cellids={'oys027b-c1','oys027c-c1','oys028a-c1','oys033a-a1',...
         'oys033b-b1','oys033c-b1','oys033c-b2','oys034b-a1',...
         'oys027b-c2',...
         'oys027c-c2','oys033a-b1','oys033b-a1','oys030b-a1',...
         'oys031b-a2','oys032a-a1','oys028a-c2',...
         'oys033b-a2'};
close all

dpsum=zeros(4,length(cellids),2);
ravg=cell(2,length(cellids),2);
mr=zeros(length(cellids),2,2,2);
er=zeros(length(cellids),2,2,2);
fh=figure;
for ii=1:length(cellids),
    %active=0,
    for active=0:1,
        [dp,travg,trialcat]=RDT_decoder(cellids{ii},active,1);
        dpsum(:,ii,active+1)=dp;
        for tc=1:2,
            ff=find(trialcat==tc | trialcat==tc+2);
            mr(ii,:,tc,active+1)=mean(travg(:,ff),2)';
            er(ii,:,tc,active+1)=mean(travg(:,ff),2)';
            ravg{tc,ii,active+1}=travg(:,ff);
        end
    end
    
    ff=find(~isnan(dpsum(1,:,1)) & min(dpsum(:,:,1))>-1);
    dpsolo=cat(1,squeeze(dpsum(1,ff,:)),squeeze(dpsum(3,ff,:)));
    dpolap=cat(1,squeeze(dpsum(2,ff,:)),squeeze(dpsum(4,ff,:)));
    
    sfigure(fh);
    subplot(2,2,1);
    plot(dpsolo(ff,1),dpsolo(ff,2),'.');
    hold on
    plot([-1 3.5],[-1 3.5],'k--');
    axis tight square
    xlabel('D-prime solo trial, passive');
    ylabel('D-prime solo trial, active');
    
    subplot(2,2,2);
    plot(dpolap(ff,1),dpolap(ff,2),'.');
    hold on
    plot([-1 3.5],[-1 3.5],'k--');
    axis tight square
    xlabel('D-prime olap trial, passive');
    ylabel('D-prime olap trial, active');
    
    N=2000;
    goodcells=find(mean(mean(dpsum,1),3)>0);
    r=zeros(N,length(goodcells),2,2);
    for nn=1:N
        for ii=goodcells,
            active=0;
            ff=ceil(rand.*size(ravg{1,ii,active+1},2));
            r(nn,ii,:,1)=ravg{1,ii,active+1}(:,ff)';
            ff=ceil(rand.*size(ravg{2,ii,active+1},2));
            r(nn,ii,:,2)=ravg{2,ii,active+1}(:,ff)';
        end
    end
    s=zeros(N,1,2,2);
    s(:,:,2,:)=1;
    stim=s(:);
    resp=permute(r,[2 1 3 4]);
    resp=resp(:,:)';
    resp=resp-repmat(nanmean(resp,1),[size(resp,1),1]);
    [H,BRAC]=revrecCore(stim-nanmean(stim),resp);
    pred=reshape(resp*H,N,2,2)+nanmean(s(:));
    mm=squeeze(mean(pred(:,2,:)-pred(:,1,:)));
    ee=squeeze(std(pred(:,2,:)-pred(:,1,:)))./sqrt(2);
    %ee=squeeze(std(pred(:,2,:)));
    dppop=mm./ee
    
    subplot(2,2,3);
    [hh,nn]=hist(pred(:,:,1),linspace(-0.5,1.5,20));
    bar(nn,hh./repmat(sum(hh),[size(hh,1) 1]));
    xlabel('Population decoder output');
    ylabel('Fraction of trials');
    title(sprintf('Single stream D-prime=%.2f (n=%d sites)',...
                  dppop(1), length(cellids)));
    aa=axis;
    axis([-.6 1.6 0 aa(4)]);
    
    subplot(2,2,4);
    [hh,nn]=hist(pred(:,:,2),linspace(-0.5,1.5,20));
    bar(nn,hh./repmat(sum(hh),[size(hh,1) 1]));
    xlabel('Populatoin decoder output');
    ylabel('Fraction of trials');
    title(sprintf('Dual stream D-prime=%.2f (n=%d sites)',...
                  dppop(2), length(cellids)));
    axis([-.6 1.6 0 aa(4)]);
    drawnow
end
