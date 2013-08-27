function [TrialSound, events , o] = waveform (o,TrialIndex)

par = get(o); % get the parameters of the trial object

RefObject = par.ReferenceHandle; % get the reference handle
RefSamplingRate = ifstr2num(get(RefObject, 'SamplingRate'));

TarObject = par.TargetHandle; % getthe target handle
TarSamplingRate = ifstr2num(get(TarObject,'SamplingRate'));
RefLevel = par.RefLevel;
TarLevel = par.TarLevel;
RepIndex = par.RepIndex;
Gap = get(o,'Gap');
RefTarOrder = get(o,'RefTarORder');
TorcOrTone = get(o,'TorcOrTone');
ToneFrqs = get(o,'RandTarFrqs');
TrialSamplingRate = max(RefSamplingRate, TarSamplingRate);
SDorWM = get(o,'SDorWM');
ITI = par.ITI(TrialIndex)
if get(RefObject, 'SamplingRate')~=TrialSamplingRate,
  RefObject = set(RefObject, 'SamplingRate', TrialSamplingRate);
  
end

if strcmp(SDorWM,'WM')
  f1  = ToneFrqs(RepIndex)
  RefTrialIndex = par.ReferenceIndices{RepIndex}; % get the index of reference sounds for current trial
else
  f1  = ToneFrqs(TrialIndex);
  RefTrialIndex = par.ReferenceIndices{TrialIndex}; % get the index of reference sounds for current trial
end

TrialSound = []; % initialize the waveform
ind = 0;
events = [];
LastEvent = 0;


RandomizeDur=get(o,'RoveDurs'); %flag to randomize the duration of TORCs within the reference window
RefDur = get(RefObject,'Duration');
TarDur = mean(RefDur);

NumSounds = length(RefTrialIndex);
if RandomizeDur(1,1) == 1
  RandDurs = RefDur(1):RandomizeDur(1,2):RefDur(2);
  w = exppdf(RandDurs,mean(RandDurs));
  RefRoveDur=randsample(RandDurs,NumSounds,'true',w);
  
else
  RefRoveDur = repmat(mean(RefDur),1,NumSounds);
end

%Trial Sounds
%Tone Tone
if TorcOrTone(TrialIndex) == 2 && RefTarOrder(TrialIndex) == 2
  TempRefObject = TarObject;
  TempRefObject = set(TempRefObject,'Duration',RefRoveDur);
  TempRefObject = set(TempRefObject,'Names',num2str(f1));
  TempRefObject = set(TempRefObject,'Frequencies',f1);
  TempRefObject = set(TempRefObject,'PostStimSilence',0);
  [w_ref, ev_ref] = waveform(TempRefObject, 1, 0); % 0 means its target
  w_ref = 5 * w_ref / max(abs(w_ref(:)));
  w_ref = w_ref / (10^((80-RefLevel)/20));
  ramp = hanning(round(.01 * get(TarObject,'SamplingRate')*2));
  ramp = ramp(1:floor(length(ramp)/2));
  w_ref(1:length(ramp)) = w_ref(1:length(ramp)) .* ramp;
  w_ref(length(w_ref)-length(ramp)+1:end) = w_ref(length(w_ref)-length(ramp)+1:end) .* flipud(ramp);
  
  TempTarObject = TarObject;
  TempTarObject = set(TempTarObject,'Duration',TarDur);
  TempTarObject = set(TempTarObject,'Names',num2str(f1));
  TempTarObject = set(TempTarObject,'Frequencies',f1);
  TempTarObject = set(TempTarObject,'PreStimSilence',Gap);
  [w_tar, ev_tar] = waveform(TempTarObject, 1, 0); % 0 means its target
  w_tar = 5 * w_tar / max(abs(w_tar(:)));
  w_tar = w_tar / (10^((80-RefLevel)/20));
  ramp = hanning(round(.01 * get(TarObject,'SamplingRate')*2));
  ramp = ramp(1:floor(length(ramp)/2));
  w_tar(1:length(ramp)) = w_tar(1:length(ramp)) .* ramp;
  w_tar(length(w_tar)-length(ramp)+1:end) = w_tar(length(w_tar)-length(ramp)+1:end) .* flipud(ramp);
  
  o = set(o,'Punish',0);
  
  %Torc Tone
elseif TorcOrTone(TrialIndex) == 1 && RefTarOrder(TrialIndex) == 2
  TempRefObject = RefObject;
  TempRefObject = set(TempRefObject,'Duration',RefRoveDur);
  TempRefObject = set(TempRefObject,'PostStimSilence',0);
  RefType = get(TempRefObject);  
 if  ~strcmp(RefType.descriptor,'Torc')
    TempRefObject = set(TempRefObject,'Frequencies',f1);
 end
  [w_ref, ev_ref] = waveform(TempRefObject, RefTrialIndex, TrialIndex); % 1 means its reference
  if size(w_ref,2)>size(w_ref,1),
    w_ref=w_ref';
  end
  w_ref = 5 * w_ref / max(abs(w_ref(:)));
  w_ref = w_ref / (10^((80-RefLevel)/20));
  ramp = hanning(round(.01 * get(RefObject,'SamplingRate')*2));
  ramp = ramp(1:floor(length(ramp)/2));
  w_ref(1:length(ramp)) = w_ref(1:length(ramp)) .* ramp;
  w_ref(length(w_ref)-length(ramp)+1:end) = w_ref(length(w_ref)-length(ramp)+1:end) .* flipud(ramp);
  
  TempTarObject = TarObject;
  TempTarObject = set(TempTarObject,'Duration',TarDur);
  TempTarObject = set(TempTarObject,'Names',num2str(f1));
  TempTarObject = set(TempTarObject,'Frequencies',f1);
  TempTarObject = set(TempTarObject,'PreStimSilence',Gap);
  [w_tar, ev_tar] = waveform(TempTarObject, 1, 0); % 0 means its target
  w_tar = 5 * w_tar / max(abs(w_tar(:)));
  w_tar = w_tar / (10^((80-TarLevel)/20));
  ramp = hanning(round(.01 * get(TarObject,'SamplingRate')*2));
  ramp = ramp(1:floor(length(ramp)/2));
  w_tar(1:length(ramp)) = w_tar(1:length(ramp)) .* ramp;
  w_tar(length(w_tar)-length(ramp)+1:end) = w_tar(length(w_tar)-length(ramp)+1:end) .* flipud(ramp);
  
  o = set(o,'Punish',1);
  
  % Tone Torc
elseif TorcOrTone(TrialIndex) == 2 && RefTarOrder(TrialIndex) == 1
  TempRefObject = TarObject;
  TempRefObject = set(TempRefObject,'Duration',RefRoveDur);
  TempRefObject = set(TempRefObject,'Names',num2str(f1));
  TempRefObject = set(TempRefObject,'Frequencies',f1);
  TempRefObject = set(TempRefObject,'PostStimSilence',0);
  [w_ref, ev_ref] = waveform(TempRefObject, 1, 0); % 0 means its target
  w_ref = 5 * w_ref / max(abs(w_ref(:)));
  w_ref = w_ref / (10^((80-RefLevel)/20));
  ramp = hanning(round(.01 * get(TarObject,'SamplingRate')*2));
  ramp = ramp(1:floor(length(ramp)/2));
  w_ref(1:length(ramp)) = w_ref(1:length(ramp)) .* ramp;
  w_ref(length(w_ref)-length(ramp)+1:end) = w_ref(length(w_ref)-length(ramp)+1:end) .* flipud(ramp);
  
  TempTarObject = RefObject;
  TempTarObject = set(TempTarObject,'Duration',TarDur);
  TempTarObject = set(TempTarObject,'PreStimSilence',Gap);
  RefType = get(TempTarObject);  
  if  ~strcmp(RefType.descriptor,'Torc')
    TempTarObject = set(TempTarObject,'Frequencies',f1);
 end
  [w_tar, ev_tar] = waveform(TempTarObject, RefTrialIndex, TrialIndex); % 1 means its reference
  if size(w_tar,2)>size(w_tar,1),
    w_tar=w_tar';
  end
  w_tar = 5 * w_tar / max(abs(w_tar(:)));
  w_tar = w_tar / (10^((80-TarLevel)/20));
  ramp = hanning(round(.01 * get(RefObject,'SamplingRate')*2));
  ramp = ramp(1:floor(length(ramp)/2));
  w_tar(1:length(ramp)) = w_tar(1:length(ramp)) .* ramp;
  w_tar(length(w_tar)-length(ramp)+1:end) = w_tar(length(w_tar)-length(ramp)+1:end) .* flipud(ramp);
  
  o = set(o,'Punish',1);
  
  %Torc Torc
elseif TorcOrTone(TrialIndex) == 1 && RefTarOrder(TrialIndex) == 1
  TempRefObject = RefObject;
  TempRefObject = set(TempRefObject,'Duration',RefRoveDur);
  TempRefObject = set(TempRefObject,'PostStimSilence',0);
    RefType = get(TempRefObject);  
 if  ~strcmp(RefType.descriptor,'Torc')
    TempRefObject = set(TempRefObject,'Frequencies',f1);
 end
 
 [w_ref, ev_ref] = waveform(TempRefObject, RefTrialIndex, TrialIndex); % 1 means its reference
  if size(w_ref,2)>size(w_ref,1),
    w_ref=w_ref';
  end
  w_ref = 5 * w_ref / max(abs(w_ref(:)));
  w_ref = w_ref / (10^((80-RefLevel)/20));
  ramp = hanning(round(.01 * get(RefObject,'SamplingRate')*2));
  ramp = ramp(1:floor(length(ramp)/2));
  w_ref(1:length(ramp)) = w_ref(1:length(ramp)) .* ramp;
  w_ref(length(w_ref)-length(ramp)+1:end) = w_ref(length(w_ref)-length(ramp)+1:end) .* flipud(ramp);
  
  TempTarObject = RefObject;
  TempTarObject = set(TempTarObject,'Duration',TarDur);
  TempTarObject = set(TempTarObject,'PreStimSilence',Gap);
  RefType = get(TempRefObject);  
  if  ~strcmp(RefType.descriptor,'Torc')
    TempTarObject = set(TempTarObject,'Frequencies',f1);
 end
  [w_tar, ev_tar] = waveform(TempTarObject, RefTrialIndex, TrialIndex); % 1 means its reference
  if size(w_tar,2)>size(w_tar,1),
    w_tar=w_tar';
  end
  w_tar = 5 * w_tar / max(abs(w_tar(:)));
  w_tar = w_tar / (10^((80-RefLevel)/20));
  ramp = hanning(round(.01 * get(RefObject,'SamplingRate')*2));
  ramp = ramp(1:floor(length(ramp)/2));
  w_tar(1:length(ramp)) = w_tar(1:length(ramp)) .* ramp;
  w_tar(length(w_tar)-length(ramp)+1:end) = w_tar(length(w_tar)-length(ramp)+1:end) .* flipud(ramp);
  
  o = set(o,'Punish',0);
  
end

TrialSound = [w_ref; w_tar];
% now, add reference and targets to the note, correct the time stamp in respect to
% last event, and add Trial
for cnt2 = 1:length(ev_ref)
  ev(cnt2).Note = [ev_ref(cnt2).Note ' , Reference'];
  ev(cnt2).StartTime = ev_ref(cnt2).StartTime + LastEvent;
  ev(cnt2).StopTime = ev_ref(cnt2).StopTime + LastEvent;
  ev(cnt2).Trial = TrialIndex;
  ev(cnt2).Rove = [RefRoveDur RefTarOrder(TrialIndex)];
  
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
  if TorcOrTone(TrialIndex) == 2
    ev(cnt2).Rove = [TorcOrTone(TrialIndex) RefTarOrder(TrialIndex)  f1 ITI];
  else
    ev(cnt2).Rove = [TorcOrTone(TrialIndex) RefTarOrder(TrialIndex)  0 ITI];
  end
end

events = [events ev];
LastEvent = ev(end).StopTime;

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
            delay1=max([1 events(1).StopTime/2]);                %high flow rate start before stimulus on
            delay1=(delay1*TrialSamplingRate);
            delay2=events(end).StopTime;  %high flow rate extended during post-silence
            delay2=round(delay2*TrialSamplingRate);   %10 samples for set flow rate back to low
            TrialSound(delay1:delay2,2)=pumppro(3);
        else pumppro(1)==2   %low flow arte during both ISI ans ITI, high during stimulus
            TrialSound(find(TrialSound(:,1)),2)=pumppro(2); %high speed during sound
        end
    end
end