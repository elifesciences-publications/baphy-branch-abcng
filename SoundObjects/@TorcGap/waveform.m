function [w,events] = waveform (o,index,IsRef);

% first, create an instance of torc object:
TorcObj = Torc(get(o,'SamplingRate'),...
    0, ...               % No Loudness
    get(o,'PreStimSilence'), ...    % Put the PreStimSilence before torc.
    get(o,'PostStimSilence'), ...     % Put half of gap after torc, the other half goes before Click
    get(o,'Duration'), get(o,'FreqRange'), get(o,'Rates'));
%
SamplingRate = get(o,'SamplingRate');
StartSample = (get(o,'GapStartTime')+get(o,'PreStimSilence')) * SamplingRate;
StopSample = StartSample + get(o,'GapDuration') * SamplingRate;
% Now get the event and waveforms:
[w, events] = waveform(TorcObj, index);
% Now put the gap in:
w (StartSample:StopSample) = 0;
events(end+1) = events(end);
ind = findstr(events(end-1).Note,',');
events(end-1).Note = ['GAP ' events(end-1).Note(ind(1):end)];
events(end-1).StartTime = StartSample / SamplingRate;
events(end-1).StopTime = StopSample / SamplingRate;
