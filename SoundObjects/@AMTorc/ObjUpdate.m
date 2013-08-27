function o = ObjUpdate (o);
% ObjUpdate updates the fields of AMTorc object after any set
% command. Names is set to be the name of torc plus the tone. max index is
% the maxindex of Torc.

% Create a torc object with correct fields:
TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...                          % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'TorcToneGap')/2, ...     % Put half of gap after torc, the other half goes before tone
    get(o,'TorcDuration'),...
    get(o,'TorcFreqRange'),...
    get(o,'TorcRates'));

% now generate the tone object:
ToneObj = RandomAM(get(o, 'TorcToneGap')/2,...     % PreStimSilence is half the gap between torc and tone
    get(o, 'PostStimSilence'),...
    get(o, 'BaseFundamental'),...
    get(o, 'TonesPerOctave'),...
    get(o, 'ToneDuration'),...
    get(o, 'AMFreq'),...
    get(o, 'AMDepth'),...    
    get(o, 'NumOfHarmonics'));

% now merge the names:
Names = get(TorcObj, 'Names');
% Tonenames = get(ToneObj, 'Names');
params = get(TorcObj,'params');

%Names = strcat(Torcnames, ' | ', Tonenames);

o = set(o,'Names',Names); % pass the index for the random shuffle
o = set(o,'MaxIndex', length(Names));
o = set(o,'params',params);