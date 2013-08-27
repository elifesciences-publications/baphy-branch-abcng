% function HW=niCreateDO(HW,Device,Channels,Names,varargin)
%
% create a bank of Digital Output channels in HW.DIO(nextavailableid).  Paramters:
%   HW: Baphy HW structure
%   Device: NI device name string (eg, "Dev0")
%   Channels:  Channel id string (eg, "port0/line2:3")
%   Names:  String to assign names to these channels (can be comma
%   separated if multiple channels)
%   Optional parameters:
%          'InitState',[0 0]:  Initial value (0 or 1) for each channel.
%          Default is not to specify an intial state.
%
% created SVD 2012-05-29
%
function HW=niCreateDO(HW,Device,Channels,Names,varargin)

global NI_MASTER_TASK_LIST NI_SHOW_ERR_WARN

P = parsePairs(varargin);
if ~isfield(P,'InitState') P.InitState = []; end

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
HW.DIO(id).Direction='Out';


% Create a task
TaskPtr = libpointer(HW.params.ptrType,false); % for 32 bit
S = DAQmxCreateTask(HW.DIO(id).TaskName,TaskPtr);
if S NI_MSG(S); end
HW.DIO(id).Ptr = get(TaskPtr,'Value');
NI_MASTER_TASK_LIST=cat(2,NI_MASTER_TASK_LIST,HW.DIO(id).Ptr);

% Allow multiple ports to be used for one task
Separators = find(Channels==','); Separators = [0,Separators,length(Channels)+1];
FullChannels = []; 
for i=1:length(Separators)-1
  FullChannels = [FullChannels,'/',Device,'/',Channels(Separators(i)+1:Separators(i+1)-1),','];
end
FullChannels = FullChannels(1:end-1);

% assign channels to this task
NumChans = libpointer(HW.params.longType,1);
S = DAQmxCreateDOChan(HW.DIO(id).Ptr,FullChannels,Names, NI_decode('DAQmx_Val_ChanPerLine'));
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

if ~isempty(P.InitState) && length(P.InitState)<HW.DIO(id).NumChannels,
  P.InitState=repmat(P.InitState(1),[1 HW.DIO(id).NumChannels]);
end
HW.DIO(id).InitState=P.InitState;
% SET INITIAL STATE (added BE - 13/3/13)
niPutValue(HW.DIO(id),P.InitState);

% debug report
if NI_SHOW_ERR_WARN,
    fprintf(['Device ',Device,' - Line ',n2s(id),' - DIO Channels: ',n2s(get(NumChans,'Value')),'\n']);
end

