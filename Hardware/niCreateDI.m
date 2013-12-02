% function HW=niCreateDI(HW,Device,Channels,Names)
%
% create a bank of Digital input channels in HW.DIO(nextavailableid).  Paramters:
%   HW: Baphy HW structure
%   Device: NI device name string (eg, "Dev0")
%   Channels:  Channel id string (eg, "port0/line0:1")
%   Names:  String to assign names to these channels (can be comma
%   separated if multiple channels)
%
% created SVD 2012-05-29
%
function HW=niCreateDI(HW,Device,Channels,Names)

global NI_MASTER_TASK_LIST NI_SHOW_ERR_WARN

if ~isfield(HW,'DIO'),
  CurrentLineCount=0;
else
  CurrentLineCount=length(HW.DIO);
end
id=CurrentLineCount+1;

HW=niUpdateDevices(HW,Device);
HW.DIO(id).TaskName=['DIO_',Device,'_',num2str(id)];
HW.DIO(id).Device=Device;
HW.DIO(id).Channels=Channels;
HW.DIO(id).Names=Names;
HW.DIO(id).Direction='In';

% Create a task
TaskPtr = libpointer(HW.params.ptrType,false); % for 32 bit
S = DAQmxCreateTask(HW.DIO(id).TaskName,TaskPtr);
if S NI_MSG(S); end
HW.DIO(id).Ptr = TaskPtr;
NI_MASTER_TASK_LIST=cat(2,NI_MASTER_TASK_LIST,HW.DIO(id).Ptr);

% assign channels to this task
NumChans = libpointer('uint32Ptr',1);
S = DAQmxCreateDIChan(HW.DIO(id).Ptr,['/',Device,'/',Channels],Names, NI_decode('DAQmx_Val_ChanPerLine'));
if S NI_MSG(S); end

S = DAQmxGetTaskNumChans(HW.DIO(id).Ptr,NumChans);
if S NI_MSG(S); end
HW.DIO(id).NumChannels=double(get(NumChans,'Value'));

cnames=strsep(Names,',');
if ~isfield(HW,'Didx'),
  HW.Didx=[];
end
Didxcount=length(HW.Didx);
for ii=1:HW.DIO(id).NumChannels,
  Didxcount=Didxcount+1;
  if ii<=length(cnames),
    HW.Didx(Didxcount).Name=cnames{ii};
  else
    HW.Didx(Didxcount).Name=[HW.DIO(id).TaskName '_Line' num2str(ii)];
  end
  HW.Didx(Didxcount).Task=id;
  HW.Didx(Didxcount).Line=ii;
end

% debug report
if NI_SHOW_ERR_WARN,
    fprintf(['Device ',Device,' - Line ',n2s(id),' - DIO Channels: ',n2s(get(NumChans,'Value')),'\n']);
end
