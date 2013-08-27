function stplot(stdata,lfreq,tleng,smooth,noct,clim,siglev)
% stplot(stdata,lfreq,tleng,smooth,smooth,noct,clim,siglev)
% the user can also pass the standard deviation matrix, in which case the
% contours will be displayed.

if nargin < 7, siglev = 5;end
if nargin < 6, clim = []; end
if nargin < 5, noct = 5; end
if nargin < 4, smooth = 0; end
if nargin < 3, tleng = size(stdata,2); end
if isempty(tleng), tleng = size(stdata,2); end
if iscell(stdata),
    stdmat = stdata{2};
    stdata = stdata{1};
end

if smooth,
   if length(smooth)==1,
      smooth = [100 250];
   end
   stdata = interpft(interpft(stdata,smooth(1),1),smooth(2),2);
end

if ~isempty(clim),
   % do nothing
elseif sum(isnan(stdata(:)))>0,
   clim = [-1 1];
elseif max(abs(max(max(stdata))),abs(min(min(stdata)))),
   clim = [-1, 1]*max(max(abs(stdata)));
else
   clim = [-1, 1];
end

f=gcf;
hold off;
imagesc(1:tleng,0:.01:noct,stdata,clim);axis xy
dcm_obj = datacursormode(f);
set(dcm_obj, 'updateFcn', @UpdateCursor);

if nargin > 1 && ~isempty(lfreq),
    set(gca,'ytick',(0:noct))
    set(gca,'yticklabel',num2str(round(lfreq*2.^str2num(get(gca,'yticklabel')))));
else
    set(gca,'xtick',[],'ytick',[])
end
if exist('stdmat','var')
   %siglev = 2.5;
   hold on
   [Xf,Xt] = size(stdata(:,1:75));
   contour(linspace(0,Xt,Xt),linspace(0,5,Xf),...
           (abs(stdata(:,1:75))>(siglev*stdmat(:,1:75))),[.5,.5],'k:')
end
