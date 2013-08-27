function [TrialSound, events , o] = CDD(o, RefObject, RefLevel, RefDurs, TarObject, TarLevel, TarProb, TarDurs, TrialSamplingRate, TrialIndex, NumSounds, RefTrialIndex)

par = get(o);
TarPar = get(TarObject);
SilenceProb = TarPar.SilenceProb;
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
  
  if ShockTar == 1
    FMorTone = randsample([1 2 3 4 5],1,'true',TarProb);
    if FMorTone == 1 || FMorTone == 2
      Shock = 1;
    elseif FMorTone == 4 || FMorTone == 5
      Shock = 2;
    elseif FMorTone == 3
      Shock = randi(2)
    end
  elseif ShockTar == 2
    FMorTone = randsample([1 2 3 4 5],1,'true',TarProb);
    if FMorTone == 4 || FMorTone == 5
      Shock = 2;
    elseif FMorTone == 1 || FMorTone == 2
      Shock = 1;
    elseif FMorTone == 3
      Shock = randi(2)
    end
  end
  Shock
  TempTarObject = TarObject;
  TempTarObject = set(TempTarObject,'SamplingRate',TrialSamplingRate);
  TempTarObject = set(TempTarObject,'Duration',TarDurs(1));
  TarFrq = get(TarObject,'Frequencies');
  SamplingRate = get(TempTarObject,'SamplingRate');
  if rand < SilenceProb(1)
    TempTarObject = set(TempTarObject,'PreStimSilence',SilenceProb(2));
  end
  
  if FMorTone == 1 %Low Frequency Down Sweep
    f1 = randsample(linspace(TarFrq(1)+1000,TarFrq(2),10),1);
    f1 = round([f1 f1-1000]);
    TempTarObject = set(TempTarObject,'Names',num2str(mean(f1)));
    TempTarObject = set(TempTarObject,'Frequencies',f1);
    TempTarObject = set(TempTarObject,'FMorTone',1);
    [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0);
    
  elseif FMorTone == 2 %High Frequency Up Sweep
    f1 = randsample(linspace(TarFrq(5),TarFrq(6)-1000,10),1);
    f1 = round([f1 f1+1000]);
    TempTarObject = set(TempTarObject,'Names',num2str(mean(f1)));
    TempTarObject = set(TempTarObject,'Frequencies',f1);
    TempTarObject = set(TempTarObject,'FMorTone',1);
    [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0);
    
  elseif FMorTone == 3 %Mid Frequency Tone
    f1 = randsample([TarFrq(3) TarFrq(4)],1);
    TempTarObject = set(TempTarObject,'Frequencies',f1);
    TempTarObject = set(TempTarObject,'FMorTone',2);
    [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0); % 0 means its target
    
  elseif FMorTone == 4 %Low Frequency Up Sweep
    f1 = randsample(linspace(TarFrq(1),TarFrq(2)-1000,10),1);
    f1 = round([f1 f1+1000]);
    TempTarObject = set(TempTarObject,'Names',num2str(mean(f1)));
    TempTarObject = set(TempTarObject,'Frequencies',f1);
    TempTarObject = set(TempTarObject,'FMorTone',1);
    [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0);
    
  elseif FMorTone == 5 %High Frequency Down Sweep
    f1 = randsample(linspace(TarFrq(5)+1000,TarFrq(6),10),1);
    f1 = round([f1 f1-1000]);
    TempTarObject = set(TempTarObject,'Names',num2str(mean(f1)));
    TempTarObject = set(TempTarObject,'Frequencies',f1);
    TempTarObject = set(TempTarObject,'FMorTone',1);
    [w_tar, ev_tar] = waveform(TempTarObject, cnt1, 0);
    
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
      ev(cnt2).Rove = [Shock FMorTone 0 TarDurs(1) {f1} {get(TempTarObject,'PreStimSilence')}];
    else
      ev(cnt2).Rove = [Shock FMorTone 1 TarDurs(1) {f1} {get(TempTarObject,'PreStimSilence')}];
    end
    
  end
  
  events = [events ev];
  LastEvent = ev(end).StopTime;
  
end

if max(abs(TrialSound(:)))>5,
  warning('max(abs(TrialSound))>5!  May having clipping problem!')
end
