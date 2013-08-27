function HW=IOSetAnalogInDuration (HW, Duration, globalparams);
% function IOSetAnalogInDuration (HW, Duration, globalparams);
%
% This function sets the Sample per Trigger field of analog input to match
% the Duration. It uses the HW.params.fsAI to calculate the number of
% samples needed.
% Duration specifies the time duration of data logging and is in Seconds.
% 
% SVD update 2012-05-30 : added Nidaqmx support

% SVD add for NIDAQ driver (2005-05-30):
if strcmpi(IODriver(HW),'NIDAQMX'),
  if HW.params.HWSetup>0
    HW.params.MaxTrialLen=Duration;
    HW=niSetAOSamplingRate(HW);
  end
  return;
end

% Nima, nov 2005
switch HW.params.HWSetup
  case 0; % Testing, do nothing
  case 4;     
    % Bug in Training Rig 4: logging sometimes never finishes
    Samples = ceil(HW.params.fsAI * (Duration + 0.5));
    set (HW.AI, 'SamplesPerTrigger', Samples);
  otherwise
    Samples = ceil(HW.params.fsAI * Duration);
    set (HW.AI, 'SamplesPerTrigger', Samples);
end