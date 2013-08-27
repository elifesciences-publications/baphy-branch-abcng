function Duration = LogDuration (o, HW, StimEvents, globalparams, exptparams, TrialIndex);
% the duration is when sound ends plus response time plus postlick
% window. this is true for targets and referenfec:
% find the last STIM:

Duration = StimEvents(end).StopTime;