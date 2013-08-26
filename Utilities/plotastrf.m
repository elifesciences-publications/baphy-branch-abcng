% function plotastrf(strf,interpfactor,ff,timefs);
function plotastrf(strf,interpfactor,ff,timefs);

tbincount=size(strf,2);

if exist('interpfactor','var') & interpfactor>1,
    strf=imresize(strf,interpfactor,'bilinear');
else
    interpfactor=1;
end
if ~exist('timefs','var'),
   timefs=100;
end

tbinsize=round(1./timefs .*1000);
tfinal=size(strf,2);
trange=((1:tfinal)-0.5)./tfinal.*tbincount.*tbinsize;
xrange=(1:size(strf,1))./interpfactor;

mss=max(abs(strf(:)));
if mss==0,
   mss=1;
end

if 0
    smooth=[100 250];
    strf = interpft(interpft(strf,smooth(2),2),smooth(1),1);
end
imagesc(trange,xrange,strf,[-1 1].*mss);
axis xy

if exist('ff','var'),
    ll=1:round(length(ff)./6):length(ff);
    set(gca,'YTick',ll,'YTickLabel',ff(ll));
end