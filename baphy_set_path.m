function baphy_set_path
% set up environment for baphy

% clear classes if running baphy.m--this avoids conflicts with daqpc
caller=dbstack;
if strcmp(caller(1).name,'baphy') && ...
      (~exist('BAPHYHOME','var') || isempty(BAPHYHOME)),
    clear classes;
end

% Set up globals
global BAPHYHOME BAPHYDATAROOT SERVER_PATH BEHAVIOR_CHART_PATH 
global BAPHY_CONFIG_PATH BAPHY_LAB
global LOCAL_DATA_ROOT LOCAL_DATA_LIMIT MD
global DB_USER DB_SERVER DB_PASSWORD DB_NAME MYSQL_BIN_PATH
clear global MD

% figure out dir containing baphy.m
BAPHYHOME=fileparts(which('baphy'));
% Add baphy subfolders to path
addpath(BAPHYHOME,...
    [BAPHYHOME filesep 'Anatomy'],...
    [BAPHYHOME filesep 'Analysis'],...
    [BAPHYHOME filesep 'SoundObjects'],...
    [BAPHYHOME filesep 'Utilities'],...
    [BAPHYHOME filesep 'Modules'],...
    [BAPHYHOME filesep 'Modules' filesep 'MultiStim'],...
    [BAPHYHOME filesep 'Modules' filesep 'dms'],...
    [BAPHYHOME filesep 'Modules' filesep 'RefTar'],...
    [BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'TrialObjects'],...
    [BAPHYHOME filesep 'Modules' filesep 'RefTar' filesep 'BehaviorObjects'],...
    [BAPHYHOME filesep 'Config'],...
    [BAPHYHOME filesep 'cellDB'],...
    [BAPHYHOME filesep 'RemoteAnalysis'],...
    [BAPHYHOME filesep 'Meska'],...
    genpath([BAPHYHOME filesep 'Utilities' filesep 'UtilitiesYves']),...    
    genpath([BAPHYHOME filesep 'Utilities' filesep 'UtilitiesAnna']),...  
    [BAPHYHOME filesep 'Utilities' filesep 'UtilitiesBernhard'],...
    [BAPHYHOME filesep 'Utilities' filesep 'UtilitiesBernhard' filesep 'UNIT-tools'],...
    [BAPHYHOME filesep 'QuickSort']);
addpathWithoutVC([BAPHYHOME,filesep,'MANTA']);
addpathWithoutVC([BAPHYHOME,filesep,'Hardware']);
addpathWithoutVC([BAPHYHOME filesep 'Utilities' filesep 'UtilitiesBernhard']);

%% set lab-specific variables (use default values if not set in BaphyConfigPath)
%% SVD added 2012-05-25
if exist('BaphyConfigPath.m','file'),
    BaphyConfigPath;
else
    baphy_learn_config_path;
end

% if any lab-specific variables are missing, set them to defaults
if ~exist('BAPHY_CONFIG_PATH') || isempty(BAPHY_CONFIG_PATH),
    BAPHY_CONFIG_PATH='default';
end
if ~exist('BAPHY_LAB') || isempty(BAPHY_LAB),
    if strcmpi(BAPHY_CONFIG_PATH,'default'),
        BAPHY_LAB='nsl';
    else
        BAPHY_LAB=BAPHY_CONFIG_PATH;
    end
end
if ~exist('WIN_SERVER_PATH') || isempty(WIN_SERVER_PATH),
  WIN_SERVER_PATH='M:\';
end
if ~exist('MAC_SERVER_PATH') || isempty(MAC_SERVER_PATH),
  MAC_SERVER_PATH='/Volumes/data/';
end
if ~exist('LINUX_SERVER_PATH') || isempty(LINUX_SERVER_PATH),
  LINUX_SERVER_PATH='/auto/data/';
end
if isempty(DB_SERVER),
  %DB_SERVER='bhangra.isr.umd.edu';
  %DB_SERVER='128.8.140.174';
  DB_SERVER='metal.isr.umd.edu';
end
addpath([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH])
if exist([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'BehaviorObjects'],'dir'),
  addpath([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'BehaviorObjects'])
end
if exist([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'SoundObjects'],'dir'),
  addpath([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'SoundObjects'])
end
if exist([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'TrialObjects'],'dir'),
  addpath([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'TrialObjects'])
end
if exist([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'LocalUtilities'],'dir'),
    addpath([BAPHYHOME filesep 'Config' filesep BAPHY_CONFIG_PATH filesep 'LocalUtilities'])
end

% correct alpha omega tools version depends on which version of
% matlab is running
matlab_version=strsep(version,'.',1);
matlab_version=str2num([matlab_version{1} '.' matlab_version{2}]);
if matlab_version>=7.11,
    addpath([BAPHYHOME filesep 'Utilities' filesep 'AlphaOmega2.5']);
else
    addpath([BAPHYHOME filesep 'Utilities' filesep 'AlphaOmega']);
end    

global meska_ROOT
meska_ROOT=fileparts(which('meska'));

% also, remove daqpc is it exists in path (this should be
% irrelevant now that daqpc has been retired for several years)
a=path;
b=strsep(a,';');
c=(strfind(b,'behavior\'));
for cnt1 = length(c):-1:1  % so that we can delete them and index doesnt change
    if ~isempty(c{cnt1})
        rmpath(b{cnt1});
    end
end

% system-specific path settings
if strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64'),
    addpath([BAPHYHOME filesep 'cellDB' filesep 'db_win']);
    MYSQL_BIN_PATH=[BAPHYHOME filesep 'cellDB' filesep 'db_win' filesep];
    MYSQL_BIN_PATH=strrep(MYSQL_BIN_PATH,'Program Files','PROGRA~1');
    SERVER_PATH=WIN_SERVER_PATH;
   
elseif strcmp(computer,'MAC'),
    addpath([BAPHYHOME filesep 'cellDB' filesep 'db_mac']);
    MYSQL_BIN_PATH=[BAPHYHOME filesep 'cellDB' filesep 'db_mac' filesep];
    SERVER_PATH=MAC_SERVER_PATH;
    
elseif strcmp(computer,'MACI'),
    addpath([BAPHYHOME filesep 'cellDB' filesep 'db_maci']);
    MYSQL_BIN_PATH=[BAPHYHOME filesep 'cellDB' filesep 'db_maci' filesep];
    SERVER_PATH=LINUX_SERVER_PATH;  % this system was configured with autofs
    
elseif strcmp(computer,'MACI64'),
    addpath([BAPHYHOME filesep 'cellDB' filesep 'db_maci64']);
    MYSQL_BIN_PATH=[BAPHYHOME filesep 'cellDB' filesep 'db_maci64' filesep];
    SERVER_PATH=MAC_SERVER_PATH;
    
else %LINUX
    
    addpath([BAPHYHOME filesep 'cellDB' filesep 'db_linux']);
    MYSQL_BIN_PATH='';
    if exist('onseil','file') && onseil==1,
       SERVER_PATH='/homes/svd/data/';
    else
       SERVER_PATH=LINUX_SERVER_PATH;
    end
end
BAPHYDATAROOT=[SERVER_PATH];
BEHAVIOR_CHART_PATH=[SERVER_PATH 'web' filesep 'behaviorcharts' filesep];
%if ~exist(BEHAVIOR_CHART_PATH,'dir'),
   %ButtonName=questdlg('Behavior chart path (<dataroot>/web/behaviorcharts) not found.  You must connect to metal first to save behavior!', ...
    %                   'Can''t connect to metal','Ignore','Quit','Quit');
  %  warning('Behavior chart path (<dataroot>/web/behaviorcharts) not found.  You must connect to metal first to save behavior!');
    %if strcmp(ButtonName,'Quit'),
    %  quit_baphy=1;
   %end
%end

% LOCAL_DATA_ROOT is where data files are stored on the local machine
% (when copying down via evpmakelocal and --possibly-- the same as
% during recording.)  Can also be set in BaphyConfigPath
HostName=lower(HF_getHostname);
if isempty(LOCAL_DATA_ROOT),
  switch HostName
    case 'plethora';
      if ~isempty(strfind(computer,'WIN')) LOCAL_DATA_ROOT = ['G:\Data\'];
      else  LOCAL_DATA_ROOT = ['/media/storage/Data/'];
      end
    case 'deeppurple';
      LOCAL_DATA_ROOT = ['/home/data/'];
    case 'mouserig';
      LOCAL_DATA_ROOT = ['D:\Data\'];
    case 'deepthought'; LOCAL_DATA_ROOT = ['C:\SharedFolders\Data\'];
      %case 'deepthought'; LOCAL_DATA_ROOT = ['W:\'];
    case 'avw2202j'; LOCAL_DATA_ROOT = ['K:\'];
    case 'avw2202f'; LOCAL_DATA_ROOT = ['W:\'];
    case 'dog'; LOCAL_DATA_ROOT = '/home/data/daq/';
    case 'blues'; LOCAL_DATA_ROOT = '/home/delgueda/Data/';
    case{'largebooth','chronic1','chronic1-pc','chronic2','chronic3'};   LOCAL_DATA_ROOT = 'D:\Data\';
    otherwise
      disp('Using default LOCAL_DATA_ROOT for this computer.');
      LOCAL_DATA_ROOT=[tempdir 'evpread' filesep];
  end
end

LOCAL_DATA_LIMIT=20;

% force reset of db connection.  Currently disabled, in case working
% offline
%dbopen(1);

% set some global color sets for plotting with errorshade:
global ES_LINE ES_SHADE
gl=0.70;
ES_LINE={[0 0 1],[1 0 0],[0 0.6 0],[0 0 0],[1 0 1],[1 1 0],[0 0.9 0.9]};
ES_SHADE={[gl gl 1],[1 gl gl],[gl 0.9 gl],[gl gl gl],...
          [1 0.4 1],[1 1 0.4],[0.4 1 1]};
   
global chanstr
chanstr=cell(1,128);
for ii=1:length(chanstr),
  chanstr{ii}=sprintf('%02d-',ii);
end

% for grid recordings:
global USECOMMONREFERENCE

if isempty(USECOMMONREFERENCE),
  USECOMMONREFERENCE=0;
end


function addpathWithoutVC(Path)

switch architecture
  case 'PCWIN'; Delimiter = ';';
  otherwise Delimiter = ':';
end

Paths=''; PathsAll=strsep(genpath(Path),Delimiter);
for ii=1:length(PathsAll),
  if isempty(findstr('.svn',PathsAll{ii})) && isempty(findstr('.git',PathsAll{ii})) && ~isempty(PathsAll{ii}),
    Paths=[Paths,Delimiter,PathsAll{ii}];
  end
end
addpath(Paths(2:end));