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
    varargout{1} = {'Austin Powers','Bernhard','Yves','Jennifer','Claire','Thibaut'};
    % Ferret Names:
  case 'Ferret'
    if dbopen,
      sql=['SELECT * FROM gAnimal WHERE onschedule<2 AND lab="abcnl" ORDER BY animal'];
      adata=mysql(sql);
      if isempty(adata),
          sql=['SELECT * FROM gAnimal WHERE onschedule<2 ORDER BY animal'];
          adata=mysql(sql);
      end          
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
      varargout{1} = {'Test', 'Amazon'};
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
    varargout{1} = {'Reference Target'};
  case 'Physiology'
    % Physiology:
    varargout{1} = {'Yes -- Behavior','Yes -- Passive','No'};
    % Site ID,  name of the recording site, ex. c021b
  case 'SiteID'
    varargout{1} = {''};
  case 'HWSetup'
    % Sound Proof rooms:
    varargout{1} = {'0: Test', '1: SB1', '2: SB2','3: LB1','11:HP1'};
    % number of electrodes
  case 'NumberOfElectrodes'
    varargout{1} = '1';
  case 'outpath',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve outpath');
    end
    switch globalparams.HWSetup,
      case 0;
         if exist('D:\','dir'),
            varargout{1}='D:\Data\';
         else
            varargout{1}=fileparts(tempname);
         end
      case {1,2,3} % PHYSIOLOGY SETUPS
        varargout{1}='D:\Data\';
      case {4,11} % PSYCHOPHYSICSSETUP
        varargout = {'C:\Data\'};
    end
  case 'PumpMlPerSec',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve PumpMlPerSec');
    end
    varargout{1} = 0;
  case 'tempdatapath',
    varargout{1}=tempdir;
  case 'initcommand',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve initcommand');
    end
    switch globalparams.Module,
      case 'Reference Target',
        varargout{1}='BaphyRefTarGui';
      otherwise
        error('BaphyMainGuiIterms(initcommand): Module not found!');
    end
    
  case 'runcommand',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve runcommand');
    end
    switch globalparams.Module,
      case 'Reference Target',
        varargout{1}='RefTarScript';
      otherwise
        error('BaphyMainGuiIterms(runcommand): Module not found!');
    end
    
  case 'TuningCurveCommand',
    varargout{1}='TestTuning';
    
  case 'AOTriggerType',
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve AOTriggerType');
    end
    switch globalparams.Module,
      case {'Reference Target'}
        varargout{1} = 'HWDigital';
        globalparams.LickSign = 1;
      otherwise
        error('BaphyMainGuiIterms(AOTriggerType): Module not found!');
    end
    
  case 'fsAO',
    varargout{1}=100000;
    
  case 'LickSign',
    switch globalparams.Module,
      case {'Reference Target'}
        varargout{1} = 1;
      otherwise
        error('BaphyMainGuiIterms(LickSign): Module not found!');
    end
    
  case 'EqualizerIPAddress'
    varargout{1} = '';
  case 'FilterGPIBAddress'
    varargout{1} = 23;
 
end
