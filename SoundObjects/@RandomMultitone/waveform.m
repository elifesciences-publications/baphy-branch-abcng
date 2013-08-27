function [w, event]=waveform (o, index, IsRef)
% function w=waveform(t);
% this function is the waveform generator for object Tone

event = [];
% the parameters of tone object
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end
Names = get(o,'Names');
Names = Names(index);
Frequencies = str2num(Names{1});
% generate the tone
timesamples = (1 : Duration*SamplingRate) / SamplingRate;
w=zeros(size(timesamples));
for cnt1 = 1:length(Frequencies)
    w = w + sin(2*pi*Frequencies(cnt1)*timesamples);
end
% 10ms ramp at onset:
w = w(:);
ramp = hanning(.01 * SamplingRate*2);
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
% Now, put it in the silence:
w = [zeros(PreStimSilence*SamplingRate,1) ; w(:) ;zeros(PostStimSilence*SamplingRate,1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{:}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{:}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{:}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
w = 5 * w/max(abs(w));
