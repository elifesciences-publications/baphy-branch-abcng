% function SamplesOut=niPutValue(DIO,value,SHOW_ERR_WARN)
%
% Set the value(s) of a bank of Digital Out channels.  All entries in value
% expected to be 0 or 1. If length(value)==1 and DIO.NumChannels>1,
% output the same value to all channels.
%
% created SVD 2012-05-29
%
function SamplesOut=niPutValue(DIO,value,SHOW_ERR_WARN)

if ~exist('SHOW_ERR_WARN','var'),
  SHOW_ERR_WARN=0;
end

if length(value)==1 && DIO.NumChannels>1,
  value=repmat(value,[1 DIO.NumChannels]);
end

SamplesWritten = libpointer('int32Ptr',false);
WriteArray = libpointer('uint8PtrPtr',value);
S = DAQmxWriteDigitalLines(DIO.Ptr,1,1,10,NI_decode('DAQmx_Val_GroupByScanNumber'),WriteArray,SamplesWritten,[]);
if SHOW_ERR_WARN && S NI_MSG(S); end

SamplesOut=get(SamplesWritten,'value');
%fprintf('DIO samples written: %d\n',SamplesOut);
