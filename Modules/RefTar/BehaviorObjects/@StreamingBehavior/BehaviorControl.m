function [LickEvents, exptparams] = BehaviorControl(o, HW, StimEvents, ...
    globalparams, exptparams, TrialIndex);

% The maximum shock duration is 0.3:
ShockDuration = min(0.2, get(o,'ShockDuration'));
% find the pretarget and posttarget window. to do so, we need to find the
% begining of the target:
PreWindow = [];
PostWindow = [];
LickEvents = [];
for cnt1 = 1:length(StimEvents);
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(StimRefOrTar,'Target') | strcmpi(StimRefOrTar,'Sham')
        PreWindow  = [StimEvents(cnt1).StartTime - get(exptparams.BehaveObject,'PreTargetWindow') ...
            StimEvents(cnt1).StartTime];
    end
end
PostWindow= [StimEvents(end).StartTime ... % assuming the last StimEvents is always the poststim silence
StimEvents(end).StartTime + get(exptparams.BehaveObject,'PostTargetWindow')];
[Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(end));
IsSham = strcmpi(StimRefOrTar,'sham');

lightFlag=0;
CurrentTime = IOGetTimeStamp(HW);
LastPunishTime = clock - 1;
% we monitor the lick until the end plus response time and postargetlick
while CurrentTime < exptparams.LogDuration
    Lick = IoLickRead (HW);
    if (Lick) & (CurrentTime > PostWindow(1)) & (CurrentTime < PostWindow(2)) & ...
            (etime(clock,LastPunishTime) > (ShockDuration+0.05)) & ~IsSham % dont send shock command until the last one is done
        % send the shock!
        ev = IOControlShock (HW, ShockDuration);
        % add shock event to experiment events
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        LastPunishTime = clock;
        % also turn on the light????
        [ll,ev] = IOLightSwitch (HW, 1, get(o,'PostTargetWindow'));
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
    end
    CurrentTime = IOGetTimeStamp(HW);
end
