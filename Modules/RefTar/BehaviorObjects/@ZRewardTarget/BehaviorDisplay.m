function exptparams = BehaviorDisplay (o, HW, StimEvents, globalparams, exptparams, TrialIndex, ...
    AIData, TrialSound)
% BehaviorDisplay method of RewardTarget behavior
% Main duties of this method is to display a figure with:
%  Title that has the info about ferret, ref, tar, date, time
%  plot of Hit and False Alarm rate
%  a plot of lick in the last trial with correct labling
%  a histogram of first lick for ref and tar
%  Hit and False Alarm for each position
%  after each TrialBlock, display the performance data

% Nima, april 2006
% if there is paw signal, take it out:
if size(AIData,2)>1,
    AIData = AIData(:,1);
end


fs = HW.params.fsAI;
% see if the results figure exists, otherwise create it:
if ~isfield(exptparams, 'ResultsFigure')
    %     if globalparams.HWSetup==3
    %         exptparams.ResultsFigure = figure('position',[-1270 50 1250 940]);
    %     else
    exptparams.ResultsFigure = figure('position',[1 1 900 900]);
    movegui(exptparams.ResultsFigure,'northwest');
    %     end
end
figure(exptparams.ResultsFigure);
subplot(5,4,1:4);
% create the title:
HWSetup = BaphyMainGuiItems('HWSetup');
titleMes = ['Ferret: ' globalparams.Ferret '     Reference: ' ...
    get(exptparams.TrialObject,'ReferenceClass') '     Target: ' ...
    get(exptparams.TrialObject,'TargetClass') '     Rig: ' , HWSetup{1+globalparams.HWSetup} '       ' ...
    num2str(exptparams.StartTime(1:3),'Date: %1.0f-%1.0f-%1.0f') '     ' ...
    num2str(exptparams.StartTime(4:6),'Start: %1.0f:%1.0f:%1.0f')];
if isfield(exptparams,'StopTime')
    titleMes = [titleMes '     ' num2str(exptparams.StopTime(4:6),'Stop: %1.0f:%1.0f:%1.0f')];
end
% if Trial block is reached or the experiment has ended, then
% show the block on the screen:
if ~mod(TrialIndex,exptparams.TrialBlock) || (isempty(AIData) && isempty(TrialSound))
    if isempty(AIData) && isempty(TrialSound) % if this it the last one:
        ind = 1-(ceil(TrialIndex/exptparams.TrialBlock))/25;
    else
        ind = 1-(floor(TrialIndex/exptparams.TrialBlock))/25;
    end
    subplot(5,4,[11 12 15 16 19 20]);axis off;
    if ind==.96 % this it the first time:
        text(  0,1  ,'Trial','FontWeight','bold','HorizontalAlignment','center');
        text(0.1,1  ,'HR','FontWeight','bold','HorizontalAlignment','center','color','b');
        text(0.2,1  ,'FR','FontWeight','bold','HorizontalAlignment','center');
        text(0.3,1  ,'DR','FontWeight','bold','color','b','HorizontalAlignment','center');
        text(0.4,1  ,'ER','FontWeight','bold','HorizontalAlignment','center');
        text(0.5,1  ,'WaR','FontWeight','bold','color','b','HorizontalAlignment','center');
        text(0.6,1  ,'InfR','FontWeight','bold','HorizontalAlignment','center');
        text(0.7,1  ,'bHR','FontWeight','bold','color','b','HorizontalAlignment','center');
        text(0.8,1  ,'bFR','FontWeight','bold','HorizontalAlignment','center');
        text(0.9,1  ,'bDR','FontWeight','bold','color','b','HorizontalAlignment','center');
    end
    % display trialnumber, SR, HR, DR, hitnum, Snooze Hit Rate, Snooze, shams,
    text(0, ind, num2str(TrialIndex),'FontWeight','bold','HorizontalAlignment','center');
    if isfield(exptparams, 'Performance')
        text(.1, ind, num2str(exptparams.Performance(end).HitRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center','color','b');
        text(.2, ind, num2str(exptparams.Performance(end).FalseAlarmRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.3, ind, num2str(exptparams.Performance(end).DiscriminationRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center','color','b');
        text(.4, ind, num2str(exptparams.Performance(end).EarlyRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.5, ind, num2str(exptparams.Performance(end).WarningRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.6, ind, num2str(exptparams.Performance(end).IneffectiveRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.7, ind, num2str(exptparams.Performance(end).RecentHitRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.8, ind, num2str(exptparams.Performance(end).RecentFalseAlarmRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.9, ind, num2str(exptparams.Performance(end).RecentDiscriminationRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.14, ind, num2str(exptparams.Performance(end).LickRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.14, ind, num2str(exptparams.Performance(end).LickRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.14, ind, num2str(exptparams.Performance(end).LickRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.7, ind, [num2str(exptparams.Performance(end).WarningTrial(1),'%2.0f') '/' num2str(exptparams.Performance(end).WarningTrial(2),'%2.0f')],'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.84, ind, [num2str(exptparams.Performance(end).Ineffective(1),'%2.0f') '/' num2str(exptparams.Performance(end).Ineffective(2),'%2.0f')],'FontWeight','bold','HorizontalAlignment','center');
        %         text( 1, ind, [num2str(exptparams.Performance(end).EarlyTrial(1),'%2.0f') '/' num2str(exptparams.Performance(end).EarlyTrial(2),'%2.0f')],'FontWeight','bold','color','b','HorizontalAlignment','center');
    end
end
if isempty(AIData) && isempty(TrialSound)
    % this is the end, things has been displayed already:
    subplot(5,4,1:4);
    title(titleMes,'interpreter','none');
    % also turn off the light if BehaveorPassive:
    if strcmpi(get(o,'TurnOnLight'),'BehaveOrPassive') && ~isfield(exptparams,'OfflineAnalysis')
        [ll,ev] = IOLightSwitch (HW, 0);
    end
    drawnow;
    return;
end
% display Hitrate, FalseAlarmRate.
subplot(5,4,1:4),plot(100*cat(1,exptparams.Performance(1:end-1).HitRate),'o-','LineWidth',2,...
    'MarkerFaceColor',[1 .5 .5],'MarkerSize',5,'color',[1 .5 .5]);
hold on;
plot(100*cat(1,exptparams.Performance(1:end-1).FalseAlarmRate),'<-','LineWidth',2,...
    'MarkerFaceColor',[.1 .5 .1],'MarkerSize',5,'color',[.1 .5 .1]);
% also, show which trials were Ineffective:
AllIneffective = cat(1,exptparams.Performance(1:TrialIndex).Ineffective);
AllIneffective(find(AllIneffective==0))=nan;
plot(110*AllIneffective,'r*','markersize',10);
axis ([0 (TrialIndex+1) 0 115]);
title(titleMes,'FontWeight','bold','interpreter','none');
h=legend({'HR','FAR','Inef'},'Location','SouthWest');
LegPos = get(h,'position');
set(h,'fontsize',8);
LegPos(1) = 0.005; % put the legend on the far left of the screen
set(h,'position', LegPos);
xlabel('Trial Number','FontWeight','bold');
% display the lick signal and the boundaries:
h = subplot(5,4,5:8);plot(AIData);
axis ([0 length(AIData) 0 1.5]);
set(h,'XTickLabel',get(h,'Xtick')/fs); % convert to seconds
xlabel('Time (seconds)','FontWeight','bold');
% First, draw the boundries of Reference and Target
for cnt1 = 1:length(StimEvents)
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim')
        if strcmpi(StimRefOrTar,'Reference'), c=[.1 .5 .1]; else c=[1 .5 .5]; end
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
% Second, draw the boundry of response window, and early window:
for cnt1 = 1:2:length(exptparams.RefResponseWin)
    line([fs*exptparams.RefResponseWin(cnt1) fs*exptparams.RefResponseWin(cnt1+1)],[1.1 1.1],...
        'color','k','LineStyle','-','LineWidth',2);
    text(fs*(mean(exptparams.RefResponseWin(cnt1:cnt1+1))), 1.15, 'Res','Color',[.1 .5 .1],...
        'HorizontalAlignment','center');
end
line([fs*exptparams.TarResponseWin(1) fs*exptparams.TarResponseWin(2)],[1.1 1.1],...
    'color','k','LineStyle','-','LineWidth',2);
text(fs*(mean(exptparams.TarResponseWin)), 1.15, 'Res','Color',c,...
    'HorizontalAlignment','center');
line([fs*exptparams.TarEarlyWin(1) fs*exptparams.TarEarlyWin(2)],[1.3 1.3],...
    'color','k','LineStyle','-','LineWidth',2);
text(fs*(mean(exptparams.TarEarlyWin)), 1.35, 'Erl','Color',c,...
    'HorizontalAlignment','center');
% First lick Histogram for target and reference
subplot(5,4,9:10)
hold off;
BinSize = 0.04;
h1=hist(exptparams.FirstLick.Tar,0:BinSize:max(exptparams.FirstLick.Tar));
if ~isempty(h1)
    h1=h1/sum(h1); % normalize by sum, so it becomes the probability of lick
    h1=stairs(0:BinSize:max(exptparams.FirstLick.Tar),h1,'color',[1 .5 .5],'linewidth',2);
    hold on;
end
h1=hist(exptparams.FirstLick.Ref,0:BinSize:max(exptparams.FirstLick.Ref));
if ~isempty(h1)
    h1=h1/sum(h1); % normalize by sum, so it becomes the probability of lick
    h1=stairs(0:BinSize:max(exptparams.FirstLick.Ref),h1,'color',[.1 .5 .1],'linewidth',2);
end
title('First Lick Histogram');
xlabel('Time (seconds)');
h=legend({'Tar','Ref'});
LegPos = get(h,'position');
set(h,'fontsize',8);
LegPos(1) = 0.005; % put the legend on the far left of the screen
set(h,'position', LegPos);
% and last, show the hit and false alarm for each position:
subplot(5,4,13:14); hold off;
plot(100*exptparams.PositionHit(:,1)./exptparams.PositionHit(:,2),'marker','o',...
    'markersize',10,'color',[1 .5 .5],'linewidth',2);
hold on;
if isfield(exptparams,'PositionFalseAlarm')
    plot(100*exptparams.PositionFalseAlarm(:,1)./exptparams.PositionFalseAlarm(:,2),...
        'marker','o','markersize',10,'color',[.1 .5 .1],'linewidth',2);
end
axis tight;a=axis;
axis ([a(1) a(2) 0 100]);
xlabel('Position');
h=legend({'Hit','FlsAl'});
LegPos = get(h,'position');
set(h,'fontsize',8);
LegPos(1) = 0.005; % put the legend on the far left of the screen
set(h,'position', LegPos);

subplot(5,4,17:18)
hold off
BinSize = 0.04;
hTrial = get(exptparams.TrialObject);
trialName = hTrial.descriptor;
hRef = get(hTrial.ReferenceHandle);
hTar = get(hTrial.TargetHandle);
preTime1 = hTrial.PreTrialSilence;
preTime2 = hRef.PreStimSilence;
toneDur = hRef.ToneDur;
gapDur = hRef.GapDur;
refBurstCnt = hRef.BurstCnt;
tarBurstCnt = hTar.BurstCnt;
numPlot = length(refBurstCnt);
hBehave = get(exptparams.BehaveObject);
rewardTime = hBehave.EarlyWindow + hBehave.ResponseWindow;
if strcmp(trialName,'BackForegroundTrial')
longestTime = (preTime1 + preTime2) + (toneDur + gapDur) * (max(refBurstCnt) - tarBurstCnt) + rewardTime;
else
 longestTime =    (preTime1 + preTime2) + (toneDur + gapDur) * max(refBurstCnt) + rewardTime;
end
hgap = 0.2;
for i = 1:numPlot
    if strcmp(trialName,'BackForegroundTrial')
        vec = find(exptparams.FirstLick.Total(2,:) == refBurstCnt(i) );
    else
        vec = find(exptparams.FirstLick.Total(2,:) == refBurstCnt(i) + tarBurstCnt);
    end

    if ~isempty(vec)
        hvec = exptparams.FirstLick.Total(1,vec);
        if sum(~isnan(hvec)) ~= 0
            h1=hist(hvec,0:BinSize:max(hvec(~isnan(hvec))));
            h1=h1/sum(h1) + hgap * (i - 1); % normalize by sum, so it becomes the probability of lick
            h = stairs(0:BinSize:max(hvec),h1,'color',[0 1 0],'linewidth',2);
            hold on
        end
    end
    if strcmp(trialName,'BackForegroundTrial')
        refKeyTime = [0,(toneDur + gapDur) * [(refBurstCnt(1:i) - tarBurstCnt)], (toneDur + gapDur) * (max(refBurstCnt(1:i)) - tarBurstCnt) + rewardTime] + (preTime1 + preTime2);
    else
        refKeyTime = [0,(toneDur + gapDur) * refBurstCnt(1:i), (toneDur + gapDur) * max(refBurstCnt(1:i))+ rewardTime] + (preTime1 + preTime2);
    end
    for j = 1 : length(refKeyTime)
        line([refKeyTime(j),refKeyTime(j)],[hgap * (i - 1) ,hgap * i],'LineStyle','-','Color',[.8 .8 .8]);
        hold on
    end
    if i ~= numPlot
        line([0, longestTime],[hgap * i hgap * i])
    end
end

title('Total First Lick Histogram');
xlabel('Time (seconds)');
axis([0 longestTime 0 hgap * i]);
drawnow