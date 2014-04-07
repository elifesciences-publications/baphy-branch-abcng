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
    varargout{1} = {'Austin Powers','Dani','Henry','Sean','Stephen','Zack'};
    % Ferret Names:
  case 'Ferret'
    if dbopen,
      sql=['SELECT * FROM gAnimal WHERE onschedule<2 AND lab="lbhb" ORDER BY animal'];
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
  case 'SiteID'
    % Site ID,  name of the recording site, ex. c021b
    varargout{1} = {''};
  case 'HWSetup'
    % Sound Proof rooms:
    varargout{1} = {'0: Test', '1: SB 1',...
        '2: LB 1 (Primary=R)', '3: LB 1 (Primary=L)',...
        '4: LB 2 (Primary=R)', '5: LB 2 (Primary=L)', '6: DR 1 (Primary=R)',...
        '7: DR 1 (Primary=L)'};
  case 'HWSetupSpecs',
    % boilerplate descriptor of recording setup for saving to gPenetration
    % in celldb.
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve HWSetupSpecs');
    end
    
    % default values
    varargout{1}.probenotes='NA';
    varargout{1}.ear='';
    
    switch globalparams.HWSetup,
        case 0,
            varargout{1}.racknotes='TEST MODE';
            varargout{1}.speakernotes='Sound card';
        case 1,
            varargout{1}.racknotes=sprintf('Small booth 1, pump cal: %.2f ml/sec',globalparams.PumpMlPerSec.Pump);
            varargout{1}.speakernotes='Pyle amp. Polk free-field speaker.';
            if ~globalparams.training,
                varargout{1}.probenotes=sprintf('%d-channel. Well position: XXX',globalparams.numchans);
                varargout{1}.electrodenotes='FHC: size, impendence not specified';
            end
            varargout{1}.ear='B';
        case {2,3},
            varargout{1}.racknotes=sprintf('Large booth 1, pump cal: %.2f ml/sec',globalparams.PumpMlPerSec.Pump);
            if ~globalparams.training,
                varargout{1}.probenotes=sprintf('%d-channel. Well position: XXX',globalparams.numchans);
                varargout{1}.electrodenotes='FHC: size, impendence not specified';
            end
            if globalparams.HWSetup==2,
                varargout{1}.speakernotes='Crown amp. Software attenuation/equalizer. Manger free-field speakers. Channel 1=right speaker.';
                varargout{1}.ear='R';
            else
                varargout{1}.speakernotes='Crown amp. Software attenuation/equalizer. Manger free-field speakers. Channel 1=left speaker.';
                varargout{1}.ear='L';
            end
               
        case {4,5},
            varargout{1}.racknotes=sprintf('Large booth 2, pump cal: %.2f ml/sec',globalparams.PumpMlPerSec.Pump);
            if ~globalparams.training,
                varargout{1}.probenotes=sprintf('%d-channel. Well position: XXX',globalparams.numchans);
                varargout{1}.electrodenotes='FHC: size, impendence not specified';
            end
            if globalparams.HWSetup==4,
                varargout{1}.speakernotes='Crown amp. Software attenuation/equalizer. Manger free-field speakers. Channel 1=right speaker.';
                varargout{1}.ear='R';
            else
                varargout{1}.speakernotes='Crown amp. Software attenuation/equalizer. Manger free-field speakers. Channel 1=left speaker.';
                varargout{1}.ear='L';
            end
            
             case {6,7}, %% Dark room 1
            varargout{1}.racknotes=sprintf('Dark room, pump cal: %.2f ml/sec',globalparams.PumpMlPerSec.Pump);
            if ~globalparams.training,
                varargout{1}.probenotes=sprintf('%d-channel. Well position: XXX',globalparams.numchans);
                varargout{1}.electrodenotes='FHC: size, impendence not specified';
            end
            if globalparams.HWSetup==6,
                varargout{1}.speakernotes='Pyle amp. Software attenuation/equalizer. Cheapo free-field speakers. Channel 1=right speaker.';
                varargout{1}.ear='R';
            else
                varargout{1}.speakernotes='Pyle amp. Software attenuation/equalizer. Cheapo free-field speakers. Channel 1=left speaker.';
                varargout{1}.ear='L';
            end
    end
  case 'NumberOfElectrodes'
    % number of electrodes
    varargout{1} = '1';
  case 'outpath',
    % root path to save mfiles and raw data. use <outpath>/<animalname>/<penname>
    if ~exist('globalparams','var')
      error('must pass globalparams to retrieve outpath');
    end
    switch globalparams.HWSetup,
      case 0;
         if exist('H:\','dir'),
            varargout{1}='H:\daq\';
         else
            varargout{1}=fileparts(tempname);
         end
        case {1,6,7}
        varargout{1}='H:\daq\';  % ie, save direct to the server
      case {2,3}
          if strcmpi(globalparams.Physiology,'No'),
              varargout{1}='H:\daq\';  % for training, save direct to the server
          else
              varargout{1}='L:\';  % Mapped to C:\Data\ on MOLE (ie, \\MOLE\Data)
          end
        case {4,5}
            if strcmpi(globalparams.Physiology,'No'),
                varargout{1}='H:\daq\';  % for training, save direct to the server
            else
                varargout{1}='K:\';  % Mapped to C:\Data\ on badger (ie, \\MOLE\Data)
            end
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
      case {4,5}
        varargout{1}=0.233;   % SVD calibrated 2006-05-10
     otherwise
        varargout{1}=0;
       
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
    
  case 'TuningCurveCommand',
    varargout{1}='TestTuning';
    
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
    varargout{1}=100000;
    %if any(globalparams.HWSetup==[9,10])
    %  varargout{1}=100000;
    %else
    %  varargout{1}=40000;
    %end

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
    
end
