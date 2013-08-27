function spikeplot(spdata,mf,fname,recs,expData,stimTime)
% spikeplot(spdata,mf,fname,recs,paramdata,stimTime)
%
% fname : file name... used for label (not required)
% mf : multiplication factor ... used to scale axis (default = 1)
% recs: which records to plot (default = all)
% paramdata: used in labeling plots (optional)
% stimTime: an array of stimOnset and stimDuration times (optional)

[numspikes, sweeps, records, numclass] = size(spdata);

if ~exist('mf')
 mf = 1;
elseif isempty(mf)
 mf = 1;
end

if ~exist('fname')
 fname = ' ';
 plotfname = ' ';
elseif isempty(fname)
 fname = ' ';
 plotfname = ' ';
else
 plotfname = fname;
end

if ~exist('recs')
 recs = 1:records;
elseif isempty(recs)
 recs = 1:records;
else
 plotfname = [fname,':',num2str(recs)];
end

if exist('expData')
 paramver = get(expData,'Version');
 unitNum = [];
 if ~isempty(unitNum); plotfname=[plotfname,', unit ',num2str(unitNum)];end
else
 paramver = 0
end

durationtime = numspikes/mf;

if ~exist('stimTime') 
  stimTime = [0 durationtime];
else
  if isempty(stimTime)
	stimTime = [0 durationtime];
  else
	stimTime(1) = max([0 stimTime(1)]);
	stimTime(2) = min([durationtime stimTime(2)]);
  end
end

stimDuration = stimTime(2);
firsttime = 0 + (paramver >= 3) * (-stimTime(1));
stimOnset = firsttime+stimTime(1);
stimOffset = stimOnset + stimDuration;

nSpikes = sum(sum(sum(sum(spdata))));

font = 'Times';


if ~isempty(expData) & (length(fname)>7)
    deltat =1/mf;
    paramstring = '';
    paramstring = [sprintf('\\Deltat = %g ms, ', deltat), paramstring];
    paramstring = [sprintf('%d sweeps, ',num2str(sweeps)),...
    paramstring];
    ylabels =[1:recs]';
    ylabelstring = 'Stimuli';
    intsty = get(expData,'OveralldB'); intsty = intsty(1);
    paramstring = [sprintf('%d dB, ',intsty),paramstring];
        if recs(end) <= length(ylabels), 
	 ylabels = ylabels(recs);
        else,
         ylabels = recs(:);
	end 
else
	ylabels = [1:length(recs)]';
	ylabelstring = 'stimulus';
	paramstring = '';
end
paramstring = [num2str(nSpikes),' spikes, ',paramstring];
paramstring = ['\fontname{',font,'}\fontsize{10}',paramstring];
if strcmp(paramstring(end-1:end),', ');paramstring = paramstring(1:end-2);end
ylabelstring = ['\fontname{',font,'}',ylabelstring];

clf
hold on
disp(['Plotting... ' plotfname])

yAx = axes('position',[0.0700    0.1100    0.01    0.8125]);
set(yAx,'XColor','w','YColor','w','ZColor','w','xTick',[],'yTick',[])
yLbl = ylabel('','Color','k');
%set(yLbl,'String',ylabelstring)
set(yLbl,'String',paramstring)

%paramAx = axes('Position',[0.1300    0.0400    0.7750    0.01]);
%set(paramAx,'XColor','w','YColor','w','ZColor','w','xTick',[],'yTick',[])
%xLbl = xlabel('','Color','k');
%xPos = get(xLbl,'Position');xPos(1) = 1;set(xLbl,'Position',xPos)
%set(xLbl,'HorizontalAlignment', 'right')
%set(xLbl,'String',paramstring)

colors = {'k','r','b','g'};
for cls = 1:numclass,

 for abc = 1:length(recs)

  subplot(length(recs),1,abc)
  set(gca,'Fontname',font);
  set(gca,'Ytick',[]);
  hold on
  line(stimOnset *[1 1],[1 sweeps],'Color',[.95 .95 .75])
  line(stimOffset*[1 1],[1 sweeps],'Color',[.95 .95 .75])
  
  for swp = 1:sweeps
	spikesind=find(squeeze(spdata(:,swp,recs(abc),cls)));
	spikestimes = spikesind/mf+firsttime;
	ph=plot(spikestimes,sign(spdata(spikesind,swp,recs(abc),cls))*swp,[colors{cls} '.']);
	set(ph,'MarkerSize',.4)
	set(ph,'Marker','o')
	% The following lines are for transfer to Canvas. 
        if numclass == 1,
	 set(ph,'Marker','pentagram')
	 set(ph,'MarkerSize',2)
	 set(ph,'MarkerEdgeColor','none')
	 set(ph,'MarkerFaceColor',[0 0 0])
        end
  end
  ylabel(['\fontname{',font,'}\fontsize{10}',num2str(ylabels(abc),3)],...
      'Rotation',0,'HorizontalAlignment', 'right')
  xLim = firsttime+[0,durationtime];
  set(gca,'Xlim',xLim);
  set(gca,'Ylim',[0,sweeps+1]);
  set(gca,'Box','on')
  set(gca,'Tickdir','out')
  set(gca,'TickLength', [0.004 0.006]);

  line([1 1]*xLim(1),[0 sweeps+1],'Color',[.90 .90 .90])
  line([1 1]*xLim(2),[0 sweeps+1],'Color',[.90 .90 .90])
  line(xLim,[0 0],'Color',[.90 .90 .90])
  line(xLim,[sweeps+1 sweeps+1],'Color',[.90 .90 .90])
  line([stimOnset,stimOffset],[0 0],'Color',[0 0 0])
  
  if abc == 1
	title(['\fontname{',font,'}\fontsize{10}\bf',fname])
  end
  if abc ~= length(recs)
	set(gca,'XtickLabel','');
  else
	%xlab = str2num(get(gca,'xticklabel'));
	%set(gca,'xticklabel',num2str(xlab/mf))
	set(gca,'fontsize',10,'XColor',[0 0 0])
	xlabel(['\fontname{',font,'}Time (ms)']);
  end
  
 end

end
fig = get(gca,'parent');
set(fig,'Color',[1 1 1]*.999) % to overcome bug that lowest x axis is white
set(fig,'Name',plotfname)
set(fig,'Tag',['tplot:',fname])
set(fig,'UserData',recs)
set(fig,'KeyPressFcn','feawindowkeydown')
if (length(fname)>7)
  featype=fname(end-6:end-4);
  % 	if strcmp('m1-',featype)|strcmp('m2-',featype)|strcmp('a1-',featype)
  % 		set(fig,'WindowButtonUpFcn',['mplot(''',fname,''');'])
  % 	else
  % 		set(fig,'WindowButtonUpFcn',['nplot(''',fname,''');'])
  %  	end
else featype = '';
end

figOldPos = get(fig,'Position');
axPos = get(gca,'Position');axHgt = axPos(4);
nomSize = 0.0575;
figNewPos(3) = figOldPos(3); % width
figNewPos(4) = round(figOldPos(4)/axHgt*nomSize); % height
figNewPos(1) = round(figOldPos(1)*rand(1)); % left
figNewPos(2) = round((figOldPos(2)+figOldPos(4)-figNewPos(4))*rand(1));%bottom 
set(fig,'Position',figNewPos)
% center figure on page at correct size
set(fig,'PaperPositionMode','Auto')
% rescale if too large for paper
ppo=get(fig,'PaperPosition');
ps = get(fig,'PaperSize');
if ppo(4) > (ps(2)-0.5)
	ppn3 = ppo(3)*(ps(2)-0.5)/ppo(4);
	set(fig,'PaperPosition',[ (ps(1)-ppn3)/2 0.25 ppn3 ps(2)-0.5])	
end

cm = uimenu(fig,'Label','&NSL');
itemLabel = 'Close'; callback = ['close(',num2str(fig),')'];
uimenu(cm,'Label',itemLabel,'Callback',callback);
%  itemLabel = '&Tplot'; callback = ['tplot(''',fname,''')']
%  uimenu(cm,'Label',itemLabel,'Callback',callback);
itemLabel = '&Nplot'; callback = ['nplot(''',fname,''')'];
uimenu(cm,'Label',itemLabel,'Callback',callback);
if (strcmp('m1-',featype)|strcmp('m2-',featype)|strcmp('a1-',featype))
  itemLabel = '&Mplot'; callback = ['mplot(''',fname,''')'];
  uimenu(cm,'Label',itemLabel,'Callback',callback);
end
if strcmp(featype,'a1-')
  itemLabel = '&Iplot'; callback = ['iplot(''',fname,''')'];
  uimenu(cm,'Label',itemLabel,'Callback',callback);
end


figure(fig)
drawnow
