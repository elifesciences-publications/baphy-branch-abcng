% function SamplesAvailable=niSamplesAvailable(AI)
%
% returns how many samples are available on a bank of Analog Input channels
%
% created SVD 2012-05-29
%
function SamplesAvailable=niSamplesAvailable(AI)

SamplesRead = libpointer('uint32Ptr',false);

S = DAQmxGetReadAvailSampPerChan(AI.Ptr,SamplesRead);
if S NI_MSG(S); end

SamplesAvailable = double(get(SamplesRead,'Value'));
%fprintf('AO Avaialble (%.2f): %d\n',toc,SamplesAvailable);
