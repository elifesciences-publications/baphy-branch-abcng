function [LickEvents, exptparams] = BehaviorControl(o, HW, StimEvents, ...
    globalparams, exptparams, TrialIndex)

% The maximum shock duration is 0.3:
ShockDuration = min(0.2, get(o,'ShockDuration'));
exptparams.ThereWasShock = 0;
% first, find the shock window, which is the time duration that animal gets
% shocked if lick:
TarPostLickWin = [];
RefPostLickWin = [];
RefSound = [];
TarSound = []; 
LickEvents=[];
StopWaterIfNoLick = get(o,'StopWaterIfNoLick');
WaterDuration = get(o,'PumpDuration');
if StopWaterIfNoLick
    if ~isfield(exptparams,'Water'), exptparams.Water = 0;end
    % we are going to control the water based on the response of the
    % ferret. At the begining, turn the pump on:
    ev = IOControlPump(HW,'Start',WaterDuration);
    LickEvents = AddEvent(LickEvents, ev, TrialIndex);
    exptparams.Water = exptparams.Water+WaterDuration;
end
NumOfEvPerStim = get(exptparams.TrialObject,'NumOfEvPerStim');
% the following two have been added to work in more general situations,
% NumOfEvPerStim is not needed anymore but we keep it for backward
% compatibility
if isfield(get(exptparams.TrialObject),'NumOfEvPerRef'),
    NumOfEvPerRef = get(exptparams.TrialObject,'NumOfEvPerRef');
    NumOfEvPerTar = get(exptparams.TrialObject,'NumOfEvPerTar');
else
    NumOfEvPerRef = NumOfEvPerStim;
    NumOfEvPerTar = NumOfEvPerStim;
end
cnt1 = 1;
while cnt1<length(StimEvents)
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim')
        if strcmpi(StimRefOrTar, 'Reference')
            cnt1 = cnt1 + NumOfEvPerRef-3;
            RefPostLickWin = [RefPostLickWin StimEvents(cnt1).StopTime + get(o,'ResponseTime') ...
                StimEvents(cnt1).StopTime + get(o,'ResponseTime') + get(o,'PostLickWindow')];
            % also save the start time of the reference:
            RefSound(end+1).Start = StimEvents(cnt1).StartTime;
            RefSound(end).Dur = StimEvents(cnt1).StopTime - StimEvents(cnt1).StartTime;
        else
            cnt1 = cnt1 + NumOfEvPerTar-3;
            TarPostLickWin = [TarPostLickWin StimEvents(cnt1).StopTime + get(o,'ResponseTime') ...
                StimEvents(cnt1).StopTime + get(o,'ResponseTime') + get(o,'PostLickWindow')];
            % also save the start time of the reference:
            TarSound(end+1).Start = StimEvents(cnt1).StartTime;
            TarSound(end).Dur = StimEvents(cnt1).StopTime - StimEvents(cnt1).StartTime;
        end
    end
    cnt1 = cnt1+1;
end
if isempty(TarPostLickWin)    % which means its a sham trial, no punishment
    TarPostLickWin = [0 0];
end
% Now monitor the lick
lightFlag=0;
CurrentTime = IOGetTimeStamp(HW);
LastPunishTime = clock - 1;
LastWaterTime = clock - 1;
DidSheLick = 1;
flag1 = 0;
% we monitor the lick until the end plus response time and postargetlick
while CurrentTime < exptparams.LogDuration
    Lick = IoLickRead (HW);
    if (Lick) && (CurrentTime > TarPostLickWin(1)) && (CurrentTime < TarPostLickWin(2)) && ...
            (etime(clock,LastPunishTime) > (ShockDuration+0.05)) % dont send shock command until the last one is done
        % punish her!
        ev = IOControlShock (HW, ShockDuration);
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        LastPunishTime = clock;
        exptparams.ThereWasShock = 1;
    end
    % in the first transition to the PostLick, set the flag to one:
    if mod(length(find(RefPostLickWin<CurrentTime)),2) && (StopWaterIfNoLick) && (flag1 ==0)
        flag1 = 1;
        DidSheLick = 0;
    end
    % now, if she licks in Post window set the flag to one
    if (Lick) && mod(length(find(RefPostLickWin<CurrentTime)),2) && (StopWaterIfNoLick)
        DidSheLick = 1;
    end
    % at anytime, if we are not in post window, set the flag1 to zero, also if she didnot lick stop
    % the water:
    if ~mod(length(find(RefPostLickWin<CurrentTime)),2) && (StopWaterIfNoLick) && (flag1==1)
        flag1 = 0;
        if DidSheLick
            ev = IOControlPump(HW,'Start',WaterDuration);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            exptparams.Water = exptparams.Water+WaterDuration;
            %             ev = IOControlPump (HW,'Stop',0);
            %             LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
    end
    % for the light control, if its yes turn in on on target. if its
    % RefOnTarFlash turn it on for reference but flash for the target.
    switch get(o,'LightOnTarget')
        case 'Yes'
            if (CurrentTime > TarPostLickWin(1)) && (CurrentTime < TarPostLickWin(2)) && lightFlag==0
                [ll,ev] = IOLightSwitch (HW, 1, get(o,'PostLickWindow'));
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
                lightFlag=1;
            end
        case 'RefOnTarFlash'
            % if we are in reference time
            % if multiple light source is on, have the reference light on
            % the LED line, otherwise on the Light:
            if ~isempty(RefSound) && (CurrentTime > RefSound(1).Start)
                    [ll,ev] = IOLightSwitch (HW, 1, RefSound(1).Dur,'start');
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
                RefSound(1)=[];
            end
            % if we are in target time
            if ~isempty(TarSound) && (CurrentTime > TarSound(1).Start)
                [ll,ev] = IOLightSwitch (HW, 1, TarSound(1).Dur,'start',get(o,'LightFlashFreq'));
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
                TarSound(1)=[];
            end
        otherwise
    end
    CurrentTime = IOGetTimeStamp(HW);
end
