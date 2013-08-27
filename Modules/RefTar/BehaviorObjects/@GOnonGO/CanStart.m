function StopExperiment = CanStart (o, HW, StimEvents, globalparams, exptparams, TrialIndex)
% CanStart for ReferenceAvoidance
% We wait until the animal does not lick for at least NoResponseTime
global StopExperiment;
if ~isempty(strfind(globalparams.Physiology,'Passive'))
    % in the passive mode, we do not wait for the lick/stoplick to start the trial:
    return;
end

% turn on the light if its needed:
if strcmpi(get(o,'TurnOffLight'),'Ineffective')
    ev = IOLightSwitch(HW,1);
end

if TrialIndex==1
    PumpDuration = 2*get(o,'PumpDuration');
    tic;  %added by pby
    ev = IOControlPump (HW,'start',PumpDuration(1));    
    if strcmpi(get(o,'TurnOnLight'),'BehaveOrPassive')
        [ll,ev] = IOLightSwitch (HW, 1);
    end
    pause(PumpDuration(1));
end
disp('Waiting for no response time');
LastTime = clock;
while etime(clock,LastTime)<get(o,'NoResponseTime') && ~StopExperiment
    if IOLickRead(HW)
        % if she licks, reset the timer
        LastTime = clock;
    end
    drawnow;
end