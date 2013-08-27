function Duration = LogDuration (o, HW, StimEvents, globalparams, exptparams, TrialIndex)
% the duration is when sound ends plus response time plus postlick
% window. this is true for targets and referenfec:
% find the last STIM:
for cnt1 = 1:length(StimEvents)
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type, 'Stim')
        LastStimStopTime = StimEvents(cnt1).StopTime;
    end
end
% The log duration is laststim stop time plus response time plus
% PostLickWindow, or when the sound stops, whichever is greater.
Duration = max(LastStimStopTime+get(o,'ResponseTime')+get(o,'PostLickWindow'), ...
    StimEvents(end).StopTime);
