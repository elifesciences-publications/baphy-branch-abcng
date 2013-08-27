% function HW=niCreateAO(HW,Device,Channels,Names,TriggerSource)
%
% create a bank of Analog output channels in HW.AO(nextavailableid).  Paramters:
%   HW: Baphy HW structure
%   Device: NI device name string (eg, "Dev0")
%   Channels:  Channel id string (eg, "ao0:1")
%   Names:  String to assign names to these channels (can be comma
%   separated if multiple channels)
%   TriggerSource (optional):  Complete NI address string to the trigger
%   (hard coded to be rising edge!) (eg, '/Dev0/PFI1').  If not passed, no
%   trigger is assigned.  Nothing will happen in this case since there's
%   no option currently to start AO without a digital trigger.
%
% created SVD 2012-05-29
%
function HW=niCreateAO(HW,Device,Channels,Names,TriggerSource)

global NI_MASTER_TASK_LIST NI_SHOW_ERR_WARN

if ~isfield(HW,'AO'),
  CurrentLineCount=0;
else
  CurrentLineCount=length(HW.AO);
end
id=CurrentLineCount+1;

HW=niUpdateDevices(HW,Device);
HW.AO(id).TaskName=['AO_',Device,'_',num2str(id)];
HW.AO(id).Device=Device;
HW.AO(id).Channels=Channels;
HW.AO(id).Names=Names;

% Create a task
TaskPtr = libpointer('uint32Ptr',false); % for 32 bit
S = DAQmxCreateTask(HW.AO(id).TaskName,TaskPtr);
if S NI_MSG(S); end
HW.AO(id).Ptr = get(TaskPtr,'Value');
NI_MASTER_TASK_LIST=cat(2,NI_MASTER_TASK_LIST,HW.AO(id).Ptr);

% ADD ANALOG OUTPUT CHANNELS
S = DAQmxCreateAOVoltageChan(HW.AO(id).Ptr,['/',Device,'/',Channels],Names,-10,10,NI_decode('DAQmx_Val_Volts'),[]);
if S NI_MSG(S); end

% SET SAMPLING RATE AND SAMPLING MODE
HW=niSetAOSamplingRate(HW);

% CONFIGURE TRIGGER
if exist('TriggerSource','var'),
  S = DAQmxCfgDigEdgeStartTrig(HW.AO(id).Ptr,TriggerSource,NI_decode('DAQmx_Val_Rising'));
  if S NI_MSG(S); end
  HW.AO(id).TriggerSource=TriggerSource;
else
  HW.AO(id).TriggerSource='none';
end

% debugging stuff
ActualRate = libpointer('doublePtr',10);
S = DAQmxGetSampClkRate(HW.AO(id).Ptr,ActualRate); 
if S NI_MSG(S); end
S = DAQmxTaskControl(HW.AO(id).Ptr,NI_decode('DAQmx_Val_Task_Verify')); 
if S NI_MSG(S); end

NumChans = libpointer('uint32Ptr',1);
S = DAQmxGetTaskNumChans(HW.AO(id).Ptr,NumChans);
if S NI_MSG(S); end
HW.AO(id).NumChannels=double(get(NumChans,'Value'));

% debug report
if NI_SHOW_ERR_WARN,
    fprintf(['Device ',Device,' - Line ',n2s(id),' - AO Channels: ',n2s(get(NumChans,'Value')),' SR: ',n2s(get(ActualRate,'Value')),'\n']);
end

