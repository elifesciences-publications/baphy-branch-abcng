% function [ccg,sigma]=spk_roughmatch(spkraw,unitmean/sigthresh,xaxis);
function [ccg,sigma]=spk_roughmatch(spkraw,unitmean,xaxis);

unitlength=size(unitmean,1);
unitcount=size(unitmean,2);
st=xaxis(1):xaxis(2);
sigma=std(spkraw);

if unitlength~=length(st) & unitcount>0,
    thr=unitmean
    unitmean=[];
    unitcount=0;
end

if unitcount>0 & size(unitcount,1)>1,
   
   disp('finding template matches');
   cc=zeros(size(spkraw));
   for ii=1:unitcount,
      nn=norm(unitmean(:,ii));
      tvec=unitmean(:,ii)./nn.^2;
      
      tcc=conv(flipud(tvec),spkraw);
      tcc=tcc(xaxis(2)+1:end+xaxis(1));
      cc=max(cc,tcc);
   end
   clear tcc
   
   % find all points over threshold correlation
   ccg=[];
   ccthresh=0.3;
   while ccthresh==0.3 | length(ccg)>length(cc)/50,
      ccthresh=ccthresh+0.025;
      ccg=find(cc(1:end-xaxis(2)+1)>ccthresh);
   end
   fprintf('ccthresh=%.2f\n',ccthresh);
   
   ccg=ccg(find(ccg>-xaxis(1)));
   ccg=ccg(find(ccg<=length(spkraw)-xaxis(2)));
   
   mm=zeros(length(ccg),unitcount);
   
   disp('computing mse');
   for ii=1:unitcount,
      for jj=1:length(ccg),
         mm(jj,ii)=norm(unitmean(:,ii)-spkraw(ccg(jj)+st));
      end
   end
   
   % find local minima in mse
   disp('finding mse local minima');
   ccgs=find([1;diff(ccg)>1]);
   for jj=1:length(ccgs)-1,
      ss=ccg(ccgs(jj));
      ee=ccg(ccgs(jj+1)-1);
      tmm=min(mm(ccgs(jj):ccgs(jj+1)-1,:),[],2);
      pp=min(find(tmm==min(tmm)));
      ccgs(jj)=ccgs(jj)+pp-1;
   end
   
   ccg=ccg(ccgs);
   mm=mm(ccgs,:);
elseif 0,
   thr=4;
   sigma=std(spkraw);
   %pn=input('trigger sign (p/[n]): ','s');
   pn='n';
   if ~isempty(pn) & pn(1)=='p',
       ccg= find(diff((spkraw > thr*sigma))>0);
   else
       ccg= find(diff((-spkraw > thr*sigma))>0);
   end
   fprintf('found %d triggers (thr=%.1f sigma / %s)\n',...
           length(ccg),thr,pn);

else
    if ~exist('thr','var'),
       thr=3;
    end
   sigma=std(spkraw);
   fprintf('using threshold %.1f sigma\n',thr);
   pn='n';
   disp('assuming negative trigger sign!');
   %pn=input('trigger sign (p/[n]): ','s');
   %if ~isempty(pn) & pn(1)=='p',
   %   ccg=find(diff(spkraw) > thr*sigma);
   %else
   %   ccg=find(-diff(spkraw) > thr*sigma);
   %end
   if ~isempty(pn) & pn(1)=='p',
      ccg=find(spkraw > thr*sigma);
   else
      ccg=find(-spkraw > thr*sigma);
   end
   fprintf('found %d triggers\n',length(ccg));
   
   % find local maxima in raw trace
   ccgs=find([1;diff(ccg)>1]);
   for jj=1:length(ccgs)-1,
      ss=ccg(ccgs(jj));
      ee=ccg(ccgs(jj+1)-1);
      tmm=abs(spkraw(ss:ee));
      pp=min(find(tmm==max(tmm)));
      ccgs(jj)=ccgs(jj)+pp-1;
   end
   ccg=ccg(ccgs);
   fprintf('trimmed to %d after removing adjacent triggers\n',length(ccg));
end

% trim off early entries
ccg=ccg(find(ccg>-xaxis(1) & ccg<length(spkraw)-xaxis(2)));
