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

SetupNames = {'SB1','SB2','LB1','TwoP','SB2Earphones','LB1multiSpeakers','ePhy','','','','HP1'};
globalparams.HWSetupName = SetupNames{globalparams.HWSetup};

% Based on the hardware setup, start the initialization:
switch globalparams.HWSetup
  
  case 0 % TEST MODE
    % create an audioplayer object which lets us control start, stop, sampling rate
    HW.AO = audioplayer(rand(4000,1), HW.params.fsAO);
    HW.AI = HW.AO;
    HW.DIO.Line.LineName = {'Touch','TouchL','TouchR'};
  case 10 % ALL RECORDING BOOTHS SHOULD REMAIN IDENTICAL AS LONG AS POSSIBLE
    SetupNames = {'SB1'};
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
    
  case {1,2,3,5,6} % ALL RECORDING BOOTHS SHOULD REMAIN IDENTICAL AS LONG AS POSSIBLE
    SetupNames = {'SB1','SB2','LB1',[],'SB2Earphones','LB1multiSpeakers'};
    globalparams.HWSetupName = SetupNames{globalparams.HWSetup};
    if globalparams.HWSetup==6; HW.SpeakerNb = 4; end
    DAQID = 'D0'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    niResetDevice(DAQID);
    
    %% DIGITAL IO
    HW=niCreateDO(HW,DAQID,'port0/line0:1,port2/line0:1','TrigAI,TrigAO,TrigAIInv,TrigAOInv','InitState',[0 0 1 1]);
    HW=niCreateDO(HW,DAQID,'port0/line6','TrigOnlineAI','InitState',0);  % monitor eye position online
    HW=niCreateDO(HW,DAQID,'port0/line2','EyeFixationInitiated','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line3','EyeFixationTerminated','InitState',0);
    HW=niCreateDO(HW,DAQID,'port2/line3','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line7','LightR','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line4','LightL','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line5','Pump','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line7','PumpMotor','InitState',0);
    HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
    HW=niCreateDI(HW,DAQID,'port1/line6','Fixation');
    
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:6','Touch,Microphone,PupilD,EyeX,Diode,ABR,EyeY',['/',DAQID,'/PFI0']); 
    % 16/08-YB: was before HW=niCreateAI(HW,DAQID,'ai0:7','Touch,Microphone,EyeX,EyeY,Diode,PsyTriggers,PupilD',['/',DAQID,'/PFI0'])
    %HW2 =niCreateAIOnline(HW2,'Dev1','ai0:1','OnlineEyeX,OnlineEyeY',['/','Dev1','/PFI0']);  % monitor eye position online; triggered by 'TrigOnlineAI'
    
    %% SETUP SPEAKER CALIBRATION    
    switch globalparams.HWSetup
      case {1,3,5}
          %% ANALOG OUTPUT % 14/09-YB: rmv independant audio channels for introducing Opto
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut1,SoundOut2',['/',DAQID,'/PFI1']);
        HW.Calibration.Speaker = ['SHIE800',globalparams.HWSetupName];
      case 2
%         HW=niCreateAO(HW,DAQID,'ao1','SoundOut,OptTrig',['/',DAQID,'/PFI1']);
        HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut1,SoundOut2',['/',DAQID,'/PFI1']);
        HW.Calibration.Speaker = ['RS',globalparams.HWSetupName];
      case {6}
        HW=niCreateAO(HW,DAQID,'ao0:3','SoundOut1,SoundOut2,SoundOut3,SoundOut4',['/',DAQID,'/PFI1']);
%         DAQID = 'D1'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
%         niResetDevice(DAQID);
%         HW=niCreateAO(HW,DAQID,'ao0:3','SoundOut5,SoundOut6,SoundOut7,SoundOut8',['/',DAQID,'/PFI1']);
        HW.Calibration(1).Speaker = ['VISATON59',globalparams.HWSetupName,'_ch00'];
        HW.Calibration(2).Speaker = ['VISATON59',globalparams.HWSetupName,'_ch01'];
        HW.Calibration(2).Microphone = 'GRAS46BE';
        HW.Calibration(3).Speaker = ['VISATON59',globalparams.HWSetupName,'_ch02'];
        HW.Calibration(3).Microphone = 'GRAS46BE';
        HW.Calibration(4).Speaker = ['VISATON59',globalparams.HWSetupName,'_ch03'];
        HW.Calibration(4).Microphone = 'GRAS46BE';
    end
    HW.Calibration(1).Microphone = 'GRAS46BE';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
    
    %% COMMUNICATE WITH MANTA
    if Physiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
    
  case {4} % TWO PHOTON BOOTH IN BIOLOGY
      DAQID = 'Dev4'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
      %    version with PCIe 6259 board
      HW.params.fsAO = 500000;
    niResetDevice(DAQID);
    
    %% DIGITAL IO
    HW=niCreateDO(HW,DAQID,'port0/line0:1','TrigAI,TrigAO','InitState',[0,0]);
    HW=niCreateDO(HW,DAQID,'port2/line3','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line7','LightR','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line4','LightL','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line5','Pump','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line6','Shock','InitState',0);
    HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
%    HW=niCreateDO(HW,DAQID,'port1/line0:1','TrigAI,TrigAO','InitState',[0,0]);
%    HW=niCreateDO(HW,DAQID,'port0/line6:7','TrigAI,TrigAO','InitState',[0,0]);
 %   version with PCIe 6259 board
 

    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:1','Touch,Microphone',['/',DAQID,'/PFI8']);
    
    %% ANALOG OUTPUT
%     HW=niCreateAO(HW,DAQID,'ao2:3','SoundOut1,SoundOut2',['/',DAQID,'/PFI9']);
    HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut1,SoundOut2',['/',DAQID,'/PFI9']);
 %    version with PCIe 6259 board
 
    % In this setup, TrigAO is NOT connected to PFI9 because Labview starts
    %the stim (via the frame trig sent on PFI9), in synchronization with the image acquisition.
    % Instead, TrigAO is recorded in LabView, registering the frame before
    %the trial starts.    
    HW.OPTICAL = struct([]);     
    
    %% SETUP SPEAKER CALIBRATION
    HW.Calibration.Speaker = ['Tweeter_',globalparams.HWSetupName];
    HW.Calibration.Microphone = 'GRAS46BE';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
    
case {7} %ePHY BOOTHS IN BIOLOGY
    DAQID = 'D0'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    HW.params.fsAO = 500000;
    niResetDevice(DAQID);
    
     %% DIGITAL IO
    HW=niCreateDO(HW,DAQID,'port0/line0:1,port2/line0:1','TrigAI,TrigAO,TrigAIInv,TrigAOInv','InitState',[0 0 1 1]);
    HW=niCreateDO(HW,DAQID,'port0/line6','TrigOnlineAI','InitState',0);  % monitor eye position online
    HW=niCreateDO(HW,DAQID,'port0/line2','EyeFixationInitiated','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line3','EyeFixationTerminated','InitState',0);
    HW=niCreateDO(HW,DAQID,'port2/line3','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line7','LightR','InitState',0);
    HW=niCreateDO(HW,DAQID,'port0/line4','LightL','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line5','Pump','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line7','PumpMotor','InitState',0);
    HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
    HW=niCreateDI(HW,DAQID,'port1/line6','Fixation');
    
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:6','Touch,Microphone,PupilD,EyeX,Diode,PsyTriggers,EyeY',['/',DAQID,'/PFI0']); 
    
    %% ANALOG OUTPUT
    HW=niCreateAO(HW,DAQID,'ao0:1','SoundOut1,SoundOut2',['/',DAQID,'/PFI1']);
    
    %% SETUP SPEAKER CALIBRATION
    HW.Calibration.Speaker = ['Tweeter_',globalparams.HWSetupName];
    HW.Calibration.Microphone = 'GRAS46BE';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
    
    %% COMMUNICATE WITH MANTA
    if Physiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
        
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