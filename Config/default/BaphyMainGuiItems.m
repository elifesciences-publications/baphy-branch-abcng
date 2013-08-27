function varargout = BaphyMainGuiItems (field,globalparams)
% Baphy Main Gui items are defined here.
%
% To add a new tester, ferret, paradigm or mode, just add the new item to
% the corresponding list below.
%

% Nima, November 2005

varargout = {};

switch field
  
  case 'Tester';
    varargout{1} = {'Austin Powers','Brendan','Bernhard','Catherine','ClairePelofi','Dan W', 'Dana', 'Danielle',...
      'Diego', 'James', 'Jenna', 'Jonathan', 'Julia', 'Kevin D', 'Kevin N','Ka Yang','Locastro','Nik',...
      'Pingbo', 'Roger', 'Shin', 'Stephen', 'Takahiro' ,'Yanbo'};
 
  case 'Ferret';
    if dbopen,
      sql=['SELECT animal,id FROM gAnimal WHERE onschedule<2 ORDER BY animal'];
      Animals=mysql(sql);
      for i=1:length(Animals) Animals(i).animal(1) = upper(Animals(i).animal(1)); end 
      varargout{1}= {Animals.animal};
    else
      varargout{1} = {'Test'};
    end

  case 'FerretId';
    if dbopen,
      sql=['SELECT animal,id FROM gAnimal WHERE animal="',globalparams.Ferret,'"'];
      cAnimal=mysql(sql); varargout{1} = cAnimal.id;
    else
      varargout{1} = 21;
    end
    
    % Module:
 
  case 'Module';
    varargout{1} = {'Reference Target', 'Delayed Match-To-Sample', 'Delayed Match-To-Sample-I', 'Multi-Stimulus', 'Delayed NonMatch-To-Sample'};
  
  case 'Physiology';
    varargout{1} = {'Yes -- Behavior','Yes -- Passive','No'};
  
  case 'SiteID'; 
    varargout{1} = {''};
  
  case 'HWSetup'; 
    varargout{1} = {'0: Test', '1: SPR 1', '2: FRB 1', '3: SPR 2', '4: FRB 2','5: HTB 1','6: KLFRB1','7: CMB 1','8: SPR2 + MANTA',  '9: SPR1 High Freq', '10: Mouserig', '11: SPR2 SNR'};
    % number of electrodes
 
  case 'NumberOfElectrodes'
    varargout{1} = '1';
  
  case 'outpath',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve outpath');
    end
    switch globalparams.HWSetup,
      case 0;       varargout{1} = fileparts(tempname);
      case {1,9};   varargout{1} = 'K:\';
      case 2;       varargout{1} = 'C:\Data\';
      case 3;       varargout{1} = 'K:\';
      case 4;       varargout{1} = 'D:\Data\';
      case 5;       varargout{1} = 'C:\Data\';
      case 6;       varargout{1} = 'C:\BehaviorData\';
      case 7;       varargout{1} = 'G:\Data\';
      case 8;       varargout{1} = 'D:\Data\';
      case 10;     varargout{1} = 'D:\Data\';
      case 11;       varargout{1} = 'S:\';
    end
    
  case 'PumpMlPerSec',
    switch globalparams.HWSetup,
      case 0,      varargout{1}=1;
      otherwise varargout{1} = 0; % CALIBRATION PERFORMED IN CALIBRATION GUI
    end
    
  case 'tempdatapath',
    varargout{1}=tempdir;
 
  case 'initcommand',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve initcommand');
    end
    switch globalparams.Module,
      case 'Delayed Match-To-Sample',        varargout{1}='dms_init';
      case 'Delayed Match-To-Sample-I',     varargout{1}='dms_init';
      case 'Delayed NonMatch-To-Sample',  varargout{1}='dnms_init';
      case 'Reference Target',                      varargout{1}='BaphyRefTarGui';
      case 'Multi-depth',                              varargout{1}='multidepth_init';
      case 'Multi-Stimulus',                           varargout{1}='multistim_init';
      case 'Stream Segregation';                   varargout{1}='streamSeg_init';
      otherwise
        error('BaphyMainGuiIterms(initcommand): Module not found!');
    end
    
  case 'runcommand',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve runcommand');
    end
    switch globalparams.Module,    
      case 'Delayed Match-To-Sample',       varargout{1}='dms_run';
      case 'Delayed Match-To-Sample-I',    varargout{1}='dms_run_I';
      case 'Delayed NonMatch-To-Sample', varargout{1}='dnms_run';
      case 'Reference Target',                     varargout{1}='RefTarScript';
      case 'Multi-depth',                             varargout{1}='multidepth_run';
      case 'Multi-Stimulus',                         varargout{1}='multistim_run';
      case 'Stream Segregation';                   varargout{1}='streamSeg_run';
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
    
  case 'fsAO';
    switch globalparams.HWSetup
      case {9,10};     varargout{1}=100000;
      case {7};         varargout{1} = 80000;
      otherwise       varargout{1}=40000;
    end
    
  case 'LickSign';
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
      case 1;          varargout{1} = '128.8.140.198';
      case {3,11};          varargout{1} = '128.8.140.200';
      case 5;          varargout{1} = '128.8.140.199';
      case 8;          varargout{1} = '128.8.140.200';
      otherwise       varargout{1} = '';
    end
    
  case 'FilterGPIBAddress'
    switch globalparams.HWSetup
      case 1;         varargout{1} = 22;
      case {3,11};          varargout{1} = 23;
      case 5;        varargout{1} = 23;
      case 8;        varargout{1} = 23;
      otherwise     varargout{1} = 23;
    end
    
  case 'TuningCurveCommand';
    varargout{1} = [];
        
end
