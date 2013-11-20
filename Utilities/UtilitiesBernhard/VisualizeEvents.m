function VisualizeEvents(varargin)
%
%
%

%% PARSE ARGUMENTS
P = parsePairs(varargin);
checkField(P,'Events')
checkField(P,'TrialRange','all')
checkField(P,'FIG',1);
checkField(P,'Data',[]); % Data assumed to in Format from evpread with option 'dataformat','separated'
checkField(P,'DataType','Spike');
checkField(P,'Electrode',1); 
checkField(P,'SensorData');
checkField(P,'Params');
checkField(P,'SensorNames',{'TouchL','TouchR'});
checkField(P,'SRAUX',1000);


if isfield(P,'Data') PlotData = 1; end
if isfield(P,'SensorData') PlotSensorData = 1; 
  SensorNames = P.Params.RespSensors;
  SensorInd = find(ismember(SensorNames,P.SensorNames));
end

%% CONSOLIDATE TRIAL RANGE
Trials = [P.Events.Trial];
if strcmp(P.TrialRange,'all') 
  P.TrialRange = unique(Trials);
  NTrials = length(Trials);
else
  NTrials = length(P.TrialRange); 
end
cInd = ismember(Trials,P.TrialRange);
P.Events = P.Events(cInd);

StartTimes = [P.Events.StartTime];
StopTimes = [P.Events.StopTime];


%% PREPARE PLOTTING AND PLOT RAW DATA
figure(P.FIG); clf;
DC = HF_axesDivide(ceil(sqrt(NTrials)),ceil(sqrt(NTrials)),[0.03,0.1,0.92,0.8],[0.25],[0.35])';
XLim = [min(StartTimes)-0.1,max(StopTimes)];
for iY=1:size(DC,1)
  for iX = 1:size(DC,2)
    i = (iY-1)*size(DC,2) + iX;
    cTrial = P.TrialRange(i);
    AH(i) = axes('Pos',DC{iX,iY},'YTick',[],'XLim',XLim,'YLim',[-2,2]);
    TH(i) = text(1,0.95,['Trial ',n2s(cTrial)],'Horiz','r','Units','n');
    hold on;
    if iY == size(DC,1) xlabel('Time [s]'); end  
  end
end

%% PLOT  EVENTS
dOffset = 0.2;
% LOOP OVER TRIALS
for iT=1:length(P.TrialRange)
  cTrial = P.TrialRange(iT); 
  cTrialInd = find(cTrial==P.TrialRange);
  axes(AH(cTrialInd));  StimOff = 0;

  % PLOT RAW DATA
  if PlotData
    cTime = [0:size(P.Data.(P.DataType){cTrial},1)-1]/P.Data.Info.SR;
    cData = P.Data.(P.DataType){cTrial}(:,P.Electrode); cData = cData/std(cData)/10;
    plot(cTime,cData,'Color',[0.7,0.7,0.7]);
  end
  
  % PLOT SENSOR DATA
  if PlotSensorData
    cTime = [0:size(P.SensorData.AUX{cTrial},1)-1]/P.SRAUX;
    Colors = {[0,0,1],[1,0,0],[0,1,0]};
    for iN=1:length(SensorInd)
      cData = P.SensorData.AUX{cTrial}(:,SensorInd(iN))/10; 
      plot(cTime,cData - 1 - 0.22*iN,'Color',Colors{SensorInd(iN)});
    end
  end

  cEventsInd = find(Trials==cTrial);
  cEvents = P.Events(cEventsInd);
  cStartTimes = StartTimes(cEventsInd);
  [cStartTimes,cSortInd] = sort(cStartTimes,'ascend');
  cEvents = cEvents(cSortInd);
  % LOOP OVER EVENTS IN A TRIAL
  for iE = 1:length(cEvents)
    cEvent = cEvents(iE);

    if cEvent.StopTime-cEvent.StartTime == 0 Marker = '.'; LineStyle = '-';
    else Marker = '.'; LineStyle = '-'; end
    
    if isempty(cEvent.StopTime) cEvent.StopTime = cEvent.StartTime; end
    PlotStyle = 'LineWithEnds'; FontWeight = 'normal'; PLOT = 1; TEXT = 1; Align = 'r'; TextStyle = 'V';
    switch cEvent.Note
      case 'TRIALSTART'; Color = [0,1,0]; YOffset = -0.5; TEXT = 0;  PLOT = 1; PlotStyle = 'VerticalLine';
      case 'TRIALSTOP'; Color = [1,0,0]; YOffset = -0.5; TEXT = 0; PLOT = 1; PlotStyle = 'VerticalLine';
      otherwise
        if ~isempty(findstr(lower(cEvent.Note),'silence'))
          Color = [0.5,0.5,0.5]; YOffset = 0; TEXT = 0;
        elseif ~isempty(findstr(lower(cEvent.Note),'lick'))
          YOffset = -dOffset; TYOffset = -2*dOffset; Color = [1,0,1]; cEvent.Note = cEvent.Note(6:end);
        elseif ~isempty(findstr(lower(cEvent.Note),'pump'))
          YOffset = -2*dOffset; TYOffset = -3.2*dOffset; Color = [0,0,1]; cEvent.Note = cEvent.Note(17:end); TEXT = 1;
        elseif ~isempty(findstr(lower(cEvent.Note),'lightoff'))
          YOffset = -2*dOffset; TYOffset = -3.2*dOffset; Color = [1,1,0]; cEvent.Note = 'LIGHT ON'; TEXT = 0;
          cEvent.StopTime = cEvent.StartTime; cEvent.StartTime = LastOutcome.StartTime;
        elseif ~isempty(findstr(lower(cEvent.Note),'behavior'))
          YOffset = -3*dOffset ; TYOffset = -4*dOffset; Color = [1,0.5,0.5]; cEvent.Note = cEvent.Note(10:end);
        elseif ~isempty(findstr(lower(cEvent.Note),'outcome'))
          NewString = [get(TH(cTrialInd),'String'),' (',cEvent.Note(9:end),')'];
          PLOT = 0; TEXT = 0; set(TH(cTrialInd),'String',NewString);
          LastOutcome = cEvent;
        elseif ~isempty(findstr(lower(cEvent.Note),'pause'))
          PLOT = 0; TEXT = 0;
        elseif  ~isempty(findstr(lower(cEvent.Note),'stim ,'))
          YOffset = 0.15; TYOffset = 0.3;  Align = 'l'; cEvent.Note = cEvent.Note(7:find(cEvent.Note==',',1,'last')-2);
          if ~StimOff Color = [0,0,0]; else Color = [1,0,0]; end
        elseif  ~isempty(findstr(lower(cEvent.Note),'stim,off'))
          Color = [1,0,0]; YOffset = 0.15; TYOffset = 0.3;  Align = 'l'; StimOff = 1;
        else
          Color = [0,0,0]; YOffset = 0.15; TYOffset = 0.3;  Align = 'l';
        end
    end
    
    if PLOT
      switch PlotStyle
        case 'Line';
          plot([cEvent.StartTime,cEvent.StopTime],[0,0]+YOffset,'Marker',Marker,'LineStyle',LineStyle,'MarkerSize',15,'LineWidth',2,'Color',Color)
        case 'LineWithEnds';
          if cEvent.StartTime ~= cEvent.StopTime
            plot([cEvent.StartTime+0.02,cEvent.StopTime-0.02],[0,0]+YOffset,'LineStyle','-','LineWidth',1.5,'Color',Color)
          end
          plot([cEvent.StartTime,cEvent.StartTime],YOffset + [-0.1,0.1],'LineStyle','-','LineWidth',1,'Color',Color)
          plot([cEvent.StopTime,cEvent.StopTime],YOffset + [-0.1,0.1],'LineStyle','-','LineWidth',1,'Color',Color)
        case 'VerticalLine';
          plot([cEvent.StartTime,cEvent.StartTime],[-2,2],'LineStyle','--','LineWidth',1.5,'Color',Color)
        otherwise
          
      end
    end
    if TEXT
      switch TextStyle
        case 'H';
          text([cEvent.StartTime]+0.2,YOffset,cEvent.Note,'Color',Color,'FontSize',8,'Horiz','l','FontWeight',FontWeight);
        case 'V';
          text((cEvent.StartTime+cEvent.StopTime)/2,0+TYOffset,cEvent.Note,'Rotation',90,'Color',Color,'FontSize',8,'Horiz',Align,'FontWeight',FontWeight);
        otherwise
      end
    end
  end
end

for i=1:length(AH)
  axes(AH(i));
  set([AH(i);get(AH(i),'Title');get(AH(i),'Children')],'ButtonDownFcn',...
    ['H = gca; NFig = figure; SS = get(0,''ScreenSize''); set(NFig,''Pos'',[10,3*SS(4)/2-100,SS(3:4)/2]); '...
    'NH = copyobj(H,NFig); set(NH,''Position'',[0.15,0.1,0.8,0.85]); xlabel(''Time [s]'')'])
end

