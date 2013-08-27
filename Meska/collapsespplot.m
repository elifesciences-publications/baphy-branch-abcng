function collapsespplot(spdata,mf,fname,recs,paramdata,stonset,stdur,ddur,deltaT)

[spikes, sweeps, records] = size(spdata);
if isempty(recs);recs = 1:records;end
spcollapse = squeeze(sum(spdata,2));
if ~exist('deltaT'); deltaT = 5; end% 5 milliseconds
smfact = deltaT*mf;
spsmooth = resample(spcollapse,1,smfact).^3;
surf((1:ddur*mf/smfact)*smfact/mf,recs,spsmooth')
ax = gca;
axis ij, colormap(1-gray), axis tight, view([-25,45])
line(stonset+[0,0;stdur,stdur]', ...
	[1,1;size(spsmooth,2),size(spsmooth,2)], ...
	ones(2)*mean(std(spsmooth)), 'Color','g')
[yticklabels,ylabelstring,paramstring] = relevantfeainfo(fname,...
 paramdata,deltaT);
paramstring = ['\fontname{Times}\fontsize{9}',paramstring];
set(ax,'Ytick',recs);
set(ax,'YtickLabel',num2str(yticklabels,3));
ylabel(['\fontname{Times}',ylabelstring])
set(ax,'ZTick',[]) 
set(ax,'GridLineStyle','none')
set(ax,'Color',get(get(ax,'Parent'),'Color'))
set(ax,'ZColor',get(get(ax,'Parent'),'Color'))
axP = get(ax,'Position'); axP(2) = 2*axP(2);set(gca,'Position',axP)
xlabel('\fontname{Times}Time (ms)')
zlabel(['\fontname{Times}                    ', ...
      '\fontsize{12}',fname], ...
     'HorizontalAlignment', 'left', 'Color', 'k','Rotation', 0)

paramAx = axes('Position',[0.1300    0.0400    0.7750    0.01]) ; 
set(paramAx,'xTick',[],'yTick',[], ...
 'XColor',get(get(paramAx,'Parent'),'Color'), ...
 'YColor',get(get(paramAx,'Parent'),'Color'), ...
 'ZColor',get(get(paramAx,'Parent'),'Color'))
set(paramAx,'Color',get(get(paramAx,'Parent'),'Color'))
xLbl = xlabel('','Color','k');
xPos = get(xLbl,'Position');xPos(1) = 1;set(xLbl,'Position',xPos)
set(xLbl,'HorizontalAlignment', 'right')
set(xLbl,'String',paramstring)

featype=fname(end-6:end-4);

fig = get(gca,'parent');
set(fig,'Name',fname)
set(fig,'Tag',['nplot:',fname])
set(fig,'KeyPressFcn','feawindowkeydown')

cm = uimenu(fig,'Label','&NSL');
itemLabel = 'Close'; callback = ['close(',num2str(fig),')'];
uimenu(cm,'Label',itemLabel,'Callback',callback);
itemLabel = '&Tplot'; callback = ['tplot(''',fname,''')'];
uimenu(cm,'Label',itemLabel,'Callback',callback);
%  itemLabel = '&Nplot'; callback = ['nplot(''',fname,''')'];
%  uimenu(cm,'Label',itemLabel,'Callback');
if (strcmp('m1-',featype)|strcmp('m2-',featype)|strcmp('a1-',featype))
  itemLabel = '&Mplot'; callback = ['mplot(''',fname,''')'];
  uimenu(cm,'Label',itemLabel,'Callback',callback);
end
if strcmp(featype,'a1-')
  itemLabel = '&Iplot'; callback = ['iplot(''',fname,''')'];
  uimenu(cm,'Label',itemLabel,'Callback',callback);
end
