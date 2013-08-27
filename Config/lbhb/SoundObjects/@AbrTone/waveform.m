function [w, event,o]=waveform (o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object JitterTone

if ~exist('index','var') || isempty(index)
    index = 1;
end

event = [];

% get object parameters
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
RampDuration = get(o,'RampDuration'); % duration is second
Frequencies = get(o,'Frequencies');
Levels = get(o,'Levels');
Names = get(o,'Names');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

% generate the tone
timesamples = (1 : Duration*SamplingRate)' / SamplingRate;
w=zeros(size(timesamples));

FreqCount=length(Frequencies);
LevelCount=length(Levels);
l=mod(index-1,LevelCount)+1;
f=floor((index-1)./LevelCount)+1;

% +/-5 peak-to-peak = 80dB SPL
atten=10.^((Levels(l)-80)./20);
if ~Frequencies(f),
    % Freq=0 means click
    ClickWidth = .0001;
    ClickBins=ceil(ClickWidth.*SamplingRate);
    w=zeros(size(timesamples));
    w(1:ClickBins)=5*atten;
else
    w = sin(2*pi*Frequencies(f)*timesamples)*5*atten;
    
    % variable ramp duration:
    ramp = hanning(round(RampDuration * SamplingRate*2));
    ramp = ramp(1:floor(length(ramp)/2));
    w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
    w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
end

% flip the sign of the waveform for 180-deg phase shift on even indices
persistent flip
if isempty(flip) || flip==0;
    flip=1;
else
    flip=0;
    w=-w;
end
%if mod(index,2)==0,
%    w=-w;
%end

% Now, put it in the silence:
w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];

% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

