% function [H,BRAC]=revrecCore(stim,resp);
function [H,BRAC]=revrecCore(stim,resp);

respchancount=size(resp,2);
stimchancount=size(stim,2);

BRAC=resp'*resp;

% iterate through each stim channel
RS0=zeros(respchancount,stimchancount);
for ss=1:stimchancount,
   tstim=stim(:,ss);
   RS0(:,ss)=resp'*tstim;
end

if 1,
   %disp('approx. normalizing RS by response RR (0.00001)');
   [u,s]=svd(BRAC);
   dd=cumsum(diag(s));
   ddcut=min(find(dd>dd(end).*0.99999));
   dd=diag(s);
   if length(dd)>1,
       dd=1./dd;
       dd(ddcut:end)=0;
       s=diag(dd);
   end
   BRACinv=u*diag(dd)*u';
   %fprintf('kept %d/%d dimensions\n',ddcut-1,length(dd));
   %BRACinv=pinv(BRAC,0.5);
else
   disp('normalizing RS by response RR');
   BRACinv=BRAC^-1;
end
H=BRACinv * RS0;
