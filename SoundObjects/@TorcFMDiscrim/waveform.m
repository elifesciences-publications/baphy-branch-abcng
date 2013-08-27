function [w,events] = waveform (o, index,IsRef)
% waveform is a method of TorcFMDiscrim object. It returns the
% stimuli(Torc-gap-FM) waveform (w) and event structure.

% first, create an instance of torc object:
TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'TorcFMGap')/2, ...     % Put half of gap after torc, the other half goes before FM
    get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
% now generate the FM object:
FMObj = FMSweep(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o, 'TorcFMGap')/2,...     % PreStimSilence is half the gap between torc and FM
    get(o, 'PostStimSilence'),...
    get(o, 'FMStartFrequency'),...
    get(o, 'FMEndFrequency'),...
    get(o, 'FMDuration'));
% Now get the event and waveforms:
[wTorc, eTorc] = waveform(TorcObj, index);
[wFM, eFM] = waveform(FMObj, 1);   % FM does not have index, pass it anyway.
clear TorcObj FMObj;
for cnt1 = 1:length(eFM);
    eFM(cnt1).StartTime = eFM(cnt1).StartTime + eTorc(end).StopTime;
    eFM(cnt1).StopTime  = eFM(cnt1).StopTime  + eTorc(end).StopTime;
end
if isfield(get(o),'TorcFMDB'),
    wFM = wFM / (10^(get(o,'TorcFMDB')/20));
end
w = [wTorc(:); wFM(:)];
events = [eTorc eFM];