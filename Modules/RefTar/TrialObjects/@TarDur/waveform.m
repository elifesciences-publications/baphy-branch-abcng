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

TarObject =[];
TarSamplingRate=0;
if (par.NumberOfTarPerTrial~=0) && ~strcmpi(par.TargetClass,'none')
    TarTrialIndex = par.TargetIndices{TrialIndex};
    if ~isempty(TarTrialIndex)  % if its not Sham
        TarObject = par.TargetHandle; % getthe target handle
        TarSamplingRate = ifstr2num(get(TarObject,'SamplingRate'));
        RandTarDur = get(TarObject,'Duration');
        if length(RandTarDur) == 1
            TarRoveDur = RandTarDur;
        else
            TarRoveDur = randsample(RandTarDur,1,'true');
        end
        
    else
        % this means there is a target but this trial is sham. ALthough
        % there is no target, we need to adjust the amplitude based on
        % RefTardB.
        TarObject = -1;
    end
end

RefLevel = par.RefLevel;
TarLevel = par.TarLevel;
ToneFrqs = get(o,'RandTarFrqs');
TrialSamplingRate = max(RefSamplingRate, TarSamplingRate);

if get(RefObject, 'SamplingRate')~=TrialSamplingRate,
    RefObject = set(RefObject, 'SamplingRate', TrialSamplingRate);
    
end


RefTrialIndex = par.ReferenceIndices{TrialIndex}; % get the index of reference sounds for current trial

TrialSound = []; % initialize the waveform
ind = 0;
events = [];
LastEvent = 0;

%Trial Sounds
for cnt1 = 1:length(RefTrialIndex)  % go through all the reference sounds in the trial
    
    TempRefObject = RefObject;
    [w_ref, ev_ref] = waveform(TempRefObject, RefTrialIndex(cnt1), TrialIndex); % 1 means its reference
    if size(w_ref,2)>size(w_ref,1),
        w_ref=w_ref';
    end
    w_ref = 5 * w_ref / max(abs(w_ref(:)));
    w_ref = w_ref / (10^((80-RefLevel)/20));
    ramp = hanning(round(.01 * get(RefObject,'SamplingRate')*2));
    ramp = ramp(1:floor(length(ramp)/2));
    w_ref(1:length(ramp)) = w_ref(1:length(ramp)) .* ramp;
    w_ref(length(w_ref)-length(ramp)+1:end) = w_ref(length(w_ref)-length(ramp)+1:end) .* flipud(ramp);
    
    TrialSound = [TrialSound; w_ref];
    
    for cnt2 = 1:length(ev_ref)
        ev(cnt2).Note = [ev_ref(cnt2).Note ' , Reference'];
        ev(cnt2).StartTime = ev_ref(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev_ref(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
        ev(cnt2).Rove = [RefTrialIndex];
        
    end
    
    events = [events ev];
    LastEvent = ev(end).StopTime;
    
end

if isobject(TarObject)
    if ~strcmp(par.TargetClass,'Tarc')
ToneFrq  = ToneFrqs(TrialIndex);
end

    TempTarObject = TarObject;
    if ~strcmp(par.TargetClass,'Tarc')
        f1 = round(ToneFrq);
        TempTarObject = set(TempTarObject,'Duration',TarRoveDur);
        TempTarObject = set(TempTarObject,'Names',num2str(f1));
        TempTarObject = set(TempTarObject,'Frequencies',f1);
        [w_tar, ev_tar] = waveform(TempTarObject, 1, 0); % 0 means its target
        w_tar = 5 * w_tar / max(abs(w_tar(:)));
        w_tar = w_tar / (10^((80-TarLevel)/20));
        ramp = hanning(round(.01 * get(TarObject,'SamplingRate')*2));
        ramp = ramp(1:floor(length(ramp)/2));
        w_tar(1:length(ramp)) = w_tar(1:length(ramp)) .* ramp;
        w_tar(length(w_tar)-length(ramp)+1:end) = w_tar(length(w_tar)-length(ramp)+1:end) .* flipud(ramp);
        
    else
        TarTrialIndex = par.TargetIndices{TrialIndex}; % get the index of reference sounds for current trial
        TempTarObject = TarObject;
        [w_tar, ev_tar] = waveform(TempTarObject, TarTrialIndex, 0); % 0 means its target
        w_tar = 5 * w_tar / max(abs(w_tar(:)));
        w_tar = w_tar / (10^((80-TarLevel)/20));
        ramp = hanning(round(.01 * get(TarObject,'SamplingRate')*2));
        ramp = ramp(1:floor(length(ramp)/2));
        w_tar(1:length(ramp)) = w_tar(1:length(ramp)) .* ramp;
        w_tar(length(w_tar)-length(ramp)+1:end) = w_tar(length(w_tar)-length(ramp)+1:end) .* flipud(ramp);
        f1 = get(TarObject,'Rates');
    end
        
    TrialSound = [TrialSound; w_tar];
    
    for cnt2 = 1:length(ev_tar)
        ev_tar(cnt2).Note = [ev_tar(cnt2).Note ' , Target' ];
        ev_tar(cnt2).StartTime = ev_tar(cnt2).StartTime + LastEvent;
        ev_tar(cnt2).StopTime = ev_tar(cnt2).StopTime + LastEvent;
        ev_tar(cnt2).Trial = TrialIndex;
        ev_tar(cnt2).Rove = [TarRoveDur f1];
        
    end
    events = [events ev_tar];
end

if max(abs(TrialSound(:)))>5,
    warning('max(abs(TrialSound))>5!  May having clipping problem!')
end

o = set(o, 'SamplingRate', TrialSamplingRate);

%2nd AO channel use for control MASTEWRFLEX flow rate.....pby added 10/06/2011
pumppro=ifstr2num(par.PumpProfile);
if length(pumppro)==1 & pumppro(1)==0
    return;  %not required for pump control
else
    pumppro(2:end)=10*pumppro(2:3)/6  %convert the flow rate (ml/min)to VDC. 10 V= 6.0 ml/min
    TrialSound(:,2)=pumppro(2);    %set constant speed
    if length(pumppro)==3
        if pumppro(1)==1     %low flow rate inter_trial_interval
            delay1=events(1).StopTime/2;                %high flow rate start before stimulus on
            delay1=(delay1*TrialSamplingRate);
            delay2=events(end).StopTime-.15;  %high flow rate extended during post-silence
            delay2=round(delay2*TrialSamplingRate);   %10 samples for set flow rate back to low
            TrialSound(delay1:delay2,2)=pumppro(3);
        else pumppro(1)==2   %low flow arte during both ISI ans ITI, high during stimulus
            TrialSound(find(TrialSound(:,1)),2)=pumppro(2); %high speed during sound
        end
    end
end


