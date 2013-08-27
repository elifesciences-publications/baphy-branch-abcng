function [w, event]=waveform (o,void,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object Tone

event = [];
% the parameters of tone object
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
ProbeFreq = get(o,'ProbeFreq');
NotchWidth= get(o,'NotchWidth');
findx= findstr(NotchWidth, 'f');
notchWidth= str2num(NotchWidth(1:findx-1));
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
Names = get(o,'Names');
% generate the Noise
wnoise = wgn(Duration*SamplingRate,1,0);
f1= (ProbeFreq-(ProbeFreq*notchWidth)/2)-ProbeFreq/4;
f2= (ProbeFreq-(ProbeFreq*notchWidth)/2);
f3= (ProbeFreq+(ProbeFreq*notchWidth)/2);
f4= (ProbeFreq+ProbeFreq*notchWidth/2)+ProbeFreq/4;

f1= f1/SamplingRate*2;
f3= f3/SamplingRate*2;
f2= f2/SamplingRate*2;
f4= f4/SamplingRate*2;

[b,a] = ellip(4,.5,20,[f1 f2]);
[bb, aa] = ellip(4,.5,20,[f3 f4]);

bandBelowProbe= filtfilt(b,a,wnoise);
bandAboveProbe= filtfilt(bb,aa,wnoise);

w= bandBelowProbe+bandAboveProbe;


% 5ms ramp at onset:
w = w(:);
ramp = hanning(round(.005 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
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
