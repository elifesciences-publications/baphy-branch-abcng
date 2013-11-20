function [HW, globalparams] = InitializeHW (globalparams)
% function HW = InitializeHW (globalparams);
%
% InitializeHW initializes the hardware based on which hardware setup is
% used and the parameters of the experiments specified in globalparams.
% Specific values are now lab-dependent.  The range of possible HWSetup
% values is specified in BaphyMainGuiItems (also lab-dependent)
%
% Nima, original November 2005
% BE, specific setup for ABCNL

global FORCESAMPLINGRATE

% create a default HW structure
HW=HWDefaultNidaq(globalparams);

doingphysiology = ~strcmp(globalparams.Physiology,'No');


% Based on the hardware setup, start the initialization:
switch globalparams.HWSetup
  
  case 0 % TEST MODE
    % create an audioplayer object which lets us control start, stop, sampling rate
    HW.AO = audioplayer(rand(4000,1), HW.params.fsAO);
    HW.AI = HW.AO;
    HW.DIO.Line.LineName = {'Touch','TouchL','TouchR'};
    
  case {1,2,3} % ALL RECORDING BOOTHS SHOULD REMAIN IDENTICAL AS LONG AS POSSIBLE
    DAQID = 'D0'; % NI BOARD ID WHICH CONTROLS STIMULUS & BEHAVIOR
    niResetDevice(DAQID);
    
    %% DIGITAL IO
    HW=niCreateDO(HW,DAQID,'port0/line0:1,port2/line0:1','TrigAI,TrigAO,TrigAIInv,TrigAOInv','InitState',[0 0 1 1]);
    HW=niCreateDO(HW,DAQID,'port0/line2','Light','InitState',0);
    HW=niCreateDO(HW,DAQID,'port1/line5','Pump','InitState',0);    
    HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
    
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0:1','Touch,Microphone',['/',DAQID,'/PFI0']);
    
    %% ANALOG OUTPUT
    HW=niCreateAO(HW,DAQID,'ao0:1','SoundOutL,SoundOutR',['/',DAQID,'/PFI1']);
    
    %% SETUP SPEAKER CALIBRATION
    HW.Calibration.Speaker = 'SHIE800';
    HW.Calibration.Microphone = 'GRAS46BE';
    HW.Calibration = IOLoadCalibration(HW.Calibration);
       
    %% COMMUNICATE WITH MANTA
    if doingphysiology  [HW,globalparams] = IOConnectWithManta(HW,globalparams); end
  
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
    HW=niCreateDO(HW,DAQID,'port0/line3','Pump','InitState',0);
    HW=niCreateDI(HW,DAQID,'port0/line5','Touch');
    
    %% ANALOG INPUT
    HW=niCreateAI(HW,DAQID,'ai0','Touch',['/',DAQID,'/PFI0']);
    
    %% ANALOG OUTPUT
    HW=niCreateAO(HW,DAQID,'ao0:1','SoundOutL,SoundOutR',['/',DAQID,'/PFI1']);
    
    %% SETUP SPEAKER CALIBRATION
    HW.Calibration.Speaker = 'ATHM50';
    HW.Calibration.Microphone = 'GRAS46BE';
    HW.Calibration = IOLoadCalibration(HW.Calibration);

    HW.params.DAQSystem = 'none';
    
end % END SWITCH

if ~isfield(HW.params,'DAQSystem')
  if isfield(HW,'MANTA') HW.params.DAQSystem = 'MANTA';
  else                     HW.params.DAQSystem = 'AO';
  end
end
globalparams.HWparams = HW.params;

function CBF_Trigger(obj,event)
[TV,TS] = datenum2time(now); fprintf([' >> Trigger received (',TS{1},')\n']); 