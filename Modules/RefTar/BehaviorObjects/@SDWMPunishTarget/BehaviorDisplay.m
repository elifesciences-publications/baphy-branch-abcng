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
     [ll,ev] = IOLightSwitch (HW,0,[],[],[],[],'LED');

    % this is the end, things has been displayed already:
    % display overall hit rate,  discrim rate and discrim index:
    if isfield(exptparams,'Performance')
        
        subplot(5,4,1:4)
        plot(1,1)
        axis off
        
        text(-.25,1.5,['TnTn: ',num2str(exptparams.AllToneRefToneTarLick.Num)],'fontsize',12)
        text(-.25,.4,['TnTr: ',num2str(exptparams.AllToneRefTorcTarLick.Num)],'fontsize',12)
        text(-.05,1.5,['TrTn: ',num2str(exptparams.AllTorcRefToneTarLick.Num)],'fontsize',12)
        text(-.05,.4,['TrTr: ',num2str(exptparams.AllTorcRefTorcTarLick.Num)],'fontsize',12)

        text(.2,.4,['FAr: ',num2str(roundTo(exptparams.Performance(end).FalsePositiveRate,1))],'fontsize',30,'color','b')
        text(.2,1.5,['Hr: ',num2str(roundTo(exptparams.Performance(end).HitRate,1))],'fontsize',30,'color','r')
        text(.7,.4,['CRr: ',num2str(roundTo(exptparams.Performance(end).CorrectRejectionRate,1))],'fontsize',30,'color','c')
        text(.75,1.5,['Mr: ',num2str(roundTo(exptparams.Performance(end).MissRate,1))],'fontsize',30,'color','m')
        text(1.25,1.5,['Sr: ',num2str(roundTo(exptparams.Performance(end).SafeRate,1))],'fontsize',30,'color','g')
        text(1.25,.4,['Szr: ',num2str(roundTo(exptparams.Performance(end).SnoozeRate,1))],'fontsize',30,'color','y')
        text(1.8,1.5,['Dr: ',num2str(roundTo(exptparams.Performance(end).DiscrimRate,1))],'fontsize',30,'color','k')
        zHr = norminv(exptparams.Performance(end).HitRate./100);
        zFPr = norminv(exptparams.Performance(end).FalsePositiveRate./100);
        dprime = roundTo(zHr-zFPr,2);
        text(1.75,.4,['d'': ',num2str(dprime)],'fontsize',30,'color',[.5 .5 .5])
        
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
            elseif StimEvents(cnt1).Rove(1) ~= StimEvents(cnt1).Rove(2)
                c='r';
            elseif StimEvents(cnt1).Rove(1) == StimEvents(cnt1).Rove(2)
                c='c';
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
            elseif StimEvents(cnt1).Rove(1) ~= StimEvents(cnt1).Rove(2)
                text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, StimRefOrTar(1),...
                    'color',c,'FontWeight','bold','HorizontalAlignment','center');
            elseif StimEvents(cnt1).Rove(1) == StimEvents(cnt1).Rove(2)
                text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, 'D',...
                    'color',c,'FontWeight','bold','HorizontalAlignment','center');
            end
            
        end
    end
end

% display hit rate, miss rate, false positive rate and correct rejection rate:
Tarcnt = exptparams.Tarcnt;
Discnt = exptparams.Discnt;

h1=subplot(5,4,5:6);
cla(h1)
plot(0,0,'r','linewidth',2);
hold on;
plot(0,0,'b','linewidth',2);
legend(h1, {'Hr','FAr'},'Location','SouthWest');
set(h1,'fontsize',8);

plot(Tarcnt, 100*cat(1,exptparams.Performance(Tarcnt).RecentHitRate),'ro-','LineWidth',2,'MarkerEdgeColor','r',...
    'MarkerFaceColor','r','MarkerSize',4);
hold on;
plot(Discnt, 100*cat(1,exptparams.Performance(Discnt).RecentFalsePositiveRate),'bo-','LineWidth',2,'MarkerEdgeColor','b',...
    'MarkerFaceColor','b','MarkerSize',4);
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

h1=subplot(5,4,7:8);
cla(h1)
plot(0,0,'c','linewidth',2);
hold on;
plot(0,0,'m','linewidth',2);
legend(h1, {'CRr','Mr'},'Location','SouthWest');
set(h1,'fontsize',8);

plot(Discnt, 100*cat(1,exptparams.Performance(Discnt).RecentCorrectRejectionRate),'co-','LineWidth',2,'MarkerEdgeColor','c',...
    'MarkerFaceColor','c','MarkerSize',4);
hold on;
plot(Tarcnt, 100*cat(1,exptparams.Performance(Tarcnt).RecentMissRate),'mo-','LineWidth',2,'MarkerEdgeColor','m',...
    'MarkerFaceColor','m','MarkerSize',4);
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

% display discrim rate, d', snooze rate and safe rate:
h1=subplot(5,4,9:10);
cla(h1)
plot(0,0,'g','linewidth',2);
hold on;
plot(0,0,'y','linewidth',2);
legend(h1, {'Sr','SZr'},'Location','SouthWest');
set(h1,'fontsize',8);

plot(100*cat(1,exptparams.Performance(1:end-1).RecentSafeRate),'go-','LineWidth',2,'MarkerEdgeColor','g',...
    'MarkerFaceColor','g','MarkerSize',4);
hold on;
plot(100*cat(1,exptparams.Performance(1:end-1).RecentSnoozeRate),'yo-','LineWidth',2,'MarkerEdgeColor','y',...
    'MarkerFaceColor','y','MarkerSize',4);
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

h1=subplot(5,4,11:12);
plot(0,0,'k','linewidth',2);
legend(h1, {'Dr'},'Location','SouthWest');
set(h1,'fontsize',8);

plot(Tarcnt, 100*cat(1,exptparams.Performance(Tarcnt).RecentDiscrimRate),'ks-','LineWidth',2,'MarkerEdgeColor','k',...
    'MarkerFaceColor','k','MarkerSize',4);
hold on;
xlabel('Trial Number');
axis ([0 length(exptparams.Performance) 0 115]);

if isfield (exptparams,'AnalysisWindow')
    exptparams = rmfield(exptparams,'AnalysisWindow')
end

% Lick Histogram:
% Reference
% Add together all references traces
h1 = subplot(5,4,13:16);
cla(h1)
plot(0,0,'k','linewidth',2);
hold on;
plot(0,0,'r','linewidth',2);
plot(0,0,'c','linewidth',2);
legend(h1, {'ToneRef','ToneTorc','ToneTone'},'Location','SouthEast');
xlabel('Time (s re:onset)');

x = get(exptparams.TrialObject,'rovedurs');
if length(x) ~=1
  DurIncrement = x(1,2);
  RefDurs = get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration');
  PossibleDurs =RefDurs(1):DurIncrement:RefDurs(2);
  Increment =1:DurIncrement*fs:max(PossibleDurs).*fs;
else
  DurIncrement = 0;
  RefDurs = mean(get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration'));
  PossibleDurs =RefDurs;
  Increment =1:0.25*fs:max(PossibleDurs).*fs;
end

TarDur = mean(RefDurs);

ToneRefLick = [];
if ~isempty(exptparams.AllToneRefLick.Hist)
    for cnt1 = 1:length(Increment)

        TempToneRefLick=[];
        for cnt2 = 1:length(exptparams.AllToneRefLick.Hist)
            if length(exptparams.AllToneRefLick.Hist{cnt2}) > Increment(cnt1)
                TempToneRefLick = [TempToneRefLick exptparams.AllToneRefLick.Hist{cnt2}(Increment(cnt1):Increment(cnt1)+249,:)];

            end
        end

        if isempty(TempToneRefLick)==0
            if size(TempToneRefLick,2) ~= 1
                ToneRefLick = [ToneRefLick; mean(TempToneRefLick,2) 2*sqrt(var(TempToneRefLick')./size(TempToneRefLick,2))'];
            else
                ToneRefLick = [ToneRefLick; TempToneRefLick zeros(size(TempToneRefLick))];
            end
        end
    end

    t=0:1/fs:(length(ToneRefLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*ToneRefLick(:,1),100*ToneRefLick(:,2),{'k','linewidth',3},1);
    hold on
end

ToneRefTorcTarLick = [];
if ~isempty(exptparams.AllToneRefTorcTarLick.Hist)

            if size(exptparams.AllToneRefTorcTarLick.Hist{1},2) ~= 1
                ToneRefTorcTarLick = [ToneRefTorcTarLick; mean(exptparams.AllToneRefTorcTarLick.Hist{1},2) 2*sqrt(var(exptparams.AllToneRefTorcTarLick.Hist{1}')./size(exptparams.AllToneRefTorcTarLick.Hist{1},2))'];
            else
                ToneRefTorcTarLick = [ToneRefTorcTarLick; exptparams.AllToneRefTorcTarLick.Hist{1} zeros(size(exptparams.AllToneRefTorcTarLick.Hist{1}))];
            end

    t=0:1/fs:(length(ToneRefTorcTarLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*ToneRefTorcTarLick(:,1),100*ToneRefTorcTarLick(:,2),{'r','linewidth',3},1);
    hold on
end

ToneRefToneTarLick = [];
if ~isempty(exptparams.AllToneRefToneTarLick.Hist)

            if size(exptparams.AllToneRefToneTarLick.Hist{1},2) ~= 1
                ToneRefToneTarLick = [ToneRefToneTarLick; mean(exptparams.AllToneRefToneTarLick.Hist{1},2) 2*sqrt(var(exptparams.AllToneRefToneTarLick.Hist{1}')./size(exptparams.AllToneRefToneTarLick.Hist{1},2))'];
            else
                ToneRefToneTarLick = [ToneRefToneTarLick; exptparams.AllToneRefToneTarLick.Hist{1} zeros(size(exptparams.AllToneRefToneTarLick.Hist{1}))];
            end

    t=0:1/fs:(length(ToneRefToneTarLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*ToneRefToneTarLick(:,1),100*ToneRefToneTarLick(:,2),{'c','linewidth',3},1);
    hold on
end

% label the segments:
PostLickWindow = get(o,'PostLickWindow');
Bounds = [0 TarDur+PostLickWindow TarDur];
patch([Bounds(1,2) Bounds(1,2) ...
    Bounds(1,3) Bounds(1,3)], [0 100 100 0],'y','EdgeColor','y')
alpha(0.5);

Bounds = [0 TarDur+PostLickWindow unique([TarDur max(PossibleDurs)])];
set(gca,'XTick', Bounds)
set(gca,'XTickLabel',(Bounds)'); % convert to seconds
xlim([0 max(Bounds)]);
ylim([0 100])


h1 = subplot(5,4,[17:20]);
cla(h1)
plot(0,0,'k','linewidth',2);
hold on;
plot(0,0,'r','linewidth',2);
plot(0,0,'c','linewidth',2);
legend(h1, {'TorcRef','TorcTone','TorcTorc'},'Location','SouthEast');
xlabel('Time (s re:onset)');

x = get(exptparams.TrialObject,'rovedurs');
if length(x) ~=1
  DurIncrement = x(1,2);
  RefDurs = get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration');
  PossibleDurs =RefDurs(1):DurIncrement:RefDurs(2);
  Increment =1:DurIncrement*fs:max(PossibleDurs).*fs;
else
  DurIncrement = 0;
  RefDurs = mean(get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration'));
  PossibleDurs =RefDurs;
  Increment =1:0.25*fs:max(PossibleDurs).*fs;
end
TorcRefLick = [];
if ~isempty(exptparams.AllTorcRefLick.Hist)
    for cnt1 = 1:length(Increment)

        TempTorcRefLick=[];
        for cnt2 = 1:length(exptparams.AllTorcRefLick.Hist)
            if length(exptparams.AllTorcRefLick.Hist{cnt2}) > Increment(cnt1)
                TempTorcRefLick = [TempTorcRefLick exptparams.AllTorcRefLick.Hist{cnt2}(Increment(cnt1):Increment(cnt1)+249,:)];

            end
        end

        if isempty(TempTorcRefLick)==0
            if size(TempTorcRefLick,2) ~= 1
                TorcRefLick = [TorcRefLick; mean(TempTorcRefLick,2) 2*sqrt(var(TempTorcRefLick')./size(TempTorcRefLick,2))'];
            else
                TorcRefLick = [TorcRefLick; TempTorcRefLick zeros(size(TempTorcRefLick))];
            end
        end
    end

    t=0:1/fs:(length(TorcRefLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*TorcRefLick(:,1),100*TorcRefLick(:,2),{'k','linewidth',3},1);
    hold on
end

TorcRefToneTarLick = [];
if ~isempty(exptparams.AllTorcRefToneTarLick.Hist)

            if size(exptparams.AllTorcRefToneTarLick.Hist{1},2) ~= 1
                TorcRefToneTarLick = [TorcRefToneTarLick; mean(exptparams.AllTorcRefToneTarLick.Hist{1},2) 2*sqrt(var(exptparams.AllTorcRefToneTarLick.Hist{1}')./size(exptparams.AllTorcRefToneTarLick.Hist{1},2))'];
            else
                TorcRefToneTarLick = [TorcRefToneTarLick; exptparams.AllTorcRefToneTarLick.Hist{1} zeros(size(exptparams.AllTorcRefToneTarLick.Hist{1}))];
            end

    t=0:1/fs:(length(TorcRefToneTarLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*TorcRefToneTarLick(:,1),100*TorcRefToneTarLick(:,2),{'r','linewidth',3},1);
    hold on
end

TorcRefTorcTarLick = [];
if ~isempty(exptparams.AllTorcRefTorcTarLick.Hist)

            if size(exptparams.AllTorcRefTorcTarLick.Hist{1},2) ~= 1
                TorcRefTorcTarLick = [TorcRefTorcTarLick; mean(exptparams.AllTorcRefTorcTarLick.Hist{1},2) 2*sqrt(var(exptparams.AllTorcRefTorcTarLick.Hist{1}')./size(exptparams.AllTorcRefTorcTarLick.Hist{1},2))'];
            else
                TorcRefTorcTarLick = [TorcRefTorcTarLick; exptparams.AllTorcRefTorcTarLick.Hist{1} zeros(size(exptparams.AllTorcRefTorcTarLick.Hist{1}))];
            end

    t=0:1/fs:(length(TorcRefTorcTarLick(:,1))./fs)-(1/fs);
    shadedErrorBar(t,100*TorcRefTorcTarLick(:,1),100*TorcRefTorcTarLick(:,2),{'c','linewidth',3},1);
    hold on
end


% label the segments:
PostLickWindow = get(o,'PostLickWindow');
Bounds = [0 TarDur+PostLickWindow TarDur];
patch([Bounds(1,2) Bounds(1,2) ...
    Bounds(1,3) Bounds(1,3)], [0 100 100 0],'y','EdgeColor','y')
alpha(0.5);

Bounds = [0 TarDur+PostLickWindow unique([TarDur max(PossibleDurs)])];
set(gca,'XTick', Bounds)
set(gca,'XTickLabel',(Bounds)'); % convert to seconds
xlim([0 max(Bounds)]);
ylim([0 100])



drawnow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbutton_Callback(hObject, eventdata, handles)

global StopExperiment;
StopExperiment = 1;
