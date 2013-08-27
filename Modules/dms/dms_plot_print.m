% function dms_plot_ext(exptparams,events,count);
%
% extended dms behavior analysis
%
function dms_plot_print(mfile);

global BEHAVIOR_CHART_PATH

globalparams=dms_di(mfile);

ff=gcf;

yystring=globalparams.date(1:4);

jpegpath=[BEHAVIOR_CHART_PATH lower(globalparams.Ferret) filesep yystring];
jpegfile=[basename(globalparams.mfilename(1:end-1)) 'jpg'];
if ~exist([BEHAVIOR_CHART_PATH lower(globalparams.Ferret)]),
    mkdir(BEHAVIOR_CHART_PATH,lower(globalparams.Ferret));
end
if ~exist(jpegpath),
    mkdir([BEHAVIOR_CHART_PATH lower(globalparams.Ferret)],yystring);
end
fprintf('printing to %s\n',jpegfile);
tpo=get(ff,'PaperOrientation');
tpp=get(ff,'PaperPosition');
set(ff,'PaperOrientation','portrait','PaperPosition',[0.5 0.5 10 7.5])
drawnow;
print('-djpeg',['-f',num2str(ff)],[jpegpath filesep jpegfile]);
set(ff,'PaperOrientation',tpo,'PaperPosition',tpp)
