function [w,events] = waveform (o, index,IsRef);
% waveform is a method of TorcToneDiscrim object. It returns the
% stimuli(Torc-gap-Tone) waveform (w) and event structure.
% first, create an instance of torc object:


TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...                          % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'TorcToneGap')/2, ...     % Put half of gap after torc, the other half goes before tone
    get(o,'TorcDuration'), ...
    get(o,'TorcFreqRange'), ...
    get(o,'TorcRates'));

% now generate the tone object:
ToneObj = RandomAM( get(o, 'TorcToneGap')/2,...     % PreStimSilence is half the gap between torc and tone
    get(o, 'PostStimSilence'),...
    get(o, 'BaseFundamental'),...
    get(o, 'TonesPerOctave'),...
    get(o, 'ToneDuration'),...
    get(o, 'AMFreq'),...
    get(o, 'AMDepth'),...    
    get(o, 'NumOfHarmonics'));

% Now get the event and waveforms:
[wTorc, eTorc] = waveform(TorcObj, index);   % tone has the random index
[wTone, eTone] = waveform(ToneObj, index);   % tone does not have index, pass it anyway

clear TorcObj ToneObj;

for cnt1 = 1:length(eTone);
    eTone(cnt1).StartTime = eTone(cnt1).StartTime + eTorc(end).StopTime;
    eTone(cnt1).StopTime  = eTone(cnt1).StopTime  + eTorc(end).StopTime;
end

w = [wTorc(:); wTone(:)];
events = [eTorc eTone];