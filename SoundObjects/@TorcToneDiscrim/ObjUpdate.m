function o = ObjUpdate (o)
% ObjUpdate updates the fields of TorcToneDiscrim object after any set
% command. Names is set to be the name of torc plus the tone. max index is
% the maxindex of Torc.

% Create a torc object with correct fields:
TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'TorcToneGap')/2, ...     % Put half of gap after torc, the other half goes before tone
    get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
% now generate the tone object:
% new: if more than one frequency is specified, it means it has to be a
% random selection in that range.
AllFreq = get(o,'ToneFreqs');
    % randomly choose one:
ToneFrequency = AllFreq(ceil(rand(1)*length(AllFreq)));
ToneObj = Tone(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o, 'TorcToneGap')/2,...     % PreStimSilence is half the gap between torc and tone
    get(o, 'PostStimSilence'),...
    ToneFrequency ,...
    get(o, 'ToneDuration'),...
    get(o, 'ToneGap'));
% now merge the names:
Torcnames = get(TorcObj, 'Names');
Tonenames = get(ToneObj, 'Names');
Names = strcat(Torcnames, ' | ', Tonenames);
o = set(o,'Names',Names);
o = set(o,'MaxIndex', length(Names));
o = set(o,'CurrentToneFreq',ToneFrequency);