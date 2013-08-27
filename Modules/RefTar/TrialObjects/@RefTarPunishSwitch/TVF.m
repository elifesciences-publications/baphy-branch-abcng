function [TrialSound, events , o] = TVF(o, RefObject, RefLevel, RefDurs, TarObject, TarLevel, TarProb, TarDurs, TrialSamplingRate, TrialIndex, NumSounds, RefTrialIndex)

par = get(o);
FMorTone = par.FMorTone{TrialIndex}; % get the index of reference sounds for current trial
TarPar = get(TarObject);
SilenceProb = TarPar.SilenceProb;
CorPchSwp = TarPar.CorPchSwp;
PunishTone = TarPar.PunishTone;
ShockTar = par.ShockTar;
PunishPercent = str2num(par.PunishPercent);

RandomizeDur=get(o,'RoveDurs'); %flag to randomize the duration of TORCs within the reference window
if RandomizeDur(1,1) == 1
    RandDurs = RefDurs(1):RandomizeDur(1,2):RefDurs(2);
    w = exppdf(RandDurs,mean(RandDurs));
    RefRoveDur=randsample(RandDurs,NumSounds,'true',w);
    
else
    RefRoveDur = repmat(RefDurs(1),1,NumSounds);
    
end


TarFrqIndex=randsample([1 2],NumSounds,'true',TarProb);

% generate the reference sound
TrialSound = []; % initialize the waveform
events = [];
LastEvent = 0;
for cnt1 = 1:length(RefTrialIndex)  % go through all the reference sounds in the trial
    TempRefObject = RefObject;
    TempRefObject = set(TempRefObject,'SamplingRate',TrialSamplingRate);
    TempRefObject = set(TempRefObject,'Duration',RefRoveDur(cnt1));
    
    if rand < SilenceProb(1)
        TempRefObject = set(TempRefObject,'PreStimSilence',SilenceProb(2));
    end
    
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
    
    %If the animal is to lick freely to safe sounds (ie. not FMs in the target frequeny range, then eliminate FMs in the target frequency range)
    if PunishPercent == 0 && PunishTone == 0 && FMorTone(cnt1) == 1 && TarFrqIndex(cnt1) == ShockTar
        FMorTone(cnt1) = 2;
    end
    
    %If I only want to present and punish FMs in the target frequency range
    if PunishPercent > 0 && PunishTone == 0 && FMorTone(cnt1) == 2 && TarFrqIndex(cnt1) == ShockTar && (sum(TarProb == [1 0]) == 2 || sum(TarProb == [0 1]) == 2)
        FMorTone(cnt1) = 1;
    end

    TempTarObject = TarObject;
    TempTarObject = set(TempTarObject,'SamplingRate',TrialSamplingRate);
    TempTarObject = set(TempTarObject,'Duration',TarDurs(1));
    TarFrq = get(TarObject,'Frequencies');
    SamplingRate = get(TempTarObject,'SamplingRate');
    TempTarObject = set(TempTarObject,'FMorTone',FMorTone(cnt1));
    if rand < SilenceProb(1)
        TempTarObject = set(TempTarObject,'PreStimSilence',SilenceProb(2));
    end
    
    if TarFrqIndex(cnt1) == 1
        f1 = randsample(linspace(TarFrq(1)+1000,TarFrq(2),10),1);
        f1 = round([f1 f1-1000])
        TempTarObject = set(TempTarObject,'Names',num2str(mean(f1)));
        if FMorTone(cnt1) == 2
            f1 = randsample([f1 mean(f1)],1);
            TempTarObject = set(TempTarObject,'Frequencies',f1);
            [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
            
        else
            if CorPchSwp == 1
                f1 = f1;
            elseif CorPchSwp == 0
                if rand > 0.5
                    f1 = fliplr(f1);
                end
                
            end
            
            TempTarObject = set(TempTarObject,'Frequencies',f1);
            [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
            
        end
        
    else
        f1 = randsample(linspace(TarFrq(3)+1000,TarFrq(4),10),1);
        f1 = round([f1 f1-1000])
        TempTarObject = set(TempTarObject,'Names',num2str(mean(f1)));
        if FMorTone(cnt1) == 2
            f1 = randsample([f1 mean(f1)],1);
            TempTarObject = set(TempTarObject,'Frequencies',f1);
            [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
            
        else
            if CorPchSwp == 1
                f1 = fliplr(f1);
            elseif CorPchSwp == 0
                if rand > 0.5
                    f1 = fliplr(f1);
                end
                
            end
            
            TempTarObject = set(TempTarObject,'Frequencies',f1);
            [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
            
        end
        
    end
    
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
        ev(cnt2).Rove = [RefRoveDur(cnt1) {RefTrialIndex} {get(TempRefObject,'PreStimSilence')}];
        
    end
    
    if length(ev) > 3
        LastEvent = ev(end-3).StopTime;
    else
        LastEvent = ev(end).StopTime;
    end
    
    if PunishPercent > 0 && PunishTone == 0 && ShockTar == 1 && FMorTone(cnt1) == 2
        TarFrqIndex(cnt1) = 2;
    elseif PunishPercent > 0 && PunishTone == 0 && ShockTar == 2 && FMorTone(cnt1) == 2
        TarFrqIndex(cnt1) = 1;
    end
     
%     if PunishPercent == 0 && ShockTar == 1
%         TarFrqIndex(cnt1) = 2;
%     elseif PunishPercent == 0 && ShockTar == 2
%         TarFrqIndex(cnt1) = 1;
%     end
    
    for cnt2 = (1:length(ev_ref))+length(ev_ref)
        ev(cnt2).Note = [ev_tar(cnt2-length(ev_ref)).Note ' , Target'];
        ev(cnt2).StartTime = ev_tar(cnt2-length(ev_ref)).StartTime + LastEvent;
        ev(cnt2).StopTime = ev_tar(cnt2-length(ev_ref)).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
        if cnt1 ~= length(RefTrialIndex)
            ev(cnt2).Rove = [TarFrqIndex(cnt1) FMorTone(cnt1) 0 TarDurs(1) {f1} {get(TempTarObject,'PreStimSilence')}];
        else
            ev(cnt2).Rove = [TarFrqIndex(cnt1) FMorTone(cnt1) 1 TarDurs(1) {f1} {get(TempTarObject,'PreStimSilence')}];
        end
        
    end
    
    events = [events ev];
    LastEvent = ev(end).StopTime;
    
end

if max(abs(TrialSound(:)))>5,
    warning('max(abs(TrialSound))>5!  May having clipping problem!')
end
