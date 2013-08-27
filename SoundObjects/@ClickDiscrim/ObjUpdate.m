function o = ObjUpdate (o);
% ObjUpdate updates the fields of ClickDiscrim object after any set
% command. Names is set to be the name of torc plus the Click. max index is
% the maxindex of Torc.

% Create a torc object with correct fields:
TorcObj = Torc(get(o,'SamplingRate'),...
    0,...                           % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'TorcClickGap')/2, ...    % Put half of gap after torc, the other half goes before tone
    get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
% now generate the tone object:
ClickObj = Click(get(o,'SamplingRate'),...
    0, ...                          % No Loudness
    get(o, 'TorcClickGap')/2,...    % PreStimSilence is half the gap between torc and tone
    get(o, 'PostStimSilence'),...
    get(o, 'ClickWidth'),...
    get(o, 'ClickRate'),...
    get(o, 'ClickDuration'));
% now merge the names:
Torcnames = get(TorcObj, 'Names');
Clicknames = get(ClickObj, 'Names');
if length(Clicknames)==1,
    Names = strcat(Torcnames, ' | ', Clicknames);
else
    Names = Torcnames;
end
o = set(o,'Names',Names);
o = set(o,'MaxIndex', length(Names));
o = set(o,'params',get(TorcObj,'params'));
clear TorcObj ClickObj;