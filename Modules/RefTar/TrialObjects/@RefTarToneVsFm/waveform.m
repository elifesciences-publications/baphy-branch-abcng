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
TarObject = par.TargetHandle; % getthe target handle
RandBand = get(TarObject,'RandBand');
TarSamplingRate = ifstr2num(get(TarObject,'SamplingRate'));
RefLevel = par.RefLevel;
TarLevel = par.TarLevel;
TrialSamplingRate = max(RefSamplingRate, TarSamplingRate);
if get(RefObject, 'SamplingRate')~=TrialSamplingRate,
    RefObject = set(RefObject, 'SamplingRate', TrialSamplingRate);
    
end

RefTrialIndex = par.ReferenceIndices{TrialIndex}; % get the index of reference sounds for current trial
TarTrialIndex = par.FMorTone{TrialIndex}; % get the index of reference sounds for current trial
TrialSound = []; % initialize the waveform
ind = 0;
events = [];
LastEvent = 0;

RefDur = get(RefObject,'Duration');
TarDur = get(TarObject,'Duration');
for i = 1:length(TarTrialIndex)
    switch TarTrialIndex(i)
        case 1
            TarRoveDur(i)=TarDur(1);
        case 2
            TarRoveDur(i)=TarDur(2);
        case 3
            TarRoveDur(i)=TarDur(1);
        case 4
            TarRoveDur(i)=TarDur(2);
    end
end


% generate the reference sound
for cnt1 = 1:length(RefTrialIndex)  % go through all the reference sounds in the trial
    
    TempRefObject = RefObject;
    TempRefObject = set(TempRefObject,'Duration',RefDur);
    [w_ref, ev_ref] = waveform(TempRefObject, RefTrialIndex(cnt1),TrialIndex); % 1 means its reference
    if size(w_ref,2)>size(w_ref,1),
        w_ref=w_ref';
    end
    w_ref = 5 * w_ref / max(abs(w_ref(:)));
    w_ref = w_ref / (10^((80-RefLevel)/20));
    ramp = hanning(round(.005 * get(RefObject,'SamplingRate')*2));
    ramp = ramp(1:floor(length(ramp)/2));
    w_ref(1:length(ramp)) = w_ref(1:length(ramp)) .* ramp;
    w_ref(length(w_ref)-length(ramp)+1:end) = w_ref(length(w_ref)-length(ramp)+1:end) .* flipud(ramp);
    
    TempTarObject = TarObject;
    TempTarObject = set(TempTarObject,'Duration',TarRoveDur(cnt1));
    TarFrq = get(TarObject,'Frequencies');
    SamplingRate = get(TempTarObject,'SamplingRate');
    TempTarObject = set(TempTarObject,'FMorTone',TarTrialIndex(cnt1));
    
    if RandBand == 0
        f1 = [TarFrq(2) TarFrq(1)];
        b=fir1(1000,[min(f1)/(SamplingRate/2), (max(f1))/(SamplingRate/2)]);
        TempTarObject = set(TempTarObject,'Names',num2str(mean(f1)));
        if TarTrialIndex(cnt1) == 3 || TarTrialIndex(cnt1) == 4
            TempTarObject = set(TempTarObject,'Frequencies',f1);
             f1=mean(f1);
        else
            f1 = randsample([TarFrq(1) mean(TarFrq) TarFrq(2)],1);
            TempTarObject = set(TempTarObject,'Frequencies',f1);
        end
        
        
    else
        
        
        f1 = randsample(linspace(TarFrq(1)+1000,TarFrq(2),10),1);
        f1 = round([f1 f1-1000])
        b=fir1(1000,[min(f1)/(SamplingRate/2), (max(f1))/(SamplingRate/2)]);
        TempTarObject = set(TempTarObject,'Names',num2str(mean(f1)));
        if TarTrialIndex(cnt1) == 3 || TarTrialIndex(cnt1) == 4
            TempTarObject = set(TempTarObject,'Frequencies',f1);
                    f1=mean(f1);
        else
             f1 = randsample([TarFrq(1) mean(TarFrq) TarFrq(2)],1);
            TempTarObject = set(TempTarObject,'Frequencies',mean(f1));
        end
        
    end
    
    
    [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
    
    w_tar = filtfilt(b,1,w_tar);
    ramp = hanning(round(.005 * get(RefObject,'SamplingRate')*2));
    ramp = ramp(1:floor(length(ramp)/2));
    w_tar(1:length(ramp)) = w_tar(1:length(ramp)) .* ramp;
    w_tar(length(w_tar)-length(ramp)+1:end) = w_tar(length(w_tar)-length(ramp)+1:end) .* flipud(ramp);
    
        
    w_tar = 5 * w_tar / max(abs(w_tar(:)));
    
    w_tar = w_tar / (10^((80-TarLevel)/20));
    
    TrialSound = [TrialSound; w_ref; w_tar];
    
    % now, add reference and targets to the note, correct the time stamp in respect to
    % last event, and add Trial
    for cnt2 = 1:length(ev_ref)
        ev(cnt2).Note = [ev_ref(cnt2).Note ' , Reference'];
        ev(cnt2).StartTime = ev_ref(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev_ref(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
        ev(cnt2).Rove = [RefDur {RefTrialIndex}];
        
    end
    
    if length(ev) > 3
        LastEvent = ev(end-3).StopTime;
    else
        LastEvent = ev(end).StopTime;
    end
    
    for cnt2 = (1:length(ev_ref))+length(ev_ref)
        ev(cnt2).Note = [ev_tar(cnt2-length(ev_ref)).Note ' , Target'];
        ev(cnt2).StartTime = ev_tar(cnt2-length(ev_ref)).StartTime + LastEvent;
        ev(cnt2).StopTime = ev_tar(cnt2-length(ev_ref)).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
        if cnt1 ~= length(RefTrialIndex)
            ev(cnt2).Rove = [TarTrialIndex(cnt1) 0 TarRoveDur(cnt1) f1];
        else
            ev(cnt2).Rove = [TarTrialIndex(cnt1) 1 TarRoveDur(cnt1) f1];
        end
        
    end
    
    events = [events ev];
    LastEvent = ev(end).StopTime;
    
end

if max(abs(TrialSound(:)))>5,
    warning('max(abs(TrialSound))>5!  May having clipping problem!')
end


o = set(o, 'SamplingRate', TrialSamplingRate);
