function [TrialSound, events , o] = waveform (o,TrialIndex)
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. This is a generic script
% that works for all passive cases, all active cases that use a standard
% SoundObject (e.g. tone). You can overload it by writing your own waveform.m
% script and copying it in your object's folder.

% Nima Mesgarani, October 2005

par = get(o); % get the parameters of the trial object
RefObject = par.ReferenceHandle; % get the reference handle
RefSamplingRate = ifstr2num(get(RefObject, 'SamplingRate'));
%
TarObject =[];
TarSamplingRate = 0;
if (par.NumberOfTarPerTrial~=0) && ~strcmpi(par.TargetClass,'none')
    TarTrialIndex = par.TargetIndices{TrialIndex};
    if ~isempty(TarTrialIndex)  % if its not Sham
        TarObject = par.TargetHandle; % getthe target handle
        TarSamplingRate = ifstr2num(get(TarObject,'SamplingRate'));
    else
        % this means there is a target but this trial is sham. ALthough
        % there is no target, we need to adjust the amplitude based on
        % RefTardB.
        TarObject = -1;
    end
end
TrialSamplingRate = max(RefSamplingRate, TarSamplingRate);
if get(RefObject, 'SamplingRate')~=TrialSamplingRate,
    RefObject = set(RefObject, 'SamplingRate', TrialSamplingRate);
end
%
RefTrialIndex = par.ReferenceIndices{TrialIndex}; % get the index of reference sounds for current trial
TrialSound = []; % initialize the waveform
ind = 0;
events = [];
LastEvent = 0;

if any(strcmp(fieldnames(RefObject),'OverrideAutoScale')),
    OverrideAutoScale=get(RefObject,'OverrideAutoScale');
else
    OverrideAutoScale=0;
end

RoveLeveldB = get(o,'RoveLevelsdB');
RoveRefs = get(o,'RoveRefs');

% generate the reference sound
for cnt1 = 1:length(RefTrialIndex)  % go through all the reference sounds in the trial
    if (cnt1==1) && get(o,'NoPreStimForFirstRef')
        RefPreStim = get(RefObject,'PreStimSilence');
        RefObject = set(RefObject,'PreStimSilence',0);
    end
    
    [w, ev] = waveform(RefObject, RefTrialIndex(cnt1),TrialIndex); % 1 means its reference
    if (cnt1==1) && get(o,'NoPreStimForFirstRef')
        RefObject = set(RefObject,'PreStimSilence',RefPreStim);
    end
    if size(w,2)>size(w,1),
        w=w';
    end
    % now, add reference to the note, correct the time stamp in respect to
    % last event, and add Trial
    for cnt2 = 1:length(ev)
        ev(cnt2).Note = [ev(cnt2).Note ' , Reference'];
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
        if iscell(RoveLeveldB)
            ev(cnt2).Rove{1} = RoveLeveldB{TrialIndex}(1:length(RefTrialIndex));
        else
            ev(cnt2).Rove{1} = RoveLeveldB(TrialIndex);
        end        
    end
    LastEvent = ev(end).StopTime;
    w = 5 * w / max(abs(w(:)));
    ramp = hanning(round(.001 * get(RefObject,'SamplingRate')*2));
    ramp = ramp(1:floor(length(ramp)/2));
    w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
    w(length(w)-length(ramp)+1:end) = w(length(w)-length(ramp)+1:end) .* flipud(ramp);
    
    if RoveRefs == 0
        TrialSound = [TrialSound ;w];
        
    else
        RoveScaleFactor = 80-RoveLeveldB{TrialIndex}(cnt1);
        TrialSound = [TrialSound ;w / (10^(RoveScaleFactor/20))];
        
    end
    
    events = [events ev];
    
end

%Set TrialSound Rove Level (dB)
if RoveRefs == 0
    TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
    RoveScaleFactor = 80-RoveLeveldB(TrialIndex);
    TrialSound = TrialSound / (10^(RoveScaleFactor/20));
    
end

RelativeTarRefdB = get(o,'RelativeTarRefdB');
if length(RelativeTarRefdB)>1, RelativeTarRefdB = RelativeTarRefdB(ceil(rand(1)*length(RelativeTarRefdB)));end

if isobject(TarObject)
    TarTrialIndex = par.TargetIndices{TrialIndex}; % get the index of reference sounds for current trial
    if get(TarObject,'SamplingRate')~=TrialSamplingRate,
        TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
    end
    
    % generate the target sound:
    [w, ev] = waveform(TarObject, TarTrialIndex, 0); % 0 means its target
    
    if size(w,2)>size(w,1),
        w=w';
    end
    
    if isempty(strfind(upper(class(TarObject)),'TONEINROVINGTORC'))
        
        if isempty(strfind(upper(class(TarObject)),'DISCRIM'))
            if size(TrialSound,2)<size(w,2),
                TrialSound=[TrialSound zeros(length(TrialSound),1)];
            end
            
            if RoveRefs == 0
                w = 5 * w / max(abs(w(:)));
                RoveScaleFactor = 80-RoveLeveldB(TrialIndex);
                TrialSound = [TrialSound ;w / (10^(RoveScaleFactor/20));];
                
            else
                w = 5 * w / max(abs(w(:)));
                RoveScaleFactor = 80-RoveLeveldB{TrialIndex}(length(RefTrialIndex)+1);
                TrialSound = [TrialSound ;w / (10^(RoveScaleFactor/20))];
                
            end
            
        end
        
    else
        
        wTorc = w(:,1);
        wTone = w(:,2);
        
        if isempty(strfind(upper(class(TarObject)),'DISCRIM'))
            if size(TrialSound,2)<size(wTorc,2),
                TrialSound=[TrialSound zeros(length(TrialSound),1)];
            end
            
            if RoveRefs == 0
                RoveScaleFactor = 80-RoveLeveldB(TrialIndex);
                wTorc = wTorc / (10^(RoveScaleFactor/20));
                SNRScaleFactor = 80-(RoveLeveldB(TrialIndex) + get(TarObject,'SNR'));
                wTone = wTone / 10^(SNRScaleFactor/20);
                w = wTorc+wTone;
                ramp = hanning(round(.001 * get(RefObject,'SamplingRate')*2));
                ramp = ramp(1:floor(length(ramp)/2));
                w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
                w(length(w)-length(ramp)+1:end) = w(length(w)-length(ramp)+1:end) .* flipud(ramp);
                TrialSound = [TrialSound ;w];
                
            else
                RoveScaleFactor = 80-RoveLeveldB{TrialIndex}(length(RefTrialIndex)+1);
                wTorc = wTorc / (10^(RoveScaleFactor/20));
                SNRScaleFactor = 80-(RoveLeveldB{TrialIndex}(length(RefTrialIndex)+1) + get(TarObject,'SNR'));
                wTone = wTone / 10^(SNRScaleFactor/20);
                w = wTorc+wTone;
                ramp = hanning(round(.001 * get(RefObject,'SamplingRate')*2));
                ramp = ramp(1:floor(length(ramp)/2));
                w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
                w(length(w)-length(ramp)+1:end) = w(length(w)-length(ramp)+1:end) .* flipud(ramp);
                TrialSound = [TrialSound ;w];
                
            end
            
        end
        
        ramp = hanning(round(.001 * get(RefObject,'SamplingRate')*2));
        ramp = ramp(1:floor(length(ramp)/2));
        w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
        w(length(w)-length(ramp)+1:end) = w(length(w)-length(ramp)+1:end) .* flipud(ramp);
        
    end
    
    % now, add Target to the note, correct the time stamp in respect to
    % last event, and add Trial
    for cnt2 = 1:length(ev)
        ev(cnt2).Note = [ev(cnt2).Note ' , Target , ' num2str(RelativeTarRefdB) 'dB' ];
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
        
        if iscell(RoveLeveldB)
            ev(cnt2).Rove{1} = RoveLeveldB{TrialIndex}(length(RefTrialIndex)+1);
        else
            ev(cnt2).Rove{1} = RoveLeveldB(TrialIndex);
            
        end
                
    end
    LastEvent = ev(end).StopTime;
    events = [events ev];
end

if OverrideAutoScale && max(abs(TrialSound(:)))>5,
    warning('max(abs(TrialSound))>5!  May having clipping problem!')
end

Refloudness = get(RefObject,'Loudness');
if isobject(TarObject)
    Tarloudness = get(TarObject,'Loudness');
else
    Tarloudness = 0;
end

o = set(o, 'SamplingRate', TrialSamplingRate);
