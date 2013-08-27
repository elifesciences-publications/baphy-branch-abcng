
st=xaxis(1):xaxis(2);

tolerance=0.75;
ok=0;
firstloop=1;
kcol={'b','g','c','r','k','m','y'};
PCC=3;

newunitmean=unitmean;
newunitstd=unitstd;
nunitcount=unitcount;

while ~ok,
   % pick centers if not first loop
   if firstloop,
       yn='y';
   else
       yn=input('re-threshold [n]? ','s');
   end
   
   if ~isempty(yn) & yn(1)=='y',
       [ccg,sigma]=spk_roughmatch(spkraw,newunitmean,xaxis);
        
       spikeset=zeros(length(st),length(ccg));
       for jj=1:length(ccg),
           spikeset(:,jj)=spkraw(ccg(jj)+st);
       end
       scorr=spikeset*spikeset';
       [u,s,v]=svd(scorr);
        
       uproj=spikeset'*u(:,1:PCC);
       for jj=1:PCC,
           if (sum(spikeset(:,jj)))<0,
               u(:,jj)=-u(:,jj);
               uproj(:,jj)=-uproj(:,jj);
           end
       end
       spkclass=ones(size(ccg));
       if unitcount>0,
           c0=(u(:,1:PCC)'*newunitmean)';
           k=nunitcount;
           fprintf('guessing k=%d clusters, tolerance = %.1f std\n',k,tolerance);
       else
           k=1;
       end
   else
       prompt={'Number of clusters?','Tolerance?'};
       name='Clustering parameters';
       numlines=1;
       defaultanswer={num2str(k),num2str(tolerance)};
       answer=inputdlg(prompt,name,numlines,defaultanswer);
       tk=str2num(answer{1});
       if ~isempty(tk),
           k=tk;
       end

       ttol=str2num(answer{2});
       if ~isempty(ttol),
           tolerance=ttol;
       end

       disp('choose centers');
       figure(1);
       subplot(U-1,U-1,1);
       [x,y]=ginput(k);
      
      c0=zeros(k,PCC);
      for ii=1:k,
         dd=(sqrt((uproj(:,1)-x(ii)).^2+(uproj(:,2)-y(ii)).^2));
         sidx=find(dd==min(dd));
         c0(ii,:)=uproj(sidx,1:PCC);
      end
   end
   firstloop=0;
   
   % do the clustering
   if k>1,
      [spkclass,c] = kmeans(uproj, k,'Start',c0);
   else
      spkclass=ones(length(uproj),1);
      c=mean(uproj,1);
      c0=c;
   end
   
   cs=zeros(size(c));
   for jj=1:k,
      spmatch=find(spkclass==jj);
      cs(jj,:)=std(uproj(spmatch,:));
      
      tt=length(spmatch);
      newunitmean=mean(spikeset(:,spmatch),2);
      newunitstd=std(spikeset(:,spmatch),0,2).^2;
      %dd=  sqrt(mean((spikeset(:,spmatch)-repmat(newunitmean,[1 tt])).^2./...
      %               repmat(newunitstd,[1 tt])));
      dd=  sqrt(mean((spikeset(:,spmatch)-repmat(newunitmean,[1 tt])).^2./...
                     std(newunitmean).^2));
      
      %sig=repmat(cs(jj,:),[length(spmatch),1]);
      %dd=sqrt(sum((((uproj(spmatch,:)-...
      %               repmat(c(jj,:),[length(spmatch),1]))./sig).^2),2));
      
      spkclass(spmatch(dd>tolerance))=k+1;
   end
   
   % plot clusters projected into PC space
   figure(1);
   clf
   testrange=round(linspace(1,length(ccg),2000));
   U=PCC;
   for u1=1:U-1,
      for u2=u1+1:U,
         subplot(U-1,U-1,(u1-1)*(U-1)+u2-1);
         
         for jj=max(spkclass):-1:1,
            spmatch=find(spkclass==jj);
            testrange=spmatch(round(linspace(1,length(spmatch),...
                                             round(2000/max(spkclass)))));
            
            plot(uproj(testrange,u1),uproj(testrange,u2),[kcol{jj},'.']);
            hold on
            
         end
         a=axis;
         plot([a(1) a(2)],[0 0],'k--');
         plot([0 0],[a(3) a(4)],'k--');
         
         for ii=1:unitcount,
            x0=u(:,u1)'*unitmean(:,ii);
            xs=u(:,u1)'*unitstd(:,ii);
            y0=u(:,u2)'*unitmean(:,ii);
            ys=u(:,u2)'*unitstd(:,ii);
            text(x0,y0,num2str(ii));
            
            %plot([x0-xs x0+xs],[y0 y0],'r-','LineWidth',2);
            %plot([x0 x0],[y0-ys y0+ys],'r-','LineWidth',2);
         end
         
         hold off
         axis tight
         
         title(sprintf('PCs %d vs %d',u1,u2));
      end
   end
   
   %legend('c4','c3','c2','c1');
   
   subplot(U-1,U-1,U);
   plot(st,u(:,1:PCC));
   legend('pc1','pc2','pc3');
   
   figure(2);
   clf
   classcount=max(spkclass);
   a=[];
   for ii=1:unitcount,
      subplot(max([unitcount classcount]),4,ii*4-3);
      errorshade(st',unitmean(:,ii,1),unitstd(:,ii,1));
      if ii<=length(spkcount),
          title(sprintf('%s template (%d spikes)',cellids{ii},spkcount(ii)));
      else
          title(sprintf('CLUSTER #%d CRAP',ii));
      end
      a=[a;axis];
   end
   newunitmeanpc0=u(:,1:PCC)*c0';
   newunitmeanpc=u(:,1:PCC)*c';
   newsnr=zeros(classcount,1);
   for jj=1:classcount,
      spmatch=find(spkclass==jj);
      
      subplot(max([unitcount classcount]),4,jj*4-2);
      newunitmean=mean(spikeset(:,spmatch),2);
      newunitstd=std(spikeset(:,spmatch),0,2);
      
      errorshade(st',newunitmean,newunitstd);
      if jj<=k,
         hold on
         plot(st',newunitmeanpc(:,jj),'k--','LineWidth',2);
         plot(st',newunitmeanpc0(:,jj),[kcol{jj},'--'],'LineWidth',2);
         hold off
         a=[a;axis];
         
         newsnr(jj)=std(newunitmean)./sigma;
         fprintf('cluster %d: n=%d snr=%.2f\n',jj,length(spmatch),...
                 newsnr(jj));
         title(sprintf('cluster %d',jj));
      else
         fprintf('crap: %d\n',length(spmatch));
         title('crap cluster');
      end
      
      subplot(max([unitcount classcount]),4,jj*4-1);
      testidx=spmatch(round(linspace(1,length(spmatch),100)));
      plot(st,spikeset(:,testidx));
      a=[a;axis];
      
      subplot(max([unitcount classcount]),4,jj*4);
      isi=diff(ccg(spmatch))./extras.rate*1000;
      isi=isi(find(isi<30));
      hist(isi,50);
      if jj==1,
         title('ISI');
      end
   end
   
   subplot(max([unitcount classcount]),4,max([unitcount classcount])*4-3);
   for jj=k:-1:1,
      spmatch=find(spkclass==jj);
      testidx=spmatch(round(linspace(1,length(spmatch),20)));
      plot(st,spikeset(:,testidx),[kcol{jj},'-']);
      hold on
      a=[a;axis];
   end
   hold off
   
   aout=[xaxis min(a(:,3)) max(a(:,4))];
   
   for ii=1:max([unitcount classcount]),
      for jj=1:3,
         subplot(max([unitcount classcount]),4,(ii-1)*4+jj);
         axis(aout);
      end
      subplot(max([unitcount classcount]),4,ii*4);
      a=axis;
      axis([0 30 a(3:4)]);
   end
   
   % decide how and whether to save
   tt=input(sprintf('unitcount [%d]? ',unitcount));
   if ~isempty(tt),
      nunitcount=tt;
   else
      nunitcount=unitcount;
   end
   unitmap=zeros(nunitcount,1);
   isopct=zeros(nunitcount,1);
   for jj=1:nunitcount,
      tt=input(sprintf('map which cluster to cell %s [0=none]? ',cellids{jj}));
      if ~isempty(tt),
         unitmap(jj)=tt;
      end
      if unitmap(jj)>0,
         isopct(jj)=100*erf(newsnr(jj)./2);
         tt=input(sprintf('iso pct [%.1f]? ',isopct(jj)));
         if ~isempty(tt),
            isopct(jj)=tt;
         end
      end
   end
   for jj=1:nunitcount,
      spmatch=find(spkclass==unitmap(jj));
      fprintf('unit %d: cluster %d, %d spikes\n',jj,unitmap(jj),length(spmatch));
   end
   
   yn=input('ok [n]? ','s');
   if ~isempty(yn) & yn(1)=='y',
      ok=1;
   end
   
end

source=parmfile2;
source2=parmfile2;

[bb,pp]=basename(parmfile2);
SORTROOT=[pp 'sorted'];

destbase=basename(parmfile2);
if strcmp('.par',destbase(end-3:end)),
   destbase=destbase(1:end-4);
end

destin=[SORTROOT filesep destbase];
destin2=[SORTROOT filesep destbase];
sorter= 'david';
PSORTER=1;
comments='PC-cluster sorted by meskres.m';

spksav1=cell(12,1);
for ab=1:nunitcount,
   spksav1{ab,1}=ccg(find(spkclass==unitmap(ab)));
end
spk=spksav1;

if exist([destin '.spk.mat'],'file'),
   yn=input('append existing .spk.mat file (rather than overwrite!) ([y]/n)? ','s');
   if length(yn)>0 && yn(1)=='n',
      delete([destin '.spk.mat']);
   end
end

% save templates for each cluster
unitmean=zeros(size(spikeset,1),classcount);
unitstd=zeros(size(spikeset,1),classcount);
for jj=1:classcount,
   spmatch=find(spkclass==jj);
   
   subplot(max([unitcount classcount]),4,jj*4-2);
   unitmean(:,jj)=mean(spikeset(:,spmatch),2);
   unitstd(:,jj)=std(spikeset(:,spmatch),0,2);
end

% reorder templates so that first one corresponds to first unit in sorted
% cells. and so on. crap clusters tacked on at the end
unitmap=[unitmap(:)' setdiff(1:(classcount-1),unitmap(:)')];
unitmean=unitmean(:,unitmap);
unitstd=unitstd(:,unitmap);

extras.unitmean=unitmean;
extras.unitstd=unitstd;
extras.tolerance=tolerance;
savespikes(source,destin,ccg,spikeset,spksav1,sorter, PSORTER,...
           comments,extras,abaflag,xaxis);

ONEFILE=1;
fname=parmfile2;
matchcell2file;
