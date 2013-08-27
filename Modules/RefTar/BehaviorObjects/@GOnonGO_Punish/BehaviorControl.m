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
FlowRate=get(exptparams.TrialObject,'FlowRate_mlPmin')/60;  %flowarte ml/sec

[t,trial,Note,toff,StimIndex] = evtimes(StimEvents,'Stim*');
%stidur = StimEvents(StimIndex).StopTime-StimEvents(StimIndex).StartTime;
[Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(StimIndex));

stimOnset=StimEvents(StimIndex).StartTime;
ResponseWin = [0 get(o,'ShockWindow')] + stimOnset + get(o,'EarlyWindow');
CurrentTime = IOGetTimeStamp(HW);

% we monitor the lick until the end plus response time and postargetlick
TimeOutFlag=0;
RespFlag=0;  %1- correct reject, 2- miss
earlyFlag=0;
LickEvents=[];
if strcmpi(get(o,'TurnOnLight'),'BehaveOrPassive')
    LIGHTON=1; else
    LIGHTON=0; 
end
while CurrentTime < exptparams.LogDuration
    Lick = IoLickRead (HW);  
    if RespFlag==0 && CurrentTime>ResponseWin(1) && CurrentTime<ResponseWin(2)  %if lick during get a shock
        if strcmpi(StimRefOrTar,'target') && (Lick)
            ev = IOControlShock (HW, .2, 'Start');
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            TimeOutFlag=1;   %apply timeout
            RespFlag=2;      %mark a miss
        elseif strcmpi(StimRefOrTar,'reference') && (Lick)
            RespFlag=1;      %mark a correct reject
            TimeOutFlag=0;
        end
    elseif CurrentTime>=ResponseWin(1)   %sum of licks before resonsp window
        if (Lick)
            earlyFlag=earlyFlag+1;
        end
    end

    if RespFlag==2 && strcmpi(StimRefOrTar,'target')   % if she licks in target response window (miss)
        if strcmpi(get(o,'TurnOnLight'),'miss') && LIGHTON==0
            [ll,ev] = IOLightSwitch (HW, 1, .2);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            LIGHTON=1;
        end
        if strcmpi(get(o,'TurnOffLight'),'miss') && LIGHTON==1
            [ll,ev] = IOLightSwitch (HW, 0,0.5);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            LIGHTON=0;
        end
        if strcmpi(get(o,'PunishSound'),'Click')
            ClickSend (0.5);
        end
    end

    if RespFlag==1 && strcmpi(StimRefOrTar,'reference')  % if she licks in reference response window        
       %no action for correct reject for now
    end
    CurrentTime = IOGetTimeStamp(HW);
end
%computing water amount in ml
exptparams.Water = exptparams.LogDuration*FlowRate;

if TimeOutFlag>0
    ThisTime = clock;
    TimeOut = ifstr2num(get(o,'TimeOut'));
    while etime(clock,ThisTime) < (TimeOut+exptparams.LogDuration-CurrentTime)
        drawnow;
    end
%     if LIGHTON==0
%         [ll,ev] = IOLightSwitch (HW, 1);
%         LickEvents = AddEvent(LickEvents, ev, TrialIndex);
%     end
end