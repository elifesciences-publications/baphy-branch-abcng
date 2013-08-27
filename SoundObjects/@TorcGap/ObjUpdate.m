function o = ObjUpdate (o);
% ObjUpdate updates the fields of ClickDiscrim object after any set
% command. Names is set to be the name of torc plus the Click. max index is
% the maxindex of Torc.

% Create a torc object with correct fields:
TorcObj = Torc(get(o,'SamplingRate'),...
    0,...                           % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'PostStimSilence')/2, ...    % Put half of gap after torc, the other half goes before tone
    get(o,'Duration'), get(o,'FreqRange'), get(o,'Rates'));
% now merge the names:
Torcnames = get(TorcObj, 'Names');
Names = strcat(Torcnames, ' | ', ' Gap');
o = set(o,'Names',Names);
o = set(o,'MaxIndex', length(Names));
clear TorcObj;
