function [TrialSound, events , o] = PRD(o, RefObject, RefLevel, RefDurs, TarObject, TarLevel, TarProb, TarDurs, TrialSamplingRate, TrialIndex, NumSounds, RefTrialIndex)

par = get(o);
FMorTone = par.FMorTone{TrialIndex}; % get the index of reference sounds for current trial
TarPar = get(TarObject);
SilenceProb = TarPar.SilenceProb;
ShockTar = par.ShockTar;
onlytones = TarPar.onlytones;

RandomizeDur=get(o,'RoveDurs'); %flag to randomize the duration of TORCs within the reference window
if RandomizeDur(1,1) == 1
    RandDurs = RefDurs(1):RandomizeDur(1,2):RefDurs(2);
    w = exppdf(RandDurs,mean(RandDurs));
    RefRoveDur=randsample(RandDurs,NumSounds,'true',w);
    
else
    RefRoveDur = repmat(RefDurs(1),1,NumSounds);
    
end

TarFrqIndex=randsample([1 2],NumSounds,'true',TarProb);

if ShockTar < 3
    if TrialIndex == 1 & isempty(find(TarProb==0))
        if ShockTar == 1
            TarFrqIndex(1) = 2;
        elseif ShockTar == 2
            TarFrqIndex(1) = 1;
        end
    end
end

    

FixTrialFreq = get(TarObject,'FixTrialFreq');
if FixTrialFreq == 1
    %     FMorToneLow = randi(2);
    %     FMorToneHigh = randi(2);
    %
    TarFrq = unique(get(TarObject,'Frequencies'));
    %     Lowtempf1 = randsample(linspace(TarFrq(1)+1000,TarFrq(2),10),1);
    %     Lowtempf1 = round([Lowtempf1 Lowtempf1]); %removed second value-1000 to prevent diff frequency
    %     if rand > 0.5
    %         Lowf1 = fliplr(Lowtempf1);
    %     else
    %         Lowf1 = Lowtempf1;
    %
    %     end
    %
    %     Hightempf1 = randsample(linspace(TarFrq(3)+1000,TarFrq(4),10),1);
    %     Hightempf1 = round([Hightempf1 Hightempf1]);%removed second value-1000 to prevent diff frequency
    %     if rand > 0.5
    %         Highf1 = fliplr(Hightempf1);
    %     else
    %         Highf1 = Hightempf1;
    %
    %     end
    %
    for cnt1 = 1:length(TarFrqIndex)
        if TarFrqIndex(cnt1) == 1
            tempf1{cnt1} = TarFrq(1);
            %             FMorTone(cnt1) = FMorToneLow;
        else
            tempf1{cnt1} = TarFrq(2);
            %             FMorTone(cnt1) = FMorToneHigh;
            
        end
    end
end

if onlytones == 1
    FMorTone = ones(size(FMorTone))+1;
end

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
    
    TempTarObject = TarObject;
    TempTarObject = set(TempTarObject,'SamplingRate',TrialSamplingRate);
    TempTarObject = set(TempTarObject,'Duration',TarDurs(1));
    SamplingRate = get(TempTarObject,'SamplingRate');
    TempTarObject = set(TempTarObject,'FMorTone',FMorTone(cnt1));
    if rand < SilenceProb(1)
        TempTarObject = set(TempTarObject,'PreStimSilence',SilenceProb(2));
    end
    
    if FixTrialFreq == 0
        
        TarFrq = get(TarObject,'Frequencies');
        
        if TarFrqIndex(cnt1) == 1
            f1 = randsample(linspace(TarFrq(1)+1000,TarFrq(2),10),1);
            f1 = round([f1 f1-1000])
            TempTarObject = set(TempTarObject,'Names',num2str(mean(f1)));
            if FMorTone(cnt1) == 2
                f1 = randsample([f1 mean(f1)],1);
                TempTarObject = set(TempTarObject,'Frequencies',f1);
                [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
                
            else
                if rand > 0.5
                    f1 = fliplr(f1);
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
                if rand > 0.5
                    f1 = fliplr(f1);
                end
                
                TempTarObject = set(TempTarObject,'Frequencies',f1);
                [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
                
            end
            
        end
    else
        f1 = tempf1{cnt1};
        if FMorTone(cnt1) == 2
            f1 = mean(f1);
        end
        TempTarObject = set(TempTarObject,'Frequencies',f1);
        [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
        
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
            delay2=events(end).StopTime;  %high flow rate extended during post-silence
            delay2=round(delay2*TrialSamplingRate);   %10 samples for set flow rate back to low
            TrialSound(delay1:delay2,2)=pumppro(3);
        else pumppro(1)==2   %low flow arte during both ISI ans ITI, high during stimulus
            TrialSound(find(TrialSound(:,1)),2)=pumppro(2); %high speed during sound
        end
    end
end