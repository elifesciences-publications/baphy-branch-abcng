function exptparams = BehaviorDisplay (o, HW, StimEvents, globalparams, exptparams, TrialIndex, ...
    AIData, TrialSound)
% This part handles the display options for PunishTarget behavior
% control mode:
% display the following:
%   Sound waveform, Lick, and spike data. Label them using
%   StimEvents and pre pos lick data:
%   performance as a graph
fs = HW.params.fsAI;
% if there is paw signal, take it out:
if size(AIData,2)>1,
    AIData = AIData(:,1);
end

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
titleMes = ['Ferret: ' globalparams.Ferret '    Ref: ' ...
    get(exptparams.TrialObject,'ReferenceClass') '    Tar: ' ...
    get(exptparams.TrialObject,'TargetClass') '   Rig: ' , HWSetup{1+globalparams.HWSetup}(1) '   ' ...
    num2str(exptparams.StartTime(1:3),'Date: %1.0f-%1.0f-%1.0f') '    ' ...
    num2str(exptparams.StartTime(4:6),'Time: %1.0f:%1.0f:%1.0f')];
if isfield(exptparams,'StopTime')
    titleMes = [titleMes num2str(exptparams.StopTime(4:6),'  - %1.0f:%1.0f:%1.0f')];
    if isfield(exptparams,'Water')
        titleMes = [titleMes '  Water: ' num2str(exptparams.Water,'%2.1f') 'ml'];
    end
    [a,b,c] = fileparts(globalparams.mfilename);
    titleMes = [b '  ' titleMes];
end
% if Trial block is reached or the experiment has ended, then
% show the block on the screen:
if ~mod(TrialIndex,exptparams.TrialBlock) || (isempty(AIData) && isempty(TrialSound))
    if isempty(AIData) && isempty(TrialSound) % if this it the last one:
        ind = 1-(ceil(TrialIndex/exptparams.TrialBlock))/20;
    else
        ind = 1-(floor(TrialIndex/exptparams.TrialBlock))/20;
    end
    subplot(5,5,[14 15 19 20]);axis off;
    if ind==.95 % this it the first time:
        text(0,1,'Trial','HorizontalAlignment','center');
        text(.1,1,'SF','color','b','HorizontalAlignment','center');
        text(.2,1,'HR','HorizontalAlignment','center');
        text(0.3,1,'DR','color','b','HorizontalAlignment','center');
        text(.4,1,'H#','HorizontalAlignment','center');
        text(0.5,1,'SZHR','color','b','HorizontalAlignment','center');
        text(0.6,1,'SN','color','k','HorizontalAlignment','center');
        text(.7,1,'Shm','color','b','HorizontalAlignment','center');
        text(.8,1,'bSR','HorizontalAlignment','center');
        text(.9,1,'bHR','color','b','HorizontalAlignment','center');
        text(1,1,'bDR','HorizontalAlignment','center');
    end
    % display trialnumber, SR, HR, DR, hitnum, Snooze Hit Rate, Snooze, shams,
    text(0, ind, num2str(TrialIndex),'FontWeight','bold','HorizontalAlignment','center');
    if isfield(exptparams, 'Performance')
        text(.1, ind, num2str(exptparams.Performance(end).SafeRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.2, ind, num2str(exptparams.Performance(end).HitRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.3, ind, num2str(exptparams.Performance(end).DiscriminationRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.4, ind, [num2str(exptparams.Performance(end).Hit(1),'%2.0f') '/' num2str(exptparams.Performance(end).Hit(2),'%2.0f')],'FontWeight','bold','HorizontalAlignment','center');
        text(.5, ind, num2str(exptparams.Performance(end).SnoozeHitRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.6, ind, num2str(exptparams.Performance(end).SnoozeTar(1),'%2.0f'),'FontWeight','bold','color','k','HorizontalAlignment','center');
        text(.7, ind, num2str(exptparams.Performance(end).Sham(1),'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.8, ind, num2str(exptparams.Performance(end).RecentSafeRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.9, ind, num2str(exptparams.Performance(end).RecentHitRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(1, ind, num2str(exptparams.Performance(end).RecentDiscriminationRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
    end
    if isempty(AIData) && isempty(TrialSound) && isfield(get(exptparams.TrialObject),'Comment') && ...
            ~isempty(get(exptparams.TrialObject,'Comment'))
        % at the end, a text can be displyed below the numbers. This text
        % is taken from the TrialObject.Comment:
        text(0, ind/2, get(exptparams.TrialObject,'Comment'));
    end
end
if isempty(AIData) && isempty(TrialSound)
    % this is the end, things has been displayed already:
    % display block safe rate, block discrim rate and block hitrate rate:
    dbComments = [];
    if dbopen
        try
            dbComments = dbget('gDataRaw',globalparams.rawid,'Comments');
            tempcomment=[];
            for cnt1 = 1:ceil(length(dbComments)/100)
                tempcomment{end+1} = dbComments((cnt1-1)*100+1:min(length(dbComments),cnt1*100));
            end
            dbComments = tempcomment;
        catch
        end
    end
    if strcmpi(get(exptparams.BehaveObject,'FirstDisplay'),'cumulative') || ...
            isempty(dbComments)
        if isfield(exptparams,'Performance')
            subplot(5,4,1:4),plot(100*cat(1,exptparams.Performance(1:end-1).HitRate),'ko-','LineWidth',2,'MarkerEdgeColor','k',...
                'MarkerFaceColor','k','MarkerSize',4);
            hold on;
            plot(100*cat(1,exptparams.Performance(1:end-1).DiscriminationRate),'b<-','LineWidth',2,...
                'MarkerFaceColor','b','MarkerSize',4);
            plot(100*cat(1,exptparams.Performance(1:end-1).SafeRate),'gd-','LineWidth',2,...
                'MarkerFaceColor','g','MarkerSize',4);
            % also, show which trials were Sham and Snooze:
AllShams = cat(1,exptparams.Performance(1:end-1).Sham);
            AllShams(~logical(AllShams))=nan;
            plot(110*AllShams,'r*','markersize',6);
AllSnoozes = cat(1,exptparams.Performance(1:end-1).SnoozeTar);
            AllSnoozes (~logical(AllSnoozes))=nan;
            plot(110*AllSnoozes,'d','markersize',6,'markerfacecolor',[.7 0 .7]);
            axis ([0 length(exptparams.Performance) 0 115]);
            % title(titleMes,'FontWeight','bold');
            % h=legend({'HR','DR','SR','Shm','Snz'},'Location','SouthWest');
            % LegPos = get(h,'position');
            % set(h,'fontsize',8);
            % LegPos(1) = 0.005; % put the legend on the far left of the screen
            % set(h,'position', LegPos);
            title(titleMes,'interpreter','none');
            xlabel([]);
            drawnow;
        end
    else
        % display the comments from the database
        subplot(5,4,1:4);
        hold off;
        plot(0);
        axis off;
        text(.1,0,dbComments);
        title(titleMes,'interpreter','none');
        xlabel([]);
        drawnow;
    end
    if isfield (exptparams,'SalientWin'),       exptparams = rmfield(exptparams,'SalientWin');end
    return;
end
% display safe rate, discrim rate and snooze rate:
subplot(5,4,5:8),plot(100*cat(1,exptparams.Performance(1:end-1).RecentHitRate),'ko-','LineWidth',2,'MarkerEdgeColor','k',...
    'MarkerFaceColor','k','MarkerSize',4);
hold on;
plot(100*cat(1,exptparams.Performance(1:end-1).RecentDiscriminationRate),'b<-','LineWidth',2,...
    'MarkerFaceColor','b','MarkerSize',4);
plot(100*cat(1,exptparams.Performance(1:end-1).RecentSafeRate),'gd-','LineWidth',2,...
    'MarkerFaceColor','g','MarkerSize',4);
% also, show which trials were Sham and Snooze:
AllShams = cat(1,exptparams.Performance(1:end-1).Sham);
AllShams(~logical(AllShams))=nan;
plot(110*AllShams,'r*','markersize',6);
AllSnoozes = cat(1,exptparams.Performance(1:end-1).SnoozeTar);
AllSnoozes (~logical(AllSnoozes))=nan;
plot(110*AllSnoozes,'d','markersize',6,'markerfacecolor',[.7 0 .7]);
axis ([0 length(exptparams.Performance) 0 115]);
if TrialIndex ==1
    h=legend({'HR','DR','SR','Shm','Snz'},'Location','SouthWest');
    LegPos = get(h,'position');
    set(h,'fontsize',8);
    LegPos(1) = 0.005; % put the legend on the far left of the screen
    set(h,'position', LegPos);
end
xlabel('Trial Number');
% display the lick signal and the boundaries:
h = subplot(5,4,1:4);plot(AIData);
axis ([0 length(AIData) 0 1.5]);
set(h,'XTickLabel',get(h,'Xtick')/fs); % convert to seconds
xlabel('Time (seconds)');
title(titleMes,'FontWeight','bold');
% First, draw the boundries of Reference and Target
for cnt1 = 1:length(StimEvents)
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim')
        if strcmp(StimRefOrTar,'Reference'), c=[.1 .5 .1]; else c=[1 .5 .5]; end
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
% Second, draw the boundry of pre and post lick windows:
for cnt1 = 1:length(exptparams.SalientWin);
    if strcmp(exptparams.SalientWin(cnt1).RefOrTar,'Reference'), c=[.1 .5 .1]; else c=[1 .5 .5]; end
    line([fs*exptparams.SalientWin(cnt1).PreWin(1) fs*exptparams.SalientWin(cnt1).PreWin(2)],[1.1 1.1],...
        'color','k','LineStyle','-','LineWidth',2);
    text(fs*(mean(exptparams.SalientWin(cnt1).PreWin)), 1.15, 'Pre','Color',c,...
        'HorizontalAlignment','center');
    line([fs*exptparams.SalientWin(cnt1).PosWin(1) fs*exptparams.SalientWin(cnt1).PosWin(2)],[1.3 1.3],...
        'color','k','LineStyle','-','LineWidth',2);
    text(fs*(mean(exptparams.SalientWin(cnt1).PosWin)), 1.35, 'Post','Color',c,...
        'HorizontalAlignment','center');
end
% ROC curves:
subplot(5,4,20);
hold off;
%first for the experiment:
plot(100-exptparams.Performance(end).SafeRate, exptparams.Performance(end).HitRate...
    , 'marker','o', 'markersize',5, 'markerfacecolor','y','markeredgecolor','k');
if TrialIndex >= exptparams.TrialBlock
    hold on;
    for cnt1 = exptparams.TrialBlock:exptparams.TrialBlock:TrialIndex;
        % users have the option of specifying a name for trial blocks which
        % will displayed on the roc curve, or have just a number specifying
        % it. To do this, the user should add a TrialBlckName to the
        % TrialObject and for each trialblock put one letter in it.
        if isfield(get(exptparams.TrialObject), 'TrialBlockName') && ...
                ~isempty(get(exptparams.TrialObject,'TrialBlockName'))
            ROCletter = get(exptparams.TrialObject, 'TrialBlockName');
            ROCletter = ROCletter(min(length(ROCletter), floor(cnt1/exptparams.TrialBlock)));
        else
            ROCletter = num2str(floor(cnt1/exptparams.TrialBlock));
        end
        text(100-exptparams.Performance(cnt1).RecentSafeRate*100, exptparams.Performance(cnt1).RecentHitRate*100,...
            ROCletter ,'color','b','fontsize',8,'fontweight','bold');
    end
end
line([0 100],[0 100],'linewidth',1,'color','r','linestyle','--');
xlabel('False positive rate (%)');
ylabel('Hit rate (%)');
% Lick Histogram:
% Reference
AllRef=[];RefLick = [];Num=0;
for cnt1 = 1:length(exptparams.AllRefLick.Hist)
    AllRef = [AllRef ;exptparams.AllRefLick.Hist{cnt1}/exptparams.AllRefLick.Num(cnt1)];
    RefLick( end+1:length(exptparams.AllRefLick.Hist{cnt1}),1)=0;
    RefLick(1:length(exptparams.AllRefLick.Hist{cnt1})) = RefLick(1:length(exptparams.AllRefLick.Hist{cnt1}))+...
        exptparams.AllRefLick.Hist{cnt1};
    Num = Num + exptparams.AllRefLick.Num(cnt1);
end
subplot(5,5,[11:13 16:18]), hold off, plot(100*RefLick/Num,'k');
hold on;
plot(100*exptparams.TarLick.Hist/exptparams.TarLick.Num,'b');
title_str=[num2str(Num) ' References , ' num2str(exptparams.TarLick.Num) ' Targets '];
legend_str={'Ref','Tar'};
if isfield(exptparams,'ProLick') && exptparams.ProLick.Num>0
    plot(100*exptparams.ProLick.Hist/exptparams.ProLick.Num,'m');
    title_str=[title_str ',' num2str(exptparams.ProLick.Num) ' Probes '];
    legend_str{end+1}='Pro';
end
axis tight;
set(gca,'XTickLabel',get(gca,'Xtick')/fs); % convert to seconds
title(title_str);
xlabel('Time (seconds)');
axis tight;a=axis;
axis ([a(1) a(2) 0 100]);a=axis;
h=legend(legend_str,'Location','SouthWest');
LegPos = get(h,'position');
set(h,'fontsize',8);
LegPos(1) = 0.005; % put the legend on the far left of the screen
set(h,'position', LegPos);
% label the segments:
for cnt1=1:length(exptparams.AllRefLick.Bound)
    line([fs*exptparams.AllRefLick.Bound(cnt1) fs*exptparams.AllRefLick.Bound(cnt1)],[a(3) a(4)],'LineStyle',':','Color','r');
end
% all references:
subplot(5,4,17:19),plot(100*AllRef,'k');
axis tight;a=axis;
axis ([a(1) a(2) 0 100]);a=axis;
set(gca,'XTickLabel',get(gca,'Xtick')/fs); % convert to seconds
xlabel('Time (seconds)');
% label the segments:
offset = 0;
for cnt1=1:length(exptparams.AllRefLick.Hist)
    line([fs*(offset+exptparams.AllRefLick.Bound(1)) ...
        fs*(offset+exptparams.AllRefLick.Bound(1))],[a(3) a(4)],'LineStyle','-','color','r');
    for cnt2 = 1:length(exptparams.AllRefLick.Bound)
        line([fs*(offset+exptparams.AllRefLick.Bound(cnt2)) ...
            fs*(offset+exptparams.AllRefLick.Bound(cnt2))],[a(3) a(4)],'LineStyle',':','color','r');
    end
    offset = offset+exptparams.AllRefLick.Bound(end);
end
drawnow;