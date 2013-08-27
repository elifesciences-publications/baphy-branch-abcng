function [TrialSound, events , o] = waveform (o,TrialIndex)

% Nima Mesgarani, October 2005
RefObject = get(o,'ReferenceHandle'); % get the reference handle
RefSamplingRate = (get(RefObject, 'SamplingRate'));
TarObject = get(o,'TargetHandle'); % getthe target handle
TarSamplingRate = ifstr2num(get(TarObject,'SamplingRate'));
%
TrialSamplingRate = max(RefSamplingRate, TarSamplingRate);
if TrialSamplingRate ~= RefSamplingRate
    RefObject = set(RefObject, 'SamplingRate', TrialSamplingRate);
end
if TrialSamplingRate ~= TarSamplingRate
    TarObject = set(TarObject, 'SamplingRate', TrialSamplingRate);
end
%
RefTrialIndex = get(o,'ReferenceIndices');
SNR = get(o,'TrialSNRs');
RefTrialIndex = RefTrialIndex{TrialIndex}; % get the index of reference sounds for current trial
TarTrialIndex = get(o,'TargetIndices');
if ~isempty(TarTrialIndex)
    TarTrialIndex = TarTrialIndex{TrialIndex};
end
TrialSound = []; % initialize the waveform
RefSound = [];
TarSound = [];
ind = 0;
events = [];
LastEvent = 0;
MaxRefIndex = get(RefObject,'MaxIndex');
% generate the reference sound
for cnt1 = 1:length(RefTrialIndex)
    [w, ev] = waveform(RefObject, min(RefTrialIndex(cnt1),MaxRefIndex));
    for cnt1 = 1:length(ev), ev(cnt1).Note = [ev(cnt1).Note ' | SNR_' num2str(SNR{TrialIndex})];end
    ev(2).Note = [ev(2).Note ' $ '];
    [ev,LastEvent] = ModifyEvent (ev,LastEvent,'Reference',TrialIndex);
    RefSound = [RefSound ;w(:)];
    events = [events ev];
end
% generate the target sound
if ~isempty(TarTrialIndex)
    [w, ev] = waveform(TarObject, TarTrialIndex(1));
    for cnt1 = 1:length(ev), ev(cnt1).Note = [ev(cnt1).Note ' | SNR_' num2str(SNR{TrialIndex})];end
    ev(2).Note = [ev(2).Note ' $ '];       
    [ev,LastEvent] = ModifyEvent (ev,LastEvent,'Target',TrialIndex);
    TarSound = [TarSound ;w(:)];
    events = [events ev];
end
if get(o,'RelativeRefTardB')~=0
    RefSound = RefSound*(10^(get(o,'RelativeRefTardB')/10));
end
TrialSound = [RefSound ;TarSound];
loudness = get(RefObject,'Loudness');
if loudness(min(TrialIndex,length(loudness)))>0
    o = set(o,'OveraldB', loudness(min(TrialIndex,length(loudness))));
end
TrialSound(logical(isnan(TrialSound))) = 0;
if get(o,'SamplingRate')~=TrialSamplingRate
    o = set(o, 'SamplingRate', TrialSamplingRate);
end
if exist('SNR','var') && (SNR{TrialIndex}<100)
    % user has specified the SNR, add noise to the sound:
    TrialSound = baphy_awgn(TrialSound,SNR{TrialIndex},'measured');
    TrialSound = 5*TrialSound/max(abs(TrialSound));
end
%
function [ev LastEvent] = ModifyEvent(ev,LastEvent,tag,TrialIndex)
for cnt2 = 1:length(ev)
    ev(cnt2).Note = [ev(cnt2).Note ' , ' tag];
    ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
    ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
    ev(cnt2).Trial = TrialIndex;
end
LastEvent = ev(end).StopTime;
