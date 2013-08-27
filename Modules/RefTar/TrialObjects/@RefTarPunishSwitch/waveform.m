function [TrialSound, events , o] = waveform (o,TrialIndex)
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. This is a generic script
% that works for all passive cases, all active cases that use a standard
% SoundObject (e.g. tone). You can overload it by writing your own waveform.m
% script and copying it in your object's folder.

% Nima Mesgarani, October 2005

par = get(o);

RefObject = par.ReferenceHandle;
RefSamplingRate = ifstr2num(get(RefObject, 'SamplingRate'));
RefLevel = par.RefLevel;
RefDurs = get(RefObject,'Duration');

TarObject = par.TargetHandle;
TarSamplingRate = ifstr2num(get(TarObject,'SamplingRate'));
TarLevel = par.TarLevel;
ExpType = get(TarObject,'ExpType');
TarProb = get(TarObject,'TarProb');
TarDurs = get(TarObject,'Duration');

TrialSamplingRate = max(RefSamplingRate, TarSamplingRate);
if get(RefObject, 'SamplingRate')~=TrialSamplingRate,
    RefObject = set(RefObject, 'SamplingRate', TrialSamplingRate);
    
end
if get(TarObject, 'SamplingRate')~=TrialSamplingRate,
    TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
    
end
o = set(o, 'SamplingRate', TrialSamplingRate);

RefTrialIndex = par.ReferenceIndices{TrialIndex};
NumSounds = length(RefTrialIndex);

eval(['[TrialSound events o] = ',ExpType,'(o, RefObject, RefLevel, RefDurs, TarObject, TarLevel, TarProb, TarDurs, TrialSamplingRate, TrialIndex, NumSounds, RefTrialIndex);']);


