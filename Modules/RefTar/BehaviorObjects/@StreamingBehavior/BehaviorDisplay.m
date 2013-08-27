function exptparams = BehaviorDisplay (o, HW, StimEvents, globalparams, exptparams, TrialIndex, ...
    AIData, TrialSound);
% This part handles the display options for PunishTarget behavior
% control mode:
% display the following:
%   Sound waveform, Lick, and spike data. Label them using
%   StimEvents and pre pos lick data:
%   performance as a graph
% if there is paw signal, take it out:
if size(AIData,2)>1,
    AIData = AIData(:,1);
end
fs = HW.params.fsAI;
% see if the results figure exists, otherwise create it:
if ~isfield(exptparams, 'ResultsFigure')
    if globalparams.HWSetup==3
        exptparams.ResultsFigure = figure('position',[-1270 50 1250 940]);
    else
        exptparams.ResultsFigure = figure('position',[1 1 900 900]);
        movegui(exptparams.ResultsFigure,'northwest');
    end
end
figure(exptparams.ResultsFigure);
subplot(4,3,1:3);
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
if ~mod(TrialIndex,exptparams.TrialBlock) | (isempty(AIData) & isempty(TrialSound))
    if isempty(AIData) & isempty(TrialSound) % if this it the last one:
        ind = 1-(ceil(TrialIndex/exptparams.TrialBlock))/10;
    else
        ind = 1-(floor(TrialIndex/exptparams.TrialBlock))/10;
    end
    subplot(4,3,[10:12]);axis off;
    if ind==.9 % this it the first time:
        text(0,1,'Trial','FontWeight','bold','HorizontalAlignment','center');
        text(.12,1,'LR','FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.24,1,'HR','FontWeight','bold','HorizontalAlignment','center');
        text(0.36,1,'SzHR','FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.48,1,'H#','FontWeight','bold','HorizontalAlignment','center');
        text(0.60,1,'Snz','FontWeight','bold','color','b','HorizontalAlignment','center');
        text(0.72,1,'ShHR','FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.84,1,'SSHR','FontWeight','bold','HorizontalAlignment','center');
        text(.98,1,'Sham','FontWeight','bold','HorizontalAlignment','center');
    end
    % display trialnumber, SR, HR, DR, hitnum, Snooze Hit Rate, Snooze, shams,
    text(0, ind, [num2str(TrialIndex)],'FontWeight','bold','HorizontalAlignment','center');
    if isfield(exptparams, 'Performance')
        text(.12, ind, [num2str(exptparams.Performance(end).LickRate,'%2.0f')],'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.24, ind, [num2str(exptparams.Performance(end).HitRate,'%2.0f')],'FontWeight','bold','HorizontalAlignment','center');
        text(.36, ind, [num2str(exptparams.Performance(end).SnoozeHitRate,'%2.0f')],'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.48, ind, [num2str(exptparams.Performance(end).Hit(1),'%2.0f') '/' num2str(exptparams.Performance(end).Hit(2),'%2.0f')],'FontWeight','bold','HorizontalAlignment','center');
        text(.60, ind, [num2str(exptparams.Performance(end).Snooze(1),'%2.0f') '/' num2str(exptparams.Performance(end).Snooze(2),'%2.0f')],'FontWeight','bold','HorizontalAlignment','center');
        text(.72, ind, [num2str(exptparams.Performance(end).ShamHitRate,'%2.0f')],'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.84, ind, [num2str(exptparams.Performance(end).ShamSnoozeHitRate,'%2.0f')],'FontWeight','bold','HorizontalAlignment','center');
        text(.98, ind, [num2str(exptparams.Performance(end).Sham(1),'%2.0f') '/' num2str(exptparams.Performance(end).Sham(2),'%2.0f')],'FontWeight','bold','HorizontalAlignment','center');
    end
end
if isempty(AIData) & isempty(TrialSound)
    % this is the end, things has been displayed already:
    subplot(4,3,1:3);
    title(titleMes,'interpreter','none');
    drawnow;
    varargout{1} = exptparams;
    return;
end
% display Hitrate, Sham hitrate.
subplot(4,3,1:3),plot(100*cat(1,exptparams.Performance(1:end-1).HitRate),'ko-','LineWidth',2,'MarkerEdgeColor','k',...
    'MarkerFaceColor','k','MarkerSize',5);
hold on;
plot(100*cat(1,exptparams.Performance(1:end-1).ShamHitRate),'b<-','LineWidth',2,...
    'MarkerFaceColor','b','MarkerSize',5);
% also, show which trials were Sham and Snooze:
AllShams = cat(1,exptparams.Performance(1:exptparams.TotalTrials).Sham);
AllShams(find(AllShams==0))=nan;
plot(110*AllShams,'r*','markersize',10);
AllSnoozes = cat(1,exptparams.Performance(1:exptparams.TotalTrials).Snooze);
AllSnoozes (find(AllSnoozes==0))=nan;
plot(110*AllSnoozes,'d','markersize',8,'markerfacecolor',[.7 0 .7]);
axis ([0 (exptparams.TotalTrials+1) 0 115]);
title(titleMes,'FontWeight','bold','interpreter','none');
h=legend({'Hit Rate','ShamHitRate','Sham','Snooze'},'Location','SouthWest');
LegPos = get(h,'position');
LegPos(1) = 0.005; % put the legend on the far left of the screen
set(h,'position', LegPos);
xlabel('Trial Number','FontWeight','bold');
% display the lick signal and the boundaries:
h = subplot(4,3,4:6),plot(AIData);
axis ([0 length(AIData) 0 1.5]);
set(h,'XTickLabel',get(h,'Xtick')/fs); % convert to seconds
xlabel('Time (seconds)','FontWeight','bold');
% First, draw the boundries of Reference and Target
% for cnt1 = [1 2:4:length(StimEvents)-1 length(StimEvents)]
cnt1 = 1;
while  cnt1 < length(StimEvents)
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim')
        if (strcmp(StimRefOrTar,'Reference')) || strcmpi(StimRefOrTar,'Sham'), c=[.1 .5 .1]; else, c=[1 .5 .5]; end
        line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StartTime],[0 .5],'color',c,...
            'LineStyle','-','LineWidth',2);
        line([fs*StimEvents(cnt1).StopTime fs*StimEvents(cnt1).StopTime],[0 .5],'color',c,...
            'LineStyle','-','LineWidth',2);
        line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StopTime], [.5 .5],'color',c,...
            'LineStyle','--','LineWidth',2);
        text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2, .6, StimRefOrTar(1),...
            'color',c,'FontWeight','Normal','HorizontalAlignment','center');
    end
    cnt1 = cnt1 + 1;
end
% Second, draw the boundry of pre and post lick windows:
line([fs*exptparams.PreWin(1) fs*exptparams.PreWin(2)],[1.1 1.1],...
    'color','k','LineStyle','-','LineWidth',2);
text(fs*(mean(exptparams.PreWin)), 1.15, 'Pre','Color',c,...
    'HorizontalAlignment','center');
line([fs*exptparams.PostWin(1) fs*exptparams.PostWin(2)],[1.3 1.3],...
    'color','k','LineStyle','-','LineWidth',2);
text(fs*(mean(exptparams.PostWin)), 1.35, 'Post','Color',c,...
    'HorizontalAlignment','center');
% Lick Histogram:
Lick = exptparams.Lick;
cCode = {'b','k','g','r','c'};
PreTargetWin = get(exptparams.BehaveObject,'PreTargetWindow');
PostTargetWin = get(exptparams.BehaveObject,'PostTargetWindow');
subplot(4,3,[7:9])
hold off;
for cnt1 = 1:length(Lick)
    plot(100*Lick(cnt1).Ave/Lick(cnt1).Num,cCode{cnt1});
    hold on;
end
axis tight;
set(gca,'XTickLabel',get(gca,'Xtick')/fs-fs*(1+PreTargetWin)); % convert to seconds
title(['Average Lick']);
xlabel('Time (seconds)');
axis tight;a=axis;
axis ([a(1) a(2) 0 100]);a=axis;
line([fs fs],[ 0 100],'LineStyle','--','color','r');
line([fs*(1+PreTargetWin) fs*(1+PreTargetWin)],[ 0 100],'LineStyle','--','color','k');
line([a(2)-PostTargetWin*fs a(2)-PostTargetWin*fs],[ 0 100],'LineStyle','--','color','r');
legend(num2str(cat(1,exptparams.Lick.Freq)));
% label the segments:
drawnow;
varargout{1} = exptparams;