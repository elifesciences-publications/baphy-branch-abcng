function StopExperiment = CanStart (o, HW, StimEvents, globalparams, exptparams, TrialIndex)
% In punish target script,
% start as soon as the animal licks:

% in the passive mode, we do not wait for the lick to start the trial:
global StopExperiment LastTrialWasSham;
% if flash in beginning, for the first experiemt only flash the light:

if isempty(LastTrialWasSham), LastTrialWasSham=0;end
if (globalparams.HWSetup==2) && (~isempty(strfind(globalparams.Physiology,'Passive')) || ...
        get(o,'ExtendedShock'))
    IOControlShock(HW,0,'stop');
    ShockDuration = min(0.2, get(o,'ShockDuration'));
    % wait until there is no lick for at least 0.4 seconds. If animal
    % licks, shock her :-(
    LastTime = clock;
    while etime(clock,LastTime)< 0.5 && ~StopExperiment && ~LastTrialWasSham
        if IOLickRead(HW)
            % if she licks, reset the timer
            ev = IOControlShock (HW, ShockDuration);
            LastTime = clock;
        end
        drawnow;
    end
    return;
end

pause(randsample([2.5:.5:4],1))
if  globalparams.HWSetup ~= 0
    LightTemp = get(o);
    LightTemp = o.LightOnTrial;
    if  strcmp(LightTemp,'Yes')
        if globalparams.HWSetup~=7
            IOLightSwitch (HW,1,1,[],3);
        else
                  IOLightSwitch (HW,1,1,[],6,[],'LightL');

        end
    end
end

if  globalparams.HWSetup ~= 0
    IOControlPump(HW,'Start',10000);
end



disp('Waiting for lick signal');
while ~IOLickRead(HW) && ~StopExperiment && isempty(strfind(globalparams.Physiology,'Passive'))
    drawnow;
end