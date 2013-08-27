function Duration = LogDuration (o, HW, StimEvents, globalparams, exptparams, TrialIndex);
% LogDuration method for ReferenceAvoidance object
% the log duration is the end of the sound plus response time
Duration = StimEvents(end).StopTime + get(o,'ResponseWindow');