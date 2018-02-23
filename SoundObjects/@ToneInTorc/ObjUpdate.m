function o = ObjUpdate (o)
% ObjUpdate updates the fields of TorcToneDiscrim object after any set
% command. Names is set to be the name of torc plus the tone. max index is
% the maxindex of Torc.

global exptparams_Copy;
global globalparams;
NoiseType = get(o,'NoiseType');
o = set(o,'NoiseType',NoiseType(1:(find(isletter(NoiseType),1,'last'))));
% Create a torc object with correct fields:
switch get(o,'NoiseType')
    case 'TORC'
        TorcObj = Torc(get(o,'SamplingRate'),...
            0, ...               % No Loudness
            get(o,'PreStimSilence'), ...        % Put the PreStimSilence before torc.
            get(o,'PostStimSilence'), ...       %
            get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
    case 'Noise'
        TorcObj = Noise();
        TorcObj = set(TorcObj,'LowFreq',1000);
        TorcObj = set(TorcObj,'HighFreq',16000);
        TorcObj = set(TorcObj,'TonesPerBurst',20);
        TorcObj = set(TorcObj ,'Duration',get(o,'TorcDuration'));   
        TorcObj = ObjUpdate(TorcObj);
end
% now generate the tone object:
ToneObj = RandomTone();
ToneObj = set(ToneObj,'SamplingRate',get(o,'SamplingRate'));
ToneObj = set(ToneObj,'PreStimSilence',get(o,'PreStimSilence'));
ToneObj = set(ToneObj,'PostStimSilence',get(o,'PostStimSilence'));
ToneObj = set(ToneObj,'BaseFrequency',get(o,'BaseFrequency'));
ToneObj = set(ToneObj,'OctaveBelow',get(o,'OctaveBelow'));
ToneObj = set(ToneObj,'OctaveAbove',get(o,'OctaveAbove'));
ToneObj = set(ToneObj,'TonesPerOctave',get(o,'TonesPerOctave'));
ToneObj = ObjUpdate(ToneObj);
% now merge the names:
Torcnames = get(TorcObj, 'Names');
Tonenames = get(ToneObj, 'Names');
Names = cell(0,0);
SnrLst = get(o,'SNR');
for SnrNum = 1:length(SnrLst)
    for ToneNum = 1:length(Tonenames)
        Names(length(Names)+(1:length(Torcnames))) = strcat(Torcnames, ' | ', Tonenames{ToneNum}, '|', 'SNR: ', num2str(SnrLst(SnrNum)));
    end
end
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


o = set(o,'ShamNorm',max(abs(w)));
%disp(['loudness: ' num2str(get(o,'Loudness'))])
