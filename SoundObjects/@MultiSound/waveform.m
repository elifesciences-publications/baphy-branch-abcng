function [w,events] = waveform (o, index ,IsRef)

% Choose randomly one of the Targets:
TargetObjects = get(o,'TargetObjects');
TargetIndex = TargetObjects(ceil(rand(1)*length(TargetObjects)));
if TargetIndex == 1 % then this is a tone object:
    T = Tone(get(o,'SamplingRate'),...
        0,...
        get(o,'PreStimSilence'),...
        get(o,'PostStimSilence'),...
        get(o,'TFreqs'),...
        get(o,'Duration'));
elseif TargetIndex == 2 % then this is a tone in TORC object:
    T = ToneInTorc(get(o,'SamplingRate'),...
        0,...
        get(o,'PreStimSilence'),...
        get(o,'PostStimSilence'),...
        get(o,'Duration'),... % torc duration
        get(o,'TNTFreqs'),...
        0, ... % tone start time relative to torc
        get(o,'Duration'),... % tone stop time
        get(o,'TNTSNR'));
elseif TargetIndex == 3 % multitone object
    T = MultipleTones(get(o,'SamplingRate'),...
        0,...
        get(o,'PreStimSilence'),...
        get(o,'PostStimSilence'),...
        get(o,'MTFreqs'),...
        get(o,'Duration'));
elseif TargetIndex==4 % RandomTone
    T = RandomTone(get(o,'SamplingRate'),...
        0,...
        get(o,'PreStimSilence'),...
        get(o,'PostStimSilence'),...
        get(o,'RTBaseFreq'),...
        get(o,'RTOctaveBelow'),...
        get(o,'RTOctaveAbove'),...
        get(o,'RTTonesPerOctave'),...
        get(o,'Duration'));    
elseif TargetIndex==5
    T = Click(get(o,'SamplingRate'),...
        0,...
        get(o,'PreStimSilence'),...
        get(o,'PostStimSilence'),...
        0.001,...
        get(o,'ClickRate'),...
        get(o,'Duration'));
elseif TargetIndex==6
    T = FMSweep(get(o,'SamplingRate'),...
        0,...
        get(o,'PreStimSilence'),...
        get(o,'PostStimSilence'),...
        get(o,'FMStartFreq'),...
        get(o,'FMEndFreq'),...
        get(o,'Duration'));
end
index = get(T,'MaxIndex');
if index>1, index = ceil(rand(1)*index); end
[w, events] = waveform(T, index);
% We need to have the same number of events for all targets. The only one
% that has to be modified is Tone In Torc:
if TargetIndex==2
    [temp,remain] = strtok(events(4).Note);
    for cnt1=1:3
        events(cnt1).Note = [events(cnt1).Note remain];
    end
    events(4:end)=[];
end
for cnt1 = 1:length(events)
    events(cnt1).Note = [events(cnt1).Note ' | ' get(T,'descriptor')];
end
clear T;
w = 5*(w/max(abs(w)));