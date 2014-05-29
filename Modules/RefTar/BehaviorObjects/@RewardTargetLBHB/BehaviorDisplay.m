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
    exptparams.ResultsFigure = figure('position',[1 1 900 900]);
    movegui(exptparams.ResultsFigure,'northwest');
end
figure(exptparams.ResultsFigure);
subplot(4,4,1:4);
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
    %subplot(4,4,[11 12 15 16]);axis off;
    subplot(5,4,[ 15 16 19 20]);axis off;
    if ind==.96 % this it the first time:
        text(  0,1  ,'Trial','FontWeight','bold','HorizontalAlignment','center');
        text(0.1,1  ,'HR','FontWeight','bold','HorizontalAlignment','center','color','b');
        text(0.2,1  ,'FR','FontWeight','bold','HorizontalAlignment','center');
        text(0.3,1  ,'DR','FontWeight','bold','color','b','HorizontalAlignment','center');
        text(0.4,1  ,'DI','FontWeight','bold','HorizontalAlignment','center');
        text(0.5,1  ,'WaR','FontWeight','bold','color','b','HorizontalAlignment','center');
        %text(0.6,1  ,'InfR','FontWeight','bold','HorizontalAlignment','center');
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
        text(.4, ind, num2str(exptparams.Performance(end).DiscriminationIndex,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.5, ind, num2str(exptparams.Performance(end).WarningRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %text(.6, ind, num2str(exptparams.Performance(end).IneffectiveRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.6, ind, num2str(exptparams.Performance(end).RecentHitRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        text(.7, ind, num2str(exptparams.Performance(end).RecentFalseAlarmRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.8, ind, num2str(exptparams.Performance(end).RecentDiscriminationRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.14, ind, num2str(exptparams.Performance(end).LickRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.14, ind, num2str(exptparams.Performance(end).LickRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.14, ind, num2str(exptparams.Performance(end).LickRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.7, ind, [num2str(exptparams.Performance(end).WarningTrial(1),'%2.0f') '/' num2str(exptparams.Performance(end).WarningTrial(2),'%2.0f')],'FontWeight','bold','color','b','HorizontalAlignment','center');
        %         text(.84, ind, [num2str(exptparams.Performance(end).Ineffective(1),'%2.0f') '/' num2str(exptparams.Performance(end).Ineffective(2),'%2.0f')],'FontWeight','bold','HorizontalAlignment','center');
        %         text( 1, ind, [num2str(exptparams.Performance(end).EarlyTrial(1),'%2.0f') '/' num2str(exptparams.Performance(end).EarlyTrial(2),'%2.0f')],'FontWeight','bold','color','b','HorizontalAlignment','center');
    end
end
%disp('stopping in BehaviorDisplay');
%keyboard
if isempty(AIData) && isempty(TrialSound)
    % this is the end, things has been displayed already:
    subplot(4,4,1:4);
    title(titleMes,'interpreter','none');
    % also turn off the light if BehaveorPassive:
    if strcmpi(get(o,'TurnOnLight'),'BehaveOrPassive') && ~isfield(exptparams,'OfflineAnalysis')
        [ll,ev] = IOLightSwitch (HW, 0);
    end
    drawnow;
    return;
end

%% display Hitrate, FalseAlarmRate, DI across trials
subplot(4,4,1:4);
hl=zeros(4,1);
if isfield(exptparams,'UniqueTargets') && length(exptparams.UniqueTargets)>1
    hl(1)=plot(100*cat(1,exptparams.Performance(1:end-1).HitRate),'-',...
        'LineWidth',2,'color',[1 .5 .5]);
    hold on;
    UniqueCount=length(exptparams.UniqueTargets);
    targetid={exptparams.Performance(1:TrialIndex).ThisTargetNote};
    colormtx=jet;
    colormtx=colormtx(round(linspace(1,64,length(exptparams.UniqueTargets))),:);
    for jj=1:UniqueCount,
        thistargetii=find(strcmp(targetid,exptparams.UniqueTargets{jj}));
        plot(thistargetii,100*cat(1,exptparams.Performance(thistargetii).HitRate),'o',...
            'MarkerFaceColor',colormtx(jj,:),'MarkerSize',5,'color',colormtx(jj,:));
    end
else
    hl(1)=plot(100*cat(1,exptparams.Performance(1:end-1).HitRate),'o-',...
        'LineWidth',2,'MarkerFaceColor',[1 .5 .5],'MarkerSize',5,'color',[1 .5 .5]);
end
hold on;
hl(2)=plot(100*cat(1,exptparams.Performance(1:end-1).FalseAlarmRate),'<-',...
    'LineWidth',2,'MarkerFaceColor',[.1 .5 .1],'MarkerSize',5,'color',[.1 .5 .1]);
hl(3)=plot(100*cat(1,exptparams.Performance(1:end-1).DiscriminationIndex),'-',...
     'LineWidth',1,'color',[0 0 0]);

% also, show which trials were Ineffective:
AllIneffective = cat(1,exptparams.Performance(1:TrialIndex).FalseAlarm);
AllIneffective(find(AllIneffective==0))=nan;
hl(4)=plot(110*AllIneffective,'r*','markersize',10);
if isfield(exptparams.Performance,'NullTrial'),
    AllNull = cat(1,exptparams.Performance(1:TrialIndex).NullTrial);
    AllNull=find(AllNull==1);
    if ~isempty(AllNull),
        plot(AllNull,110,'rs','markersize',10);
    end
end
axis ([0 (TrialIndex+1) 0 115]);
title(titleMes,'FontWeight','bold','interpreter','none');
h=legend({'HR','FAR','DI','Inef'},'Location','SouthWest');
LegPos = get(h,'position');
set(h,'fontsize',8);
LegPos(1) = 0.005; % put the legend on the far left of the screen
set(h,'position', LegPos);
xlabel('Trial Number','FontWeight','bold');


%% display the lick signal and the boundaries for last trial
h = subplot(4,4,5:8);plot(AIData);
axis ([0 length(AIData) 0 1.5]);
set(h,'XTickLabel',get(h,'Xtick')/fs); % convert to seconds
xlabel('Time (seconds)','FontWeight','bold');
% First, draw the boundries of Reference and Target
for cnt1 = 1:length(StimEvents)
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim')
        if strcmpi(StimRefOrTar,'Reference'), c=[.1 .5 .1]; else c=[1 .5 .5]; end
        line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StartTime],...
             [0 .5],'color',c,'LineStyle','--','LineWidth',2);
        line([fs*StimEvents(cnt1).StopTime fs*StimEvents(cnt1).StopTime],...
             [0 .5],'color',c,'LineStyle','--','LineWidth',2);
        line([fs*StimEvents(cnt1).StartTime fs*StimEvents(cnt1).StopTime],...
             [.5 .5],'color',c,'LineStyle','--','LineWidth',2);
        text(fs*(StimEvents(cnt1).StartTime+StimEvents(cnt1).StopTime)/2,...
             .6, StimRefOrTar(1),'color',c,...
             'FontWeight','bold','HorizontalAlignment','center');
    end
end

% Second, draw the boundry of response window, and early window:
for cnt1 = 1:2:length(exptparams.RefResponseWin)
    line([fs*exptparams.RefResponseWin(cnt1) fs*exptparams.RefResponseWin(cnt1+1)],[1.1 1.1],'color','k','LineStyle','-','LineWidth',2);
    text(fs*(mean(exptparams.RefResponseWin(cnt1:cnt1+1))), 1.15, 'Res','Color',[.1 .5 .1],'HorizontalAlignment','center');
end
if ~isempty(exptparams.TarResponseWin),
    line([fs*exptparams.TarResponseWin(1) fs*exptparams.TarResponseWin(2)],[1.1 1.1],...
        'color','k','LineStyle','-','LineWidth',2);
    text(fs*(mean(exptparams.TarResponseWin)), 1.15, 'Res','Color',c,...
        'HorizontalAlignment','center');
    line([fs*exptparams.TarEarlyWin(1) fs*exptparams.TarEarlyWin(2)],[1.3 1.3],...
        'color','k','LineStyle','-','LineWidth',2);
    text(fs*(mean(exptparams.TarEarlyWin)), 1.35, 'Erl','Color',c,...
        'HorizontalAlignment','center');
end

% First lick Histogram for target and reference
% svd added catch stim too.
subplot(4,4,9:10)
hold off;
BinSize = 0.04;
MaxBinTime=nanmax([exptparams.FirstLick.Tar exptparams.FirstLick.Tar])+BinSize;
if isfield(exptparams,'UniqueTargets') && length(exptparams.UniqueTargets)>1
  targetid={exptparams.Performance(1:TrialIndex).ThisTargetNote};
  
  % if multiple different targets (eg, catch trials) plot first lick
  % histograms for each separately.
  FAcount=sum(cat(1,exptparams.Performance(1:TrialIndex).FalseAlarm));
  FAR=FAcount./TrialIndex;
  UniqueCount=length(exptparams.UniqueTargets);
  HR=zeros(UniqueCount,1);
  RT=zeros(UniqueCount,1);
  colormtx=jet;
  colormtx=colormtx(round(linspace(1,64,length(exptparams.UniqueTargets))),:);
  for jj=1:UniqueCount,
    thistargetii=find(strcmp(targetid,exptparams.UniqueTargets{jj}));
    h1=hist(exptparams.FirstLick.Tar(thistargetii),0:BinSize:MaxBinTime);
    if ~isempty(h1)
      h1=h1/sum(h1); % normalize by sum, so it becomes the probability of lick
      h1=stairs(0:BinSize:MaxBinTime,h1,'color',colormtx(jj,:),'linewidth',2);
      hold on;
    end
    thisFAcount=sum(cat(1,exptparams.Performance(thistargetii).FalseAlarm));
    
    if TrialIndex>thisFAcount,
        HR(jj)=sum(cat(1,exptparams.Performance(thistargetii).Hit))./...
               (length(thistargetii)-thisFAcount);
    end
    RT(jj)=nanmean(exptparams.FirstLick.Tar(thistargetii));
    DI=exptparams.Performance(end).uDiscriminationIndex;
    LegendLabels{jj}=sprintf('%s(HR:%.2f RT:%.2f DI:%d n:%d)',...
                             exptparams.UniqueTargets{jj},HR(jj),RT(jj),DI(jj),...
                             length(thistargetii)-thisFAcount);
  end
  LegendLabels{end+1}=sprintf('Ref(FAR:%.2f)',FAR);
else
  h1=hist(exptparams.FirstLick.Tar(1:TrialIndex),0:BinSize:MaxBinTime);
  if ~isempty(h1)
    h1=h1/sum(h1); % normalize by sum, so it becomes the probability of lick
    h1=stairs(0:BinSize:MaxBinTime,h1,'color',[1 .5 .5],'linewidth',2);
    hold on;
  end
  LegendLabels={'Tar','Ref'};
end
ct=cat(1,exptparams.Performance(1:TrialIndex).FirstCatchTime);
fct=find(~isnan(ct) & ct<cat(1,exptparams.Performance(1:TrialIndex).FirstLickTime));
if ~isempty(fct),
    h1=hist(exptparams.FirstLick.Catch(fct),0:BinSize:MaxBinTime);

    if ~isempty(h1)
        h1=h1/length(fct); % normalize to convert to probability
        h1=stairs(0:BinSize:MaxBinTime,h1,'color',[.5 .5 .5],'linewidth',2);
        RT=nanmean(exptparams.FirstLick.Catch(fct));
        HR=sum(~isnan(exptparams.FirstLick.Catch(fct)))/length(fct);
        LegendLabels{end+1}=LegendLabels{end};
        LegendLabels{end-1}=sprintf('Catch(HR:%.2f RT:%.2f DI:%.0f n:%d)',...
            HR,RT,exptparams.Performance(end).cDiscriminationIndex,length(fct));
    end
end
h1=hist(exptparams.FirstLick.Ref(1:TrialIndex),0:BinSize:MaxBinTime);
if ~isempty(h1)
    h1=h1/length(exptparams.FirstLick.Ref); % normalize to convert to probability
    h1=stairs(0:BinSize:MaxBinTime,h1,'color',[.1 .5 .1],'linewidth',2);
    h=legend(LegendLabels);
    LegPos = get(h,'position');
    set(h,'fontsize',8);
    xlim=get(gca,'Xlim');
    ylim=get(gca,'Ylim');
    %LegPos(1:2) = [0.005 ylim(2)]; % put the legend on the far left of the screen
    LegPos(1:2) = [0.4 0.425]; % put the legend on the far left of the screen
    set(h,'position', LegPos);
end

title('First Lick Histogram');
xlabel('Time (seconds)');

% and last, show the hit and false alarm for each trial length:
subplot(4,4,13:14); hold off;
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
drawnow;
