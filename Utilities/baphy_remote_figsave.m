function baphy_remote_figsave(FIG,UH,globalparams,analysis_name,psth)

global BEHAVIOR_CHART_PATH

AnalysisPath=strrep(BEHAVIOR_CHART_PATH,'behaviorcharts','analysis');

if ~exist('psth','var') psth = 0; end

yearstr=globalparams.date(1:4);
if exist(AnalysisPath,'dir'),
    if ~exist([AnalysisPath lower(globalparams.Ferret)]),
        mkdir(AnalysisPath,lower(globalparams.Ferret));
    end
    jpegpath=[AnalysisPath lower(globalparams.Ferret) filesep yearstr];
elseif exist('M:\web\analysis','dir'),
    if ~exist(['M:\web\analysis' filesep lower(globalparams.Ferret)]),
        mkdir('M:\web\analysis',lower(globalparams.Ferret));
    end
    jpegpath=['M:\web\analysis' filesep lower(globalparams.Ferret) filesep yearstr];
elseif exist('H:\web\analysis','dir'),
    if ~exist(['H:\web\analysis' filesep lower(globalparams.Ferret)]),
        mkdir('H:\web\analysis',lower(globalparams.Ferret));
    end
    jpegpath=['H:\web\analysis' filesep lower(globalparams.Ferret) filesep yearstr];
elseif exist('/auto/data/web/analysis','dir'),
    if ~exist(['/auto/data/web/analysis' filesep lower(globalparams.Ferret)]),
        mkdir('/auto/data/web/analysis',lower(globalparams.Ferret));
    end
   jpegpath=['/auto/data/web/analysis' filesep lower(globalparams.Ferret) filesep yearstr];
else
   jpegpath='';
end

if ~isempty(jpegpath),
  if psth && strcmp(analysis_name,'raster') analysis_name = 'psth'; end
  jpegfile=[basename(globalparams.mfilename(1:end-1)),analysis_name,'.jpg'];
  if ~exist(jpegpath),  mkdir(jpegpath);   end
  fprintf('printing to %s\n',jpegfile);

  set(UH,'Visible','off'); drawnow
  print('-djpeg',['-f',num2str(FIG)],[jpegpath filesep jpegfile]);
  set(UH,'Visible','on');
end
