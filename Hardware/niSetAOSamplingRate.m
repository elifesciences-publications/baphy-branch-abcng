function HW=niSetAOSamplingRate(HW,varargin)

P = parsePairs(varargin);
if ~isfield(P,'SR'),
  P.SR = HW.params.fsAO; 
else
  HW.params.fsAO=P.SR;
end
if ~isfield(P,'MaxTrialLen') P.MaxTrialLen = HW.params.MaxTrialLen; end

HW.params.fsAO=P.SR;
HW.params.MaxTrialLen=P.MaxTrialLen;

% SET SAMPLING RATE AND SAMPLING MODE
for id=1:length(HW.AO)
  %niStop(HW.AO(id));
  S = DAQmxCfgSampClkTiming(HW.AO(id).Ptr,'',P.SR,...
    NI_decode('DAQmx_Val_Rising'),NI_decode('DAQmx_Val_FiniteSamps'),P.MaxTrialLen.*P.SR);
  if S NI_MSG(S); end
  
  ActualRate = libpointer('doublePtr',10);
  S = DAQmxGetSampClkRate(HW.AO(id).Ptr,ActualRate);
  if S NI_MSG(S); end
  S = DAQmxTaskControl(HW.AO(id).Ptr,NI_decode('DAQmx_Val_Task_Verify'));
  if S NI_MSG(S); end
  
  %disp(['AOSampling:  Intended SR: ',n2s(P.SR),' Actual SR: ',n2s(get(ActualRate,'Value'))]);
  
end
