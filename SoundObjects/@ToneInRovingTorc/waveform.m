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
    if (strcmpi(class(exptparams_Copy.TrialObject), 'RovingRefTar')) & (globalparams.HWSetup== 0 | globalparams.HWSetup== 2 | globalparams.HWSetup== 4)% strcmpi(class(exptparams_Copy.TrialObject), 'RefTardBControl') &
        wTone= 5*(wTone/max(abs(wTone)));
        wTorc= 5*(wTorc/max(abs(wTorc)));      
        w(:,1) = wTorc;
        w(:,2) = wTone;

    end
end
if globalparams.HWSetup== 1 | globalparams.HWSetup== 3 | globalparams.HWSetup== 5   
        wTone= 5*(wTone/max(abs(wTone)));
        wTorc= 5*(wTorc/max(abs(wTorc)));
        w(:,1) = wTorc;
        w(:,2) = wTone;
end
events = [eTorc eTone];

    