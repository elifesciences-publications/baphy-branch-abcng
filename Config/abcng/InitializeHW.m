function [HW, globalparams] = InitializeHW (globalparams)
% function HW = InitializeHW (globalparams);
%
% InitializeHW initializes the hardware based on which hardware setup is
% used and the parameters of the experiments specified in globalparams.
% Specific values are now lab-dependent.  The range of possible HWSetup
% values is specified in BaphyMainGuiItems (also lab-dependent)
%
% Nima, original November 2005
% BE, specific setup for ABCNG

global FORCESAMPLINGRATE

% create a default HW structure
HW=HWDefaultNidaq(globalparams);

Physiology = ~strcmp(globalparams.Physiology,'No');


% Based on the hardware setup, start the initialization:
switch globalparams.HWSetup
  
  case 0 % TEST MODE
    % create an audioplayer object which lets us control start, stop, sampling rate
    HW.AO = audioplayer(rand(4000,1), HW.params.fsAO);
    HW.AI = HW.AO;
    HW.DIO.Line.LineName = {'Touch','TouchL','TouchR'};
  case 1 % ALL RECORDING BOOTHS SHOULD REMAIN IDENTICAL AS LONG AS POSSIBLE
    SetupNames = {'SB1','SB2','LB1'};
    HW.TwoSpeakers = 1;
    HW.TwoAFCsetup = 1;  % Indicates there are 2 spouts (not necessarly 2 speakers)
    HW.TwoAFCtask= 0;      % By default, the task is Go/NoGo
    globalparams.HWSetupName = SetupNames{globalparams.HWSetup};
    
    DAQID = 'D0'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    niResetDevice(DAQID);
    
    %% DIGITAL IO
    HW=niCreateDO(HW,DAQID,'port0/line0:1,port2/line0:1','TrigAI,TrigAO,TrigAIInv,TrigAOInv','InitState',[0 0 1 1]);
    HW=niCreateDO(HW,DAQID,'port1/line4','PumpR','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line5','PumpL','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line7','Pump','InitState',0);
    HW=niCreateDI(HW,DAQID,'port0/line6','Light');
    HW=niCreateDI(HW,DAQID,'port0/line2','TouchR');
    HW=niCreateDI(HW,DAQID,'port0/line5','TouchL');
    %   HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:2','TouchL,Microphone,TouchR',['/',DAQID,'/PFI0']);
    
    %% ANALOG OUTPUT
    HW=niCreateAO(HW,DAQID,'ao0:1','SoundOutL,SoundOutR',['/',DAQID,'/PFI1']);
    
    %% SETUP SPEAKER CALIBRATION
    HW.Calibration(1).Speaker = ['RSR',globalparams.HWSetupName];
    HW.Calibration(1).Microphone = 'GRAS46BE';
    HW.Calibration(2).Speaker = ['RSL',globalparams.HWSetupName];
    HW.Calibration(2).Microphone = 'GRAS46BE';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
    
    %% COMMUNICATE WITH MANTA
    if Physiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
    
    
  case {2,3,5} % ALL RECORDING BOOTHS SHOULD REMAIN IDENTICAL AS LONG AS POSSIBLE
    SetupNames = {'SB1','SB2','LB1',[],'SB2Earphones'};
    globalparams.HWSetupName = SetupNames{globalparams.HWSetup};
    
    DAQID = 'D0'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    niResetDevice(DAQID);
    
    %% DIGITAL IO
    HW=niCreateDO(HW,DAQID,'port0/line0:1,port2/line0:1','TrigAI,TrigAO,TrigAIInv,TrigAOInv','InitState',[0 0 1 1]);
    HW=niCreateDO(HW,DAQID,'port0/line2','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line3','LightR','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line4','LightL','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line5','Pump','InitState',0);
    HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
    
    %% ANALOG INPUT
        HW=niCreateAI(HW,DAQID,'ai0:1','Touch,Microphone',['/',DAQID,'/PFI0']);
    
    %% ANALOG OUTPUT % 14/09-YB: rmv independant audio channels for introducing Opto
%         HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut,OptTrig',['/',DAQID,'/PFI1']);
    
    %% SETUP SPEAKER CALIBRATION
    switch globalparams.HWSetup
      case {3,5}
        HW=niCreateAO(HW,DAQID,'ao0','SoundOut,OptTrig',['/',DAQID,'/PFI1']); % for SB2 instead of changing set-up constantly, speaker and headphones are on different output 20/07/15 Jennifer
        HW.Calibration.Speaker = ['SHIE800',globalparams.HWSetupName];
      case 2
        HW=niCreateAO(HW,DAQID,'ao1','SoundOut,OptTrig',['/',DAQID,'/PFI1']);
        HW.Calibration.Speaker = ['RS',globalparams.HWSetupName];
    end
    HW.Calibration.Microphone = 'GRAS46BE';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
    
    %% COMMUNICATE WITH MANTA
    if Physiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
    
  case 4 % TWO PHOTON BOOTH IN BIOLOGY
    DAQID = 'D5'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    niResetDevice(DAQID);
    
    %% DIGITAL IO
    HW=niCreateDO(HW,DAQID,'port0/line0:1','TrigAI,TrigAO','InitState',[0,0]);
    HW=niCreateDO(HW,DAQID,'port0/line2','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line4','Shock','InitState',0);
    
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:1','Touch,Microphone',['/',DAQID,'/PFI8']);
    
    %% ANALOG OUTPUT
    HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut1,SoundOut2',['/',DAQID,'/PFI9']);
    
    HW.OPTICAL = struct([]);
    
  case {11} % Psychophysics Booth
    DAQID = 'D0'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    niResetDevice(DAQID);
    
    %% DIGITAL IO
    HW=niCreateDO(HW,DAQID,'port0/line0:1','TrigAI,TrigAO','InitState',[0 0]);
    HW=niCreateDO(HW,DAQID,'port0/line2','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line3','LightR','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line4','LightL','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
    HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
    
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:3','Touch,PupilD,EyeX,EyeY',['/',DAQID,'/PFI0']); % JL added the eye-tracking analog input channels
    
    %% ANALOG OUTPUT
    HW=niCreateAO(HW,DAQID,'ao0:1','SoundOutL,SoundOutR',['/',DAQID,'/PFI1']);
    
    %% SETUP SPEAKER CALIBRATION
    HW.Calibration.Speaker = 'SHHD380';
    HW.Calibration.Microphone = 'GRAS46BE';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
    
    HW.params.DAQSystem = 'none';
    HW.PsychoVisualDisplay = 1;
    
end % END SWITCH

if ~isfield(HW.params,'DAQSystem')
  if isfield(HW,'MANTA') HW.params.DAQSystem = 'MANTA';
  else                     HW.params.DAQSystem = 'AO';
  end
end
globalparams.HWparams = HW.params;

function CBF_Trigger(obj,event)
[TV,TS] = datenum2time(now); fprintf([' >> Trigger received (',TS{1},')\n']);