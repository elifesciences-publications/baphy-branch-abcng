function [HW, globalparams] = InitializeHW (globalparams)
% function HW = InitializeHW (globalparams);
%
% InitializeHW initializes the hardware based on which hardware setup is
% used and the parameters of the experiments specified in globalparams.
% Specific values are now lab-dependent.  The range of possible HWSetup
% values is specified in BaphyMainGuiItems (also lab-dependent)
%
% Nima, original November 2005
% SVD, lab specific setups 2012-05
%

global FORCESAMPLINGRATE

if ~exist('globalparams','var')
    globalparams=struct();
end
if ~isfield(globalparams,'HWSetup'),
    globalparams.HWSetup=0;
end
if ~isfield(globalparams,'Physiology'),
    globalparams.Physiology='No';
end

% create a default HW structure
HW=HWDefaultNidaq(globalparams);

doingphysiology = ~strcmp(globalparams.Physiology,'No');

% Based on the hardware setup, start the initialization:
switch globalparams.HWSetup
  
  case 0 % TEST MODE
    % create an audioplayer object which lets us control
    % start, stop, smapling rate , etc.
    HW.AO = audioplayer(rand(4000,1), HW.params.fsAO);
    %HW=IOMicTTLSetup(HW);
    %start(HW.AI);
    HW.DIO.Line.LineName = {'Touch','TouchL','TouchR'};
    
  case 1,  % (SB-1) SMALL BOOTH 1

    DAQID = 'Dev1'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    niResetDevice(DAQID);
    
    %% DIGITAL IO
    HW=niCreateDO(HW,DAQID,'port0/line0:1','TrigAI,TrigAO','InitState',[0 0]);
    HW=niCreateDO(HW,DAQID,'port0/line2','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line4','Shock','InitState',0);

    HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
    
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:1','Touch,Microphone','/Dev1/PFI0');
    
    %% ANALOG OUTPUT
    HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut1,SoundOut2','/Dev1/PFI1');
    
    %% SETUP SPEAKER CALIBRATION
    %HW.Calibration.Speaker = 'FreeFieldCMB1';
    %HW.Calibration.Microphone = 'BK4944A';
    %HW.Calibration = IOLoadCalibration(HW.Calibration);
   
    % no filter, so use higher AO sampling rate in some sound objects:
    FORCESAMPLINGRATE=[];

  case {2,3},  % (LB-1) LARGE SOUND BOOTH 1 -- Copied mostly from SB-1
      % setup 2 = audio channel 1 (AO0) on Right
      % setup 3 = audio channel 2 (AO0) on Left

    DAQID = 'Dev1'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    niResetDevice(DAQID);

    %% DIGITAL IO
    % "TrigAI" and "TrigAO" are special identifiers for DIO lines used to
    % trigger analog in and out, respectively.
    HW=niCreateDO(HW,DAQID,'port0/line0:2','TrigAI,TrigAO,TrigAIInv','InitState',[0 0 1]);
    % port0/line2 reserved for inverse TrigAI
    HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
    HW=niCreateDI(HW,DAQID,'port0/line4','Touch');
    HW=niCreateDO(HW,DAQID,'port0/line5','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line6','Light2','InitState',1);
    HW=niCreateDO(HW,DAQID,'port0/line7','Light3','InitState',0);
    %HW=niCreateDO(HW,DAQID,'port0/line4','Shock','InitState',0);
    
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:1','Touch,Microphone','/Dev1/PFI0');
    
    %% ANALOG OUTPUT
    if globalparams.HWSetup==2
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut1,SoundOut2','/Dev1/PFI1');
    else
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut2,SoundOut1','/Dev1/PFI1');
    end
    
    % no filter, so use higher AO sampling rate in some sound objects:
    FORCESAMPLINGRATE=[];
    
    HW.params.SoftwareEqz(:)=1.5;
    
    %% COMMUNICATE WITH MANTA
    if doingphysiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
    
  case {4,5},  % (LB-2) LARGE SOUND BOOTH 2
      % setup 4 = audio channel 1 (AO0) on Right
      % setup 5 = audio channel 2 (AO0) on Left

    DAQID = 'Dev1'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    niResetDevice(DAQID);

    %% DIGITAL IO
    % "TrigAI" and "TrigAO" are special identifiers for DIO lines used to
    % trigger analog in and out, respectively.
    HW=niCreateDO(HW,DAQID,'port0/line0:2','TrigAI,TrigAO,TrigAIInv','InitState',[0 0 1]);
    % port0/line2 reserved for inverse TrigAI
    HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
    HW=niCreateDI(HW,DAQID,'port0/line4','Touch');
    HW=niCreateDO(HW,DAQID,'port0/line5','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line6','Light2','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line7','Light3','InitState',0);
    %HW=niCreateDO(HW,DAQID,'port0/line4','Shock','InitState',0);
    
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:1','Touch,Microphone','/Dev1/PFI0');
    
    %% ANALOG OUTPUT
    if globalparams.HWSetup==4
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut1,SoundOut2','/Dev1/PFI1');
    else
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut2,SoundOut1','/Dev1/PFI1');
    end
    
    % no filter, so use higher AO sampling rate in some sound objects:
    FORCESAMPLINGRATE=[];
    
    HW.params.SoftwareEqz(:)=1.5;
    
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

