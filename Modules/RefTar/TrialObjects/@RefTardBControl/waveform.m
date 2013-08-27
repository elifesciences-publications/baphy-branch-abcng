function [TrialSound, events , o] = waveform (o,TrialIndex)
% This function generates the actual waveform for each trial from
% parameters specified in the fields of object o. This is a generic script
% that works for all passive cases, all active cases that use a standard
% SoundObject (e.g. tone). You can overload it by writing your own waveform.m
% script and copying it in your object's folder.

%Serin Atiani, March 2008

par = get(o); % get the parameters of the trial object
RefObject = par.ReferenceHandle; % get the reference handle 
RefSamplingRate = ifstr2num(get(RefObject, 'SamplingRate'));
BaseVoltage=par.BaseV;
BasedB= par.BasedB;
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
Refloudness = get(o,'OveralldB')-get(o,'RelativeTarRefdB');
Tarloudness = get(o,'OveralldB');
ControlMode= get(o,'ControlMode');
if strcmpi(ControlMode,'Random') %%%% Added to adjust for the two modes of this trial object
    if strcmpi(par.dBChange, 'Reference')
        Refloudness= Refloudness+par.dBAttenuation(TrialIndex);
    end
    if isobject(TarObject)
        %Tarloudness = get(o,'OveralldB');
        if strcmpi(par.dBChange, 'Target') 
            Tarloudness= Tarloudness+par.dBAttenuation(TrialIndex);
        end
    else
        Tarloudness = 0;
    end
    RefVoltage= BaseVoltage*10^((Refloudness-BasedB)/20);
    TarVoltage= BaseVoltage*10^((Tarloudness-BasedB)/20);
else %%% ie. the mode is multiple NSR levels for the tone in noise target
    RefVoltage= BaseVoltage*10^((Refloudness-BasedB)/20);
end

TrialSamplingRate = max(RefSamplingRate, TarSamplingRate);
RefObject = set(RefObject, 'SamplingRate', TrialSamplingRate);
%
RefTrialIndex = par.ReferenceIndices{TrialIndex}; % get the index of reference sounds for current trial
TrialSound = []; % initialize the waveform
ind = 0;
events = [];
LastEvent = 0;
% generate the reference sound
for cnt1 = 1:length(RefTrialIndex)  % go through all the reference sounds in the trial
    [w, ev] = waveform(RefObject, RefTrialIndex(cnt1),1); % 1 means its reference
    % now, add reference to the note, correct the time stamp in respect to
    % last event, and add Trial
    for cnt2 = 1:length(ev)
        ev(cnt2).Note = [ev(cnt2).Note ' , Reference , ', num2str(Refloudness), ' dB'];
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
    end
    LastEvent = ev(end).StopTime;
    TrialSound = [TrialSound ;w(:)];
    events = [events ev];
end
TrialSound= RefVoltage * TrialSound / max(abs(TrialSound));
if isobject(TarObject)
    TarTrialIndex = par.TargetIndices{TrialIndex}; % get the index of reference sounds for current trial
    if ~strcmpi(ControlMode,'Random') & strcmpi(class(TarObject), 'ToneInTorc')
        TarObject= set(TarObject,'SNR', par.dBAttenuation(TrialIndex));
        o = set(o,'TargetHandle',TarObject);
        disp(['Target SNR:' num2str(par.dBAttenuation(TrialIndex))])
    end            
    TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
    % generate the target sound:
    [w, ev] = waveform(TarObject, TarTrialIndex, 0); % 0 means its target
    % the first (kind of hack I need to add!), relative reftar db for
    % discrim cases only should be applied to the second part of the
    % target. In all other cases to the whole thing:
    if strcmpi(ControlMode,'Random')%%%% Added to adjust for the two modes of this trial object
        TrialSound = [TrialSound ; TarVoltage*(w(:)/max(abs(w(:)))) ];
    else %%% ie. the mode is multiple NSR levels for the tone in noise target
        %%%% Here we no longer normalize by the Voltage or by the max (5V)
        %%%% like in ReferenceTarget, the normalization to the Voltage
        %%%% level for the target happens in the target object
        TrialSound = [TrialSound ; w(:) ];
    end
    
    % now, add Target to the note, correct the time stamp in respect to
    % last event, and add Trial
    for cnt2 = 1:length(ev)
        if strcmpi(ControlMode,'Random')
            ev(cnt2).Note = [ev(cnt2).Note ' , Target , ', num2str(Tarloudness), ' dB'];
        else
            ev(cnt2).Note = [ev(cnt2).Note ' , Target , SNR: ', num2str(par.dBAttenuation(TrialIndex)), ' dB'];
        end
        ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
        ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
        ev(cnt2).Trial = TrialIndex;
    end
    LastEvent = ev(end).StopTime;
    events = [events ev];
end


% % figure(15); plot(TrialSound)
% disp(['Reference Loudness:' num2str(Refloudness)])
% disp(['Target Loudness:' num2str(Tarloudness)])
% %disp(['Target Voltage:' num2str(TarVoltage)])
% disp(['Reference Voltage:' num2str(RefVoltage)])

%loudness = max(Refloudness,Tarloudness);
% if loudness(min(RefTrialIndex(1),length(loudness)))>0
%     o = set(o,'OveralldB', loudness(min(RefTrialIndex(1),length(loudness))));    
% end
o = set(o, 'SamplingRate', TrialSamplingRate);
