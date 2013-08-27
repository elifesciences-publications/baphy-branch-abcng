% function [SPKCLASS,newunitmean,newunitstd]=...
%     clustercore(cluster_algorithm,tolerance,sweepout);
function [SPKCLASS,newunitmean,newunitstd]=...
    clustercore(cluster_algorithm,tolerance,sweepout);

global SPKRAW UNITMEAN UNITSTD UNITCOUNT XAXIS PCC PCS SPIKESET 
global UPROJ SPKCLASS KCOL C0 EXTRAS

if ~exist('cluster_algorithm','var'),
   cluster_algorithm='kmeans';
end
if ~exist('sweepout','var'),
   sweepout=0;
end

if sum(abs(C0(:)))==0,
   C0=mean(UPROJ);
end
k=size(C0,1);
if length(tolerance)<k,
   tolerance=[tolerance(:);...
              repmat(tolerance(1),[k-length(tolerance) 1])]
end

switch lower(cluster_algorithm),
   
 case 'kmeans',
  
  if k>1,
     [SPKCLASS,c] = kmeans(UPROJ, k,'Start',C0,'EmptyAction','singleton');
  else
     SPKCLASS=ones(length(UPROJ),1);
     c=mean(UPROJ,1);
     C0=c;
  end
  
  cs=zeros(size(c));
  normfactor=EXTRAS.sigma;
  
  for jj=1:k,
     spmatch=find(SPKCLASS==jj);
     cs(jj,:)=std(UPROJ(spmatch,:));
     
     tt=length(spmatch);
     newunitmean=mean(SPIKESET(:,spmatch),2);
     newunitstd=std(SPIKESET(:,spmatch),0,2).^2;
     %normfactor=std(newunitmean).^2);
     if sweepout,
        dd=sqrt(mean((SPIKESET(:,spmatch)-repmat(newunitmean,[1 tt])).^2))./...
           normfactor;
        dda=sqrt(mean(SPIKESET(:,spmatch).^2))./sqrt(mean(newunitmean.^2));
        nu=newunitmean./norm(newunitmean);
        ddy=nu'*SPIKESET(:,spmatch)./norm(newunitmean);
        ddx=sqrt(dda.^2-ddy.^2);
        
        %ddt=sort(ddy(dd<tolerance(jj)));
        %mm=mean(ddt(1:ceil(length(ddt)./20)))
        mm=min(ddy(dd<tolerance(jj)));
        %mm=1-2.*std(ddy(dd<tolerance(jj)))
        reqd=mm+2./(4.*(1-mm)).*ddx.^2;
        ll=find(ddy<=reqd);
        
        %kk=find(ddy>reqd);
        %sfigure(24);
        %u=UPROJ(spmatch,:);
        %(u(ll,1),u(ll,2),'r.');
        %hold on
        %plot(u(kk,1),u(kk,2),'.');
        %hold off
        
        SPKCLASS(spmatch(ll))=k+1;
     else
        dd=sqrt(mean((SPIKESET(:,spmatch)-repmat(newunitmean,[1 tt])).^2))./...
           normfactor;
        SPKCLASS(spmatch(dd>tolerance(jj)))=k+1;
     end
  end
  
 case 'distance',
  centerspikes=PCS*C0';
  
  spikecount=size(SPIKESET,2);
  dd=zeros(spikecount,k);
  
  %normfactor=mean(std(UPROJ));
  normfactor=EXTRAS.sigma;
  for jj=1:k,
     %dd(:,jj)=sqrt(mean((UPROJ-repmat(C0(jj,:),[spikecount 1])).^2,2));
     dd(:,jj)=sqrt(mean((SPIKESET-repmat(centerspikes(:,jj),...
                                         [1 spikecount])).^2));
     dd(:,jj)=dd(:,jj)./normfactor./tolerance(jj);
  end
  
  [y,xi]=sort(dd,2);
  SPKCLASS=xi(:,1);
  SPKCLASS(y(:,1)>1)=k+1;
  
  %disp('updating UNITMEAN to center of cluster!');
  %for jj=1:k,
  %   spmatch=find(SPKCLASS==jj);
  %   UNITMEAN(:,jj)=mean(SPIKESET(:,spmatch),2);
  %   UNITSTD(:,jj)=std(SPIKESET(:,spmatch),0,2);
  %end
  
  
 otherwise
  error('algorithm not supported');
  
end
