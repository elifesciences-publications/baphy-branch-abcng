function [VisualDispColor,exptparams] = VisualDisplay(TrialIndex,TrialPerformance,exptparams)
Colors.HIT = [0.3 .9 .4]; Colors.SNOOZE = [1 0 0]; Colors.EARLY = [1 0 0]; Colors.GREY = [.5 .5 .5];

if TrialIndex > 1  % Already Initialized
    VisualDispColor = exptparams.FeedbackFigure;
    ProgressBar = exptparams.ProgressBar;
	ProgressFrame = exptparams.ProgressFrame;
elseif TrialIndex==1   % Initialize
    %% SCREEN POSITION
    mp = get(0, 'MonitorPositions');
    SecondScreen = figure('MenuBar','none','ToolBar','none','OuterPosition',[mp(2,1) mp(2,2)+5 mp(2,3)-mp(1,3) mp(1,4)+25]);
    set(SecondScreen, 'color', [.5 .5 .5])
    SecondScreenAxis = gca;
    hold all;
    VisualDispGrey = fill([-10 10 10 -10],[-10 -10 10 10],[.5 .5 .5],'EdgeColor',[.5 .5 .5]);
    VisualDispColor = fill([0 4 4 0]-2.5,[0 0 4.5 4.5]-2,[.5 .5 .5],'EdgeColor',[.5 .5 .5]);
    ProgressBar = fill([-8 -8 -8 -8 -8],[-8 -8 -7 -7 -7],[.5 .5 .5],'EdgeColor',[.5 .5 .5]);
    ProgressFrame = plot([-8 8 8 -8 -8],[-8 -8 -7 -7 -7],'Color',[1 1 1]);    
    set(SecondScreenAxis,'XLim',[-9 9],'YLim',[-9 9]);
    set(SecondScreenAxis,'XTick',[],'YTick',[])  ;
end

TrialObject = get(exptparams.TrialObject);
ProgressFraction = 16*TrialIndex/TrialObject.NumberOfTrials;
if strcmp('GREY')  % Display the progres bar between trials
    set(ProgressBar,'FaceColor',[1 1 1]);
    set(ProgressBar,'XData',[-8 -8+ProgressFraction -8+ProgressFraction -8 -8 -8]);
    set(ProgressFrame,'Color',[1 1 1]);
else               % Hide the performance during trials
    set(ProgressBar,'FaceColor',Colors.GREY);
    set(ProgressBar,'XData',[-8 -8 -8 -8 -8]);
    set(ProgressFrame,'Color',Colors.GREY);
end
set(VisualDispColor,'FaceColor',Colors.(TrialPerformance));

exptparams.FeedbackFigure = VisualDispColor;
exptparams.ProgressBar = ProgressBar;
exptparams.ProgressFrame = ProgressFrame;

