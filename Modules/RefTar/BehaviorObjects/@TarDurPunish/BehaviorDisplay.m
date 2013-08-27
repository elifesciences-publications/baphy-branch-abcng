function exptparams = BehaviorDisplay (o, HW, StimEvents, globalparams, exptparams, TrialIndex, AIData, TrialSound)
% control mode:
% display the following:
%   Sound waveform, Lick, and spike data. Label them using
%   StimEvents and pre pos lick data:
%   performance as a graph

fs = globalparams.HWparams.fsAI;
if isfield(exptparams,'AnalysisWindow')
    exptparams = rmfield(exptparams,'AnalysisWindow')
end

% see if the results figure exists, otherwise create it:
if ~isfield(exptparams, 'ResultsFigure')
    exptparams.ResultsFigure = figure('position',[1 1 900 900]);
    movegui(exptparams.ResultsFigure,'northwest');
end
figure(exptparams.ResultsFigure);
titleMes = ['Ferret: ' globalparams.Ferret '    Ref: ' ...
    get(exptparams.TrialObject,'ReferenceClass') '    Tar: ' ...
    get(exptparams.TrialObject,'TargetClass')];

% if Trial block is reached or the experiment has ended, then
% show the block on the screen:
if  (isempty(AIData) && isempty(TrialSound))
    EndOfTrials = 1;
else
    EndOfTrials=0;
end

if EndOfTrials
    % this is the end, things has been displayed already:
    % display overall hit rate,  discrim rate and discrim index:
    if isfield(exptparams,'Performance')
        subplot(5,4,1:4)
        plot(1,1)
        axis off
        text(.3,.6,['Hr: ',num2str(round(exptparams.Performance(end).HitRate))],'fontsize',50,'color','r')
        text(1.3,.6,['Dr: ',num2str(round(exptparams.Performance(end).DiscrimRate))],'fontsize',50,'color','k')
        title(titleMes,'interpreter','none');
        drawnow;
        
    end
    return;
end

% display the lick signal
% display the lick signal and the boundaries:
h = subplot(5,4,1:4);plot(AIData,'k');
axis ([0 max([length(AIData) 1]) 0 1.5]);
set(h,'XTickLabel',get(h,'Xtick')/fs); % convert to seconds
xlabel('Time (s)');
title(titleMes,'FontWeight','bold');

% First, draw the boundries of Reference and Target
for cnt1 = 1:length(StimEvents)
    if ~isempty([strfind(StimEvents(cnt1).Note,'Reference') strfind(StimEvents(cnt1).Note,'Target')])
        [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
        if strcmpi(Type,'Stim')
            
            if strcmp(StimRefOrTar,'Reference')
                c='k';
            else
                c='r';
            end
            
            line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StartTime],[0 .5],'color',c,...
                'LineStyle','--','LineWidth',2);
            line([fs*StimEvents(cnt1).StopTime fs*StimEvents(cnt1).StopTime],[0 .5],'color',c,...
                'LineStyle','--','LineWidth',2);
            line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StopTime], [.5 .5],'color',c,...
                'LineStyle','--','LineWidth',2);
            
            if strcmp(StimRefOrTar,'Reference')
                text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, StimRefOrTar(1),...
                    'color',c,'FontWeight','bold','HorizontalAlignment','center');
            else
                text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, StimRefOrTar(1),...
                    'color',c,'FontWeight','bold','HorizontalAlignment','center');
            end
        end
    end
end

% display hit rate, miss rate, false positive rate and correct rejection rate:
Tarcnt = exptparams.Tarcnt;
subplot(5,4,5:8)
plot(Tarcnt, 100*cat(1,exptparams.Performance(Tarcnt).RecentHitRate),'ro-','LineWidth',2,'MarkerEdgeColor','r',...
    'MarkerFaceColor','r','MarkerSize',4);
hold on;
plot(100*cat(1,exptparams.Performance(1:end-1).RecentSafeRate),'go-','LineWidth',2,'MarkerEdgeColor','g',...
    'MarkerFaceColor','g','MarkerSize',4);
plot(100*cat(1,exptparams.Performance(1:end-1).RecentSnoozeRate),'yo-','LineWidth',2,'MarkerEdgeColor','y',...
    'MarkerFaceColor','y','MarkerSize',4);
if TrialIndex ==1
    h=legend({'Hr','Sr','SZr'},'Location','SouthWest');
    LegPos = get(h,'position');
    set(h,'fontsize',8);
end
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);


% Lick Histogram:
if size(exptparams.AllRefLick.Hist{1},2) ~= 1
    RefLick = [mean(exptparams.AllRefLick.Hist{1},2) 2*sqrt(var(exptparams.AllRefLick.Hist{1}')./size(exptparams.AllRefLick.Hist{1},2))'];
else
    RefLick = [exptparams.AllRefLick.Hist{1} zeros(size(exptparams.AllRefLick.Hist{1}))];
end

TarDurs = get(get(exptparams.TrialObject,'TargetHandle'),'Duration');
PossibleDurs =TarDurs;
TarLick1 = [];
if isempty(exptparams.AllTarLick.Hist{1})==0
    if size(exptparams.AllTarLick.Hist{1},2) ~= 1
        TarLick1 = [TarLick1; mean(exptparams.AllTarLick.Hist{1},2) 2*sqrt(var(exptparams.AllTarLick.Hist{1}')./size(exptparams.AllTarLick.Hist{1},2))'];
        
    else
        TarLick1 = [TarLick1; exptparams.AllTarLick.Hist{1} zeros(size(exptparams.AllTarLick.Hist{1}))];
        
    end
    
    subplot(5,4,[9:12]);
    plot(0,0,'k','linewidth',3);
    hold on;
    plot(0,0,'r','linewidth',2);
    legend({'Ref','Tar'},'Location','SouthWest');
    
    if isempty(TarLick1) == 0
        t=0:1/fs:(length(RefLick(:,1))./fs)-(1/fs);
        hold off;
        shadedErrorBar(t,100*RefLick(:,1),100*RefLick(:,2),'k',3);
        hold on;
        xlabel('Time (s re:onset)');
        
        t=0:1/fs:(length(TarLick1(:,1))./fs)-(1/fs);
        shadedErrorBar(t,100*TarLick1(:,1),100*TarLick1(:,2),{'r','linewidth',2},1);
        
    end
    % label the segments:
    ResponseTime = get(o,'ResponseTime');
    Durs = [TarDurs(1)  PossibleDurs(1)];
    
    Bounds = [0 ResponseTime Durs(2)];
    patch([Bounds(1,2) Bounds(1,2) ...
        Bounds(1,3) Bounds(1,3)], [0 100 100 0],'y','EdgeColor','y')
    alpha(0.5);
    
    Bounds = [0 ResponseTime Durs(2)];
    set(gca,'XTick', Bounds)
    set(gca,'XTickLabel',(Bounds)'); % convert to seconds
    xlim([0 max(Bounds)]);
    ylim([0 100])
    text(max(Bounds)-(.05*max(Bounds)),90,[num2str(exptparams.Performance(end).HitRateS),'%'],'fontweight','bold','backgroundcolor','w')
    text(max(Bounds)-(.05*max(Bounds)),75,num2str(size(exptparams.AllTarLick.Hist{1},2)),'fontweight','bold','backgroundcolor','w')
    
end

TarLick2 = [];
if isempty(exptparams.AllTarLick.Hist{2})==0
    if size(exptparams.AllTarLick.Hist{2},2) ~= 1
        TarLick2 = [TarLick2; mean(exptparams.AllTarLick.Hist{2},2) 2*sqrt(var(exptparams.AllTarLick.Hist{2}')./size(exptparams.AllTarLick.Hist{2},2))'];
        
    else
        TarLick2 = [TarLick2; exptparams.AllTarLick.Hist{2} zeros(size(exptparams.AllTarLick.Hist{2}))];
        
    end
    subplot(5,4,[13:16]);
    plot(0,0,'k','linewidth',3);
    hold on;
    plot(0,0,'r','linewidth',2);
    legend({'Ref','Tar'},'Location','SouthWest');
    
    if isempty(TarLick2) == 0
        t=0:1/fs:(length(RefLick(:,1))./fs)-(1/fs);
        hold off;
        shadedErrorBar(t,100*RefLick(:,1),100*RefLick(:,2),'k',3);
        hold on;
        xlabel('Time (s re:onset)');
        
        t=0:1/fs:(length(TarLick2(:,1))./fs)-(1/fs);
        shadedErrorBar(t,100*TarLick2(:,1),100*TarLick2(:,2),{'r','linewidth',2},1);
        
    end
    
    % label the segments:
    ResponseTime = get(o,'ResponseTime');
    Durs = [TarDurs(1)  PossibleDurs(2)];
    
    Bounds = [0 ResponseTime Durs(2)];
    patch([Bounds(1,2) Bounds(1,2) ...
        Bounds(1,3) Bounds(1,3)], [0 100 100 0],'y','EdgeColor','y')
    alpha(0.5);
    
    Bounds = [0 ResponseTime Durs(2)];
    set(gca,'XTick', Bounds)
    set(gca,'XTickLabel',(Bounds)'); % convert to seconds
    xlim([0 max(Bounds)]);
    ylim([0 100])
    text(max(Bounds)-(.05*max(Bounds)),90,[num2str(exptparams.Performance(end).HitRateM),'%'],'fontweight','bold','backgroundcolor','w')
    text(max(Bounds)-(.05*max(Bounds)),75,num2str(size(exptparams.AllTarLick.Hist{2},2)),'fontweight','bold','backgroundcolor','w')
    
end

TarLick3 = [];
if isempty(exptparams.AllTarLick.Hist{3})==0
    if size(exptparams.AllTarLick.Hist{3},2) ~= 1
        TarLick3 = [TarLick3; mean(exptparams.AllTarLick.Hist{3},2) 2*sqrt(var(exptparams.AllTarLick.Hist{3}')./size(exptparams.AllTarLick.Hist{3},2))'];
        
    else
        TarLick3 = [TarLick3; exptparams.AllTarLick.Hist{3} zeros(size(exptparams.AllTarLick.Hist{3}))];
        
    end
    
    subplot(5,4,[17:20]);
    plot(0,0,'k','linewidth',3);
    hold on;
    plot(0,0,'r','linewidth',2);
    legend({'Ref','Tar'},'Location','SouthWest');
    
    if isempty(TarLick3) == 0
        t=0:1/fs:(length(RefLick(:,1))./fs)-(1/fs);
        hold off;
        shadedErrorBar(t,100*RefLick(:,1),100*RefLick(:,2),'k',3);
        hold on;
        xlabel('Time (s re:onset)');
        
        t=0:1/fs:(length(TarLick3(:,1))./fs)-(1/fs);
        shadedErrorBar(t,100*TarLick3(:,1),100*TarLick3(:,2),{'r','linewidth',2},1);
        
    end
    
    % label the segments:
    ResponseTime = get(o,'ResponseTime');
    Durs = [TarDurs(1)  PossibleDurs(3)];
    
    Bounds = [0 ResponseTime Durs(2)];
    patch([Bounds(1,2) Bounds(1,2) ...
        Bounds(1,3) Bounds(1,3)], [0 100 100 0],'y','EdgeColor','y')
    alpha(0.5);
    
    Bounds = [0 ResponseTime Durs(2)];
    set(gca,'XTick', Bounds)
    set(gca,'XTickLabel',(Bounds)'); % convert to seconds
    xlim([0 max(Bounds)]);
    ylim([0 100])
    text(max(Bounds)-(.05*max(Bounds)),90,[num2str(exptparams.Performance(end).HitRateL),'%'],'fontweight','bold','backgroundcolor','w')
    text(max(Bounds)-(.05*max(Bounds)),75,num2str(size(exptparams.AllTarLick.Hist{3},2)),'fontweight','bold','backgroundcolor','w')
    
end

drawnow;