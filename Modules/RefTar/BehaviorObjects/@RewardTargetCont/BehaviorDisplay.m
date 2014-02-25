function exptparams = BehaviorDisplay (O, HW, StimEvents, globalparams, exptparams, TrialIndex, ...
    ResponseData, TrialSound)
% BehaviorDisplay method of RewardTargetMC BehaviorControl
%
% TODO : 
% - Indicate Rewarded position by the position of the response rectangle 
% - Response Distribution for all targets and all spouts
% - Response timing distribution for each target
% - Put information in figure (textstring, so that it will be saved) : 
%    Water given, Reference, Target, StartTime
% 
% BE 2011/7

%% SETUP
if ~TrialIndex return; end % IN CASE BREAK WITHOUT A SINGLE TRIAL
DCtmp = HF_axesDivide(1,[1,0.5,1.5,1.2],[0.1,0.1,0.85,0.85],[],[0.1,0.7,0.7]);
DCtmp2 = HF_axesDivide([1,1],1,DCtmp{end},0.4,[ ]);
DC = [DCtmp(1:end-1);DCtmp2(:)];
% SET UP ALL HANDLES, EVEN IF THE FIGURE HAS BEEN CLOSED IN BETWEEN
AllTargetPositions = exptparams.Performance(end).AllTargetPositions;
AllTargetSensors = IOMatchPosition2Sensor(AllTargetPositions);
for i=1:length(AllTargetSensors)
  RespInds(i) = find(strcmp(exptparams.RespSensors,AllTargetSensors{i})); 
end
[FIG,AH,PH,Conditions,PlotOutcomes,exptparams] = LF_prepareFigure(exptparams,DC,TrialIndex);
SRout = HW.params.fsAO;
SRin = HW.params.fsAI;
MaxIndex = get(get(exptparams.TrialObject,'TargetHandle'),'MaxIndex');
cTargetIndex = exptparams.Performance(TrialIndex).TargetIndices;

%% NAME FIGURE
FigName = ['Ferret: ',globalparams.Ferret,' | ',...
  'Ref: ',get(exptparams.TrialObject,'ReferenceClass') ' | ',...
  'Tar: ',get(exptparams.TrialObject,'TargetClass'), ' | ',...
  'Water: ',num2str(exptparams.Water),' | ',...
  num2str(exptparams.StartTime(1:3),' Date: %1.0f-%1.0f-%1.0f  | '),...
  num2str(exptparams.StartTime(4:6),' Start: %1.0f:%1.0f:%1.0f')];
set(FIG,'NumberTitle','off','Name',FigName);
Tmax = max([get(AH.Sound,'XLim'),get(AH.Sound,'XLim')]);
set(PH.InfoText,'String',FigName);

  %% PLOT SOUND WAVEFORM
  axes(AH.Sound); XLim = get(AH.Sound,'XLim');
  TimeS = [0:1/SRout:(length(TrialSound)-1)/SRout];
  set(PH.Sound.Wave,'XData',TimeS,'YData',TrialSound);
  set(PH.Sound.CurrentStimulus,'String',Conditions{cTargetIndex});

%% PLOT LICKS AT ALL SPOUTS
TarWindow =  exptparams.Performance(TrialIndex).TarWindow;
TarRegion = [TarWindow(1),0.5;TarWindow(2),0.5;...
  TarWindow(2),length(RespInds)+.5;TarWindow(1),length(RespInds)+.5; TarWindow(1),0.5]';
set(PH.Licks.RespWindow,'XData',TarRegion(1,:),'YData',TarRegion(2,:),...
  'ZData',ones(size(TarRegion,2),1));
if ~isempty(ResponseData)  
  axes(AH.Licks);
  TimeR = 0 : (1/SRin) : ((size(ResponseData,1)-1)/SRin);
  set(PH.Licks.Image,'XData',TimeR,'YData',1:length(RespInds),'CData',ResponseData(:,RespInds)');
else TimeR = 0;  
end
set([AH.Licks,AH.Sound],'XLim',[0,max([Tmax,TimeS(end),TimeR(end)])]);

%% PLOT RECENT AND OVERALL HITRATE / FALSEALARMRATE / MISSRATE / DISCRIMINATION
axes(AH.Performance); Performance = exptparams.Performance;
set(AH.Performance,'XLim',[0,TrialIndex+1]); Plots = PH.Performance.Plots;
for i=1:length(Plots)
  set(PH.Performance.(Plots{i}),'XData',[1:TrialIndex],'YData',0.005*(i-1)+[Performance.(Plots{i})]);
end
set(AH.Performance,'XLim',[0.5,max([TrialIndex,get(AH.Performance,'XLim')])]);

%% PLOT RESPONSE DISTRIBUTION OVER SPOUTS FOR EACH TARGET
% Colorplot with Targets vs. Sensors (Spouts)
% axes(AH.TarDistrib);
% RespDist = zeros(length(RespInds),MaxIndex); CompletedTrials = 0; CorrectTrials = 0;
% for i=1:length(Performance)
%   if ~isnan(Performance(i).LickSensor) ...
%     & (strcmp(Performance(i).Outcome,'HIT') || strcmp(Performance(i).Outcome,'ERROR')) 
%     cInd = find(strcmp(AllTargetSensors,Performance(i).LickSensor));
%     cTargetIndex = Performance(i).TargetIndices;
%     RespDist(cInd,cTargetIndex) = RespDist(cInd,cTargetIndex) + 1;
%     CompletedTrials = CompletedTrials + 1;
%     if strcmp(Performance(i).Outcome,'HIT') CorrectTrials = CorrectTrials + 1; end
%   end
% end
% set(PH.TarDistrib.Image,'CData',RespDist); 
% caxis([0,max(RespDist(:))]); TitleS = [];
% for i = 1:length(AllTargetSensors) TitleS = [TitleS,' ',AllTargetSensors{i},' ',num2str(sum(RespDist(i,:))),' |']; end
% TitleS = [TitleS,' ',n2s(round(100*CorrectTrials/CompletedTrials)),'% (',n2s(CorrectTrials),'/',n2s(CompletedTrials),')'];
% set(PH.TarDistrib.Title,'String',TitleS);

%% PLOT RESPONSE DISTRIBUTION OVER DIFFICULTY LEVELS
axes(AH.DiffiDistri);
DiffiMat = Performance(end).DiffiMat;
% DiffiMat = DiffiMat ./ repmat(sum(DiffiMat),size(DiffiMat,1),1);
% DiffiMat = max(DiffiMat,zeros(size(DiffiMat)));
DiffiNb = length(unique(get(get(exptparams.TrialObject,'TargetHandle'),'DifficultyLvlByInd')));
ylim([0 max(max(DiffiMat))]);
for PlotNum = 1:length(PlotOutcomes)
  for DiffiNum = 1:DiffiNb
    set( PH.DiffiDistri.Bar(DiffiNum,PlotNum) , 'YData' , [0 DiffiMat(DiffiNum,PlotNum)] );
  end
end


%% PLOT RESPONSE TIMING FOR ALL SENSORS RELATIVE TO TARGET ONSET FOR HITS
if ~isempty(ResponseData)
  axes(AH.TarTiming);
  Outcomes = {exptparams.Performance.Outcome};
  for iO=1:length(PlotOutcomes)
    switch upper(PlotOutcomes{iO})
      case 'ALL'; OutInd = [1:length(Outcomes)];
      otherwise OutInd = find(strcmp(Outcomes,upper(PlotOutcomes{iO})));
    end
    if ~isempty(OutInd)
      Licks = [exptparams.Performance(OutInd).FirstLickRelTarget];
      Sensors = {exptparams.Performance(OutInd).LickSensor};
      USensors = unique(Sensors); USensors = setdiff(USensors,'None');
%       Bins = [-TarWindow(1):0.1:diff(TarWindow)+0.5];
      Bins = -3:0.1:3;
      if ~isempty(USensors)
        for i=1:length(USensors)
          cInd = find(strcmp(Sensors,USensors{i}));
          cLicks = Licks(cInd);
          cHist(i,:) = hist(cLicks,Bins);
          set(PH.TarTiming.RespHist(iO,i),'xdata',Bins,'ydata',cHist(i,:)+iO*0.05);
        end
        axis([Bins([1,end]),0,max(cHist(:))+1]);
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% HELPER FUNCTION FOR SETTING UP THE DISPLAY
function [FIG,AH,PH,Conditions,PlotOutcomes,exptparams] = LF_prepareFigure(exptparams,DC,TrialIndex)

if ~isfield(exptparams,'ResultsFigure') ...
  || isempty(exptparams.ResultsFigure) ...
  ||  ~ishghandle(exptparams.ResultsFigure) % Figure closed
  exptparams.ResultsFigure = round(rand*100000+1000); 
  figure(exptparams.ResultsFigure); colormap(HF_colormap({[1,1,1],[0,0,1]},[0,1]));
  set(exptparams.ResultsFigure,'MenuBar','None');
end; FIG = exptparams.ResultsFigure;

UD = get(FIG,'UserData');
if ~isempty(UD) % RETURN PREVIOUS HANDLES
  AH = UD.AH; PH = UD.PH; Conditions = UD.Conditions; PlotOutcomes = UD.TarTiming.PlotOutcomes;
else % CREATE A NEW SET OF HANDLES
  %% SETUP
  AllTargetPositions = exptparams.Performance(end).AllTargetPositions;
  AllTargetSensors = IOMatchPosition2Sensor(AllTargetPositions);
  
  AxisLabelOpt = {'FontSize',8};
  AxisOpt = {'FontSize',7};
  Colors = struct('Hit',[0,1,0],'Error',[1,0,0],'Early',[1,0,0],'Snooze',[0,0,1],'Events',[1,0,0],...
    'Touch',[0,0,1],'Discrimination',[0,0,0],'All',[.5,.5,.5]);
%   Colors = struct('Hit',[0,1,0],'Error',[1,0,0],'Early',[1,0.5,0],'Snooze',[0,0.5,1],'Events',[1,0,0],...
%     'Touch',[0,0,1],'Discrimination',[0,0,1],'All',[.5,.5,.5]);
  Styles = struct('left','-','right','--','center','-');
  
  %% SOUND
  AH.Sound = axes('Pos',DC{1},AxisOpt{:}); hold on; box on;
  PH.InfoText = text(0.05,1.1,'InfoText','Units','Normalized','FontWeight','Bold','Fontsize',7);
  ylabel('Voltage [V]',AxisLabelOpt{:});
  PH.Sound.Wave = plot(1,1,'Color',[0,0,1]);
  set(AH.Sound,'XTick',[],'YLim',[-5.5,5.5]);
  PH.Sound.CurrentStimulus = text(0.99,0.1,'',...
    'Units','normalized','HorizontalAlignment','right','FontSize',7,'FontWeight','bold');
  
  %% LICKS
  AH.Licks = axes('Pos',DC{2},AxisOpt{:}); hold on; box on;
  xlabel('Time [seconds]',AxisLabelOpt{:});
  PH.Licks.Image = imagesc(1:10,1:2,zeros(2,10));
  caxis([0,1]);
  PH.Licks.RespWindow = plot3(0,0,0,'Color',Colors.Events);
  set(AH.Licks,'YTick',[1:length(AllTargetSensors)],'YTickLabel',AllTargetSensors,...
    'YLim',[.4,length(AllTargetSensors)+.6]);
  
  %% PERFORMANCE
  AH.Performance = axes('Pos',DC{3},AxisOpt{:}); hold on; box on;
  PH.Performance.Plots = {'HitRate','SnoozeRate','EarlyRate',...
    'HitRateRecent','SnoozeRateRecent','EarlyRateRecent','DiscriminationRate'};

  ylabel('Performance',AxisLabelOpt{:});
  xlabel('Trials [#]',AxisLabelOpt{:});
  ColorFields = fieldnames(Colors);
  for i=1:length(PH.Performance.Plots)
    cName = PH.Performance.Plots{i};
    cColor = Colors.(ColorFields{find(~cellfun(@isempty,strfind(ColorFields,cName(1:strfind(cName,'Rate')-1))))});  
    if ~isempty(strfind(cName,'Recent')) cColor = HF_whiten(cColor,0.75); end
    PH.Performance.(cName) = plot(0,0,'.-','Color',cColor);
  end
  Opts = {'Units','N','FontWeight','bold','FontSize',7};
  text(0.01,0.9,'Hit','Color',Colors.Hit,Opts{:});
  text(0.01,0.8,'Early','Color',Colors.Early,Opts{:});
  text(0.01,0.7,'Snooze','Color',Colors.Snooze,Opts{:});
  text(0.01,0.6,'Discrimination','Color',Colors.Discrimination,Opts{:});
  set(AH.Performance,'XLim',[0.5,10],'YLim',[-.05,1.05],'YTick',[0:0.25:1]);
  
%% TARGET DISTRIBUTION
%   AH.TarDistrib = axes('Pos',DC{4},AxisOpt{:}); hold on; box on;
%   ylabel('Sensors',AxisLabelOpt{:});
%   xlabel('Target [Index]',AxisLabelOpt{:});
%   MaxIndex = get(get(exptparams.TrialObject,'TargetHandle'),'MaxIndex');
%   PH.TarDistrib.Image = imagesc(zeros(length(AllTargetPositions),MaxIndex));
%   dPos = 0.45;
%   O = get(exptparams.TrialObject,'TargetHandle');
%   Conditions = get(O,'Names'); CurrentSensors = {};
%   for i=1:MaxIndex
%     [w,e,O] = waveform(O,i,0,'Simulation',TrialIndex);
% %     warning('YVES: reactivate the following line and add CurrentTargetPositions to your object (just center)')
% %     cPos = 'center';
%     cPos = get(O,'CurrentTargetPositions');
%     Sensors = IOMatchPosition2Sensor(cPos);
%     CurrentSensors(end+1:end+length(Sensors)) = Sensors(:);
%     for j=1:length(Sensors)
%       cT = find(strcmp(AllTargetSensors,Sensors{j}));
%       TarRegion = [i-dPos,i+dPos,i+dPos,i-dPos,i-dPos;...
%         cT-dPos,cT-dPos,cT+dPos,cT+dPos,cT-dPos];
%       PH.TarDistrib.TarRegion{i}(j) = ...
%         plot3(TarRegion(1,:),TarRegion(2,:),ones(size(TarRegion,2),1),...
%         'Color',Colors.Events);
%     end
%     XLabels{i} = LF_ParseLabel(Conditions{i}); 
%   end
%   CurrentSensors =  CurrentSensors(~cellfun(@isempty,CurrentSensors));
%   set(gca,'XTick',[1:MaxIndex],'XTickLabel',XLabels,...
%     'YTick',[1:length(unique(CurrentSensors))],'YTickLabel',unique(CurrentSensors));
%   h=colorbar; set(h,AxisOpt{:})
%   PH.TarDistrib.Title = title('');
%   axis([0.4,MaxIndex+0.6,0.4,length(AllTargetSensors)+0.6]);

  %% DIFFICULTY DISTRIBUTION
  AH.DiffiDistri = axes('Pos',DC{4},AxisOpt{:}); hold on; box on;
  ylabel('Trial nb.',AxisLabelOpt{:});
  xlabel('Diffi. lvl',AxisLabelOpt{:});
  PlotOutcomes = {'Hit','Snooze','Early'};
%   DiffiNb = length(unique(get(get(exptparams.TrialObject,'TargetHandle'),'DifficultyLvlByInd')));
  DiffiLvl_D1 = str2num(get(get(exptparams.TrialObject,'TargetHandle'),'DifficultyLvl_D1')); DiffiNb = length(DiffiLvl_D1);
  for PlotNum = 1:length(PlotOutcomes)
      for DiffiNum = 1:DiffiNb
          PH.DiffiDistri.Bar(DiffiNum,PlotNum) = plot( repmat(DiffiNum+0.22*(PlotNum-2),2,1) , zeros(2,1),...
              '-','Linewidth',6,'Color',Colors.(PlotOutcomes{PlotNum}));
          NewXaxisStr{DiffiNum} = ['+' num2str(DiffiLvl_D1(DiffiNum)) '%'];
      end
  end
  set(gca, 'XTick',1:DiffiNum); xt = get(gca, 'XTick'); set (gca, 'XTickLabel', NewXaxisStr);
  PH.DiffiDistrib.Title = title('');
  axis([0,DiffiNb+1,0,1]);
  
  %% TARGET TIMING
  AH.TarTiming = axes('Pos',DC{5}); hold on; box on;
  O = get(exptparams.TrialObject,'TargetHandle');
  PlotOutcomes = {'Hit','Snooze','Early'}; Conditions = get(O,'Names');       % PlotOutcomes = {'Hit','Early','All'};
  for iO = 1:length(PlotOutcomes)
    for i = 1:length(AllTargetPositions)
      cColor = Colors.(PlotOutcomes{iO}); cStyle = Styles.(AllTargetPositions{i});
      PH.TarTiming.Labels = text(0.05,1-(iO+1)*0.1,PlotOutcomes{iO},'Color',cColor,Opts{:});
      PH.TarTiming.RespHist(iO,i) = plot(0,0,'Color',cColor,'LineStyle',cStyle);
    end
  end
  ylabel('Trial nb.',AxisLabelOpt{:});
  xlabel('Time rel. Responsewindow [seconds]',AxisLabelOpt{:}); 
  
  UD.TarTiming.PlotOutcomes = PlotOutcomes;
  UD.Conditions = Conditions;
  UD.PH = PH; UD.AH = AH;
  set(FIG,'UserData',UD);
end

function Label = LF_ParseLabel(Condition)

Pos = strfind(Condition,'='); Label = [];
for j=1:length(Pos)
  EndPos = find(Condition(Pos(j)+2:end)==' ',1,'first') + Pos(j)+1;
  if isempty(EndPos) EndPos = length(Condition); end
  tmp = Condition(Pos(j)+1:EndPos); Label(end+1:end+length(tmp)) = char(tmp);
end
Label = char(Label);
