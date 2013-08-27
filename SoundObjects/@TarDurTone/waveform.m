function [w, event,o]=waveform (o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object Tone

% compatibility issue: make new Tone object (with index) compatible witht
% the rest:
if ~exist('index','var') || isempty(index)
    index = 1;
end


event = [];
% the parameters of tone object
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
Frequencies = get(o,'Frequencies');
Names = get(o,'Names');
AMRate = get(o,'AMRate');
if length(Frequencies)>1
    Names = Names{index};
else
    Names= Names{1};
end
if length(Frequencies)>1
    Frequencies = Frequencies(index);
end
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end
% generate the tone
timesamples = (1 : Duration*SamplingRate) / SamplingRate;
w=zeros(size(timesamples));

w = w + sin(2*pi*Frequencies*timesamples);
w = modulate(w,(AMRate/2),SamplingRate,'am');

% 10ms ramp at onset:
w = w(:);
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
% Now, put it in the silence:
w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
w = 5 * w/max(abs(w));
