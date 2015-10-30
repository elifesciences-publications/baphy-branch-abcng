function [w,events] = waveform (o, index ,IsRef)
% waveform is a method of TorcToneDiscrim object. It returns the
% stimuli(Torc-gap-Tone) waveform (w) and event structure.

%if nargin<3, IsRef = 1;end
% first, create an instance of torc object:
global globalparams;
global exptparams_Copy;

w=[];
TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...                          % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'PostStimSilence'), ...     % Put half of gap after torc, the other half goes before tone
    get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
% now generate the tone object:
ToneObj = Tone(get(o, 'SamplingRate'),...
    0, ...               % No Loudness
    get(o, 'PreStimSilence')+get(o, 'ToneStart'),...     % PreStimSilence is half the gap between torc and tone
    get(o, 'PostStimSilence'),...
    get(o, 'ToneFreqs'),...
    get(o, 'ToneStop')-get(o,'ToneStart'));
% Now get the event and waveforms:
[wTorc, eTorc] = waveform(TorcObj, index);
[wTone, eTone] = waveform(ToneObj, index);   % tone does not have index, pass it anyway.
clear TorcObj ToneObj;
maxlength = max( length(wTorc), length(wTone) );
wTorc(end+1:maxlength) = 0;
wTone(end+1:maxlength) = 0;
if ~isempty(exptparams_Copy)
    if strcmpi(class(exptparams_Copy.TrialObject), 'RefTardBControl') & (globalparams.HWSetup== 0 | globalparams.HWSetup== 2 | globalparams.HWSetup== 4)% strcmpi(class(exptparams_Copy.TrialObject), 'RefTardBControl') &
        BaseV= get(o,'BaseV');
        BasedB= get(o,'BasedB');
        OveralldB = get(exptparams_Copy.TrialObject,'OveralldB');
        OutVoltage= BaseV*10^((OveralldB-BasedB)/20);
        wTone= OutVoltage*(wTone/max(abs(wTone)));
        disp(['tone: ' num2str(max(abs(wTone)))])
        wTorc= OutVoltage*(wTorc/max(abs(wTorc)));
        disp(['torc: ' num2str(max(abs(wTorc)))])
        wTone = wTone * 10^(get(o,'SNR')/20);
        disp(['toneMan: ' num2str(max(abs(wTone)))])
        w = wTorc + wTone;
    end
end
if globalparams.HWSetup== 1 | globalparams.HWSetup== 3 | globalparams.HWSetup== 5   
    wTone= 5*(wTone/max(abs(wTone)));
    disp(['tone: ' num2str(max(abs(wTone)))])
    wTorc= 5*(wTorc/max(abs(wTorc)));
    disp(['torc: ' num2str(max(abs(wTorc)))])
    wTone = wTone * 10^(get(o,'SNR')/20);
    disp(['toneMan: ' num2str(max(abs(wTone)))])
    w = wTorc + wTone;

    % disp(10^(get(o,'SNR')/20))
end
if ~isempty(w)
    disp(max(abs(w)))
end
events = eTone;
