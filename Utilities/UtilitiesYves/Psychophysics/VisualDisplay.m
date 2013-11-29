function [VisualDispColor] = VisualDisplay(InitializeMe,TrialPerformance,VisualDispColor)
Colors.HIT = [0.3 .9 .4]; Colors.SNOOZE = [1 0 0]; Colors.EARLY = [1 0 0]; Colors.GREY = [.5 .5 .5];
if InitializeMe==1   % Behavior feedback
  %% SCREEN POSITION
  mp = get(0, 'MonitorPositions');
  SecondScreen = figure('MenuBar','none','ToolBar','none','OuterPosition',[mp(2,1) mp(2,2)+5 mp(2,3)-mp(1,3) mp(1,4)+25]);
  set(SecondScreen, 'color', [.5 .5 .5])
  SecondScreenAxis = gca;
  hold all;
  VisualDispGrey = fill([-10 10 10 -10],[-10 -10 10 10],[.5 .5 .5],'EdgeColor',[.5 .5 .5]);
  VisualDispColor = fill([0 4 4 0]-2.5,[0 0 4.5 4.5]-2,[.5 .5 .5],'EdgeColor',[.5 .5 .5]);
  set(SecondScreenAxis,'XLim',[-9 9],'YLim',[-9 9]);
  set(SecondScreenAxis,'XTick',[],'YTick',[])  ;
end
set(VisualDispColor,'FaceColor',Colors.(TrialPerformance));
