% function HW=niCreateAI(HW,Device,Channels,Names,TriggerSource)
%
% create a bank of Analog input channels in HW.Ai(nextavailableid).  Paramters:
%   HW: Baphy HW structure
%   Device: NI device name string (eg, "Dev0")
%   Channels:  Channel id string (eg, "ai0:1")
%   Names:  String to assign names to these channels (can be comma
%   separated if multiple channels)
%   TriggerSource (optional):  Complete NI address string to the trigger
%   (hard coded to be rising edge!) (eg, '/Dev0/PFIO').  If not passed, no
%   trigger is assigned.  Nothing will happen in this case since there's
%   no option currently to start AI without a digital trigger.
%
% created SVD 2012-05-29
%
function HW=niCreateAI(HW,Device,Channels,Names,TriggerSource)

global NI_MASTER_TASK_LIST
global NI_SHOW_ERR_WARN

if ~isfield(HW,'AI'),
  CurrentLineCount=0;
else
  CurrentLineCount=length(HW.AI);
end
id=CurrentLineCount+1;

HW=niUpdateDevices(HW,Device);
HW.AI(id).TaskName=['AI_',Device,'_',num2str(id)];
HW.AI(id).Device=Device;
HW.AI(id).Channels=Channels;
HW.AI(id).Names=Names;

% Create a task
TaskPtr = libpointer('uint32Ptr',false); % for 32 bit
S = DAQmxCreateTask(HW.AI(id).TaskName,TaskPtr);
if S NI_MSG(S); end
HW.AI(id).Ptr = get(TaskPtr,'Value');
NI_MASTER_TASK_LIST=cat(2,NI_MASTER_TASK_LIST,HW.AI(id).Ptr);

% ADD ANALOG INPUT CHANNELS
S = DAQmxCreateAIVoltageChan(HW.AI(id).Ptr,['/',Device,'/',Channels],Names,...
  NI_decode('DAQmx_Val_RSE'),-10,10,NI_decode('DAQmx_Val_Volts'),[]);
%S = DAQmxCreateAIVoltageChan(NI.AI(iD),[Devices{iD},'/ai0:1'],[Devices{iD},'AIchan'],...
%  NI_decode('DAQmx_Val_RSE'),-10,10,NI_decode('DAQmx_Val_Volts'),[]);
if S NI_MSG(S); end

S = DAQmxSetAITermCfg(HW.AI(id).Ptr,['/',Device,'/',Channels],NI_decode('DAQmx_Val_RSE'));
if S NI_MSG(S); end

% SET SAMPLING RATE AND SAMPLING MODE
SR=HW.params.fsAI;
TrialLen=HW.params.MaxTrialLen;
S = DAQmxCfgSampClkTiming(HW.AI(id).Ptr,'',SR,...
  NI_decode('DAQmx_Val_Rising'),NI_decode('DAQmx_Val_FiniteSamps'),TrialLen.*SR);
if S NI_MSG(S); end

% CONFIGURE TRIGGER
if exist('TriggerSource','var'),
  S = DAQmxCfgDigEdgeStartTrig(HW.AI(id).Ptr,TriggerSource,NI_decode('DAQmx_Val_Rising'));
  if S NI_MSG(S); end
  HW.AI(id).TriggerSource=TriggerSource;
else
  HW.AI(id).TriggerSource='none';
end

% debugging stuff
ActualRate = libpointer('doublePtr',10);
S = DAQmxGetSampClkRate(HW.AI(id).Ptr,ActualRate); 
if S NI_MSG(S); end
S = DAQmxTaskControl(HW.AI(id).Ptr,NI_decode('DAQmx_Val_Task_Verify')); 
if S NI_MSG(S); end


NumChans = libpointer('uint32Ptr',1);
S = DAQmxGetTaskNumChans(HW.AI(id).Ptr,NumChans);
if S NI_MSG(S); end
HW.AI(id).NumChannels=double(get(NumChans,'Value'));

% debug report
if NI_SHOW_ERR_WARN,
    fprintf(['Device ',Device,' - Line ',n2s(id),' - AI Channels: ',n2s(get(NumChans,'Value')),' SR: ',n2s(get(ActualRate,'Value')),'\n']);
end

