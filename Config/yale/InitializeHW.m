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
HW.params.MaxTrialLen=30;  % 30 seconds.  Is this long enough? remember Fiser!
HW.params.SoftwareAtten=1;
HW.params.driver = 'NIDAQMX';  % versus default 'DAQTOOLBOX';
HW.params.syncAIAO=1;

if isfield(globalparams,'EqualizerCurve'),
   HW.params.SoftwareEqz=globalparams.EqualizerCurve;
else
   HW.params.SoftwareEqz=0;
end
HW.params.driver = 'NIDAQMX';  % versus default 'DAQTOOLBOX';
switch upper(computer),
   case 'PCWIN',
       HW.params.ptrType='uint32Ptr';
       HW.params.longType='uint32Ptr';
   case 'PCWIN64',
       HW.params.ptrType='voidPtrPtr';
       HW.params.longType='ulongPtr';
end
HW.params.SHOW_ERR_WARN=1;

% need to add support for 64-bit here?
HW.nidaqparams = loadnidaqmx;

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

% Based on the hardware setup, start the initialization:
switch globalparams.HWSetup
    
    case 0 % TEST MODE
        % create an audioplayer object which lets us control
        % start, stop, smapling rate , etc.
        HW.AO = audioplayer(rand(4000,1), HW.params.fsAO);
        HW.AI = HW.AO;
        HW.DIO.Line.LineName = {'Touch','TouchL','TouchR'};
        
    case 1,  % TRAINING BOOTH A -- ripped off of NSL HWSetup 7
        %% DIGITAL IO
        % Outputs on Ports 0 and 2 (Lines 0-7)
        DAQID = 'Dev2'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
        niResetDevice(DAQID);
        
        HW=niCreateDO(HW,DAQID,'port0/line0:1','TrigAI,TrigAO','InitState',[0 0]);
        HW=niCreateDO(HW,DAQID,'port0/line2','Pump2','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line4','Shock','InitState',0);
        
        HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
	    HW=niCreateDI(HW,DAQID,'port0/line6','walkD');
        
        %% ANALOG INPUT
        HW=niCreateAI(HW,DAQID,'ai0:4','Touch,Microphone,walk1,walk2,walkDA','/Dev2/PFI1');
        HW.AI(end).TriggerDIO=[1,1];
        
        %% ANALOG OUTPUT
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut,LightOut','/Dev2/PFI1');
        HW.AO(end).TriggerDIO=[1,2];
        
        %% SETUP SPEAKER CALIBRATION
        %HW.Calibration.Speaker = 'FreeFieldCMB1';
        %HW.Calibration.Microphone = 'BK4944A';
        %HW.Calibration = IOLoadCalibration(HW.Calibration);
        
        % no filter, so use higher AO sampling rate in some sound objects:
        FORCESAMPLINGRATE=[];
        
    case 2,  % TRAINING BOOTH B -- ripped off of NSL HWSetup 7
        %% DIGITAL IO
        % Outputs on Ports 0 and 2 (Lines 0-7)
        DAQID = 'Dev3'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
        niResetDevice(DAQID);
        
        HW=niCreateDO(HW,DAQID,'port0/line0:1','TrigAI,TrigAO','InitState',[0 0]);
        HW=niCreateDO(HW,DAQID,'port0/line2','Pump2','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line4','Shock','InitState',0);
        
        HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
        HW=niCreateDI(HW,DAQID,'port0/line6','walkD');
        
        %% ANALOG INPUT
        HW=niCreateAI(HW,DAQID,'ai0:4','Touch,Microphone,walk1,walk2,walkDA','/Dev3/PFI1');
        HW.AI(end).TriggerDIO=[1,1];
        
        %% ANALOG OUTPUT
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut,LightOut','/Dev3/PFI1');
        HW.AO(end).TriggerDIO=[1,2];
        
        %% SETUP SPEAKER CALIBRATION
        %HW.Calibration.Speaker = 'FreeFieldCMB1';
        %HW.Calibration.Microphone = 'BK4944A';
        %HW.Calibration = IOLoadCalibration(HW.Calibration);
        
        % no filter, so use higher AO sampling rate in some sound objects:
        FORCESAMPLINGRATE=[];
        
     case 3,  % TRAINING BOOTH C -- ripped off of NSL HWSetup 7
        %% DIGITAL IO
        % Outputs on Ports 0 and 2 (Lines 0-7)
        DAQID = 'Dev1'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
        niResetDevice(DAQID);
        
        HW=niCreateDO(HW,DAQID,'port0/line0:1','TrigAI,TrigAO','InitState',[0 0]);
        HW=niCreateDO(HW,DAQID,'port0/line2','Pump2','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line4','Shock','InitState',0);
        
        HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
        HW=niCreateDI(HW,DAQID,'port0/line6','walkD');
        
        %% ANALOG INPUT
        HW=niCreateAI(HW,DAQID,'ai0:4','Touch,Microphone,walk1,walk2,walkDA','/Dev1/PFI1');
        HW.AI(end).TriggerDIO=[1,1];
        
        %% ANALOG OUTPUT
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut,LightOut','/Dev1/PFI1');
        HW.AO(end).TriggerDIO=[1,2];
        
        %% SETUP SPEAKER CALIBRATION
        %HW.Calibration.Speaker = 'FreeFieldCMB1';
        %HW.Calibration.Microphone = 'BK4944A';
        %HW.Calibration = IOLoadCalibration(HW.Calibration);
        
        % no filter, so use higher AO sampling rate in some sound objects:
        FORCESAMPLINGRATE=[];
        
      case 4,  % TRAINING BOOTH D -- ripped off of NSL HWSetup 7
        %% DIGITAL IO
        % Outputs on Ports 0 and 2 (Lines 0-7)
        DAQID = 'Dev2'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
        niResetDevice(DAQID);
        
        HW=niCreateDO(HW,DAQID,'port0/line0:1','TrigAI,TrigAO','InitState',[0 0]);
        HW=niCreateDO(HW,DAQID,'port0/line2','Pump2','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line4','Shock','InitState',0);
        
        HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
        HW=niCreateDI(HW,DAQID,'port0/line6','walkD');
        
        %% ANALOG INPUT
        HW=niCreateAI(HW,DAQID,'ai0:4','Touch,Microphone,walk1,walk2,walkDA','/Dev2/PFI1');
        HW.AI(end).TriggerDIO=[1,1];
        
        %% ANALOG OUTPUT
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut,LightOut','/Dev2/PFI1');
        HW.AO(end).TriggerDIO=[1,2];
        
        %% SETUP SPEAKER CALIBRATION
        %HW.Calibration.Speaker = 'FreeFieldCMB1';
        %HW.Calibration.Microphone = 'BK4944A';
        %HW.Calibration = IOLoadCalibration(HW.Calibration);
        
        % no filter, so use higher AO sampling rate in some sound objects:
        FORCESAMPLINGRATE=[];

      case 5,  % Recording Setup -- ripped off of NSL HWSetup 7
        %% DIGITAL IO
        % Outputs on Ports 0 and 2 (Lines 0-7)
        DAQID = 'Dev1'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
        niResetDevice(DAQID);
        
        HW=niCreateDO(HW,DAQID,'port0/line0:1','TrigAI,TrigAO','InitState',[0 0]);
        HW=niCreateDO(HW,DAQID,'port0/line2','Pump2','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
        HW=niCreateDO(HW,DAQID,'port0/line4','Shock','InitState',0);
        
        HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
        HW=niCreateDI(HW,DAQID,'port0/line6','walkD');
        
        %% ANALOG INPUT
        HW=niCreateAI(HW,DAQID,'ai0:4','Touch,Microphone,walk1,walk2,walkDA','/Dev1/PFI1');
        HW.AI(end).TriggerDIO=[1,1];
        
        %% ANALOG OUTPUT
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut,LightOut','/Dev1/PFI1');
        HW.AO(end).TriggerDIO=[1,2];
        
        %% SETUP SPEAKER CALIBRATION
        %HW.Calibration.Speaker = 'FreeFieldCMB1';
        %HW.Calibration.Microphone = 'BK4944A';
        %HW.Calibration = IOLoadCalibration(HW.Calibration);
        
        % no filter, so use higher AO sampling rate in some sound objects:
        FORCESAMPLINGRATE=[];
        
%     case 6,  % LARGE SOUND BOOTH 1 -- ripped off of NSL HWSetup 7
%         % Copy NI settings from above
%         
%         %% COMMUNICATE WITH MANTA
%         if doingphysiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
        
end % END SWITCH

if isfield(HW,'MANTA')
  HW.params.DAQSystem = 'MANTA'; 
else
  HW.params.DAQSystem = 'AO';
end
globalparams.HWparams = HW.params;

function CBF_Trigger(obj,event)
[TV,TS] = datenum2time(now); fprintf([' >> Trigger received (',TS{1},')\n']); 

