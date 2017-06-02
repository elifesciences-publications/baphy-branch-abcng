function [w,events] = waveform (o, index,IsRef)
% waveform is a method of TorcToneDiscrim object. It returns the
% stimuli(Torc-gap-Tone) waveform (w) and event structure.

switch get(o,'RandomInterval')
  case 'no '  % fixed interval
    TorcToneGap = get(o,'TorcToneGap');
  case 'yes'
    TorcToneGapList = get(o,'TorcToneGap');
    TorcToneGap = TorcToneGapList(randi(length(TorcToneGapList),1));
end


% first, create an instance of torc object:
TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    TorcToneGap/2, ...     % Put half of gap after torc, the other half goes before tone
    get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
% now generate the tone object:
ToneObj = Tone(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    TorcToneGap/2,...     % PreStimSilence is half the gap between torc and tone
    get(o, 'PostStimSilence'),...
    get(o, 'CurrentToneFreq'),...
    get(o, 'ToneDuration'),...
    get(o, 'ToneGap'));
% Now get the event and waveforms:
[wTorc, eTorc] = waveform(TorcObj, index);
if ~isempty(strfind(eTorc(end-1).Note,' Reference')); eTorc(end-1).Note(strfind(eTorc(end-1).Note,' Reference'):end) = []; end% 16/10: YB We remove the Reference note for the TORC
if ~isempty(strfind(eTorc(end-1).Note,' Target')); eTorc(end-1).Note(strfind(eTorc(end-1).Note,' Target')+(0:6)) = []; end% 16/10: YB We remove the Target note for the TORC
[wTone, eTone] = waveform(ToneObj, 1);   % tone does not have index, pass it anyway.
clear TorcObj ToneObj;
for cnt1 = 1:length(eTone);
    eTone(cnt1).StartTime = eTone(cnt1).StartTime + eTorc(end).StopTime;
    eTone(cnt1).StopTime  = eTone(cnt1).StopTime  + eTorc(end).StopTime;
end
if isfield(get(o),'TorcToneDB'),
    wTone = wTone / (10^(get(o,'TorcToneDB')/20));
end
w = [wTorc(:); wTone(:)];
events = [eTorc eTone];