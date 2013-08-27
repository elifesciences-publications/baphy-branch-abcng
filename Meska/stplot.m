function stplot(stdata,lfreq,tleng,smooth,noct,clim)
% stplot(stdata,lfreq,tleng,smooth,smooth,noct,clim)

if nargin < 6, clim = []; end
if nargin < 5, noct = 5; end
if nargin < 4, smooth = 0; end
if nargin < 3, tleng = size(stdata,2); end
if isempty(tleng), tleng = size(stdata,2); end

if smooth,
 if length(smooth)==1, smooth = [100 250]; end
 stdata = interpft(interpft(stdata,smooth(1),1),smooth(2),2);
end

if isempty(clim),
 if max(abs(max(max(stdata))),abs(min(min(stdata)))),
  clim = [-1, 1]*max(max(abs(stdata)));
 else
  clim = [-1, 1];
 end
end

imagesc(1:tleng,[0:.1:noct],stdata,clim);axis xy
if nargin > 1 & ~isempty(lfreq),
 set(gca,'ytick',0:noct)
 set(gca,'yticklabel',num2str(round(lfreq*2.^str2num(get(gca,'yticklabel')))));
else
 set(gca,'xtick',[],'ytick',[])
end
