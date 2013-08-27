% function Values=niGetValue(DIO,SHOW_ERR_WARN)
%
% Read the current value(s) from a bank of Digital Inputs
%
% created SVD 2012-05-29
%
function Values=niGetValue(DIO,SHOW_ERR_WARN)

if ~exist('SHOW_ERR_WARN','var'),
  SHOW_ERR_WARN=0;
end

% int32 _stdcall DAQmxReadDigitalLines ( TaskHandle taskHandle , int32 numSampsPerChan , float64 timeout , bool32 fillMode , uInt8 readArray [], uInt32 arraySizeInBytes , int32 * sampsPerChanRead , int32 * numBytesPerSamp , bool32 * reserved );
DSamplesRead = libpointer('int32Ptr',false);
BytesPerSamp = libpointer('int32Ptr',false);
ReadArray = libpointer('uint8PtrPtr',zeros(1,DIO.NumChannels));

S=DAQmxReadDigitalLines(DIO.Ptr,1,1,NI_decode('DAQmx_Val_GroupByScanNumber'),ReadArray,DIO.NumChannels,DSamplesRead,BytesPerSamp,[]);
if SHOW_ERR_WARN && S NI_MSG(S); end
%sr=double(get(DSamplesRead,'Value'));
%bs=double(get(BytesPerSamp,'Value'));
Values=double(get(ReadArray,'Value'));
