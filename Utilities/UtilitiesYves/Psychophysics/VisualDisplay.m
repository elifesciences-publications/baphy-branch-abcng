function [VisualDispColor,exptparams] = VisualDisplay(TrialIndex,TrialPerformance,exptparams)
Colors.HIT = [0.3 .9 .4]; Colors.SNOOZE = [1 0 0]; Colors.EARLY = [1 0 0]; Colors.GREY = [.5 .5 .5];
Xbar = 9; Ybar = 9;

if TrialIndex > 1  % Already Initialized
    VisualDispColor = exptparams.FeedbackFigure;
    ProgressBar = exptparams.ProgressBar;
	  ProgressFrame = exptparams.ProgressFrame;
elseif TrialIndex==1   % Initialize
    %% SCREEN POSITION
    mp = get(0, 'MonitorPositions');
    SecondScreen = figure('MenuBar','none','ToolBar','none','OuterPosition',[mp(2,1) mp(2,2)+10 mp(2,3)-mp(1,3) mp(1,4)+10]);
    set(SecondScreen, 'color', [.5 .5 .5])
    SecondScreenAxis = gca;
    hold all;
    VisualDispGrey = fill([-10 10 10 -10],[-10 -10 10 10],[.5 .5 .5],'EdgeColor',[.5 .5 .5]);
    VisualDispColor = fill([0 4 4 0]-2.5,[0 0 4.5 4.5]-2,[.5 .5 .5],'EdgeColor',[.5 .5 .5]);
    ProgressBar = fill([0 0 0 0 0]-Xbar,[0 0 0.5 0.5 0.5]-Ybar,[.5 .5 .5],'EdgeColor',[.5 .5 .5]);
    ProgressFrame = plot([-1 1 1 -1 -1]*Xbar,[0 0 0.5 0.5 0]-Ybar,'Color',[1 1 1]);    
    set(SecondScreenAxis,'XLim',[-9 9],'YLim',[-9 9]);
    set(SecondScreenAxis,'XTick',[],'YTick',[])  ;
end

ProgressFraction = 2*Xbar*TrialIndex/exptparams.TrialBlock;
if ~strcmp(TrialPerformance,'GREY')  % Display the perf. and the progress bar between trials
    set(ProgressBar,'FaceColor',[1 1 1]);
    set(ProgressBar,'XData',[0 ProgressFraction ProgressFraction 0 0 0]-Xbar);
    set(ProgressFrame,'Color',[1 1 1]);
else                                                % Hide the performance and the bar during trials
    set(ProgressBar,'FaceColor',Colors.GREY);
    set(ProgressBar,'XData',[-1 -1 -1 -1 -1]*Xbar);
    set(ProgressFrame,'Color',Colors.GREY);
end
set(VisualDispColor,'FaceColor',Colors.(TrialPerformance));

exptparams.FeedbackFigure = VisualDispColor;
exptparams.ProgressBar = ProgressBar;
exptparams.ProgressFrame = ProgressFrame;

