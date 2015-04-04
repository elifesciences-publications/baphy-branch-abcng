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
SNR = get(o,'SNR');
Duration = get(o,'Duration'); % duration is second
Frequencies = get(o,'Frequencies');
Names = get(o,'Names');
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

% 10ms ramp at onset before adding RSS
w = w(:);
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);

% scale tone to 80dB norm
w = (5/1.6) * w/max(abs(w));         %reduce by ~4 dB to peak match Tone,RSS

%
% modifying code from RSS waveform:
%
soundpath=get(o,'SoundPath');
files = get(o,'RSSNames');
[w_rss,fs] = wavread([soundpath filesep files{index}]);

% Check the sampling rate:
if fs~=SamplingRate
    w_rss = resample(w_rss, SamplingRate, fs);
end

% make sure the Duration of the RSS matches that of the tone
if length(w_rss)./SamplingRate<Duration,
    error('RSS too short');
end
w_rss=w_rss(1:round(Duration*SamplingRate));

% hard code scale by 5 to standard "80dB" level
w_rss=w_rss*50;   %I replaced 5 with 50 (8 dB+12 dB) to better match RSS stims w/o 0-dB

% add. not scaling SNR
ScaleBy=10^(SNR/20);

w=w.*ScaleBy+w_rss;

% Now, put it in the silence:
w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);



