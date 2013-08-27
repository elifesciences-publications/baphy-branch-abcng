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
    subplot(4,4,[11 12 15 16]);axis off;
    if ind==.96 % this it the first time:
        text(  0,1  ,'Trial','FontWeight','bold','HorizontalAlignment','center');
        text(0.1,1  ,'HR','FontWeight','bold','HorizontalAlignment','center','color','b');
        text(0.2,1  ,'FR','FontWeight','bold','HorizontalAlignment','center');
        text(0.3,1  ,'DR','FontWeight','bold','color','b','HorizontalAlignment','center');
        text(0.4,1  ,'SHR','FontWeight','bold','HorizontalAlignment','center');
        text(0.5,1  ,'SFR','FontWeight','bold','color','b','HorizontalAlignment','center');
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
        text(.4, ind, num2str(exptparams.Performance(end).SNHitRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
        text(.5, ind, num2str(exptparams.Performance(end).SNFalseAlarmRate,'%2.0f'),'FontWeight','bold','color','b','HorizontalAlignment','center');
        %text(.6, ind, num2str(exptparams.Performance(end).IneffectiveRate,'%2.0f'),'FontWeight','bold','HorizontalAlignment','center');
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
    subplot(4,4,1:4);
    title(titleMes,'interpreter','none');
    % also turn off the light if BehaveorPassive:
    if strcmpi(get(o,'TurnOnLight'),'BehaveOrPassive') && ~isfield(exptparams,'OfflineAnalysis')
        [ll,ev] = IOLightSwitch (HW, 0);
    end
    drawnow;
    return;
end
% display Hitrate, FalseAlarmRate.
subplot(4,4,1:4),plot(100*cat(1,exptparams.Performance(1:end-1).HitRate),'o-','LineWidth',2,...
    'MarkerFaceColor',[1 .5 .5],'MarkerSize',5,'color',[1 .5 .5]);
hold on;
plot(100*cat(1,exptparams.Performance(1:end-1).FalseAlarmRate),'<-','LineWidth',2,...
    'MarkerFaceColor',[.1 .5 .1],'MarkerSize',5,'color',[.1 .5 .1]);
plot(100*cat(1,exptparams.Performance(1:end-1).DiscriminationRate),'o-','LineWidth',2,...
    'MarkerFaceColor',[.5 .5 .1],'MarkerSize',5,'color',[.5 .5 .1]);
% also, show which trials were Ineffective:
%AllIneffective = cat(1,exptparams.Performance(1:TrialIndex).Ineffective);
%AllIneffective(find(AllIneffective==0))=nan;
%plot(110*AllIneffective,'r*','markersize',10);
axis ([0 (TrialIndex+1) 0 115]);
title(titleMes,'FontWeight','bold','interpreter','none');
h=legend({'HR','FAR','DR'},'Location','SouthWest');
LegPos = get(h,'position');
set(h,'fontsize',8);
LegPos(1) = 0.005; % put the legend on the far left of the screen
set(h,'position', LegPos);
xlabel('Trial Number','FontWeight','bold');
% display the lick signal and the boundaries:
h = subplot(4,4,5:8);plot(AIData);
axis ([0 length(AIData) 0 1.5]);
set(h,'XTickLabel',get(h,'Xtick')/fs); % convert to seconds
xlabel('Time (seconds)','FontWeight','bold');
% First, draw the boundries of Reference and Target
for cnt1 = 1:length(StimEvents)
  [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
  if strfind(lower(StimRefOrTar),'reference')
    StimRefOrTar='reference';
  else
    StimRefOrTar='target';
  end
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

line([fs*exptparams.ResponseWin(1) fs*exptparams.ResponseWin(2)],[1.1 1.1],...
    'color','k','LineStyle','-','LineWidth',2);
text(fs*(mean(exptparams.ResponseWin)), 1.15, 'Res','Color',[.1 .5 .1],...
    'HorizontalAlignment','center');

%Lick Histogram for target and reference
subplot(4,4,9:10)
hold off;
BinSize = 0.1;
if isfield(exptparams,'RefLick')
    RL=exptparams.RefLick;
else
    RL=[];
end
if isfield(exptparams,'TarLick')
    TL=exptparams.TarLick;
else
   TL=[]; 
end
if isempty(TL), TL(length(RL))=0; end
if isempty(RL), RL(length(TL))=0; end
RL(min([length(RL) length(TL)])+1:end)=[];
TL(min([length(RL) length(TL)])+1:end)=[];
t=(1:length(RL))/fs;
stimOnset=get(exptparams.TrialObject,'PreTrialSilence');
stimOnset=stimOnset+get(get(exptparams.TrialObject,'referencehandle'),'PreStimSilence');
stimDur=get(get(exptparams.TrialObject,'referencehandle'),'Duration');
plot(t,[RL(:) TL(:)]);
addgrid(0,[0 stimDur]+stimOnset,'b');  %stim on- and off- set
addgrid(0,exptparams.ResponseWin,'r','-');  %stim on- and off- set
set(gca,'xlim',[0 t(end)]);
title('Average lick rate');
xlabel('Time (seconds)');
h=legend({'Ref','Tar'});
LegPos = get(h,'position');
set(h,'fontsize',8);
LegPos(1) = 0.005; % put the legend on the far left of the screen
set(h,'position', LegPos);

% and last, show the hit and false alarm for each position:
subplot(4,4,13:14); hold off;
stimnum=get(get(exptparams.TrialObject,'ReferenceHandle'),'MaxIndex');
stimnum=1:stimnum;
respMat=cat(1,exptparams.Performance(1:end-1).respMat);
hh0=hist(respMat(:,2),stimnum);  %total trial
hh0(hh0==0)=1;
%hh=hist(respMat(respMat(:,1)==1,2),stimnum);  %stop lick during respwin
%p=plot(100*(hh(:)./hh0(:)),'o-');
%set(p,'linewidth',2,'markersize',5,'markerfacecolor','w');

hh1=hist(respMat(respMat(:,1)==1,2),stimnum);  %stop-lick resp (warning)
hh2=hist(respMat(respMat(:,1)==3,2),stimnum);  %stop-lick resp (snoozy)
bar(100*[hh1(:) hh2(:)]./[hh0(:) hh0(:)],0.5,'stacked');
hold on; 
pp=plot(hh1(:)*100./hh0(:),'bo-'); set(pp,'markersize',5,'markerfacecolor','w');
hold off;
ylabel('Response Rate (%)');
xlabel('Stmulus#');
axis([0 length(stimnum)+1 0 100]);
h=legend({'Warning','Snoozy'});
LegPos = get(h,'position');
set(h,'fontsize',8);
LegPos(1) = 0.005; % put the legend on the far left of the screen
set(h,'position', LegPos);


drawnow;