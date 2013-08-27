function [TrialSound, events , o] = TPD(o, RefObject, RefLevel, RefDurs, TarObject, TarLevel, TarProb, TarDurs, TrialSamplingRate, TrialIndex, NumSounds, RefTrialIndex)

par=get(o);
ShockTar = par.ShockTar;

RandomizeDur=get(o,'RoveDurs'); %flag to randomize the duration of TORCs within the reference window
if RandomizeDur(1,1) == 1
    RandDurs = RefDurs(1):RandomizeDur(1,2):RefDurs(2);
    w = exppdf(RandDurs,mean(RandDurs));
    RefRoveDur=randsample(RandDurs,NumSounds,'true',w);
    
else
    RefRoveDur = repmat(RefDurs(1),1,NumSounds);
    
end

TarPresent{1}=randsample([0 1],NumSounds,'true',[1-TarProb TarProb]);
for i = 1:length(TarPresent{1})
    if TarPresent{1}(1,i) == 1
        TarPresent{2}(1,i) = randi(2);
    else
        TarPresent{2}(1,i) = 1;
        
    end
end

% generate the reference sound
TrialSound = []; % initialize the waveform
events = [];
LastEvent = 0;
for cnt1 = 1:length(RefTrialIndex)  % go through all the reference sounds in the trial
    TempRefObject = RefObject;
    TempRefObject = set(TempRefObject,'SamplingRate',TrialSamplingRate);
    TempRefObject = set(TempRefObject,'Duration',RefRoveDur(cnt1));
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
    TarFrq = get(TarObject,'Frequencies');
    SamplingRate = get(TempTarObject,'SamplingRate');
    TempTarObject = set(TempTarObject,'TarPresent',[TarPresent{1}(cnt1); TarPresent{2}(cnt1)]);
    
    if ShockTar == 1
        if TarPresent{1}(cnt1) == 0
            ShockTarFrq = 2;
            f1 = randsample(linspace(TarFrq(3)+1000,TarFrq(4),10),1);
            f1 = round([f1 f1-1000]);
            f1 = randsample([f1 mean(f1)],1);
            TempTarObject = set(TempTarObject,'Names',num2str(f1));
            TempTarObject = set(TempTarObject,'Frequencies',f1);
            [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
            
        else
            ShockTarFrq = 1;
            f1 = randsample(linspace(TarFrq(3)+1000,TarFrq(4),10),1);
            f1 = round([f1 f1-1000]);
            f1 = randsample([f1 mean(f1)],1);
            
            f2 = randsample(linspace(TarFrq(1)+1000,TarFrq(2),10),1);
            f2 = round([f2 f2-1000]);
            f2 = randsample([f2 mean(f2)],1);
            
            TempTarObject = set(TempTarObject,'Names',num2str(f2));
            TempTarObject = set(TempTarObject,'Frequencies',[f1 f2]);
            [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
            
        end
        
    elseif ShockTar == 2
        if TarPresent{1}(cnt1) == 0 %1=Is not present; 1=Is present
            ShockTarFrq = 1;
            f1 = randsample(linspace(TarFrq(1)+1000,TarFrq(2),10),1);
            f1 = round([f1 f1-1000]);
            f1 = randsample([f1 mean(f1)],1);
            TempTarObject = set(TempTarObject,'Names',num2str(f1));
            TempTarObject = set(TempTarObject,'Frequencies',f1);
            [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
            
        else
            ShockTarFrq = 2;
            f1 = randsample(linspace(TarFrq(1)+1000,TarFrq(2),10),1);
            f1 = round([f1 f1-1000]);
            f1 = randsample([f1 mean(f1)],1);
            
            f2 = randsample(linspace(TarFrq(3)+1000,TarFrq(4),10),1);
            f2 = round([f2 f2-1000]);
            f2 = randsample([f2 mean(f2)],1);
            
            TempTarObject = set(TempTarObject,'Names',num2str(f2));
            TempTarObject = set(TempTarObject,'Frequencies',[f1 f2]);
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
    ev(cnt2).Rove = [RefRoveDur(cnt1) {RefTrialIndex}];
    
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
        ev(cnt2).Rove = [ShockTarFrq TarPresent{1}(cnt1) TarPresent{2}(cnt1) TarDurs(1) {f1}];
    else
        ev(cnt2).Rove = [ShockTarFrq TarPresent{1}(cnt1) TarPresent{2}(cnt1) TarDurs(1) {f1}];
    end
    
end

events = [events ev];
LastEvent = ev(end).StopTime;

end

if max(abs(TrialSound(:)))>5,
    warning('max(abs(TrialSound))>5!  May having clipping problem!')
end
