function [w, event,o]=waveform (o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object Tone

event = [];
% the parameters of tone object
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
Frequencies = get(o,'Frequencies');
Names = get(o,'Names');
ToneDuration=get(o,'ToneDuration');
OnsetTimes=get(o,'OnsetTimes');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
RelativeAttenuation=get(o,'RelativeAttenuation');
AttenuateChan=get(o,'AttenuateChan');

Names = Names{index};
OnsetTimes=OnsetTimes{index};

% generate the individual tones
tonesamples=(1:ToneDuration*SamplingRate)' / SamplingRate;
ToneSet=zeros(length(tonesamples),length(Frequencies));
% 10ms ramp at onset of each tone:
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
for ii=1:length(Frequencies),
    ToneSet(:,ii) = sin(2*pi*Frequencies(ii)*tonesamples);
    ToneSet(1:length(ramp),ii) = ToneSet(1:length(ramp),ii) .* ramp;
    ToneSet(end-length(ramp)+1:end,ii) = ToneSet(end-length(ramp)+1:end,ii) .* flipud(ramp);
    ToneSet(:,ii)=ToneSet(:,ii)./max(abs(ToneSet(:,ii))).*5;
    if ii==AttenuateChan(index),
       scaleby=10.^(-RelativeAttenuation./20);
       ToneSet(:,ii)=ToneSet(:,ii).*scaleby;
    end
end

% generate the sequence
timesamples = (1 : Duration*SamplingRate)' / SamplingRate;
w=zeros(size(timesamples));
for ii=1:length(OnsetTimes),
    for ff=1:length(Frequencies),
        startbin=round(OnsetTimes(ii,ff).*SamplingRate);
        w(startbin+(1:length(ToneSet)))=...
            w(startbin+(1:length(ToneSet)))+ToneSet(:,ff);
    end
end

% Now, put it in the silence:
w = [zeros(round(PreStimSilence*SamplingRate),1) ; w(:) ;zeros(round(PostStimSilence*SamplingRate),1)];
% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
