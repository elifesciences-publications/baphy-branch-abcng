% function [HW,SamplesLoaded]=niLoadAOData(AO,Data);
%
% Loads waveform(s) onto a set of Analog Out channels.  Expect Data to be a
% [SampleCount X AO.NumChannels] matrix ... or if size(Data,2)==1, just repeat
% the same signal on all channels
%
% created SVD 2012-05-29
%
function SamplesLoaded=niLoadAOData(AO,Data)

NElements = size(Data,1);
DataChannels=size(Data,2);
AOChannels=AO.NumChannels;
if DataChannels==1 && AOChannels>1, 
  Data=repmat(Data,[1 AOChannels]);
elseif DataChannels>1 && DataChannels~=AOChannels,
  error('expect size(Data,2) to match number of output channels');
end

%make sure to align Data columns to output channels;
if AOChannels>1,
    ChannelNames=strsep(AO.Names,',',1);
    DataChannels=size(Data,2);
    ChannelOrder=zeros(DataChannels,1);
    for ii=1:DataChannels,
       tc=[];
       if ii==1,
          tc=find(strcmp(['SoundOut'],ChannelNames));
       end
       if isempty(tc),
          tc=find(strcmp(['SoundOut',num2str(ii)],ChannelNames));
       end
       if isempty(tc),
          ChannelOrder(ii)=ii;
       else
          ChannelOrder(ii)=tc;
       end
    end
    Data=Data(:,ChannelOrder);
end

Data=Data(:);

DataPtr = libpointer('doublePtr',Data);
SamplesWritten = libpointer('int32Ptr',false);
% start during load, don't need separate start cmd.

S = DAQmxWriteAnalogF64(AO.Ptr,NElements, 1, 10, uint32(NI_decode('DAQmx_Val_GroupByChannel')),...
  DataPtr,SamplesWritten,[]);
if S NI_MSG(S); end

SamplesLoaded=get(SamplesWritten,'Value');


