function o = ObjUpdate (o)
% ObjUpdate updates the fields of TorcFMDiscrim object after any set
% command. Names is set to be the name of torc plus the FM. max index is
% the maxindex of Torc.

% Create a torc object with correct fields:
TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'TorcFMGap')/2, ...     % Put half of gap after torc, the other half goes before FM
    get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
% now generate the FM object:
% new: if more than one frequency is specified, it means it has to be a
% random selection in that range.
FMObj = FMSweep(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o, 'TorcFMGap')/2,...     % PreStimSilence is half the gap between torc and FM
    get(o, 'PostStimSilence'),...
    get(o, 'FMStartFrequency') ,...
    get(o, 'FMEndFrequency'),...
    get(o, 'FMDuration'));
% now merge the names:
Torcnames = get(TorcObj, 'Names');
FMnames = get(FMObj, 'Names');
Names = strcat(Torcnames, ' | ', FMnames);
o = set(o,'Names',Names);
o = set(o,'MaxIndex', length(Names));