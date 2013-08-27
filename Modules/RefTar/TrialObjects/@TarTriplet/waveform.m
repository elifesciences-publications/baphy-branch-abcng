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

TripletRovedB = get(o,'TripletRovedB');
RefdB = get(o,'RefdB');

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
        ev(cnt2).Rove{1} = TripletRovedB{TrialIndex};

    end
    LastEvent = ev(end).StopTime;
    w = 5 * w / max(abs(w(:)));
    ramp = hanning(round(.001 * get(RefObject,'SamplingRate')*2));
    ramp = ramp(1:floor(length(ramp)/2));
    w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
    w(length(w)-length(ramp)+1:end) = w(length(w)-length(ramp)+1:end) .* flipud(ramp);

    ScaleFactor = 80-RefdB;
    TrialSound = [TrialSound; w / (10^(ScaleFactor/20))];

    events = [events ev];
end

RelativeTarRefdB = get(o,'RelativeTarRefdB');
if length(RelativeTarRefdB)>1, RelativeTarRefdB = RelativeTarRefdB(ceil(rand(1)*length(RelativeTarRefdB)));end

if isobject(TarObject)
    TarTrialIndex = par.TargetIndices{TrialIndex}; % get the index of reference sounds for current trial
    if get(TarObject,'SamplingRate')~=TrialSamplingRate,
        TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
    end
    % generate the target sound:
    TarObject = set(TarObject,'ScaleFactor',TripletRovedB{TrialIndex});
    [w, ev] = waveform(TarObject, TarTrialIndex, 0); % 0 means its target
    if size(w,2)>size(w,1),
        w=w';
    end
    
    TrialSound = [TrialSound ; w];
    
    % now, add Target to the note, correct the time stamp in respect to
    % last event, and add Trial
    for cnt2 = 1:length(ev)
        ev(cnt2).Note = [ev(cnt2).Note ' , Target , ' num2str(RelativeTarRefdB) 'dB' ];
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
        ev(cnt2).Rove{1} = TripletRovedB{TrialIndex};

    end
    LastEvent = ev(end).StopTime;
    events = [events ev];
    % normalize the sound, because the level control is always from attenuator.
%     if ~OverrideAutoScale,
%         TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
%     end
elseif TarObject == -1
    % sham trial:
    if isfield(get(par.TargetHandle),'ShamNorm'),
        if ~OverrideAutoScale,
            TrialSound = 5 * TrialSound / get(par.TargetHandle,'ShamNorm');
        end
    else
%         if ~OverrideAutoScale,
%             TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
%         end
%         if get(o,'RelativeTarRefdB')>0
%             TrialSound = TrialSound / (10^(get(o,'RelativeTarRefdB')/20));
%         end
    end
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
%disp(['outWFM:' num2str(max(abs(TrialSound)))])

o = set(o, 'SamplingRate', TrialSamplingRate);
