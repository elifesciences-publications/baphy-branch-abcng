%function SaveBehaviorFigure(globalparams,exptparams)
%
% save figure for display in celldb -- called by baphy.m and
% replicate_behavior_analysis
%
% created 2013-08-26 - SVD ripped out of baphy.m
%
function SaveBehaviorFigure(globalparams,exptparams)

global BEHAVIOR_CHART_PATH DB_USER
if isfield(exptparams,'ResultsFigure') && exist(BEHAVIOR_CHART_PATH,'dir'),
    jpegpath=[BEHAVIOR_CHART_PATH lower(globalparams.Ferret)...,
        filesep globalparams.date(1:4)];
    jpegfile=[basename(globalparams.mfilename(1:end-1)) 'jpg'];
    if ~exist([BEHAVIOR_CHART_PATH lower(globalparams.Ferret)],'file'),
        mkdir(BEHAVIOR_CHART_PATH,lower(globalparams.Ferret));
    end
    if ~exist(jpegpath,'dir'),
        mkdir([BEHAVIOR_CHART_PATH lower(globalparams.Ferret)],datestr(now,'yyyy'));
    end
    fprintf('printing to %s\n',jpegfile);
    tpo=get(exptparams.ResultsFigure,'PaperOrientation');
    tpp=get(exptparams.ResultsFigure,'PaperPosition');
    set(exptparams.ResultsFigure,'PaperOrientation','portrait','PaperPosition',[0.5 0.5 10 7.5])
    drawnow;
    print('-djpeg',['-f',num2str(exptparams.ResultsFigure)],[jpegpath filesep jpegfile]);
    set(exptparams.ResultsFigure,'PaperOrientation',tpo,'PaperPosition',tpp)
end
