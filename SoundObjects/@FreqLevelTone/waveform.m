function [w, ev, dB]=waveform (o,index, IsRef)
% function w=waveform(t);
% this function is the waveform generator for object FrequencyTuning


SamplingRate = ifstr2num(get(o,'SamplingRate'));
PreStimSilence = ifstr2num(get(o,'PreStimSilence'));
PostStimSilence = ifstr2num(get(o,'PostStimSilence'));

% the parameters of tone object
SamplingRate = ifstr2num(get(o,'SamplingRate'));
Duration = ifstr2num(get(o,'Duration')); % duration is second
Names = get(o,'Names');
Frequency = ifstr2num(Names{index,1});
% now generate a tone with specified frequency:
t = Tone(SamplingRate, 0, get(o,'PreStimSilence'), get(o,'PostStimSilence'), ...
    Frequency, Duration);
[w, ev] = waveform(t);
clear t;  
w = 5 * w/max(abs(w));
dB = ifstr2num(Names{index,2}) ;

disp(['freq= ' num2str(Frequency)])
disp(['dB= ' num2str(dB)])