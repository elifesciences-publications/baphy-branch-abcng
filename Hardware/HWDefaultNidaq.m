% function HW=HWDefaultNidaq(globalparams)
%
% created SVD 2012-08-07
%
function HW=HWDefaultNidaq(globalparams)

if globalparams.HWSetup>0
    % establish connection with nidaqmx dll
    nidaqparams = loadnidaqmx;
    
    % clean up mess from any previously run instance of baphy
    ShutdownHW;
    niClearTasks([]);
else
    nidaqparams=[];
end

global FORCESAMPLINGRATE NI_SHOW_ERROR_WARN
FORCESAMPLINGRATE=1;
NI_SHOW_ERROR_WARN=0;

HW=[];
HW.params.HWSetup   = globalparams.HWSetup;
HW.params.fsAO      = 100000;  % no longer coded in BaphyMainGuiItems.  Just code for each HWsetup!
HW.params.fsAI      = 1000;  % default fsAI is 1000.
HW.params.fsSpike   = 25000;  % old -- used by anything?
HW.params.fsAux     = 1000;
HW.params.MaxTrialLen = 620;  
HW.params.SoftwareAtten = 1;
HW.Calibration.LoudnessMethod = 'MinMax';

HW.params.driver = 'NIDAQMX';  % versus default 'DAQTOOLBOX';
switch upper(computer),
  case 'PCWIN',
      HW.params.ptrType='uint32Ptr';
      HW.params.longType='uint32Ptr';
  case 'PCWIN64',
      HW.params.ptrType='voidPtr';
      HW.params.longType='ulongPtr';
end
HW.params.syncAIAO=1;
HW.params.SHOW_ERR_WARN=0;

% need to add support for 64-bit here?
HW.nidaqparams = nidaqparams;

if isfield(globalparams,'EqualizerCurve'),
  HW.params.SoftwareEqz=globalparams.EqualizerCurve;
else
  HW.params.SoftwareEqz=0;
end
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
