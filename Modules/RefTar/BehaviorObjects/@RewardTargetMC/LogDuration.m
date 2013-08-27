function Duration = LogDuration (O, HW, StimEvents, globalparams, exptparams, TrialIndex);
% LogDuration method for RewardTargetMC object
% The maximal logduration is the duration of the sound plus the time to respond
% The actual logduration can be shorter
Duration = StimEvents(end).StopTime + get(O,'ResponseWindow') + get(O,'AfterResponseDuration');