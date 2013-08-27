function exptparams = BehaviorDisplay (o, HW, StimEvents, globalparams, exptparams, TrialIndex, AIData, TrialSound)
% control mode:
% display the following:
%   Sound waveform, Lick, and spike data. Label them using
%   StimEvents and pre pos lick data:
%   performance as a graph

out=[];
fs = globalparams.HWparams.fsAI;

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
% set(gcf,'OuterPosition',[66 211 520 710])
% create the title:
titleMes = ['Ferret: ' globalparams.Ferret '    Ref: ' ...
    get(exptparams.TrialObject,'ReferenceClass') '    Tar: ' ...
    get(exptparams.TrialObject,'TargetClass')];
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

if  (isempty(AIData) && isempty(TrialSound))
    EndOfTrials = 1;
else
    EndOfTrials=0;
end

if ~mod(TrialIndex,exptparams.TrialBlock) || (isempty(AIData))
    ind = 1-(floor(TrialIndex/exptparams.TrialBlock))/20;
    
    if EndOfTrials==0
        subplot(5,4,[12]);axis off;
        if ind==.95 % this it the first time:
            text(0,1,'T','HorizontalAlignment','center');
            text(.25,1,'bSr','HorizontalAlignment','center');
            text(.5,1,'bHr','color','b','HorizontalAlignment','center');
            text(.75,1,'bDr','HorizontalAlignment','center');
            text(1,1,'bDi','HorizontalAlignment','center');
            
        end
        % display trialnumber, SR, HR, DR, hitnum, Snooze Hit Rate, Snooze, shams,
        text(0, ind-(.1*(TrialIndex/10)), num2str(TrialIndex),'FontWeight','bold','HorizontalAlignment','center');
        if isfield(exptparams, 'Performance')
            text(.25, ind-(.1*(TrialIndex/10)), num2str(exptparams.Performance(end).RecentSafeRate,'%2.0f'),'FontWeight','bold','color','g','HorizontalAlignment','center');
            text(.5, ind-(.1*(TrialIndex/10)), num2str(exptparams.Performance(end).RecentHitRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
            text(.75, ind-(.1*(TrialIndex/10)), num2str(exptparams.Performance(end).RecentDiscriminationRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
            text(1, ind-(.1*(TrialIndex/10)), num2str(exptparams.Performance(end).RecentDiscriminationIndex,'%2.0f'),'FontWeight','bold','color','r', 'HorizontalAlignment','center');
            
        end
    end
    
    if EndOfTrials && isfield(get(exptparams.TrialObject),'Comment') && ...
            ~isempty(get(exptparams.TrialObject,'Comment'))
        % at the end, a text can be displyed below the numbers. This text
        % is taken from the TrialObject.Comment:
        text(0, ind/2, get(exptparams.TrialObject,'Comment'));
    end
end

if EndOfTrials
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
            ind = 1-(floor(TrialIndex/exptparams.TrialBlock))/20;
            subplot(5,4,[12]);
            axis off;
            % display trialnumber, SR, HR, DR, hitnum, Snooze Hit Rate, Snooze, shams,
            text(0, ind-(.1*((TrialIndex+5)/10)), '--------------------------------','FontWeight','bold','HorizontalAlignment','left');
            text(0, ind-(.1*((TrialIndex+15)/10)), 'End','FontWeight','bold','HorizontalAlignment','center');
            if isfield(exptparams, 'Performance')
                text(.25, ind-(.1*((TrialIndex+15)/10)), num2str(exptparams.Performance(end).SafeRate,'%2.0f'),'FontWeight','bold','color','g','HorizontalAlignment','center');
                text(.5, ind-(.1*((TrialIndex+15)/10)), num2str(exptparams.Performance(end).HitRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
                text(.75, ind-(.1*((TrialIndex+15)/10)), num2str(exptparams.Performance(end).DiscriminationRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
                text(1,  ind-(.1*((TrialIndex+15)/10)), num2str(exptparams.Performance(end).DiscriminationIndex,'%2.0f'),'FontWeight','bold','color','r', 'HorizontalAlignment','center');
            end
            
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
    if isfield (exptparams,'AnalysisWindow'),       exptparams = rmfield(exptparams,'AnalysisWindow');end
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
    h=legend({'HR','DR','SR','Shm','Snz'},'Location','West');
    LegPos = get(h,'position');
    set(h,'fontsize',8);
    %     LegPos(1:2) = [.8 .5]; % put the legend on the far left of the screen
    %     set(h,'position', LegPos);
end
xlabel('Trial Number');

% display the lick signal
% display the lick signal and the boundaries:
h = subplot(5,4,1:4);plot(AIData);
axis ([0 max([length(AIData) 1]) 0 1.5]);
set(h,'XTickLabel',get(h,'Xtick')/fs); % convert to seconds
xlabel('Time (s)');
title(titleMes,'FontWeight','bold');

% First, draw the boundries of Reference and Target
for cnt1 = 1:length(StimEvents)
    if ~isempty([strfind(StimEvents(cnt1).Note,'Reference') strfind(StimEvents(cnt1).Note,'Target')])
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
end

% ROC curves:
subplot(5,4,[20]);
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
xlabel('100-Safe rate (%)');
ylabel('Hit rate (%)');

% Lick Histogram:
% Reference
Num=0;RefLick=zeros(size(exptparams.AllRefLick.Hist{1,1},1),1);
for cnt2 = 1:length(exptparams.AllRefLick.Hist)
    RefLick = RefLick+exptparams.AllRefLick.Hist{cnt2};
    Num = Num + exptparams.AllRefLick.Num(cnt2);
end
RefLick = RefLick./Num;
TarLick = exptparams.TarLick.Hist./exptparams.TarLick.Num;

subplot(5,4,[9:11 13:15]);
prelickwin = (get(o,'PreLickWindow'));
t1=0:1/fs:(length(RefLick)./fs)-(1/fs);
t2=-prelickwin:1/fs:((length(TarLick)-(prelickwin.*fs))./fs)-(1/fs);
hold off; plot(t1,100*RefLick,'k','linewidth',2);
hold on;
plot(t2,100*TarLick,'b');
xlabel('Time (s re:onset)');
a=axis;
axis ([a(1) a(2) 0 100]);
legend({'Ref','Tar'},'Location','SouthWest');

% label the segments:
if length(exptparams.TarLick.Bound)> 1
    exptparams.TarLick.Bound = exptparams.TarLick.Bound-.25;
    patch([exptparams.TarLick.Bound(1,4) exptparams.TarLick.Bound(1,4) ...
        exptparams.TarLick.Bound(1,5) exptparams.TarLick.Bound(1,5)], [0 100 100 0],'y','EdgeColor','y')
    alpha(0.75);
    
    line([exptparams.TarLick.Bound(1,2) exptparams.TarLick.Bound(1,2)],[0 100],'LineStyle',':','Color','r');
    line([exptparams.TarLick.Bound(1,3) exptparams.TarLick.Bound(1,3)],[0 100],'LineStyle',':','Color','r');
    line([exptparams.TarLick.Bound(1,4) exptparams.TarLick.Bound(1,4)],[0 100],'LineStyle',':','Color','r');
    line([exptparams.TarLick.Bound(1,5) exptparams.TarLick.Bound(1,5)],[0 100],'LineStyle','-','Color','r');
    
    xticks = unique(exptparams.TarLick.Bound);
    set(gca,'XTick', xticks)
    set(gca,'XTickLabel',(xticks)'); % convert to seconds
    xlim([min(xticks) max(xticks)])

end

%Total average ref lick curve
AllLicks = [];
for cnt1 = 1:length(exptparams.AllRefLick.Hist)
    AllLicks=[AllLicks; exptparams.AllRefLick.Hist{cnt1}./exptparams.AllRefLick.Num(cnt1)];
end
AllLicks = AllLicks./max(AllLicks);

subplot(5,4,17:19)
t=0:1/fs:(length(AllLicks)/fs)-(1/fs);
plot(t,AllLicks.*100,'k');
a=axis;
axis ([a(1) a(2) 0 100]);
axis tight
hold on
for i = 1:length(exptparams.AllRefLick.Hist{1,1}):length(AllLicks)
    plot([i-1 i-1]./fs,[a(3) a(4)],'LineStyle',':','Color','r','Linewidth',2);
end
hold off
xlabel('Reference Time (s)')


% Discrimination Index
subplot(5,4,[16]);
hold off;
ht = [];
for i = 1:length(exptparams.TarDi)
    if isempty(exptparams.TarDi{i})==0
        ht = [ht; exptparams.TarDi{i}(1,:)];
    end
end
ht = [mean(ht,1) 1]';

fa = [];
for i2 = 1:size(exptparams.RefDi{1},1)
    fa_temp=[];
    for i = 1:length(exptparams.RefDi)
        fa_temp = [fa_temp; exptparams.RefDi{i}(i2,:)];
    end
    fa = [fa; nanmean(fa_temp,1)];
end
fa = [nanmean(fa,1) 1]';

if length(ht) > 1
    t=linspace(0,get(get(exptparams.TrialObject,'ReferenceHandle'),'Duration'),length(fa));
    plot(t,[0; fa(1:end-1)].*100,'k','linewidth',2);
    hold on
    plot(t,[0; ht(1:end-1)].*100,'b','linewidth',1);
    xlabel('Time (s re:stimulus onset)');
    ylabel('P(\tau)');
    ylim([0 100])
    set(gca,'YTick',[0 50 100])
end

drawnow;