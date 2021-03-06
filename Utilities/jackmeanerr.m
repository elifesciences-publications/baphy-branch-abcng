% function [m,se]=jackmeanerr(x,n,domedian);
%
% domeadian -(default 0) if 1, calculate median instead of mean
%
% m - mean
% se - jackknife estimate of standard error
%
function [m,se]=jackmeanerr(x,n,domedian);

if ~exist('n','var'),
   n=20;
end
if ~exist('domedian'),
   domedian=0;
end

if length(x)==1,
   warning('jackmeanerr: length(x)=1, setting m=se=x');
   m=x;
   se=x;
   return
end

if n>size(x,1),
   n=size(x,1);
end

jackstep=size(x,1)/n;

mi=zeros(n,size(x,2));
for ii=1:n,
   jackrange=[1:round((ii-1)*jackstep) round(jackstep*ii+1):size(x,1)];
   if domedian,
      mi(ii,:)=nanmedian(x(jackrange,:));
   else
      mi(ii,:)=nanmean(x(jackrange,:));
   end
end

if domedian,
   m=nanmedian(mi,1);
else
   m=nanmean(mi,1);
end
se=nanstd(mi,0) * sqrt(n-1);



