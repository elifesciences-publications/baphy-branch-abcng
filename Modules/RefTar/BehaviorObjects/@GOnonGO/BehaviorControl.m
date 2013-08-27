function [LickEvents, exptparams] = BehaviorControl(o, HW, StimEvents, ...
    globalparams, exptparams, TrialIndex)
% Behavior Object for RewardTarget object
% Lick during the response window after a reference is a false alarm.
% Lick within response window after a target, a drop of water rewarded.
% A click sound will play as a reinforement signal when delivering the reward.
% A lick before the response window and after onset of target is an early
% response,

% Pingbo, Aguest 3, 2006, NSL
if ~isfield(exptparams,'Water'), exptparams.Water = 0;end

[t,trial,Note,toff,StimIndex] = evtimes(StimEvents,'Stim*');
%stidur = StimEvents(StimIndex).StopTime-StimEvents(StimIndex).StartTime;
[Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(StimIndex));

ResponseWin = [StimEvents(StimIndex).StartTime + get(o,'EarlyWindow') ...
    StimEvents(StimIndex).StartTime + get(o,'ResponseWindow') + get(o,'EarlyWindow')];

stimOnset=StimEvents(StimIndex).StartTime;
CurrentTime = IOGetTimeStamp(HW);
% we monitor the lick until the end plus response time and postargetlick
LastLick = 0;
TimeOutFlag=0;
RespFlag=0; earlyFlag=0; condFlag=0;
StimulationFlag=0;
LickEvents=[];
PumpDuration = get(o,'PumpDuration');
% stimulation parameters
TarStimulation = get(o,'TarStimulation');
TarStimulation = TarStimulation && (~isempty(strfind(globalparams.Physiology,'Passive')));
%TarStimulation work only in passive condition
TarStimulationDur = get(o,'TarStimulationDur');
TarStimulationOnset = get(o,'TarStimulationOnset');
LIGHTON=1;
while CurrentTime < exptparams.LogDuration
    if CurrentTime>ResponseWin(2) && earlyFlag==0 && RespFlag==0 && condFlag==0 ... 
            && PumpDuration(2)>0 && strcmpi(StimRefOrTar,'target') && (~TarStimulation)
        %conditioning drop delivery after a target miss 
        ev = IOControlPump (HW,'start',PumpDuration(2));
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        exptparams.Water = exptparams.Water+PumpDuration(2);
        condFlag=1;   %
    end
    
    ThisLick = IoLickRead (HW);  
    Lick = ThisLick && ~LastLick;
    LastLick = ThisLick;
    if (Lick)
        if (earlyFlag==0) && CurrentTime<=ResponseWin(2) && CurrentTime>ResponseWin(1) && (RespFlag==0)
            RespFlag = 1;  end
        if CurrentTime<=ResponseWin(1) && earlyFlag==0
            earlyFlag=1; end
    end

    if RespFlag==1 && strcmpi(StimRefOrTar,'reference') && (~TarStimulation)
        if strcmpi(get(o,'TurnOnLight'),'FalseAlarm')
            [ll,ev] = IOLightSwitch (HW, 1, .2);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        elseif strcmpi(get(o,'TurnOffLight'),'FalseAlarm')
            [ll,ev] = IOLightSwitch (HW, 0,0.5);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            LIGHTON=0;
        end
        if strcmpi(get(o,'Shock'),'FalseAlarm')
            ev = IOControlShock (HW, .2, 'Start');
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
        TimeOutFlag=1;
        RespFlag=2;
    end

    if RespFlag==1 && strcmpi(StimRefOrTar,'target') && (~TarStimulation);  % if she licks in target response window        
        if PumpDuration(1) > 0
            ev = IOControlPump (HW,'start',PumpDuration(1));
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            exptparams.Water = exptparams.Water+PumpDuration(1);
            if strcmpi(get(exptparams.BehaveObject,'RewardSound'),'Click') && PumpDuration(1)
                ClickSend (PumpDuration(1)/2);
            end
            if strcmpi(get(exptparams.BehaveObject,'TurnOnLight'),'Reward')
                [ll,ev] = IOLightSwitch (HW, 1, get(o,'PumpDuration'));
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            end
        end
        RespFlag=2;
    end
    if TarStimulation && strcmpi(StimRefOrTar,'target') && (StimulationFlag==0) && ...
            (CurrentTime>=(stimOnset+TarStimulationOnset))
        % send the stimulation
        ev = IOControlStimulation (HW,TarStimulationDur,'Start');
        disp('Pairing stimulation...');
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        StimulationFlag=1;
    end
    CurrentTime = IOGetTimeStamp(HW);
end
if TimeOutFlag>0 && (~TarStimulation)
    ThisTime = clock;
    TimeOut = ifstr2num(get(o,'TimeOut'));
    while etime(clock,ThisTime) < (TimeOut+exptparams.LogDuration-CurrentTime)
        drawnow;
    end
    if LIGHTON==0
        [ll,ev] = IOLightSwitch (HW, 1);
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
    end
end