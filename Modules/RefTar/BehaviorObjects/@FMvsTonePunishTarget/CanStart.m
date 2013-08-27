function StopExperiment = CanStart (o, HW, StimEvents, globalparams, exptparams, TrialIndex)
% In punish target script, 
% start as soon as the animal licks:

% in the passive mode, we do not wait for the lick to start the trial:
global StopExperiment LastTrialWasSham;
% if flash in beginning, for the first experiemt only flash the light:
if (TrialIndex==1) && strcmpi(get(o,'LightOnTarget'),'Beginning')
    Gap = (0.5/ifstr2num(get(o,'LightFlashFreq')));
    [ll,ev] = IOLightSwitch (HW, 1, 0.5 ,'start',...
        ifstr2num(get(o,'LightFlashFreq')),Gap);
end

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

pause(randi(4))
LightTemp = get(o);
LightTemp = o.LightOnTarget;
if  strcmp(LightTemp,'Yes')
  IOLightSwitch (HW,1,10000);
end
if (globalparams.HWSetup==1)
  IOControlPump(HW,'Start',10000);
end

disp('Waiting for lick signal');
while ~IOLickRead(HW) && ~StopExperiment && isempty(strfind(globalparams.Physiology,'Passive'))
    drawnow;
end