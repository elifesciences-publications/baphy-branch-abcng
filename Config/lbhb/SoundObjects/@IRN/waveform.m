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
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
StepMS=get(o,'StepMS');
Gain=get(o,'Gain');
Iterations=get(o,'Iterations');
SplitChannels=get(o,'SplitChannels');
bSplitChannels=strcmpi(SplitChannels,'Yes');
Names = get(o,'Names');
BandCount=min(length(LowFreq),length(HighFreq));
if length(StepMS)<BandCount,
    StepMS=repmat(StepMS(1),[1 BandCount]);
end
if length(Gain)<BandCount,
    Gain=repmat(Gain(1),[1 BandCount]);
end
if length(Iterations)<BandCount,
    Iterations=repmat(Iterations(1),[1 BandCount]);
end

w=BandpassNoise(LowFreq(index),HighFreq(index),...
    Duration,SamplingRate);
mm=max(abs(w));

IterateStepSize=round(StepMS(index)./1000.*SamplingRate);
for ii=1:Iterations(index),
    w=w+shift(w,IterateStepSize).*Gain(index);
end
w=w./max(abs(w)).*5;  % normalize by pre-iterated level

fprintf('IRN idx %d  --  Iterations: %d  --  Iteration Step Size: %d\n',...
    index,Iterations(index),IterateStepSize);

% SVD 2013-03-27, started using onset/offset ramp of 1ms rather than 10ms:
ramp = hanning(round(.001 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
% Now, put it in the silence:
w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

if bSplitChannels && index>1,
    w=cat(2,zeros(size(w)),w);
end
