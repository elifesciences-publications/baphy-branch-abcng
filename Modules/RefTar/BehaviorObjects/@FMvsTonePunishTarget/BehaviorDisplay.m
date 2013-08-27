function exptparams = BehaviorDisplay (o, HW, StimEvents, globalparams, exptparams, TrialIndex, AIData, TrialSound)
% control mode:
% display the following:
%   Sound waveform, Lick, and spike data. Label them using
%   StimEvents and pre pos lick data:
%   performance as a graph

fs = globalparams.HWparams.fsAI;

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
        subplot(5,6,1:6)
        plot(1,1)
        axis off
        text(-.1,1.5,['Hr: ',num2str(roundTo(mean(100*cat(1,exptparams.Performance(exptparams.Tone1scnt).T1HitRate)),2))],'fontsize',30,'color','r')
        text(-.1,.4,['Dr: ',num2str(roundTo(mean(100*cat(1,exptparams.Performance(exptparams.Tone1scnt).T1DiscrimRate)),2))],'fontsize',30,'color','r')
        
        text(.5,1.5,['Hr: ',num2str(roundTo(mean(100*cat(1,exptparams.Performance(exptparams.Tone3scnt).T3HitRate)),2))],'fontsize',30,'color','m')
        text(.5,.4,['Dr: ',num2str(roundTo(mean(100*cat(1,exptparams.Performance(exptparams.Tone3scnt).T3DiscrimRate)),2))],'fontsize',30,'color','m')
        
        text(1.1,1.5,['Hr: ',num2str(roundTo(mean(100*cat(1,exptparams.Performance(exptparams.FM1scnt).FM1HitRate)),2))],'fontsize',30,'color','b')
        text(1.1,.4,['Dr: ',num2str(roundTo(mean(100*cat(1,exptparams.Performance(exptparams.FM1scnt).FM1DiscrimRate)),2))],'fontsize',30,'color','b')
        
        text(1.7,1.5,['Hr: ',num2str(roundTo(mean(100*cat(1,exptparams.Performance(exptparams.FM3scnt).FM3HitRate)),2))],'fontsize',30,'color','c')
        text(1.7,.4,['Dr: ',num2str(roundTo(mean(100*cat(1,exptparams.Performance(exptparams.FM3scnt).FM3DiscrimRate)),2))],'fontsize',30,'color','c')

        title(titleMes,'interpreter','none');
        drawnow;
        
        
        
    end
    if isfield (exptparams,'AnalysisWindow')
        exptparams = rmfield(exptparams,'AnalysisWindow')
    end
    return;
end

% display the lick signal
% display the lick signal and the boundaries:
h = subplot(5,6,1:4);plot(AIData,'k');
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
                switch StimEvents(cnt1).Rove(1)
                    case 1
                        c='r';
                    case 2
                        c='m';
                    case 3
                        c='b';
                    case 4
                        c='c'
                end
            end
            
            line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StartTime],[0 .5],'color',c,...
                'LineStyle','--','LineWidth',2);
            line([fs*StimEvents(cnt1).StopTime fs*StimEvents(cnt1).StopTime],[0 .5],'color',c,...
                'LineStyle','--','LineWidth',2);
            line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StopTime], [.5 .5],'color',c,...
                'LineStyle','--','LineWidth',2);
            
            text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, StimRefOrTar(1),...
                'color',c,'FontWeight','bold','HorizontalAlignment','center');
            
        end
    end
end

% display snooze rate and safe rate:
subplot(5,6,5:6)
plot(100*cat(1,exptparams.Performance(1:end-1).RecentSafeRate),'go-','LineWidth',2,'MarkerEdgeColor','g',...
    'MarkerFaceColor','g','MarkerSize',4);
hold on;
plot(100*cat(1,exptparams.Performance(1:end-1).RecentSnoozeRate),'yo-','LineWidth',2,'MarkerEdgeColor','y',...
    'MarkerFaceColor','y','MarkerSize',4);
if TrialIndex ==1
    h=legend({'Sr','SZr'},'Location','SouthWest');
    LegPos = get(h,'position');
    set(h,'fontsize',8);
end
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

% display hit rate, miss rate,and discrim rate:
Tone1scnt = exptparams.Tone1scnt;
subplot(5,6,7:9)
plot(Tone1scnt, 100*cat(1,exptparams.Performance(Tone1scnt).RecentT1HitRate),'ro-','LineWidth',2,'MarkerEdgeColor','r',...
    'MarkerFaceColor','r','MarkerSize',4);
hold on;
plot(Tone1scnt, 100*cat(1,exptparams.Performance(Tone1scnt).RecentT1DiscrimRate),'s-','Color',[.5 .5 .5],'LineWidth',2,'MarkerEdgeColor',[.5 .5 .5],...
    'MarkerFaceColor',[.5 .5 .5],'MarkerSize',4);

if isempty(Tone1scnt) == 0
    h=legend({'Hr','Dr'},'Location','SouthWest');
end
LegPos = get(h,'position');
set(h,'fontsize',8);
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

Tone3scnt = exptparams.Tone3scnt;
subplot(5,6,10:12)
plot(Tone3scnt, 100*cat(1,exptparams.Performance(Tone3scnt).RecentT3HitRate),'mo-','LineWidth',2,'MarkerEdgeColor','m',...
    'MarkerFaceColor','m','MarkerSize',4);
hold on;
plot(Tone3scnt, 100*cat(1,exptparams.Performance(Tone3scnt).RecentT3DiscrimRate),'s-','Color',[.5 .5 .5],'LineWidth',2,'MarkerEdgeColor',[.5 .5 .5],...
    'MarkerFaceColor',[.5 .5 .5],'MarkerSize',4);

if isempty(Tone3scnt) == 0
    h=legend({'Hr','Dr'},'Location','SouthWest');
end
LegPos = get(h,'position');
set(h,'fontsize',8);
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

FM1scnt = exptparams.FM1scnt;
subplot(5,6,13:15)
plot(FM1scnt, 100*cat(1,exptparams.Performance(FM1scnt).RecentFM1HitRate),'bo-','LineWidth',2,'MarkerEdgeColor','b',...
    'MarkerFaceColor','b','MarkerSize',4);
hold on;
plot(FM1scnt, 100*cat(1,exptparams.Performance(FM1scnt).RecentFM1DiscrimRate),'s-','Color',[.5 .5 .5],'LineWidth',2,'MarkerEdgeColor',[.5 .5 .5],...
    'MarkerFaceColor',[.5 .5 .5],'MarkerSize',4);

if isempty(FM1scnt) == 0
    h=legend({'Hr','Dr'},'Location','SouthWest');
end
LegPos = get(h,'position');
set(h,'fontsize',8);
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

FM3scnt = exptparams.FM3scnt;
subplot(5,6,16:18)
plot(FM3scnt, 100*cat(1,exptparams.Performance(FM3scnt).RecentFM3HitRate),'co-','LineWidth',2,'MarkerEdgeColor','c',...
    'MarkerFaceColor','c','MarkerSize',4);
hold on;
plot(FM3scnt, 100*cat(1,exptparams.Performance(FM3scnt).RecentFM3DiscrimRate),'s-','Color',[.5 .5 .5],'LineWidth',2,'MarkerEdgeColor',[.5 .5 .5],...
    'MarkerFaceColor',[.5 .5 .5],'MarkerSize',4);

if isempty(FM3scnt) == 0
    h=legend({'Hr','Dr'},'Location','SouthWest');
end
LegPos = get(h,'position');
set(h,'fontsize',8);
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

% Lick Histogram:
% Reference
%Add together all references traces
subplot(5,6,19:30);
plot(0,0,'k','linewidth',3);
hold on;
plot(0,0,'r','linewidth',2);
plot(0,0,'m','linewidth',2);
plot(0,0,'b','linewidth',2);
plot(0,0,'c','linewidth',2);

legend({'Ref','T1','T3','FM1','FM3'},'Location','SouthWest');

TempRefLick = exptparams.AllRefLick.Hist;

if size(TempRefLick,2) ~= 1
    RefLick = [mean(TempRefLick,2) 2*sqrt(var(TempRefLick')./size(TempRefLick,2))'];
else
    RefLick = [TempRefLick zeros(size(TempRefLick))];
end
t=0:1/fs:(length(RefLick(:,1))./fs)-(1/fs);
hold off;
shadedErrorBar(t,100*RefLick(:,1),100*RefLick(:,2),{'k','linewidth',3},1);
hold on;
xlabel('Time (s re:onset)');

hold on;
if ~isempty(exptparams.AllTone1sLick.Hist)
    TempTone1sLick=[];
    for cnt2 = 1:size(exptparams.AllTone1sLick.Hist,2)
        TempTone1sLick = [TempTone1sLick exptparams.AllTone1sLick.Hist];
        
    end
    if size(TempTone1sLick,2) ~= 1
        Tone1sLick = [mean(TempTone1sLick,2) 2*sqrt(var(TempTone1sLick')./size(TempTone1sLick,2))'];
    else
        Tone1sLick = [TempTone1sLick zeros(size(TempTone1sLick))];
    end
    t=0:1/fs:(length(Tone1sLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*Tone1sLick(:,1),100*Tone1sLick(:,2),{'r','linewidth',2},1);
    
end



if ~isempty(exptparams.AllTone3sLick.Hist)
    TempTone3sLick=[];
    for cnt2 = 1:size(exptparams.AllTone3sLick.Hist,2)
        TempTone3sLick = [TempTone3sLick exptparams.AllTone3sLick.Hist];
        
    end
    if size(TempTone3sLick,2) ~= 1
        Tone3sLick = [mean(TempTone3sLick,2) 2*sqrt(var(TempTone3sLick')./size(TempTone3sLick,2))'];
    else
        Tone3sLick = [TempTone3sLick zeros(size(TempTone3sLick))];
    end
    t=0:1/fs:(length(Tone3sLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*Tone3sLick(:,1),100*Tone3sLick(:,2),{'m','linewidth',2},1);
    
end

if ~isempty(exptparams.AllFM1sLick.Hist)
    TempFM1sLick=[];
    for cnt2 = 1:size(exptparams.AllFM1sLick.Hist,2)
        TempFM1sLick = [TempFM1sLick exptparams.AllFM1sLick.Hist];
        
    end
    if size(TempFM1sLick,2) ~= 1
        FM1sLick = [mean(TempFM1sLick,2) 2*sqrt(var(TempFM1sLick')./size(TempFM1sLick,2))'];
    else
        FM1sLick = [TempFM1sLick zeros(size(TempFM1sLick))];
    end
    t=0:1/fs:(length(FM1sLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*FM1sLick(:,1),100*FM1sLick(:,2),{'b','linewidth',2},1);
    
end



if ~isempty(exptparams.AllFM3sLick.Hist)
    TempFM3sLick=[];
    for cnt2 = 1:size(exptparams.AllFM3sLick.Hist,2)
        TempFM3sLick = [TempFM3sLick exptparams.AllFM3sLick.Hist];
        
    end
    if size(TempFM3sLick,2) ~= 1
        FM3sLick = [mean(TempFM3sLick,2) 2*sqrt(var(TempFM3sLick')./size(TempFM3sLick,2))'];
    else
        FM3sLick = [TempFM3sLick zeros(size(TempFM3sLick))];
    end
    t=0:1/fs:(length(FM3sLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*FM3sLick(:,1),100*FM3sLick(:,2),{'c','linewidth',2},1);
    
end


% label the segments:
PostLickWindow = get(o,'PostLickWindow');
Bounds = [0 .6 3];
patch([Bounds(1,2) Bounds(1,2) ...
    Bounds(1,3) Bounds(1,3)], [0 100 100 0],'y','EdgeColor','y')
alpha(0.5);
set(gca,'XTick', Bounds)
set(gca,'XTickLabel',(Bounds)'); % convert to seconds
xlim([0 max(Bounds)]);
ylim([0 100])

drawnow;