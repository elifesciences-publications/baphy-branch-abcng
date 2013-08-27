% function spk_pca(spk,spkraw,xaxis,fname);
%
%
function spk_pca(spk,spkraw,xaxis,fname);

unitCount=0;
spkCount=[];
spkclass=[];
spknames={};
for ii=1:length(spk),
    if ~isempty(spk{ii}),
        unitCount=ii;
        spkCount(ii)=length(spk{ii});
        spkclass=[spkclass; ones(spkCount(ii),1)*ii];
        spknames{ii}=sprintf('C%.2d',ii');
    end
    
end

st=xaxis(1):xaxis(2);
spikeset=zeros(length(st),sum(spkCount));
unitmean=zeros(length(st),unitCount);
spkidx=0;
for jj=1:unitCount,
    for ii=1:spkCount(jj),
        spkidx=spkidx+1;
        spikeset(:,spkidx)=spkraw(spk{jj}(ii)+st);
    end
    unitmean(:,jj)=mean(spikeset(:,find(spkclass==jj)),2);
end

scorr=spikeset*spikeset';
[u,s,v]=svd(scorr);

PCC=3;
uproj=spikeset'*u(:,1:PCC);
for jj=1:PCC,
   if (sum(spikeset(:,jj)))<0,
      u(:,jj)=-u(:,jj);
      uproj(:,jj)=-uproj(:,jj);
   end
end
   
% plot clusters projected into PC space
kcol={'g.','c.','r.','m.','y.','b.','k.'};
figure;
U=PCC;
for u1=1:U-1,
    for u2=u1+1:U,
        subplot(U-1,U-1,(u1-1)*(U-1)+u2-1);
        
        h=zeros(max(spkclass),1);
        for jj=max(spkclass):-1:1,
            spmatch=find(spkclass==jj);
            testrange=spmatch(round(linspace(1,length(spmatch),...
                round(2000/max(spkclass)))));

            h(jj)=plot(uproj(testrange,u1),uproj(testrange,u2),kcol{jj});
            hold on

        end
        a=axis;
        plot([a(1) a(2)],[0 0],'k--');
        plot([0 0],[a(3) a(4)],'k--');

        for ii=1:unitCount,
            x0=u(:,u1)'*unitmean(:,ii);
            y0=u(:,u2)'*unitmean(:,ii);
            text(x0,y0,num2str(ii));
        end
        hold off
        axis tight

        title(sprintf('PCs %d vs %d',u1,u2));
    end
end
legend(h,spknames);

subplot(U-1,U-1,U);
plot(st,u(:,1:PCC));
legend('pc1','pc2','pc3');

set(gcf,'Name',fname);