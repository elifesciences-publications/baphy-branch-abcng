function [w,events] = waveform (o, index ,IsRef)
% waveform is a method of TorcToneDiscrim object. It returns the
% stimuli(Torc-gap-Tone) waveform (w) and event structure.

%if nargin<3, IsRef = 1;end
% first, create an instance of torc object:
global globalparams;
global exptparams_Copy;

w=[];
% now generate the tone object:
ToneObj = RandomTone();
ToneObj = set(ToneObj,'SamplingRate',get(o,'SamplingRate'));
ToneObj = set(ToneObj,'PreStimSilence',get(o,'PreStimSilence')+get(o, 'ToneStart'));
ToneObj = set(ToneObj,'PostStimSilence',get(o,'PostStimSilence'));
ToneObj = set(ToneObj,'BaseFrequency',get(o,'BaseFrequency'));
ToneObj = set(ToneObj,'OctaveBelow',get(o,'OctaveBelow'));
ToneObj = set(ToneObj,'OctaveAbove',get(o,'OctaveAbove'));
ToneObj = set(ToneObj,'TonesPerOctave',get(o,'TonesPerOctave'));
ToneObj = set(ToneObj,'Duration',get(o,'ToneStop')-get(o,'ToneStart'));
ToneObj = ObjUpdate(ToneObj);
% ToneObj = Tone(get(o, 'SamplingRate'),...
%     0, ...               % No Loudness
%     get(o, 'PreStimSilence')+get(o, 'ToneStart'),...     % PreStimSilence is half the gap between torc and tone
%     get(o, 'PostStimSilence'),...
%     get(o, 'ToneFreqs'),...
%     get(o, 'ToneStop')-get(o,'ToneStart'));
% Now get the event and waveforms:
switch get(o,'NoiseType')
    case 'TORC'
        TorcObj = Torc(get(o,'SamplingRate'),...
            0, ...                          % No Loudness
            get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
            get(o,'PostStimSilence'), ...     % Put half of gap after torc, the other half goes before tone
            get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
    case 'Noise'
        TorcObj = Noise();
        TorcObj = set(TorcObj ,'Duration',get(o,'TorcDuration'));
        TorcObj = set(TorcObj ,'PreStimSilence',get(o,'PreStimSilence'));
        TorcObj = set(TorcObj ,'PostStimSilence',get(o,'PostStimSilence'));   
        TorcObj = ObjUpdate(TorcObj);
end
TorcLen = length(get(TorcObj, 'Names'));
ToneLen = length(get(ToneObj, 'Names'));
SnrLst = get(o,'SNR');
SnrInd = floor((index-1)/(TorcLen*ToneLen))+1;
SNR = SnrLst(SnrInd);
index = index - (SnrInd-1)*ToneLen*TorcLen;
ToneIndex = floor((index-1)/TorcLen)+1;
TORCindex = index-TorcLen*(ToneIndex-1);
[wTorc,eTorc] = waveform(TorcObj, TORCindex);
[wTone, eTone] = waveform(ToneObj, ToneIndex);   % tone does not have index, pass it anyway.
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
        wTone = wTone * 10^(SNR/20);
        disp(['toneMan: ' num2str(max(abs(wTone)))])
        w = wTorc + wTone;
    end
end
if globalparams.HWSetup== 1 | globalparams.HWSetup== 3 | globalparams.HWSetup== 5 | globalparams.HWSetup== 6
    if 0 %18/02-JN/YB
    wTone= 5*(wTone/max(abs(wTone)));
%     disp(['tone: ' num2str(max(abs(wTone)))])
    wTorc= 5*(wTorc/max(abs(wTorc)));
%     disp(['torc: ' num2str(max(abs(wTorc)))])
    else
    wTone= 5*(wTone/std(wTone(wTorc~=0)));
    wTorc= 5*(wTorc/std(wTorc(wTorc~=0)));
    end
    
    wTone = wTone * 10^(SNR/20);
%     disp(['toneMan: ' num2str(max(abs(wTone)))])
    w = wTorc + wTone;
    w = 5*(w/std(w(wTorc~=0)));
    % disp(10^(get(o,'SNR')/20))
    eTone(2).Note = [eTone(2).Note ' SNR ' num2str(SNR)];
end
if ~isempty(w)
%     disp(max(abs(w)))
end
events = eTone;
