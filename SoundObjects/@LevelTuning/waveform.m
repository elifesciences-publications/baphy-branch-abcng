function [w, ev, dB]=waveform (o, index, IsRef);

% the parameters of tone object
SamplingRate = ifstr2num(get(o,'SamplingRate'));
Duration = ifstr2num(get(o,'Duration')); % duration is second
Names = get(o,'Names');
BaseFrequency = ifstr2num(get(o,'BaseFrequency'));
% now generate a tone with specified frequency:
t = Tone(SamplingRate,0,  get(o,'PreStimSilence'), get(o,'PostStimSilence'), BaseFrequency, ...
    Duration);
[w, ev] = waveform(t);
for cnt1 = 1:length(ev)
    [type,name] = ParseStimEvent(ev(cnt1));
    ev(cnt1).Note = [type ' , ' Names{index}];
end
dB = ifstr2num(Names{index});  