function exptparams = BehaviorDisplay (o, HW, StimEvents, globalparams, exptparams, TrialIndex, AIData, TrialSound)
% control mode:
% display the following:
%   Sound waveform, Lick, and spike data. Label them using
%   StimEvents and pre pos lick data:
%   performance as a graph

fs = globalparams.HWparams.fsAI;
ShockTar = get(exptparams.TrialObject,'ShockTar');
if isfield (exptparams,'AnalysisWindow')
    exptparams = rmfield(exptparams,'AnalysisWindow')
end

% see if the results figure exists, otherwise create it:
if ~isfield(exptparams, 'ResultsFigure')
    exptparams.ResultsFigure = figure('position',[1 1 900 900]);
    movegui(exptparams.ResultsFigure,'northwest');
end
figure(exptparams.ResultsFigure);
uicontrol('Style', 'pushbutton', 'String','PAUSE','Callback', @pushbutton_Callback);
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
        
        HitRate=[];
        FalsePositiveRate=[];
        
        if isempty(exptparams.Tarcnt) == 0
            HitRate = exptparams.Performance(end).HitRate;
            DiscrimRate = exptparams.Performance(end).DiscrimRate;
            text(0,1.5,['Hr: ',num2str(HitRate)],'fontsize',30,'color','r')
            text(1.5,1.5,['Dr: ',num2str(DiscrimRate)],'fontsize',30,'color',[.5 .5 .5])
            
        end
        
        if isempty(exptparams.Discnt) == 0
            FalsePositiveRate = exptparams.Performance(end).FalsePositiveRate;
            text(0,.4,['FPr: ',num2str(mean(FalsePositiveRate))],'fontsize',30,'color','b')
            
        end
        
        if isempty(FalsePositiveRate) == 0 &&  isempty(HitRate) == 0
            zHr = norminv(HitRate./100);
            zFPr = norminv(FalsePositiveRate./100);
            dprime = zHr-zFPr;
            text(1.5,.4,['d'': ',num2str(dprime)],'fontsize',30,'color','k')
            
        end
        
        SnoozeRate = exptparams.Performance(end).SnoozeRate;
        SafeRate = exptparams.Performance(end).SafeRate;
        
        text(.75,.4,['Sr: ',num2str(SafeRate)],'fontsize',30,'color','g')
        text(.75,1.5,['Szr: ',num2str(SnoozeRate)],'fontsize',30,'color','y')
        
        title(titleMes,'interpreter','none');
        drawnow;
        
        return;
    end
end

% display the lick signal
% display the lick signal and the boundaries:
h = subplot(5,4,1:4);plot(AIData,'k');
axis ([0 max([length(AIData)+.4*fs 1]) 0 1.5]);
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
                if StimEvents(cnt1).Rove{1} == ShockTar
                    c='r';
                else
                    c='c';
                end
                
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
                if StimEvents(cnt1).Rove{1} == ShockTar
                    text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, StimRefOrTar(1),...
                        'color',c,'FontWeight','bold','HorizontalAlignment','center');
                else
                    text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, 'D',...
                        'color',c,'FontWeight','bold','HorizontalAlignment','center');
                end
            end
        end
    end
end

% display hit rate, miss rate, false positive rate and correct rejection rate:
Tarcnt = exptparams.Tarcnt;
Discnt = exptparams.Discnt;
TarDiscnt = intersect(exptparams.Tarcnt, exptparams.Discnt);

subplot(5,4,5:6)
if isempty(Tarcnt) == 0
    if length(Tarcnt) == 1
        RecentHitRate = 100*exptparams.Performance(Tarcnt).RecentHitRate;
    else
        RecentHitRate = 100*cat(1,exptparams.Performance(Tarcnt).RecentHitRate);
    end
    plot(Tarcnt, RecentHitRate,'ro-','LineWidth',2,'MarkerEdgeColor','r',...
        'MarkerFaceColor','r','MarkerSize',4);
end

hold on;

if isempty(Discnt) == 0
    if length(Discnt) == 1
        RecentFalsePositiveRate = 100*exptparams.Performance(Discnt).RecentFalsePositiveRate;
    else
        RecentFalsePositiveRate = 100*cat(1,exptparams.Performance(Discnt).RecentFalsePositiveRate);
    end
    plot(Discnt, RecentFalsePositiveRate,'bo-','LineWidth',2,'MarkerEdgeColor','b',...
        'MarkerFaceColor','b','MarkerSize',4);
end

if isempty(Tarcnt) == 0 && isempty(Discnt) == 0
    h=legend({'Hr','FPr'},'Location','SouthWest');
elseif isempty(Tarcnt) == 0 && isempty(Discnt) == 1
    h=legend({'Hr'},'Location','SouthWest');
elseif isempty(Tarcnt) == 1 && isempty(Discnt) == 0
    h=legend({'FPr'},'Location','SouthWest');
end
LegPos = get(h,'position');
set(h,'fontsize',8);
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

subplot(5,4,7:8)
if isempty(Discnt) == 0
    if length(Discnt) == 1
        RecentCorrectRejectionRate = 100*exptparams.Performance(Discnt).RecentCorrectRejectionRate;
    else
        RecentCorrectRejectionRate = 100*cat(1,exptparams.Performance(Discnt).RecentCorrectRejectionRate);
    end
    plot(Discnt, RecentCorrectRejectionRate,'co-','LineWidth',2,'MarkerEdgeColor','c',...
        'MarkerFaceColor','c','MarkerSize',4);
end
hold on;

if isempty(Tarcnt) == 0
    if length(Tarcnt) == 1
        RecentMissRate = 100*exptparams.Performance(Tarcnt).RecentMissRate;
    else
        RecentMissRate = 100*cat(1,exptparams.Performance(Tarcnt).RecentMissRate);
    end
    plot(Tarcnt, RecentMissRate,'mo-','LineWidth',2,'MarkerEdgeColor','m',...
        'MarkerFaceColor','m','MarkerSize',4);
end
if isempty(Tarcnt) == 0 && isempty(Discnt) == 0
    h=legend({'CRr','Mr'},'Location','SouthWest');
elseif isempty(Tarcnt) == 0 && isempty(Discnt) == 1
    h=legend({'Mr'},'Location','SouthWest');
elseif isempty(Tarcnt) == 1 && isempty(Discnt) == 0
    h=legend({'CRr'},'Location','SouthWest');
end

xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);


% display discrim rate, snooze rate and safe rate:
subplot(5,4,9:10)
if TrialIndex == 1
    RecentSafeRate = 100*exptparams.Performance(1:end-1).RecentSafeRate;
else
    RecentSafeRate = 100*cat(1,exptparams.Performance(1:end-1).RecentSafeRate);
end
plot(RecentSafeRate,'go-','LineWidth',2,'MarkerEdgeColor','g',...
    'MarkerFaceColor','g','MarkerSize',4);
hold on;

if TrialIndex == 1
    RecentSnoozeRate = 100*exptparams.Performance(1:end-1).RecentSnoozeRate;
else
    RecentSnoozeRate = 100*cat(1,exptparams.Performance(1:end-1).RecentSnoozeRate);
end
plot(RecentSnoozeRate,'yo-','LineWidth',2,'MarkerEdgeColor','y',...
    'MarkerFaceColor','y','MarkerSize',4);
if TrialIndex ==1
    h=legend({'Sr','SZr'},'Location','SouthWest');
    LegPos = get(h,'position');
    set(h,'fontsize',8);
end
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

subplot(5,4,11:12)
if isempty(Tarcnt) == 0
    if length(Tarcnt) == 1
        RecentDiscrimRate = 100*exptparams.Performance(Tarcnt).RecentDiscrimRate;
    else
        RecentDiscrimRate = 100*cat(1,exptparams.Performance(Tarcnt).RecentDiscrimRate);
    end
    plot(Tarcnt, RecentDiscrimRate,'s-','Color',[.5 .5 .5],'LineWidth',2,'MarkerEdgeColor',[.5 .5 .5],...
        'MarkerFaceColor',[.5 .5 .5],'MarkerSize',4);
end
hold on;
h=legend({'Dr'},'Location','SouthWest');

xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

% Lick Histogram:
% Reference
%Add together all references traces
subplot(5,4,[13:20]);
plot(0,0,'k','linewidth',3);
hold on;
plot(0,0,'b');
plot(0,0,'g');

switch isempty(exptparams.AllTarLick.Hist)
    case 0
        switch isempty(exptparams.AllDisLick.Hist)
            case 0
                legend({'Ref','Tar','Dis'},'Location','SouthWest');
            case 1
                legend({'Ref','Tar'},'Location','SouthWest');
        end
    case 1
        legend({'Ref','Dis'},'Location','SouthWest');
end

x = get(exptparams.TrialObject,'rovedurs');
DurIncrement = x(1,2);
RefDurs = get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration');
PossibleDurs =RefDurs(1):DurIncrement:RefDurs(2);
BoundPosDurs = PossibleDurs;
RefIncrement =1:DurIncrement*fs:RefDurs(2).*fs;
RefLick = [];
for cnt1 = 1:length(RefIncrement)
    
    TempRefLick=[];
    for cnt2 = 1:length(exptparams.AllRefLick.Hist)
        if length(exptparams.AllRefLick.Hist{cnt2}) > RefIncrement(cnt1)
            TempRefLick = [TempRefLick exptparams.AllRefLick.Hist{cnt2}(RefIncrement(cnt1):RefIncrement(cnt1)+249,:)];
            
        end
    end
    
    if isempty(TempRefLick)==0
        if size(TempRefLick,2) ~= 1
            RefLick = [RefLick; mean(TempRefLick,2) 2*sqrt(var(TempRefLick')./size(TempRefLick,2))'];
        else
            RefLick = [RefLick; TempRefLick zeros(size(TempRefLick))];
        end
    end
end
t=0:1/fs:(length(RefLick(:,1))./fs)-(1/fs);
hold off;
shadedErrorBar(t,100*RefLick(:,1),100*RefLick(:,2),{'k','linewidth',3},1);
hold on;
xlabel('Time (s re:onset)');

TarDur=[];
if ~isempty(exptparams.AllTarLick.Hist)
    TarDur = get(get(exptparams.TrialObject,'TargetHandle'),'Duration');
    TarIncrement =1:DurIncrement*fs:TarDur.*fs;
    TarLick = [];
    for cnt1 = 1:length(TarIncrement)
        
        TempTarLick=[];
        for cnt2 = 1:length(exptparams.AllTarLick.Hist)
            if length(exptparams.AllTarLick.Hist{cnt2}) > TarIncrement(cnt1)
                TempTarLick = [TempTarLick exptparams.AllTarLick.Hist{cnt2}(TarIncrement(cnt1):TarIncrement(cnt1)+249,:)];
                
            end
        end
        
        if isempty(TempTarLick) == 0
            if size(TempTarLick,2) ~= 1
                TarLick = [TarLick; mean(TempTarLick,2) 2*sqrt(var(TempTarLick')./size(TempTarLick,2))'];
            else
                TarLick = [TarLick; TempTarLick zeros(size(TempTarLick))];
            end
        end
    end
    t=0:1/fs:(length(TarLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*TarLick(:,1),100*TarLick(:,2),'b',1)
    
end

DisDur=[];
if ~isempty(exptparams.AllDisLick.Hist)
    DisDur = get(get(exptparams.TrialObject,'TargetHandle'),'Duration');
    DisIncrement =1:DurIncrement*fs:DisDur.*fs;
    DisLick = [];
    for cnt1 = 1:length(DisIncrement)
        
        TempDisLick=[];
        for cnt2 = 1:length(exptparams.AllDisLick.Hist)
            if length(exptparams.AllDisLick.Hist{cnt2}) > DisIncrement(cnt1)
                TempDisLick = [TempDisLick exptparams.AllDisLick.Hist{cnt2}(DisIncrement(cnt1):DisIncrement(cnt1)+249,:)];
                
            end
        end
        
        if isempty(TempDisLick)==0
            if size(TempDisLick,2) ~= 1
                DisLick = [DisLick; mean(TempDisLick,2) 2*sqrt(var(TempDisLick')./size(TempDisLick,2))'];
            else
                DisLick = [DisLick; TempDisLick zeros(size(TempDisLick))];
            end
        end
    end
    t=0:1/fs:(length(DisLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*DisLick(:,1),100*DisLick(:,2),'g',1)
    
end

% label the segments:
PostLickWindow = get(o,'PostLickWindow');
Durs = [min([TarDur DisDur])  max([TarDur DisDur]) max(BoundPosDurs)];

Bounds = [0 Durs(1)+PostLickWindow Durs(2)];
patch([Bounds(1,2) Bounds(1,2) ...
    Bounds(1,3) Bounds(1,3)], [0 100 100 0],'r','EdgeColor','r')
alpha(0.25);

Bounds = [0 Durs(1)+PostLickWindow Durs(2) Durs(3)];
set(gca,'XTick', Bounds)
set(gca,'XTickLabel',(Bounds)'); % convert to seconds
xlim([0 max(Bounds)]);
ylim([0 100])

drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbutton_Callback(hObject, eventdata, handles)

global StopExperiment;
StopExperiment = 1;

