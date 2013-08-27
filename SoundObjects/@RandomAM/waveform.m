function [w, event]=waveform (o, index, IsRef)
% function w=waveform(t);
% this function is the waveform generator for object Tone

event = [];

% the parameters of tone object
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
AMDepth = get (o, 'AMDepth');

Names = get(o,'Names');
Names = Names(index);

Frequencies = str2num(Names{1});
RandFrequency = Frequencies ([1: length(Frequencies)/2]); % fisrt half
AMFrequency = Frequencies ([length(Frequencies)/2+1 : length(Frequencies)]);  % second half



% generate the tone
timesamples = (1 : Duration*SamplingRate) / SamplingRate;
w=zeros(size(timesamples));

for cnt1 = 1:length(RandFrequency) 
    
    c = cos(2*pi*RandFrequency(cnt1)*timesamples); % carrier
    a = 1-AMDepth + AMDepth*sin(2*pi*AMFrequency(cnt1)*timesamples); % AM with the depth
    
    w = w + a.*c; % put the AM together

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
event(2) = struct('Note',['Stim , ' Names{:} ' $'],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{:}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
w = 5 * w/max(abs(w));
