function HW = IOSetTrigger(HW, triggertype);
% function HW = IOSetTrigger(HW, triggertype);
% HW.A0 triggertype property set to triggertype parameter (eg 'Immediate'
% or 'HWDigital'
% 
% SVD, November 2005
% 
% SVD update 2012-05-30 : added Nidaqmx support

HW.params.AOTriggerType = triggertype;  % for test, analog in does not exist
if strcmpi(triggertype,'Immediate'),
  HW.params.syncAIAO=0;
else
  HW.params.syncAIAO=1;
end

switch HW.params.HWSetup
    case {0},           % ie, TEST MODE
        
    otherwise
        if ~strcmpi(IODriver(HW),'NIDAQMX'),
          set(HW.AO,'TriggerType',triggertype);
        end
end
