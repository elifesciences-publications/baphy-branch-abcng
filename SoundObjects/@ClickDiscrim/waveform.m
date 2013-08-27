function [w,events] = waveform (o, index, IsRef)
% waveform is a method of ClickDiscrim object. It returns the
% stimuli(Torc-gap-click) waveform (w) and event structure.

if ~exist('IsRef','var') || isempty(IsRef), IsRef=1; end
% first, create an instance of torc object:
TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'TorcClickGap')/2, ...     % Put half of gap after torc, the other half goes before Click
    get(o,'TorcDuration'), get(o,'TorcFreqRange'), get(o,'TorcRates'));
% now generate the Click object:
ClickObj = Click(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o, 'TorcClickGap')/2,...     % PreStimSilence is half the gap between torc and Click
    get(o, 'PostStimSilence'),...
    get(o, 'ClickWidth'),...
    get(o, 'ClickRate'),...
    get(o, 'ClickDuration'));

% Now get the event and waveforms:
NumOfClicks = get(ClickObj,'maxIndex');
[wTorc, eTorc] = waveform(TorcObj, index);
% for the target, randomly choose a click rate:
if ~IsRef
    [wClick, eClick] = waveform(ClickObj,ceil(NumOfClicks*rand(1))); 
    % don't assume click has only one rate, because if you assume 
    % you make an ass out of u and me!
else
    % for the reference, we need to use the trialindex to find which click
    % to use, because we need to have all the clicks in one trial to be the
    % same (but chosen from a set). In reference mode, the ReferenceTarget
    % object passes the trial index in IsRef:
    ClickIndex = mod(IsRef,NumOfClicks); 
    if ClickIndex==0, ClickIndex = NumOfClicks; end
    [wClick, eClick] = waveform(ClickObj,ClickIndex);
end

clear TorcObj ClickObj;
for cnt1 = 1:length(eClick);
    eClick(cnt1).StartTime = eClick(cnt1).StartTime + eTorc(end).StopTime;
    eClick(cnt1).StopTime  = eClick(cnt1).StopTime  + eTorc(end).StopTime;
end
w = [wTorc(:); wClick(:)];
events = [eTorc eClick];