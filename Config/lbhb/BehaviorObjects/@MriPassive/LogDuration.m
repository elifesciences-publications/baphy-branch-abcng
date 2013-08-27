function Duration = LogDuration (o,HW, StimEvents, globalparams, exptparams, TrialIndex)
% Specifies how long we want to collect data

% the duration is when sound ends plus response time plus
% PosTargetLickWindow:
Duration = StimEvents(end).StopTime;
