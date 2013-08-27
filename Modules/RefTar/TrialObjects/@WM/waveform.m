function [TrialSound, events , o] = waveform (o,TrialIndex)
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. This is a generic script
% that works for all passive cases, all active cases that use a standard
% SoundObject (e.g. tone). You can overload it by writing your own waveform.m
% script and copying it in your object's folder.

% Nima Mesgarani, October 2005

par = get(o); % get the parameters of the trial object
FlipFlag = par.FlipFlag(TrialIndex);   % determine if ref and tar should be flipped
if ~FlipFlag,
  RefObject = par.ReferenceHandle; % get the reference handle
  TarObject = par.TargetHandle; % getthe target handle
else    %flip
   TarObject = par.ReferenceHandle;    % get the reference handle
  RefObject = par.TargetHandle;           % getthe target handle
end

RefSamplingRate = ifstr2num(get(RefObject, 'SamplingRate'));
TarSamplingRate = ifstr2num(get(TarObject,'SamplingRate'));

if (par.NumberOfTarPerTrial~=0) && ~strcmpi(par.TargetClass,'none')
    TarTrialIndex = par.TargetIndices{TrialIndex};
    if isempty(TarTrialIndex)  % if its a Sham
        % this means there is a target but this trial is sham. ALthough
        % there is no target, we need to adjust the amplitude based on
        % RefTardB.
        TarObject = -1;
    end
end
TrialSamplingRate = max(RefSamplingRate, TarSamplingRate);
RefObject = set(RefObject, 'SamplingRate', TrialSamplingRate);

% get the index of reference sounds for current trial
RefTrialIndex = par.ReferenceIndices{TrialIndex};

PostTrialSilence = par.PostTrialSilence;
PostTrialBins=round(PostTrialSilence.*TrialSamplingRate);

FlipFlag = par.FlipFlag(TrialIndex); % get the index of reference sounds for current trial
TrialSound = []; % initialize the waveform
ind = 0;
events = [];
LastEvent = 0;
% generate the reference sound
for cnt1 = 1:length(RefTrialIndex)  % go through all the reference sounds in the trial
        [w, ev] = waveform(RefObject, RefTrialIndex(cnt1),TrialIndex); % 1 means its reference
      % svd 2009-06-29 make sure that sound is in a column
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
      end
      LastEvent = ev(end).StopTime;
      TrialSound = [TrialSound ;w];
      events = [events ev];
end
chancount=size(TrialSound,2);
if isobject(TarObject)
    TarTrialIndex = par.TargetIndices{TrialIndex}; % get the index of reference sounds for current trial
    TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
    % generate the target sound:
    [w, ev] = waveform(TarObject, TarTrialIndex, 0); % 0 means its target

    % svd 2009-06-29 make sure that sound is in a column
    if size(w,2)>size(w,1),
        w=w';
    end
    % the first (kind of hack I need to add!), relative reftar db for
    % discrim cases only should be applied to the second part of the
    % target. In all other cases to the whole thing:
    if isempty(strfind(upper(class(TarObject)),'DISCRIM')),
        TrialSound = [TrialSound ; ...
            w*(10^(get(o,'RelativeTarRefdB')/20)) zeros(length(w),chancount-size(w,2)) ];
    else
        w(ev(4).StartTime*TrialSamplingRate:end,:) = ...
            w(ev(4).StartTime*TrialSamplingRate:end,:) ...
            * (10^(get(o,'RelativeTarRefdB')/20));
        TrialSound = [TrialSound ; w zeros(size(w,1),chancount-size(w,2))];
    end
    % now, add Target to the note, correct the time stamp in respect to
    % last event, and add Trial
    for cnt2 = 1:length(ev)
        ev(cnt2).Note = [ev(cnt2).Note ' , Target'];
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
    end
    LastEvent = ev(end).StopTime;
    events = [events ev];
    % normalize the sound, because the level control is always from attenuator.
    TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
elseif TarObject == -1
    % sham trial:
    if isfield(get(par.TargetHandle),'ShamNorm'),
        TrialSound = 5 * TrialSound / get(par.TargetHandle,'ShamNorm');
    else
        TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
        if get(o,'RelativeTarRefdB')>0
            TrialSound = TrialSound / (10^(get(o,'RelativeTarRefdB')/20));
        end
    end
end

if PostTrialBins>0,
   TrialSound=cat(1,TrialSound,zeros(PostTrialBins,chancount));
   events(end).StopTime=events(end).StopTime+PostTrialSilence;

end

Refloudness = get(RefObject,'Loudness');
if isobject(TarObject)
    Tarloudness = get(TarObject,'Loudness');
else
    Tarloudness = 0;
end
%disp(['outWFM:' num2str(max(abs(TrialSound)))])

loudness = max(Refloudness,Tarloudness);
if loudness(min(RefTrialIndex(1),length(loudness)))>0
    o = set(o,'OveralldB', loudness(min(RefTrialIndex(1),length(loudness))));    
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
            delay2=ev(3).StopTime;  %high flow rate extended during post-silence
            delay2=round(delay2*TrialSamplingRate)-10;   %10 samples for set flow rate back to low
            TrialSound(delay1:delay2,2)=pumppro(3);
        else pumppro(1)==2   %low flow arte during both ISI ans ITI, high during stimulus
            TrialSound(find(TrialSound(:,1)),2)=pumppro(2); %high speed during sound
        end
    end
end







