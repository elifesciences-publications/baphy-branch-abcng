% function Data=niReadAIData(AI,varargin)
%
%  Returns a Count X AI.NumChannels matrix of data from a bank of Analog
%  Inputs
% 
% optional parameters:  
%    ('Count',N): read N samples.  Default is to read all available samples
%
% created SVD 2012-05-29
%
function Data=niReadAIData(AI,varargin)

P = parsePairs(varargin);
if ~isfield(P,'Count') P.Count= []; end

if ~isempty(P.Count),
  SamplesToRead=P.Count;
else
  SamplesToRead=niSamplesAvailable(AI);
end

NElements=SamplesToRead.*AI.NumChannels;
SamplesPerChanRead = libpointer('int32Ptr',0);
AIData = libpointer('doublePtr',zeros(NElements,1));

S = DAQmxReadAnalogF64(AI.Ptr, SamplesToRead, 1, uint32(NI_decode('DAQmx_Val_GroupByChannel')),...
  AIData, NElements, SamplesPerChanRead,[]);
if S NI_MSG(S); end
SamplesRead=get(SamplesPerChanRead,'Value');
if SamplesRead<SamplesToRead,
  warning(sprintf('niReadAIData: SamplesRead<SamplesToRead : %d < %d\n',SamplesRead,SamplesToRead));
end
Data = reshape(get(AIData,'Value'),SamplesRead,AI.NumChannels);
