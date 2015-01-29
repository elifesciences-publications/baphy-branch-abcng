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
LightTrial = par.LightTrial(TrialIndex); % is light on or off?

TrialSound = []; % initialize the waveform
ind = 0;
events = [];
LastEvent = 0;

if any(strcmp(fieldnames(RefObject),'OverrideAutoScale')),
  OverrideAutoScale=get(RefObject,'OverrideAutoScale');
else
  OverrideAutoScale=0;
end

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
        if LightTrial
            ev(cnt2).Note = [ev(cnt2).Note ' , Reference+Light'];
        else
            ev(cnt2).Note = [ev(cnt2).Note ' , Reference+NoLight'];
        end
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
    end
    LastEvent = ev(end).StopTime;
    TrialSound = [TrialSound ;w];
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
    [w, ev] = waveform(TarObject, TarTrialIndex, 0); % 0 means its target
    if size(w,2)>size(w,1),
        w=w';
    end
    % the first (kind of hack I need to add!), relative reftar db for
    % discrim cases only should be applied to the second part of the
    % target. In all other cases to the whole thing:
    if isempty(strfind(upper(class(TarObject)),'DISCRIM'))
        if size(TrialSound,2)<size(w,2),
            TrialSound=[TrialSound zeros(length(TrialSound),1)];
        end
        TrialSound = [TrialSound ; w*(10^(RelativeTarRefdB/20)) ];
        %figure(2); plot(TrialSound); drawnow;
    else
        w(ev(4).StartTime*TrialSamplingRate:end) = w(ev(4).StartTime*TrialSamplingRate:end) ...
            * (10^(RelativeTarRefdB/20));
        TrialSound = [TrialSound ; w];
    end
    
    %check if the target is a probe (added on 06/1/2012 by py)
    xx=get(TarObject);
    if isfield(xx,'Probe')
        probe=str2num(xx.Names{TarTrialIndex});
        probe=probe(end);
    else
        probe=0;    
    end
    
    % now, add Target to the note, correct the time stamp in respect to
    % last event, and add Trial
    for cnt2 = 1:length(ev)
        if probe==1  %added on 06/1/2012 by py
            ev(cnt2).Note = [ev(cnt2).Note ' , Probe'];
        else
            ev(cnt2).Note = [ev(cnt2).Note ' , Target'];
        end
        if LightTrial,
            ev(cnt2).Note=[ev(cnt2).Note '+Light'];
        else
            ev(cnt2).Note=[ev(cnt2).Note '+NoLight'];
        end
        ev(cnt2).Note = [ev(cnt2).Note ' , ' num2str(RelativeTarRefdB) 'dB' ];
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
    end
    LastEvent = ev(end).StopTime;
    events = [events ev];
    % normalize the sound, because the level control is always from attenuator.
    if ~OverrideAutoScale,
      TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
    end
elseif TarObject == -1
    % sham trial:
    if isfield(get(par.TargetHandle),'ShamNorm'),
      if ~OverrideAutoScale,
        TrialSound = 5 * TrialSound / get(par.TargetHandle,'ShamNorm');
      end
    else
      if ~OverrideAutoScale,
        TrialSound = 5 * TrialSound / max(abs(TrialSound(:)));
      end
        if get(o,'RelativeTarRefdB')>0
            TrialSound = TrialSound / (10^(get(o,'RelativeTarRefdB')/20));
        end
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


% RefTarOpt-specific code: add light channel, change event strings to
% reflect light on or off
TrialBins=size(TrialSound,1);
TrialDuration=TrialBins./TrialSamplingRate;
%'LightPulseRate','edit',50,...
%'LightPulseDuration','edit',0.01,...
%'LightPulseShift','edit',0,...
%'LightEpoch','popupmenu','Sound|Sound Onset|Whole'};
LightBand=zeros(TrialBins,1);
LightPower = (get(o,'LEDpower'));
if LightTrial
    disp('Light on trial');
    LightStepSize=TrialSamplingRate./par.LightPulseRate;
    LightOnBins=round(par.LightPulseDuration.*TrialSamplingRate);
   switch par.LightEpoch,
        case 'WholeTrial',
            ii=round(par.LightPulseShift.*TrialSamplingRate);
            while ii<TrialBins,
                if ii+LightOnBins>TrialBins,
                    LightBand((ii+1):end)=LightPower;
                else
                    LightBand(ii+(1:LightOnBins))=LightPower;
                end
                ii=ii+LightStepSize;
            end
            
        case 'SoundOnset',
            for evidx=2:3:length(events),
                StimStartTime=events(evidx).StartTime;
                LightStartTime=StimStartTime+par.LightPulseShift;
                LightStartBin=round(LightStartTime*TrialSamplingRate);
                LightBand(LightStartBin+(1:LightOnBins))=LightPower;
            end
            
        case 'WholeSound',
            for evidx=2:3:length(events),
                StimStartTime=events(evidx).StartTime;
                StimStopTime=events(evidx).StopTime;
                LightStartTime=StimStartTime+par.LightPulseShift;
                while LightStartTime<StimStopTime,
                    LightStartBin=round(LightStartTime*TrialSamplingRate);
                    LightBand(LightStartBin+(1:LightOnBins))=LightPower;
                    LightStartTime=LightStartTime+1./par.LightPulseRate;
                end
            end
            
        case {'PreRef','PostRef'}
          LocusStr = par.LightEpoch(1:(strfind(par.LightEpoch,'Ref')-1));
          IndStimSil = find( ~cellfun(@isempty,strfind( {ev.Note},'Reference')) &  ~cellfun(@isempty,strfind( {ev.Note}, [LocusStr 'StimSilence'])) );
          StimStartTime=ev(IndStimSil).StartTime;
          StimStopTime=ev(IndStimSil).StopTime;
          LightStartTime=StimStartTime+par.LightPulseShift;
          while LightStartTime<StimStopTime,
            LightStartBin=round(LightStartTime*TrialSamplingRate);
            LightBand(LightStartBin+(1:LightOnBins))=LightPower;
            LightStartTime=LightStartTime+1./par.LightPulseRate;
          end
        otherwise
            error([par.LightEpoch, ' LightEpoch not supported yet']);
    end
else
    disp('Light off trial');
end

% if size(TrialSound,2)<2,
%     TrialSound=cat(2,TrialSound,zeros(size(TrialSound)),LightBand);
% else
    TrialSound=cat(2,TrialSound,LightBand);
% end


% save some changes to the TrialObject (?? good idea??)
loudness = max(Refloudness,Tarloudness);
if loudness(min(RefTrialIndex(1),length(loudness)))>0
    o = set(o,'OveralldB', loudness(min(RefTrialIndex(1),length(loudness))));    
end
o = set(o, 'SamplingRate', TrialSamplingRate);



