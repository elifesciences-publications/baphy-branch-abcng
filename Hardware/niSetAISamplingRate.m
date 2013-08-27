function HW=niSetAISamplingRate(HW,varargin)

P = parsePairs(varargin);
if ~isfield(P,'SR') 
  P.SR = HW.params.fsAI; 
else
  HW.params.fsAI=P.SR;
end
if ~isfield(P,'MaxTrialLen') P.MaxTrialLen = HW.params.MaxTrialLen; end

% SET SAMPLING RATE AND SAMPLING MODE
for id=1:length(HW.AI),
  S = DAQmxCfgSampClkTiming(HW.AI(id).Ptr,'',P.SR,...
    NI_decode('DAQmx_Val_Rising'),NI_decode('DAQmx_Val_FiniteSamps'),P.MaxTrialLen.*P.SR);
  if S NI_MSG(S); end
  
  ActualRate = libpointer('doublePtr',10);
  S = DAQmxGetSampClkRate(HW.AI(id).Ptr,ActualRate);
  if S NI_MSG(S); end
  S = DAQmxTaskControl(HW.AI(id).Ptr,NI_decode('DAQmx_Val_Task_Verify'));
  if S NI_MSG(S); end
  
  disp(['AISampling:  Intended SR: ',n2s(P.SR),' Actual SR: ',n2s(get(ActualRate,'Value'))]);
  
end
