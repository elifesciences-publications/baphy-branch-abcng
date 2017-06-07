function StopExperiment = CanStart (o, HW, StimEvents, globalparams, exptparams, TrialIndex)
% CanStart for ReferenceAvoidance
% We wait until the animal does not lick for at least NoResponseTime

% turn on the light if its needed:
if strcmpi(get(o,'TurnOffLight'),'Ineffective')
    ev = IOLightSwitch(HW,1);
end

% 15/08-YB
% if TrialIndex==1
%     PumpDuration = 2*get(o,'PumpDuration');
%     tic;  %added by pby
%     ev = IOControlPump (HW,'start',PumpDuration);
%     pause(PumpDuration);
%     if strcmpi(get(o,'TurnOnLight'),'BehaveOrPassive')
%         [ll,ev] = IOLightSwitch (HW, 1);
%     end
%     pause(1);
% end
disp('Waiting for no response time');
global StopExperiment;
LastTime = clock;
while etime(clock,LastTime)<get(o,'NoResponseTime') && ~StopExperiment
    if IOLickRead(HW)
        % if she licks, reset the timer
        LastTime = clock;
    end
    drawnow;
end