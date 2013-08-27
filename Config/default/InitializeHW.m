function [HW, globalparams] = InitializeHW (globalparams)
% function HW = InitializeHW (globalparams);
%
% InitializeHW initializes the hardware based on which hardware setup is
% used (Test, SPR1, training1, training 2, and alpha omega) and the
% parameters of the experiments specified in globalparams.
%
% The steps are as follows:
%   Analog Input: The spike and Touch (lick and paw) are connected to
%       Analog Input of NIDAQ card. NIDAQ has 16 Analog Input and 8 Digital
%       IO.  The sampling rate of Input is set to 20KHz, the data can be
%       downsampled for touch if needed.
%   Analog Output: The sound is sent to hardware from the analog output of
%       the NIDAQ card. The card has 2 Analog Outputs, the frequency is set
%       to the sampling frequency specified in TrialObject
%   TCPIP: In alphaomega rig, baphy communicate with alpha computer and
%       equalizer through TCPIP
%   Digital IO: Digital input/outputs used are as follows. The card allows
%       up to 8 channels, so all are used.
%       DIO 1:  Switch between touch ckt and shock ckt
%       DIO 2:  Send the shock
%       DIO 3:  Switch Phys.Amp      ???? what is this?
%       DIO 4:  Input for hits       ???? what is this
%       DIO 5:  Trigger for HW.AI, AI starts collecting data when this
%               line is activated
%       DIO 6:  Trigger for HW.AO, AO starts sending out the data when
%               this line is activated
%       DIO 7:  File save, a command that is sent to alpha omega system
%       DIO 8:  Paw press input
%   Attenuator
%   KHfilter
%

% Nima, November 2005

% close anything that is open:
ShutdownHW;

global BAPHYHOME;
global FORCESAMPLINGRATE

FORCESAMPLINGRATE=1;

HW=[];
HW.params.HWSetup   = globalparams.HWSetup;
% default fsout depends on Tester (hacked so Sharba gets 160K)
HW.params.fsAO      = BaphyMainGuiItems('fsAO',globalparams);
HW.params.fsAI      = 1000;  % default fsAI is 1000.
HW.params.fsSpike   = 20000;
HW.params.fsAux     = 1000;
if isfield(globalparams,'AOTriggerType')
    HW.params.AOTriggerType = globalparams.AOTriggerType;
else
    HW.params.AOTriggerType = 'HWDigital';
end
if isfield(globalparams,'LickSign')
    HW.params.LickSign  = globalparams.LickSign;
    HW.params.PawSign  = globalparams.LickSign;
else
    HW.params.LickSign  = 1;
    HW.params.PawSign  = 1;
end
% this signals to use some special line on the alpha omega rig. what for????
doingphysiology = ~strcmp(globalparams.Physiology,'No');
% can not do phyiology in setup 2,4 and 5
if ~isempty(find(globalparams.HWSetup==[2 4 5])), doingphysiology=0;end
% Based on the hardware setup, start the initialization:
switch globalparams.HWSetup
  
  case 0 % TEST MODE
    % create an audioplayer object which lets us control
    % start, stop, smapling rate , etc.
    HW.AO = audioplayer(rand(4000,1), HW.params.fsAO);
    HW.AI = HW.AO;
    HW.DIO.Line.LineName = {'Touch','TouchL','TouchR'};
  
    %% COMMUNICATE WITH MANTA
    if doingphysiology  
      [HW,globalparams] = IOConnectWithManta(HW,globalparams); 
    end  
    
  case {1,9} % SPR1, ALPHAOMEGA RIG (1= standard, 9= mouse recordings with high frequency support)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Analog output for Sound output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize the attenuator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    HW.Atten = attenuator;
    init(HW.Atten);% Set properties and fopen gpib
    attenuate(HW.Atten,60);% Set attenuation to 0db
    
    % Analog Output:
    % channel 0 is the actual experiment sound
    % channel 1 is the trigger for function generator.

    nidaq_dev=1;
    HW.AO = analogoutput('nidaq',nidaq_dev);
    %HW.AO = analogoutput('nidaq','Dev1');
    if isfield(globalparams,'TuningCurve') && strcmpi(globalparams.TuningCurve,'yes')
      addchannel(HW.AO,1,'TCTrig');
    else
      addchannel(HW.AO,0,'SoundOut');
      addchannel(HW.AO,1,'LightOut');
    end
    % set this depending on globalparams.A0TriggerType:
    set(HW.AO,'TriggerType',HW.params.AOTriggerType);
    set(HW.AO,'TransferMode','DualDMA');
    set(HW.AO,'SampleRate',HW.params.fsAO);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Analog input for lick and/or spikes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    aichannel = [2 0 3];
    ainames = {'Touch','Paw','Microphone'};  % no spikes on training setup
    HW.AI  = analoginput('nidaq',1);       % Create object DAQ.AI - NI Daq(2)
    %HW.AI  = analoginput('nidaq','Dev1');       % Create object DAQ.AI - NI Daq(2)
    HW.params.AInames = ainames;
    hwAnIn  = addchannel(HW.AI,aichannel,ainames);     % Add the h/w line
    set(HW.AI,'InputType','NonReferencedSingleEnded');    % Single ended input
    set(HW.AI,'DriveAISenseToGround','On'); % Do not use DAQ.AI sense to ground
    set(HW.AI,'SampleRate',HW.params.fsAI);           % Sample rate
    set(hwAnIn,'InputRange',[-10 10]);      % Output from Amplifiers
    set(hwAnIn,'SensorRange',[-10 10]);     % for evp data set to
    set(hwAnIn,'UnitsRange',[-10 10]);      % [-10 10]Volts
    set(HW.AI,'TriggerType','HwDigital');         % Trigger type=Manual
    set(HW.AI,'TriggerCondition','PositiveEdge');
    set(HW.AI,'LoggingMode','Memory');
    %     % This is a hack: Assuming that you never want more than 10 second long
    %     % trials
    %     set(HW.AI,'SamplesPerTrigger',HW.params.fsAI*10);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize digital i/o
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %HW.DIO  = digitalio('nidaq','Dev1');
    HW.DIO  = digitalio('nidaq',1);
    addline(HW.DIO,0:1,'Out',{'Shock','Light'});    % Shock Light and Shock Switch
    
    hwDiAT  = addline(HW.DIO,2,'Out','Pump');   % Pump
    addline(HW.DIO,3,'In','Touch');       % touch input
    addline(HW.DIO,4:5,'Out',{'TrigAO','TrigAI'});    % Trigger for AI and AO
    
    % filesave line merged with AI trigger to free up DIO 6 for microstim
    % line -- SVD 2011-11-21
    %addline(HW.DIO,6,'Out',{'FileSave'});   % Confirm save, and filesave
    
    
    addline(HW.DIO,6,'Out',{'Stimulation'});   % Confirm save, and filesave
    addline(HW.DIO,7,'In',{'Paw'});   % Paw press input
    
    % conflict for pump control. what can be replaced????
    %hwDiOut = addline(HW.DIO,5,'Out','Pump');      % Water Pump
    
    % initialze DIO outputs
    start(HW.DIO);
    putvalue(HW.DIO.Line(1:3),0);
    putvalue(HW.DIO.Line(5:6),[1 0]);   % put the triggers to 1, indices are HwLines +1
    
    HW.params.PawSign=-1;        % initialze DIO outputs
    
    
    if globalparams.HWSetup==1
      % SPR1 standard -- use filter and equalizer (connected to standard speaker)
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Initialize the KHFIlter
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Cannot set the cutoff frequencies of Krohn-hite directly. Krohn-hite
      % does not let the cutoff frequency change by more than one digit. Must start
      % with a valid value and then change cutoffs progressively by a factor of
      % 10 until target value is reached.  The function setKHcutoff sets
      % filter cutoffs by following this procedure.
      % spr1 filter is at 22, spr3 filter is at address 23. you can
      % actually see the GPIB address bu pressing the appropriate keys on
      % the filter:
      
      HW.filter = khfilter(BaphyMainGuiItems('FilterGPIBAddress',globalparams)); % Set properties and fopen gpib
      init(HW.filter);
      setfilter(HW.filter, 'Channels', 'All', 'InputGain', 0, 'OutputGain', 0);
      setfilter(HW.filter,'Channels',1,'Frequency',2000);
      setfilter(HW.filter,'Channels',1,'Frequency',HW.params.fsAO/2);
      setfilter(HW.filter,'Channels',3,'Frequency',20); % low frequency is 20??
      HW.Eqz = rpmequalizer;
      HW.Eqz = set(HW.Eqz,'IPAddress',BaphyMainGuiItems('EqualizerIPAddress',globalparams));
    
    elseif globalparams.HWSetup==9,
      % SPR1 configured for mouse recordings. Bypass equalizer and filter (manually),
      % use high frequency callibration
      
      %% SETUP SPEAKER CALIBRATION
      HW.Calibration.Speaker = 'FostexT90';
      HW.Calibration.Microphone = 'BK4944A';
      HW.Calibration = IOLoadCalibration(HW.Calibration);
      
      %%  CONFIGURE STIMULATION
      HW = InitializeStimulation(HW,'Starts',[0.1],'Durations',0.0001,'Voltages',5)
      
    else
      error('HWsetup not supported');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Communicate with alpha-omega machine for file saving/syncing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % start with TCPIP connection to alpha omega. This has an issue now, if the
    % connection is already established, it crashes. This has to be solved...
    % Establish the connection only if needed, not for behaviour and test:
    
    % do not start the acquisition if only doing behavior
    if doingphysiology,
      HW.aw=awtcpip;
      HW.aw = set(HW.aw,'AWMachineName','128.8.140.185');
      [HW.aw,awerr]=init(HW.aw);
      if ~awerr
        fwrite(HW.aw,'StopAcq'); %if acquisition is already running, stop it
      else
        ShutdownHW(HW);
        error('AW connect error');
      end
      
      % start the acquisition
      fwrite(HW.aw,'StartAcq');
      
      % initialize save file name in alphaomega system
      % ie, map filename is XXXX.m converted to XXXX.map
      [maptempfile,mapfpath]=basename(globalparams.mfilename);
      mapfpath=[mapfpath 'raw' filesep];
      maptempfile=[maptempfile 'ap'];
      
      % old system for map file location:
      %mapfpath=[globalparams.outpath globalparams.Ferret ...
      %    filesep 'tmp' filesep]
      % map filename is XXXX.m converted to XXXX.map
      %maptempfile=[basename(globalparams.mfilename) 'ap'];
      
      fprintf('AW saving to: %s%s\n',mapfpath,maptempfile);
      fwrite(HW.aw,'StartSave',maptempfile,mapfpath);
    end
    
  case {2,4} % FRB1/2, TRAINING RIGS
    % Initialize Analog output for Sound output
    nidaq_dev=1;
    HW.AO = analogoutput('nidaq',nidaq_dev);
    addchannel(HW.AO,0,'SoundOut');
    addchannel(HW.AO,1,'LightOut');
    
    % set this depending on globalparams.A0TriggerType:
    set(HW.AO,'TriggerType',HW.params.AOTriggerType);
    
    set(HW.AO,'TransferMode','DualDMA');
    % the following line is commented, until we decide how to set fs
    set(HW.AO,'SampleRate',HW.params.fsAO);
    
    % Line 1 is for touch input
    aichannel = [0 1];
    ainames = {'Touch','Paw'};  % no spikes on training setup
    HW.AI  = analoginput('nidaq',nidaq_dev);       % Create object DAQ.AI - NI Daq(2)
    hwAnIn  = addchannel(HW.AI,aichannel,ainames);     % Add the h/w line
    
    set(HW.AI,'InputType','NonReferencedSingleEnded');   % Single ended input
    set(HW.AI,'DriveAISenseToGround','On');  % Don't use DAQ.AI sense to ground
    set(HW.AI,'SampleRate',HW.params.fsAI);  % Sample rate
    set(hwAnIn,'InputRange',[-10 10]);      % Output from Amplifiers
    set(hwAnIn,'SensorRange',[-10 10]);     % for evp data set to
    set(hwAnIn,'UnitsRange',[-10 10]);      % [-10 10]Volts
    set(HW.AI,'TriggerType','HwDigital');         % Trigger type=Manual
    set(HW.AI,'LoggingMode','Memory');
    
    % This is a hack: Assuming that you never want more than 10 second trials
    set(HW.AI,'SamplesPerTrigger',HW.params.fsAI*10);
    
    % Initialize Digital IO
    % DAQ.DIO lines are as follows:
    % HwLines    Line index     Function
    % 0             1           Shock Light
    % 1             2           Shock (Shock switch and the shock)
    % 2             3           input for hits
    % 3             4           Trigger for DAQ.AI
    % 4             5           Trigger for DAQ.AO
    % 5             6           water pump
    % 6             7           LED
    % 7             8           touch input??
    HW.DIO  = digitalio('nidaq',nidaq_dev);
    addline(HW.DIO,0:1,'Out',{'Light','Shock'});    % Shock Light and Shock Switch
    addline(HW.DIO,2,'In','Paw');       % bar press input
    addline(HW.DIO,3:4,'Out',{'TrigAI','TrigAO'});    % Trigger for AI and AO
    addline(HW.DIO,5,'Out','Pump');      % Water Pump
    addline(HW.DIO,6,'Out','LED');   
    addline(HW.DIO,7,'In','Touch');       % Lick input
    putvalue(HW.DIO.Line(4:5),[1 1]);       % put the triggers to 1, indices are HwLines +1
    
    if globalparams.HWSetup==4,
      % sign is flipped to make bar up positive, bar down negative
      HW.params.PawSign=-1;
    end
    
  case {3,11}  % SPR2, ALPHAOMEGA RIG
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize the attenuator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    HW.Atten = attenuator;
    init(HW.Atten);% Set properties and fopen gpib
    attenuate(HW.Atten,60);% Set attenuation to 0db
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Analog output for Sound output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AO setup should be identical to training rig except AO channel is 1
    % rather than 0
    HW.AO = analogoutput('nidaq',1);
    if isfield(globalparams,'TuningCurve') && strcmpi(globalparams.TuningCurve,'yes')
      addchannel(HW.AO,0,'TCTrig');
    else
      addchannel(HW.AO,0,'SoundOut');
      addchannel(HW.AO,1,'SoundOut');
    end
    % set this depending on globalparams.A0TriggerType:
    set(HW.AO,'TriggerType',HW.params.AOTriggerType);
    
    set(HW.AO,'TransferMode','DualDMA');
    % the following line is commented, until we decide how to set fs
    set(HW.AO,'SampleRate',HW.params.fsAO);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Analog input for lick and/or spikes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Line 1 is for touch input
    % currently ignoring what behavior the animal is actually doing and
    % always recording both lines. is this a problem?
    aichannel = [0 1 3];
    ainames = {'Touch','Paw','Microphone'};  % no spikes on training setup
    HW.AI  = analoginput('nidaq',1);       % Create object DAQ.AI - NI Daq(2)
    hwAnIn  = addchannel(HW.AI,aichannel,ainames);     % Add the h/w line
    
    set(HW.AI,'InputType','NonReferencedSingleEnded');    % Single ended input
    set(HW.AI,'DriveAISenseToGround','On'); % Do not use DAQ.AI sense to ground
    set(HW.AI,'SampleRate',HW.params.fsAI);           % Sample rate
    set(hwAnIn,'InputRange',[-10 10]);      % Output from Amplifiers
    set(hwAnIn,'SensorRange',[-10 10]);     % for evp data set to
    set(hwAnIn,'UnitsRange',[-10 10]);      % [-10 10]Volts
    set(HW.AI,'TriggerType','HwDigital');         % Trigger type=Manual
    set(HW.AI,'TriggerCondition','positiveEdge');
    % log to memory only on training rig (not saving raw spike data)
    set(HW.AI,'LoggingMode','Memory');
    
    % The following lines specify where analoginput data should be logged:
    %set(HW.AI,'LoggingMode','Disk&Memory')   % Log the data in file and memory
    %set(HW.AI,'LogToDiskMode','Index')
    % It needs a name for the directory. Commented for now:
    % fname   = get(trialtags,'Experiment');
    % ferretname = get(trialtags,'Ferret');
    % ferretname = ferretname{1}{1};
    % trialdir = [config('datapath') filesep ferretname];
    % evpdaq = [trialdir '\tmp\' fname '.daq.tmp'];
    % set(HW.AI,'LogFileName',evpdaq);
    
    % This is a hack: Assuming that you never want more than 10 second long
    % trials
    set(HW.AI,'SamplesPerTrigger',HW.params.fsAI*10);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize digital i/o
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    HW.DIO  = digitalio('nidaq',1);
    addline(HW.DIO,0:1,'Out',{'Shock','Light'});    % Shock Light and Shock Switch
    
    % think this is some leftover thing from pre-alphaomega days, replaced
    % with pump control SVD 2006-04-25
    %hwDiAT  = addline(HW.DIO,2,'Out','AmpTrigger');   % Phys Amp  ?? what is this
    hwDiAT  = addline(HW.DIO,2,'Out','Pump');   % Pump
    addline(HW.DIO,3,'In','Touch');       % touch input
    addline(HW.DIO,4:5,'Out',{'TrigAI','TrigAO'});    % Trigger for AI and AO
    % May 2008, FileSave was merged with TrigerAI to free up a line for
    % stimulation palse:
    %         addline(HW.DIO,6,'Out',{'FileSave'});   % Confirm save, and filesave
    addline(HW.DIO,6,'Out',{'Stimulation'});   % Confirm save, and filesave
    addline(HW.DIO,7,'Out',{'LED'});   % Confirm save, and filesave
    
    % conflict for pump control. what can be replaced????
    %hwDiOut = addline(HW.DIO,5,'Out','Pump');      % Water Pump
    
    % initialze DIO outputs
    start(HW.DIO);
    putvalue(HW.DIO.Line(1:3),0);
    putvalue(HW.DIO.Line(5:6),[0 1]);   % put the triggers to 1, indices are HwLines +1
    putvalue(HW.DIO.Line(7),[0]);
    
    HW.params.PawSign=-1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize the KHFIlter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Cannot set the cutoff frequencies of Krohn-hite directly. Krohn-hite
    % does not let the cutoff frequency change by more than one digit. Must start
    % with a valid value and then change cutoffs progressively by a factor of
    % 10 until target value is reached.  The function setKHcutoff sets
    % filter cutoffs by following this procedure.
    HW.filter = khfilter(BaphyMainGuiItems('FilterGPIBAddress',globalparams)); % Set properties and fopen gpib
    init(HW.filter);
    setfilter(HW.filter, 'Channels', 'All', 'InputGain', 0, 'OutputGain', 0);
    setfilter(HW.filter,'Channels',1,'Frequency',HW.params.fsAO/2);
    setfilter(HW.filter,'Channels',3,'Frequency',20); % low frequency is 20??
    
    % do we really need to save the filter info??  commented out for now.
    % filterinfo = setfilter(HW.filter,'Channels',3,'Frequency',stimparam.lfreq);
    % save(fullfile(trialdir,[fname '.filt.mat']),'filterinfo');
    %
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize the HP mux switch
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hpmux_obj =  hpmux;
    fopen(hpmux_obj);
    fprintf(hpmux_obj,config('hpmux'));
    if isfield(globalparams,'TuningCurve') && strcmpi(globalparams.TuningCurve,'yes')
      fprintf(hpmux_obj,config('hpmux','close',['101']));
    else
      fprintf(hpmux_obj,config('hpmux','close'));
    end
    
    fclose(hpmux_obj);
    delete(hpmux_obj);
    clear hpmux_obj;
    
    HW.Eqz = rpmequalizer;
    HW.Eqz = set(HW.Eqz,'IPAddress',BaphyMainGuiItems('EqualizerIPAddress',globalparams));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Communicate with alpha-omega machine for file saving/syncing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % start with TCPIP connection to alpha omega. This has an issue now, if the
    % connection is already established, it crashes. This has to be solved...
    % Establish the connection only if needed, not for behaviour and test:
    
    % do not start the acquisition if only doing behavior
    if doingphysiology,
      
      switch globalparams.HWSetup
        
        case 3
          
          %%%%%%%%AlphaLab%%%%%%%%%%%
          HW.aw=awtcpip; %Determine the AW connection
          [HW.aw,awerr]=init(HW.aw);  %Make the AW connection
          if ~awerr
            fwrite(HW.aw,'StopAcq'); %if acquisition is already running, stop it
          else
            ShutdownHW(HW);
            error('AW connect error');
          end
          
          % start the acquisition
          fwrite(HW.aw,'StartAcq');
          
          % ie, map filename is XXXX.m converted to XXXX.map
          [maptempfile,mapfpath]=basename(globalparams.mfilename);
          mapfpath=[mapfpath 'raw' filesep]
          maptempfile=[maptempfile 'ap'];
          
          fprintf('AW saving to: %s%s\n',mapfpath,maptempfile);
          fwrite(HW.aw,'StartSave',maptempfile,mapfpath);
          
        case 11
          %%%%%%%%SnR%%%%%%%%%%%
          path(path,'c:\code\baphy\Hardware\SnR_comm')
          InternetMac='1C:6F:65:D9:20:D6';
          AlphaConnectMac='00:50:43:00:E6:A4';
          DSPMAC='00:21:ba:13:84:2a';
          AdapterIndex=0;
          retStartConnection=AO_startConnection(DSPMAC,AlphaConnectMac,AdapterIndex);
          
          for j=1:100,
            pause(1);
            ret=AO_IsConnected;
            if ret==1
              'The SnR System is Connected'
              break;
            end
          end
          
          
          % start the acquisition
          [maptempfile,mapfpath]=basename(globalparams.mfilename);
          mapfpath=[mapfpath 'raw' filesep]
          mapfpath=['c:\Data',mapfpath(findstr(mapfpath,':')+1:end)];
          maptempfile=maptempfile(1:findstr(maptempfile,'.')-1);
          ret=AO_SetSavePath(mapfpath);
          ret=AO_SetSaveFileName(maptempfile);
          for j=1:100,
            pause(1);
            ret=AO_StartSave;
            if ret==0
              fprintf('AW saving to: %s%s\n',mapfpath,maptempfile);
              break;
            end
          end
          
      end
    end
    
  case 5 % HTB1, HOLDER TRAINING BOOTH
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Analog output for Sound output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize the attenuator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    HW.Atten = attenuator;
    init(HW.Atten);% Set properties and fopen gpib
    attenuate(HW.Atten,60);% Set attenuation to 0db
    
    % Analog Output:
    % channel 0 is the actual experiment sound
    % channel 1 is the trigger for function generator.
    HW.AO = analogoutput('nidaq',1);
    addchannel(HW.AO,[0 1],{'SoundOutL','SoundOutR'});
    % set this depending on globalparams.A0TriggerType:
    set(HW.AO,'TriggerType',HW.params.AOTriggerType);
    set(HW.AO,'TransferMode','DualDMA');
    set(HW.AO,'SampleRate',HW.params.fsAO);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Analog input for lick and/or spikes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    aichannel = [2 0 3];
    ainames = {'Touch','Paw','Microphone'};  % no spikes on training setup
    HW.AI  = analoginput('nidaq',1);       % Create object DAQ.AI - NI Daq(2)
    HW.params.AInames = ainames;
    hwAnIn  = addchannel(HW.AI,aichannel,ainames);     % Add the h/w line
    set(HW.AI,'InputType','NonReferencedSingleEnded');    % Single ended input
    set(HW.AI,'DriveAISenseToGround','On'); % Do not use DAQ.AI sense to ground
    set(HW.AI,'SampleRate',HW.params.fsAI);           % Sample rate
    set(hwAnIn,'InputRange',[-10 10]);      % Output from Amplifiers
    set(hwAnIn,'SensorRange',[-10 10]);     % for evp data set to
    set(hwAnIn,'UnitsRange',[-10 10]);      % [-10 10]Volts
    set(HW.AI,'TriggerType','HwDigital');         % Trigger type=Manual
    set(HW.AI,'LoggingMode','Memory');
    %     % This is a hack: Assuming that you never want more than 10 second long
    %     % trials
    %     set(HW.AI,'SamplesPerTrigger',HW.params.fsAI*10);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize digital i/o
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    HW.DIO  = digitalio('nidaq',1);
    addline(HW.DIO,0:1,'Out',{'Shock','Light'});    % Shock Light and Shock Switch
    
    hwDiAT  = addline(HW.DIO,2,'Out','Pump');   % Pump
    addline(HW.DIO,3,'In','Touch');       % touch input
    addline(HW.DIO,4:5,'Out',{'TrigAO','TrigAI'});    % Trigger for AI and AO
    addline(HW.DIO,6,'Out',{'LED'});   % Confirm save, and filesave
    addline(HW.DIO,7,'IN',{'Paw'});   % Paw press input
    
    % conflict for pump control. what can be replaced????
    %hwDiOut = addline(HW.DIO,5,'Out','Pump');      % Water Pump
    
    % initialze DIO outputs
    start(HW.DIO);
    putvalue(HW.DIO.Line(1:3),0);
    putvalue(HW.DIO.Line(5:6),[1 1]);   % put the triggers to 1, indices are HwLines +1
    putvalue(HW.DIO.Line(7),[0]);
    
    HW.params.PawSign=1;        % initialze DIO outputs
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize the KHFIlter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Cannot set the cutoff frequencies of Krohn-hite directly. Krohn-hite
    % does not let the cutoff frequency change by more than one digit. Must start
    % with a valid value and then change cutoffs progressively by a factor of
    % 10 until target value is reached.  The function setKHcutoff sets
    % filter cutoffs by following this procedure.
    % spr1 filter is at 22, spr3 filter is at address 23. you can
    % actually see the GPIB address bu pressing the appropriate keys on
    % the filter:
    HW.filter = khfilter(BaphyMainGuiItems('FilterGPIBAddress',globalparams)); % Set properties and fopen gpib
    init(HW.filter);
    setfilter(HW.filter, 'Channels', 'All', 'InputGain', 0, 'OutputGain', 0);
    setfilter(HW.filter,'Channels',1,'Frequency',2000);
    setfilter(HW.filter,'Channels',1,'Frequency',HW.params.fsAO/2);
    setfilter(HW.filter,'Channels',3,'Frequency',20); % low frequency is 20??
    %         %
    HW.Eqz = rpmequalizer;
    HW.Eqz = set(HW.Eqz,'IPAddress',BaphyMainGuiItems('EqualizerIPAddress',globalparams));
   
  case 6 % Kanold Lab Free Running box 1
    % Initialize Analog output for Sound output
    HW.AO = analogoutput('nidaq',0);
    addchannel(HW.AO,0,'SoundOut');
    
    % set this depending on globalparams.A0TriggerType:
    set(HW.AO,'TriggerType',HW.params.AOTriggerType);
    
    set(HW.AO,'TransferMode','DualDMA');
    % the following line is commented, until we decide how to set fs
    set(HW.AO,'SampleRate',HW.params.fsAO);
    
    % Line 1 is for touch input
    aichannel = [0 1];
    ainames = {'Paw','Touch'};  % no spikes on training setup
    HW.AI  = analoginput('nidaq',1);       % Create object DAQ.AI - NI Daq(2)
    hwAnIn  = addchannel(HW.AI,aichannel,ainames);     % Add the h/w line
    
    set(HW.AI,'InputType','SingleEnded');   % Single ended input
    set(HW.AI,'DriveAISenseToGround','On');  % Don't use DAQ.AI sense to ground
    set(HW.AI,'SampleRate',HW.params.fsAI);  % Sample rate
    set(hwAnIn,'InputRange',[-10 10]);      % Output from Amplifiers
    set(hwAnIn,'SensorRange',[-10 10]);     % for evp data set to
    set(hwAnIn,'UnitsRange',[-10 10]);      % [-10 10]Volts
    
    set(HW.AI,'TriggerType','HwDigital');         % Trigger type=Manual
    set(HW.AI,'LoggingMode','Memory');
    % This is a hack: Assuming that you never want more than 10 second trials
    set(HW.AI,'SamplesPerTrigger',HW.params.fsAI*10);
    
    % Initialize Digital IO
    % DAQ.DIO lines are as follows:
    % HwLines    Line index     Function
    % 0             1           Shock Light
    % 1             2           Shock (Shock switch and the shock)
    % 2             3           input for hits
    % 3             4           Trigger for DAQ.AI
    % 4             5           Trigger for DAQ.AO
    % 5             6           water pump
    % 6             7           LED
    % 7             8           touch/lick input??
    HW.DIO  = digitalio('nidaq',1);
    addline(HW.DIO,0:1,'Out',{'Light','Shock'});    % Shock Light and Shock Switch
    addline(HW.DIO,2,'In','Paw');       % bar press input
    addline(HW.DIO,3:4,'Out',{'TrigAI','TrigAO'});    % Trigger for AI and AO
    addline(HW.DIO,5,'Out','Pump');      % Water Pump
    addline(HW.DIO,6,'Out','LED');
    addline(HW.DIO,7,'In','Touch');       % Lick input
    putvalue(HW.DIO.Line(4:5),[0 0]);       % put the triggers to 1, indices are HwLines +1
    
    if globalparams.HWSetup==4,
      % sign is flipped to make bar up positive, bar down negative
      HW.params.PawSign=-1;
    end
    
  case 7 % CMB1, COSMIC MICROWAVE BACKGROUND AKA CHRONIC MULTICHANNEL BOOTH
    %% DIGITAL IO
    % Outputs on Ports 0 and 2 (Lines 0-7)
    DAQID = 'D0'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    HW.DIO  = digitalio('nidaq',DAQID);
    addline(HW.DIO,0,0,'Out','Light');                            % LED Center / General
    addline(HW.DIO,1,0,'Out','LightL');                           % LED Left
    addline(HW.DIO,2,0,'Out','LightR');                           % LED Right
    addline(HW.DIO,[3,4],0,'Out',{'TrigAI','TrigAO'});     % Trigger for AI and AO
    addline(HW.DIO,5,0,'Out','Pump');                        % Water Pump Center
    addline(HW.DIO,6,0,'Out','PumpL');                       % Water Pump Left (not connected yet)
    addline(HW.DIO,7,0,'Out','PumpR');                       % Water Pump Right (not connected yet)
    addline(HW.DIO,0,2,'Out','Shock');                       % Shock
    
    putvalue(HW.DIO.Line(IOGetIndex(HW.DIO,{'TrigAI','TrigAO'})),[1 1]);       % put the triggers to 1
    % Inputs on Port 1 (Lines 0-7) NOTE: PFI3 Triggers the Analog Output
    TouchChannels = [5,6,7];
    TouchNames = {'Touch','TouchL','TouchR'};
    for iT = 1:length(TouchChannels)
      addline(HW.DIO,TouchChannels(iT),1,'In',TouchNames{iT}); 
    end
     
    %% ANALOG
    TriggerCondition = 'NegativeEdge';
    
    %% ANALOG INPUT
    aichannel = [0,3 TouchChannels];
    ainames = {'Paw','Microphone',TouchNames{:}};
    HW.params.AInames = ainames;
    HW.AI  = analoginput('nidaq',DAQID);       
    set(HW.AI,'InputType','SingleEnded');    % Single ended input
    set(HW.AI,'DriveAISenseToGround','On'); % Do not use DAQ.AI sense to ground
    set(HW.AI,'SampleRate',HW.params.fsAI);           % Sample rate
    AIChannels = addchannel(HW.AI,aichannel,ainames);     % Add the h/w line
    set(AIChannels,'InputRange',[-10 10]);      % Output from Amplifiers
    set(AIChannels,'SensorRange',[-10 10]);     % for evp data set to
    set(AIChannels,'UnitsRange',[-10 10]);      % [-10 10] Volts
    set(HW.AI,'TriggerType','HwDigital','HwDigitalTriggerSource','PFI0');
    set(HW.AI,'LoggingMode','Memory','TriggerCondition',TriggerCondition);
    
    %% ANALOG OUTPUT
    HW.AO = analogoutput('nidaq',DAQID);
    addchannel(HW.AO,0,'SoundOut');
    addchannel(HW.AO,1,'LightOut');
    
    set(HW.AO,'TriggerType',HW.params.AOTriggerType,...
    'HWDigitalTriggerSource','PFI1',...
      'SampleRate',HW.params.fsAO,'TriggerFcn','','TriggerCondition',TriggerCondition); %{@CBF_Trigger});
    set(HW.AO,'ExternalTriggerDriveLine','RTSI0');
   
    %% SETUP SPEAKER CALIBRATION
    HW.Calibration.Speaker = 'FreeFieldCMB1';
    HW.Calibration.Microphone = 'BK4944A';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
   
    % no filter, so use higher AO sampling rate in some sound objects:
    FORCESAMPLINGRATE=[];

    %% COMMUNICATE WITH MANTA
    if doingphysiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
    
  case 8 % SPR2 WITH MANTA
    
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize the attenuator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    HW.Atten = attenuator;
    init(HW.Atten);% Set properties and fopen gpib
    attenuate(HW.Atten,60);% Set attenuation to 0db
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Analog output for Sound output
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AO setup should be identical to training rig except AO channel is 1
    % rather than 0
    HW.AO = analogoutput('nidaq',1);
    if isfield(globalparams,'TuningCurve') && strcmpi(globalparams.TuningCurve,'yes')
      addchannel(HW.AO,0,'TCTrig');
    else
      addchannel(HW.AO,1,'SoundOut');
    end
    % set this depending on globalparams.A0TriggerType:
    set(HW.AO,'TriggerType',HW.params.AOTriggerType);
    
    set(HW.AO,'TransferMode','DualDMA');
    % the following line is commented, until we decide how to set fs
    set(HW.AO,'SampleRate',HW.params.fsAO);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize Analog input for lick and/or spikes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Line 1 is for touch input
    % currently ignoring what behavior the animal is actually doing and
    % always recording both lines. is this a problem?
    aichannel = [0 1 3];
    ainames = {'Touch','Paw','Microphone'};  % no spikes on training setup
    HW.AI  = analoginput('nidaq',1);       % Create object DAQ.AI - NI Daq(2)
    hwAnIn  = addchannel(HW.AI,aichannel,ainames);     % Add the h/w line
    
    set(HW.AI,'InputType','NonReferencedSingleEnded');    % Single ended input
    set(HW.AI,'DriveAISenseToGround','On'); % Do not use DAQ.AI sense to ground
    set(HW.AI,'SampleRate',HW.params.fsAI);           % Sample rate
    set(hwAnIn,'InputRange',[-10 10]);      % Output from Amplifiers
    set(hwAnIn,'SensorRange',[-10 10]);     % for evp data set to
    set(hwAnIn,'UnitsRange',[-10 10]);      % [-10 10]Volts
    set(HW.AI,'TriggerType','HwDigital');         % Trigger type=Manual
    set(HW.AI,'TriggerCondition','PositiveEdge');
    % log to memory only on training rig (not saving raw spike data)
    set(HW.AI,'LoggingMode','Memory');
    
    % The following lines specify where analoginput data should be logged:
    %set(HW.AI,'LoggingMode','Disk&Memory')   % Log the data in file and memory
    %set(HW.AI,'LogToDiskMode','Index')
    % It needs a name for the directory. Commented for now:
    % fname   = get(trialtags,'Experiment');
    % ferretname = get(trialtags,'Ferret');
    % ferretname = ferretname{1}{1};
    % trialdir = [config('datapath') filesep ferretname];
    % evpdaq = [trialdir '\tmp\' fname '.daq.tmp'];
    % set(HW.AI,'LogFileName',evpdaq);
    
    % This is a hack: Assuming that you never want more than 10 second long
    % trials
    set(HW.AI,'SamplesPerTrigger',HW.params.fsAI*10);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize digital i/o
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    HW.DIO  = digitalio('nidaq',1);
    addline(HW.DIO,0:1,'Out',{'Shock','Light'});    % Shock Light and Shock Switch
    
    % think this is some leftover thing from pre-alphaomega days, replaced
    % with pump control SVD 2006-04-25
    %hwDiAT  = addline(HW.DIO,2,'Out','AmpTrigger');   % Phys Amp  ?? what is this
    hwDiAT  = addline(HW.DIO,2,'Out','Pump');   % Pump
    addline(HW.DIO,3,'In','Touch');       % touch input
    addline(HW.DIO,4:5,'Out',{'TrigAI','TrigAO'});    % Trigger for AI and AO
    % May 2008, FileSave was merged with TrigerAI to free up a line for
    % stimulation palse:
    %         addline(HW.DIO,6,'Out',{'FileSave'});   % Confirm save, and filesave
    addline(HW.DIO,6,'Out',{'Stimulation'});   % Confirm save, and filesave
    addline(HW.DIO,7,'Out',{'LED'});   % Confirm save, and filesave
    
    % conflict for pump control. what can be replaced????
    %hwDiOut = addline(HW.DIO,5,'Out','Pump');      % Water Pump
    
    % initialze DIO outputs
    start(HW.DIO);
    putvalue(HW.DIO.Line(1:3),0);
    putvalue(HW.DIO.Line(5:6),[0 1]);   % put the triggers to 1, indices are HwLines +1
    putvalue(HW.DIO.Line(7),[0]);
    
    HW.params.PawSign=-1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize the KHFIlter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Cannot set the cutoff frequencies of Krohn-hite directly. Krohn-hite
    % does not let the cutoff frequency change by more than one digit. Must start
    % with a valid value and then change cutoffs progressively by a factor of
    % 10 until target value is reached.  The function setKHcutoff sets
    % filter cutoffs by following this procedure.
    HW.filter = khfilter(BaphyMainGuiItems('FilterGPIBAddress',globalparams)); % Set properties and fopen gpib
    init(HW.filter);
    setfilter(HW.filter, 'Channels', 'All', 'InputGain', 0, 'OutputGain', 0);
    setfilter(HW.filter,'Channels',1,'Frequency',HW.params.fsAO/2);
    setfilter(HW.filter,'Channels',3,'Frequency',20); % low frequency is 20??
    
    % do we really need to save the filter info??  commented out for now.
    % filterinfo = setfilter(HW.filter,'Channels',3,'Frequency',stimparam.lfreq);
    % save(fullfile(trialdir,[fname '.filt.mat']),'filterinfo');
    %
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize the HP mux switch
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hpmux_obj =  hpmux;
    fopen(hpmux_obj);
    fprintf(hpmux_obj,config('hpmux'));
    if isfield(globalparams,'TuningCurve') && strcmpi(globalparams.TuningCurve,'yes')
      fprintf(hpmux_obj,config('hpmux','close',['101']));
    else
      fprintf(hpmux_obj,config('hpmux','close'));
    end
    
    fclose(hpmux_obj);
    delete(hpmux_obj);
    clear hpmux_obj;
    
    HW.Eqz = rpmequalizer;
    HW.Eqz = set(HW.Eqz,'IPAddress',BaphyMainGuiItems('EqualizerIPAddress',globalparams));

    if doingphysiology
      
      [HW,globalparams] = IOConnectWithManta(HW,globalparams);
      
    end
   
  case 10 % MOUSE RIG IN BIO PSYCH
    %% DIGITAL IO
    % Outputs on Port 0 (Lines 0-7)
    DAQID = 'D0'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    HW.DIO  = digitalio('nidaq',DAQID);
    addline(HW.DIO,0,0,'Out','Light');                            % LED Center / General
    addline(HW.DIO,[3,4],0,'Out',{'TrigAI','TrigAO'});     % Trigger for AI and AO
    addline(HW.DIO,5,0,'Out','Pump');                        % Water Pump Center
    
    putvalue(HW.DIO.Line(IOGetIndex(HW.DIO,{'TrigAI','TrigAO'})),[1 1]);       % put the triggers to 1
    % Inputs on Port 1 (Lines 0-7)
    TouchChannels = [5];
    TouchNames = {'Touch'};
    for iT = 1:length(TouchChannels)
      addline(HW.DIO,TouchChannels(iT),1,'In',TouchNames{iT}); 
    end
     
    %% ANALOG
    TriggerCondition = 'PositiveEdge';
    
    %% ANALOG INPUT
    aichannel = [0,3 TouchChannels];
    ainames = {'Paw','Microphone',TouchNames{:}};
    HW.params.AInames = ainames;
    HW.AI  = analoginput('nidaq',DAQID);       
    set(HW.AI,'InputType','SingleEnded');    % Single ended input
    set(HW.AI,'DriveAISenseToGround','On'); % Do not use DAQ.AI sense to ground
    set(HW.AI,'SampleRate',HW.params.fsAI);           % Sample rate
    AIChannels = addchannel(HW.AI,aichannel,ainames);     % Add the h/w line
    set(AIChannels,'InputRange',[-10 10]);      % Output from Amplifiers
    set(AIChannels,'SensorRange',[-10 10]);     % for evp data set to
    set(AIChannels,'UnitsRange',[-10 10]);      % [-10 10] Volts
    set(HW.AI,'TriggerType','HwDigital','HwDigitalTriggerSource','PFI0');
    set(HW.AI,'LoggingMode','Memory','TriggerCondition',TriggerCondition);
    
    %% ANALOG OUTPUT
    HW.AO = analogoutput('nidaq',DAQID);
    addchannel(HW.AO,0,'SoundOut');
    addchannel(HW.AO,1,'LightOut');
    
    set(HW.AO,'TriggerType',HW.params.AOTriggerType,'HWDigitalTriggerSource','PFI1',...
      'SampleRate',HW.params.fsAO,'TriggerFcn','','TriggerCondition',TriggerCondition); 
    set(HW.AO,'ExternalTriggerDriveLine','RTSI0');
   
    %%  CONFIGURE STIMULATION
    HW = InitializeStimulation(HW,'Starts',[0.1],'Durations',0.0001,'Voltages',5)  
    
    %% SETUP SPEAKER CALIBRATION
    HW.Calibration.Speaker = 'FostexT90';
    HW.Calibration.Microphone = 'BK4944A';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
    
    % no filter, so use higher AO sampling rate in some sound objects:
    FORCESAMPLINGRATE=[];

    %% COMMUNICATE WITH MANTA
    if doingphysiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
   
  case 12 % Innerv8, the rig in AVW 2202 main room setup to use both MEAs and MTs.
    %% DIGITAL IO
    % Outputs on Ports 0 and 2 (Lines 0-7)
    DAQID = 'D0'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    HW.DIO  = digitalio('nidaq',DAQID);
    addline(HW.DIO,0,0,'Out','Light');                            % LED Center / General
    addline(HW.DIO,[3,4],0,'Out',{'TrigAI','TrigAO'});     % Trigger for AI and AO
    addline(HW.DIO,5,0,'Out','Pump');                        % Water Pump Center
    addline(HW.DIO,0,2,'Out','Shock');                       % Shock
    
    putvalue(HW.DIO.Line(IOGetIndex(HW.DIO,{'TrigAI','TrigAO'})),[1 1]);       % put the triggers to 1
    % Inputs on Port 1 (Lines 0-7) NOTE: PFI3 Triggers the Analog Output
    TouchChannels = [5];
    TouchNames = {'Touch'};
    for iT = 1:length(TouchChannels)
      addline(HW.DIO,TouchChannels(iT),1,'In',TouchNames{iT});
    end
    
    %% ANALOG
    TriggerCondition = 'PositiveEdge';
    
    %% ANALOG INPUT
    aichannel = [0,3 TouchChannels];
    ainames = {'Paw','Microphone',TouchNames{:}};
    HW.params.AInames = ainames;
    HW.AI  = analoginput('nidaq',DAQID);
    set(HW.AI,'InputType','SingleEnded');    % Single ended input
    set(HW.AI,'DriveAISenseToGround','On'); % Do not use DAQ.AI sense to ground
    set(HW.AI,'SampleRate',HW.params.fsAI);           % Sample rate
    AIChannels = addchannel(HW.AI,aichannel,ainames);     % Add the h/w line
    set(AIChannels,'InputRange',[-10 10]);      % Output from Amplifiers
    set(AIChannels,'SensorRange',[-10 10]);     % for evp data set to
    set(AIChannels,'UnitsRange',[-10 10]);      % [-10 10] Volts
    set(HW.AI,'TriggerType','HwDigital','HwDigitalTriggerSource','PFI0');
    set(HW.AI,'LoggingMode','Memory','TriggerCondition',TriggerCondition);
    
    
    %% ANALOG OUTPUT
    HW.AO = analogoutput('nidaq',DAQID);
    addchannel(HW.AO,0,'SoundOut');
    addchannel(HW.AO,1,'LightOut');
    
    set(HW.AO,'TriggerType',HW.params.AOTriggerType,...
      'HWDigitalTriggerSource','PFI1',...
      'SampleRate',HW.params.fsAO,'TriggerFcn','','TriggerCondition',TriggerCondition); %{@CBF_Trigger});
    set(HW.AO,'ExternalTriggerDriveLine','RTSI0');
    
    %% SETUP SPEAKER CALIBRATION
    HW.Calibration.Speaker = 'FreeFieldInnerv8';
    HW.Calibration.Microphone = 'BK4944A';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
    
    % no filter, so use higher AO sampling rate in some sound objects:
    FORCESAMPLINGRATE=[];
    
    %% COMMUNICATE WITH MANTA
    if doingphysiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
    
    
end % END SWITCH

if isfield(HW,'MANTA')
  HW.params.DAQSystem = 'MANTA'; 
else
  HW.params.DAQSystem = 'AO';
end
globalparams.HWparams = HW.params;

function CBF_Trigger(obj,event)
[TV,TS] = datenum2time(now); fprintf([' >> Trigger received (',TS{1},')\n']); 

