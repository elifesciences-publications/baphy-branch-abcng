function mpstplot(spdata,mf,fname,recs,paramdata,stonset,stdur,ddur,binnum,pststart,pstend)
% mpstplot(spdata,mf,fname,recs,paramdata,stonset,stdur,ddur,binnum,pststart,pstend)
%
global EXPERIMENT_DIR
[spikes, sweeps, records] = size(spdata);


if ~exist('recs')
    recs = 1:records;
elseif isempty(recs)
    recs = 1:records;
end

recs = 1:records;

featype=fname(end-6:end-4);
if strcmp('m1-',featype)
    rips = getfieldval(paramdata,'ang_freq')';
elseif strcmp('m2-',featype)
    rips = getfieldval(paramdata,'angular_freq') + ...
        zeros(size(getfieldval(paramdata,'cycles')'));
elseif strcmp('a1-',featype)
    inffileP = getfieldstr(paramdata,'inf_file'); % from paramdata
    %inffileI = [fname(1:end-3),'inf'];% implied by name
    %[wfmTotal, a1s_freqs, a1infodata, speechwfm] = geta1info(inffileI);
    %if wfmTotal == -1 % no file as such, try other way
    [wfmTotal, a1s_freqs, a1infodata, speechwfm] = geta1info([EXPERIMENT_DIR filesep inffileP]);
    %end
    a1am = geta1vec(a1infodata,'Ripple amplitudes');
    a1rf = geta1vec(a1infodata,'Ripple frequencies');
    a1ph = geta1vec(a1infodata,'Ripple phase shifts');
    a1rv = geta1vec(a1infodata,'Angular frequencies');
    if speechwfm
        a1am{speechwfm} = a1am{speechwfm-1};a1rf{speechwfm} = a1rf{speechwfm-1};
        a1ph{speechwfm} = a1ph{speechwfm-1};a1rv{speechwfm} = a1rv{speechwfm-1};
    end
    tmaxms   = zeros(wfmTotal,1);
    for wf = [1:wfmTotal]
        if a1rv{wf} ~= 0
            tmaxms(wf) = 1000/gcfhack(a1rv{wf});
        else
            tmaxms(wf) = ddur;
        end
    end
    rips = 1000./tmaxms';
end

if find(rips == 0);rips(find(rips == 0)) = 1000/ddur;end
[DC,AC1,norm,ACP,pst] = mpst(spdata,rips,binnum,pststart,pstend,mf);

if stonset <= 0;stonset = 3; end
if stdur >= spikes/mf-stonset;stdur = spikes/mf-stonset;end

ylabels = [1:length(recs)]';
ylabelstring = 'stimulus';
if ~isempty(paramdata) & (length(fname)>7)
    [ylabels,ylabelstring,paramstring] = relevantfeainfo(fname,paramdata,1/mf);
    ylabels = ylabels(recs);
    ylabelstring = ['\fontname{Times}',ylabelstring];
    paramstring = ['\fontname{Times}\fontsize{9}',paramstring];
end

clf
hold on

yAx = axes('position',[0.0700    0.1100    0.01    0.8125]);
set(yAx,'XColor','w','YColor','w','ZColor','w','xTick',[],'yTick',[])
yLbl = ylabel('','Color','k');
set(yLbl,'String',ylabelstring)

paramAx = axes('Position',[0.1300    0.0400    0.7750    0.01]) ; 
set(paramAx,'XColor','w','YColor','w','ZColor','w','xTick',[],'yTick',[])
xLbl = xlabel('','Color','k');
xPos = get(xLbl,'Position');xPos(1) = 1;set(xLbl,'Position',xPos)
set(xLbl,'HorizontalAlignment', 'right')
set(xLbl,'String',paramstring)

plotLims = [min(min(min(pst)),min(DC-AC1)),max(max(max(pst)),max(DC+AC1))];

for abc = 1:length(recs)
    
    subplot(length(recs),1,abc)
    set(gca,'Ytick',[]);
    hold on
    %line(stonset*[1 1]*mf,plotLims,'Color',[.95 .95 .75])
    %line((stonset+stdur)*[1 1]*mf,plotLims,'Color',[.95 .95 .75])
    %line(pststart*[1 1]*mf,plotLims,'Color',[.95 .75 .95])
    
    plot(1:spikes, DC(abc)+...
        AC1(abc)*sin(2*pi*abs(rips(abc))*(1:spikes)/mf*0.001 ...
        + ACP(abc)), 'b')
    pstplotnum = round(ddur*abs(rips(abc))/1000);
    pstplot = pst(binnum,abc);
    for mm = 1:pstplotnum
        pstplot = [pstplot;pst(:,abc)];
    end
    pstplot = [pstplot;pst(1,abc)];
    plot(([0:pstplotnum*binnum+1]-0.5)/binnum*1000/abs(rips(abc)),...
        pstplot,'r')
    
    ylabel(['\fontsize{9}',num2str(ylabels(abc),3)],...
        'Rotation',0,'HorizontalAlignment', 'right')
    set(gca,'XLim',[0 ddur]);
    set(gca,'YLim',plotLims);
    set(gca,'box','off')
    set(gca,'tickdir','out')
    
    if abc == 1
        title(['\fontname{Times}\fontsize{10}\bf',fname])
        set(gca,'XtickLabel','');
    elseif abc ~= length(recs)
        set(gca,'XtickLabel','');
    else
        xlab = str2num(get(gca,'xticklabel'));
        set(gca,'xticklabel',num2str(xlab/mf))
        set(gca,'fontsize',9)
        %xlabel('\fontname{Times}Time (ms)')
    end
    
end

fig = get(gca,'parent');
set(fig,'Color',[1 1 1])

figOldPos = get(fig,'Position');
axPos = get(gca,'Position');axHgt = axPos(4);
nomSize = 0.0575;
figNewPos(3) = figOldPos(3); % width
figNewPos(4) = round(figOldPos(4)/axHgt*nomSize); % height
figNewPos(1) = round(figOldPos(1)*rand(1)); % left
figNewPos(2) = round((figOldPos(2)+figOldPos(4)-figNewPos(4))*rand(1));%bottom 
set(fig,'Position',figNewPos)

set(fig,'Name',fname)
set(fig,'Tag',['mplot:',fname])
set(fig,'KeyPressFcn','feawindowkeydown')

cm = uimenu(fig,'Label','&NSL');
itemLabel = 'Close'; callback = ['close(',num2str(fig),')'];
uimenu(cm,'Label',itemLabel,'Callback',callback);
itemLabel = '&Tplot'; callback = ['tplot(''',fname,''')'];
uimenu(cm,'Label',itemLabel,'Callback',callback);
itemLabel = '&Nplot'; callback = ['nplot(''',fname,''')'];
uimenu(cm,'Label',itemLabel,'Callback',callback);
%  if (strcmp('m1-',featype)|strcmp('m2-',featype)|strcmp('a1-',featype))
%    itemLabel = '&Mplot'; callback = ['mplot(''',fname,''')'];
%    uimenu(cm,'Label',itemLabel,'Callback',callback);
%  end
if strcmp(featype,'a1-')
    itemLabel = '&Iplot'; callback = ['iplot(''',fname,''')'];
    uimenu(cm,'Label',itemLabel,'Callback',callback);
end

figure(fig)
drawnow
