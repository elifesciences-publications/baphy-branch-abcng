function varargout = BaphyMainGuiItems (field,globalparams)
% Baphy Main Gui items are defined here.
%
% To add a new tester, ferret, paradigm or mode, just add the new item to
% the corresponding list below.
%

% Nima, November 2005
switch field
  % Tester:
  case 'Tester'
    varargout{1} = {'Austin Powers','Henry', 'Stephen'};
    % Ferret Names:
  case 'Ferret'
    if dbopen,
      sql=['SELECT * FROM gAnimal WHERE onschedule<2 ORDER BY animal'];
      adata=mysql(sql);
      tt={};
      for ii=1:length(adata),
        tanimal=adata(ii).animal;
        if tanimal(1)>='a' && tanimal(1)<='z',
          tanimal(1)=tanimal(1)+'A'-'a';
        end
        tt{ii}=tanimal;
      end
      varargout{1}=tt;
    else
      varargout{1} = {'Test', 'Amethyst', 'Bom', 'Clapton', 'Coral', 'Emerald', ...
        'Goose', 'Hendrix', 'Jill', 'Lupis', 'Maverick', 'Nissa', 'Opal', ...
        'Page', 'Rai', 'Topaz', 'Zim', 'Zouk'};
    end
    % Ferret Names:
  case 'FerretId'
    if dbopen,
      sql=['SELECT * FROM gAnimal WHERE animal="',globalparams.Ferret,'"'];
      adata=mysql(sql);
      varargout{1}=adata.id;
    else
      varargout{1} = 21;
    end
    % Module:
  case 'Module'
    varargout{1} = {'Reference Target', 'Delayed Match-To-Sample', 'Delayed Match-To-Sample-I', 'Multi-Stimulus', 'Delayed NonMatch-To-Sample'};
  case 'Physiology'
    % Physiology:
    varargout{1} = {'Yes -- Behavior','Yes -- Passive','No'};
    % Site ID,  name of the recording site, ex. c021b
  case 'SiteID'
    varargout{1} = {''};
  case 'HWSetup'
    % Sound Proof rooms:
    varargout{1} = {'0: Test', '1: Box A', '2: Box B','3: Box C', '4: Box D','5: Record Setup'};
    % number of electrodes
  case 'NumberOfElectrodes'
    varargout{1} = '1';
  case 'outpath',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve outpath');
    end
    switch globalparams.HWSetup,
      case 0;
        varargout{1}=fileparts(tempname);
      case 1,
        varargout{1}='C:\matt\baphy_data\';  % ie, the server
      case 2,
        varargout{1}='C:\matt\baphy_data\';  % ie, the server
      case 3,
        varargout{1}='C:\matt\baphy_data\';  % ie, the server
      case 4,
        varargout{1}='C:\matt\baphy_data\';  % ie, the server
      case 5,
        varargout{1}='C:\matt\baphy_data\';  % ie, the server
    end
  case 'PumpMlPerSec',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve PumpMlPerSec');
    end
    switch globalparams.HWSetup,
      case 0,
        varargout{1}=1;
      case 1,
        varargout{1}=0;      % no pump installed
      case 2,
        varargout{1}=0.467;  % Nima calibrated 2006-5-18
      case 3,
        varargout{1}=0.24;   % SVD calibrated 2006-05-19
      case 4,
        varargout{1}=0.233;   % SVD calibrated 2006-05-10
      case 6,
        varargout{1}=0;
      case 8,
        varargout{1}=0.24;   % SVD calibrated 2006-05-19
    end
  case 'tempdatapath',
    %if ~exist('globalparams','var')
    %    error('must pass globalparams to retrieve tempdatapath');
    %end
    varargout{1}=tempdir;
  case 'initcommand',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve initcommand');
    end
    switch globalparams.Module,
      case 'Delayed Match-To-Sample',
        varargout{1}='dms_init';
      case 'Delayed Match-To-Sample-I',
        varargout{1}='dms_init';
      case 'Delayed NonMatch-To-Sample',
        varargout{1}='dnms_init';
      case 'Reference Target',
        varargout{1}='BaphyRefTarGui';
      case 'Multi-depth',
        varargout{1}='multidepth_init';
      case 'Multi-Stimulus',
        varargout{1}='multistim_init';
      case 'Stream Segregation';
        varargout{1}='streamSeg_init';
      otherwise
        error('BaphyMainGuiIterms(initcommand): Module not found!');
    end
    
  case 'runcommand',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve runcommand');
    end
    switch globalparams.Module,
      case 'Delayed Match-To-Sample',
        varargout{1}='dms_run';
      case 'Delayed Match-To-Sample-I',
        varargout{1}='dms_run_I';
      case 'Delayed NonMatch-To-Sample',
        varargout{1}='dnms_run';
      case 'Reference Target',
        varargout{1}='RefTarScript';
      case 'Multi-depth',
        varargout{1}='multidepth_run';
      case 'Multi-Stimulus',
        varargout{1}='multistim_run';
      case 'Stream Segregation'
        varargout{1}='streamSeg_run';
      otherwise
        error('BaphyMainGuiIterms(runcommand): Module not found!');
    end
    
  case 'AOTriggerType',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve AOTriggerType');
    end
    switch globalparams.Module,
      case {'Delayed Match-To-Sample','Delayed Match-To-Sample-I','Delayed NonMatch-To-Sample','Multi-depth','Multi-Stimulus'},
        varargout{1} = 'Immediate';
      case {'Reference Target','Stream Segregation'}
        varargout{1} = 'HWDigital';
        globalparams.LickSign = 1;
      otherwise
        error('BaphyMainGuiIterms(AOTriggerType): Module not found!');
    end
    
  case 'fsAO',
    
      varargout{1}=200000;
    
  case 'LickSign',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve LickSign');
    end
    switch globalparams.Module,
      case {'Delayed Match-To-Sample','Delayed Match-To-Sample-I','Delayed NonMatch-To-Sample','Multi-depth','Multi-Stimulus'},
        varargout{1} = 1;
      case {'Reference Target','Stream Segregation'}
        varargout{1} = 1;
      otherwise
        error('BaphyMainGuiIterms(LickSign): Module not found!');
    end
  case 'EqualizerIPAddress'
    switch globalparams.HWSetup
      case 1
        varargout{1} = '128.8.140.198';
      case 3
        varargout{1} = '128.8.140.200';
      case 5
        varargout{1} = '128.8.140.199';
      case 8
        varargout{1} = '128.8.140.200';
      otherwise
        varargout{1} = '';
    end
  case 'FilterGPIBAddress'
    switch globalparams.HWSetup
      case 1
        varargout{1} = 22;
      case 3
        varargout{1} = 23;
      case 5
          varargout{1} = 23;
        case 8
            varargout{1} = 23;
        otherwise
            varargout{1} = 23;
    end
    otherwise
        varargout{1} = [];
end
