function o = ObjUpdate (o)
% ObjUpdate updates the fields of TorcToneDiscrim object after any set
% command. Names is set to be the name of torc plus the tone. max index is
% the maxindex of Torc.

global exptparams_Copy;
global globalparams;

% Create a torc object with correct fields:
TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o,'PreStimSilence'), ...        % Put the PreStimSilence before torc.
    get(o,'PostStimSilence'), ...       % 
    get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
% now generate the tone object:
ToneObj = Tone(get(o,'SamplingRate'),...
    0, ...                   % No Loudness
    get(o, 'PreStimSilence'),...        % PreStimSilence is the same as TORC
    0,...                               % PostStimSilence is zero for ToneInTorc
    get(o, 'ToneFreqs'),...
    1);
% now merge the names:
Torcnames = get(TorcObj, 'Names');
Tonenames = get(ToneObj, 'Names');
Names = strcat(Torcnames, ' | ', Tonenames, '|', 'SNR: ', num2str(get(o,'SNR')));
o = set(o,'Names',Names);
o = set(o,'MaxIndex', length(Names));

w = waveform(o,1,0);
if ~isempty(exptparams_Copy) & strcmpi(exptparams_Copy.TrialObjectClass,'RefTardBControl' )
    OveralldB = get(exptparams_Copy.TrialObject,'OveralldB');
    if strcmpi(class(exptparams_Copy.TrialObject), 'RefTardBControl')
        BasedB = get(exptparams_Copy.TrialObject,'BasedB');
        BaseV = get(exptparams_Copy.TrialObject,'BaseV');
        o = set(o,'BasedB',BasedB);
        o = set(o,'BaseV',BaseV);
    end
    loudness=  round(20*log10(abs(max(w))/5)+ OveralldB);
    o = set(o,'Loudness',loudness);
    
end