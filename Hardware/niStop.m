% function HW=niStop(HW)
%
% Stop all NI Tasks pointed to by the AI, AO and DIO entries in HW.  Currently not
% dealing well with warnings for tasks that aren't running.
%
% created SVD 2012-05-29
%
function HW=niStop(HW)

global NI_SHOW_ERR_WARN

if isempty(NI_SHOW_ERR_WARN),
    NI_SHOW_ERR_WARN=0;
end

if isfield(HW,'Ptr'),
  % just stop a single device
  S = DAQmxStopTask(HW.Ptr);
  if NI_SHOW_ERR_WARN && S<0, NI_MSG(S); end
  return
end

if HW.params.HWSetup==0,
    % test mode, no daq
    return
end
% debug output
%disp('Resetting devices');

aiidx=find(strcmp({HW.Didx.Name},'TrigAI'));
aoidx=find(strcmp({HW.Didx.Name},'TrigAO'));
TriggerDIO=HW.Didx(aiidx).Task;

% IF A BILATERAL TRIGGER IS USED ADD THOSE TRIGGERS
aiidxInv=find(strcmp({HW.Didx.Name},'TrigAIInv'));
aoidxInv=find(strcmp({HW.Didx.Name},'TrigAOInv'));
if ~isempty(aiidxInv) aiidx = [aiidx,aiidxInv]; end
if ~isempty(aoidxInv) aoidx = [aoidx,aoidxInv]; end

AITriggerChan=[HW.Didx(aiidx).Line];
AOTriggerChan=[HW.Didx(aoidx).Line];

v=niGetValue(HW.DIO(TriggerDIO));
vstop=v;
vstop([AITriggerChan AOTriggerChan])=HW.DIO(TriggerDIO).InitState([AITriggerChan AOTriggerChan]);

% make sure not triggering
niPutValue(HW.DIO(TriggerDIO),vstop);

if isfield(HW,'DIO')
  for ii=1:length(HW.DIO),
    S = DAQmxStopTask(HW.DIO(ii).Ptr);
    if NI_SHOW_ERR_WARN && S<0, NI_MSG(S); end
  end
end
if isfield(HW,'AI')
  for ii=1:length(HW.AI),
    S = DAQmxStopTask(HW.AI(ii).Ptr);
    if NI_SHOW_ERR_WARN && S<0, NI_MSG(S); end
  end
end
if isfield(HW,'AO')
  for ii=1:length(HW.AO),
    S = DAQmxStopTask(HW.AO(ii).Ptr);
    if NI_SHOW_ERR_WARN && S<0, NI_MSG(S); end
  end
end


