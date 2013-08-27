function StopExperiment = CanStart (o, HW, StimEvents, globalparams, exptparams, TrialIndex);
% In punish target script, 
% start as soon as the animal licks:
disp('Waiting for lick signal');
global StopExperiment;
while ~IOLickRead(HW) && ~StopExperiment
    drawnow; 
end