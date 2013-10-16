function s=specgram(o,index,IsRef);
% function w=specgram(t,index);
% return specgram for sample # index
%
% created SVD 2011-08-11

global STREAMNOISEWAV STREAMNOISESPECGRAM

if isempty(STREAMNOISEWAV),
    % call waveform to generate cache
    waveform(o,index);
end

s=STREAMNOISESPECGRAM(index,:);
ii=length(s)./40;
s=reshape(s,40,ii);
