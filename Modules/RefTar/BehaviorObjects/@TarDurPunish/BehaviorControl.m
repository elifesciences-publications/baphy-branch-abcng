function [LickEvents, exptparams] = BehaviorControl(o, HW, StimEvents, ...
    globalparams, exptparams, TrialIndex)
% june 2009, adding a new training paradigme to the behavior:
%   shock period can be extended.
%   definition of miss and hit??
%
% June 10 2008:
% if its in passive mode, do not shock the poor animal, do not dispense
% water, and do not flash any light!!

global LastTrialWasSham;

% The maximum shock duration is 0.3:
ShockDuration = min(0.2, get(o,'ShockDuration'));
exptparams.ThereWasShock = 0;
ExtendedShock = get(o,'ExtendedShock');

% first, find the shock window, which is the time duration that animal gets
% shocked if lick:
StimulationFlag=0;
TarPostLickWin = [];
RefPostLickWin = [];
RefSound = [];
TarSound = [];
LickEvents=[];
StopWaterIfNoLick = get(o,'StopWaterIfNoLick');
WaterDuration = get(o,'PumpDuration');

% stimulation parameters
TarStimulation = get(o,'TarStimulation');
TarStimulationDur = get(o,'TarStimulationDur');
TarStimulationOnset = get(o,'TarStimulationOnset');

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

TargetInfo = get(exptparams.TrialObject);

cnt1 = 1;

while cnt1<length(StimEvents)
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim')
        if strcmpi(StimRefOrTar, 'Reference')
            cnt1 = cnt1 + NumOfEvPerRef-3;
            RefPostLickWin = [RefPostLickWin; sort([StimEvents(cnt1).StopTime + get(o,'ResponseTime') ...
                StimEvents(cnt1).StopTime + get(o,'ResponseTime') + get(o,'PostLickWindow')])];
            % also save the start time of the reference:
            RefSound(end+1).Start = StimEvents(cnt1).StartTime;
            RefSound(end).Dur = StimEvents(cnt1).StopTime - StimEvents(cnt1).StartTime;
        else
            TarPostLickWinTemp = sort([StimEvents(cnt1).StartTime + get(o,'ResponseTime') ...
                StimEvents(cnt1).StopTime]);
            
                        cnt1 = cnt1 + NumOfEvPerTar-3;
                            TarPostLickWin = [TarPostLickWin; TarPostLickWinTemp];
                        % also save the start time of the reference:
                        TarSound(end+1).Start = StimEvents(cnt1).StartTime;
                        TarSound(end).Dur = StimEvents(cnt1).StopTime - StimEvents(cnt1).StartTime;
        end
    end
    cnt1 = cnt1+1;
end

if isempty(TarPostLickWin)
    % which means its a sham trial, no punishment
    TarPostLickWin = [0 0];
elseif ExtendedShock
    % in the extended shock, shock till the end of the trial:
    TarPostLickWin(end) = exptparams.LogDuration;
end

PreStimSilence = RefSound(1).Start;
if length(TarSound)>1
    TarSound(1).Dur = TarSound(end).Start+TarSound(end).Dur-TarSound(1).Start;
    TarSound(2:end)=[];
end

% Now monitor the lick
lightFlag=0;
CurrentTime = IOGetTimeStamp(HW);
LastPunishTime = clock - 1;
LastWaterTime = clock - 1;
DidSheLick = 1;
flag1 = 0;
TarPostLickWinNowIndex=1;


% we monitor the lick until the end plus response time and postargetlick

while CurrentTime < exptparams.LogDuration
    Lick = IOLickRead (HW);
    if (Lick) && (ShockDuration) && (etime(clock,LastPunishTime) > (ShockDuration+0.05)) ...
            && isempty(strfind(globalparams.Physiology,'Passive')) % dont send shock command until the last one is done
        if TargetInfo.Punish == 1 && ((CurrentTime > TarPostLickWin(TarPostLickWinNowIndex,1)) && (CurrentTime < TarPostLickWin(TarPostLickWinNowIndex,2)))% if in target
            % punish her!
            disp('***SHOCK***')
            ev = IOControlShock (HW, ShockDuration);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            LastPunishTime = clock;
            exptparams.ThereWasShock = 1;
        end
    end
    % turn off the water 0.5 sec before the trial ends, if extended shock, and not Sham trial:
    if ExtendedShock && (CurrentTime>(exptparams.LogDuration-.5)) && (sum(TarPostLickWin(TarPostLickWinNowIndex,1)>0))
        ev = IOControlPump(HW,'Stop');
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
    end
    % now, if she licks in the second Reference, turn on the water:
    if ExtendedShock && (CurrentTime<RefPostLickWin(min(4,length(RefPostLickWin)))) && (CurrentTime>PreStimSilence) && Lick
        ev = IOControlPump(HW,'Start');
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
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
    if ~mod(length(find(RefPostLickWin<CurrentTime)),2) && (StopWaterIfNoLick) && (flag1==1) ...
            && isempty(strfind(globalparams.Physiology,'Passive'))
        flag1 = 0;
        if DidSheLick
            ev = IOControlPump(HW,'Start',WaterDuration);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            exptparams.Water = exptparams.Water+WaterDuration;
            %             ev = IOControlPump (HW,'Stop',0);
            %             LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
    end
    
    % if we have TargetStimulation, send it too:
    if TarStimulation && ~isempty(TarSound) && (StimulationFlag==0) && ...
            (CurrentTime>=(TarSound(1).Start+TarStimulationOnset))
        % send the stimulation
        ev = IOControlStimulation (HW,TarStimulationDur,'Start');
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        StimulationFlag=1;
    end
    CurrentTime = IOGetTimeStamp(HW);
    if CurrentTime > TarPostLickWin(TarPostLickWinNowIndex,2)
        if TarPostLickWinNowIndex < size(TarPostLickWin,1)
            TarPostLickWinNowIndex = TarPostLickWinNowIndex+1;
        end
    end

    if (globalparams.HWSetup~=0)
        if CurrentTime >= exptparams.LogDuration-.15;
            IOControlPump (HW,'Stop',0);
                
        end
    end
    
%     if CurrentTime >= exptparams.LogDuration-1
%           IOControlPump(HW,'Stop');
%     end
end
 [ll,ev] = IOLightSwitch (HW,0);
 disp('[pump off]')
