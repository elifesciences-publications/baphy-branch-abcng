function [LickEvents, exptparams] = BehaviorControl(o, HW, StimEvents, ...
    globalparams, exptparams, TrialIndex)
% Behavior Object for RewardTarget object
% Lick during the response window after a reference is a false alarm.
% The trial will be force-stopped at the begining of the target if false
% alarm rate is equal to 1.0, and following an instruction trial.
% Lick within response window after a target, a drop of water rewarded.
% The size of drop depends on the false alarm rate in the trial.
% A click sound will play as a reinforement signal when delivering the reward.
% A lick before the response window and after onset of target is an early response,
% the trial will be stopped.

% Ling Ma, 04/2007;, NSL
% detect light flashing from light off;


NumRef = 0;
RefFlag=[];
TarFlag=[];
FalseAlarm = 0;
StopTargetFA = get(o,'StopTargetFA');
LickEvents = [];
prestimsilence = StimEvents(1).StopTime;
TarH = get(exptparams.TrialObject,'TargetHandle');
postimsilence = get(TarH,'PostStimSilence');

LightOffWin=[]; TarEarlyWin=[]; TarResponseWin=[];
lightonfreq = get(o,'LightOnFreq');
switch get(o,'FlickerLight')
    case 'Target'
        
    case 'RespWin'
        LightFlashDur = get(o,'ResponseWindow');        
end
exptparams.LightFlashDur = LightFlashDur;
if ~isfield(exptparams,'Water'), exptparams.Water = 0;end

for cnt1 = 1:length(StimEvents);
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim') %&& ~isempty(strfind(StimName,'$'))
%         if ~isempty(RefResponseWin)  % the response window should not go to the next sound!
%             RefResponseWin(end) = min(RefResponseWin(end), StimEvents(cnt1).StartTime);
%         end
        switch get(o,'FlickerLight')
        case 'Target'
        if strcmpi(StimRefOrTar,'Target')
            % when the light start blinking or turning off
            LightOffWin = [LightOffWin StimEvents(cnt1).StartTime+get(o,'CueWindow')+get(o,'EarlyWindow') StimEvents(cnt1).StopTime];
            TarEarlyWin = [TarEarlyWin StimEvents(cnt1).StopTime StimEvents(cnt1).StopTime+get(o,'CueWindow')+get(o,'EarlyWindow')];
            TarResponseWin = [TarResponseWin  StimEvents(cnt1).StopTime+get(o,'CueWindow')+get(o,'EarlyWindow') ...
                StimEvents(cnt1).StopTime+get(o,'CueWindow')+get(o,'EarlyWindow')+get(o,'ResponseWindow')];
        end
        case 'RespWin'
            TarEarlyWin = [TarEarlyWin StimEvents(cnt1).StartTime+get(o,'CueWindow') ...
                StimEvents(cnt1).StartTime+get(o,'CueWindow')+get(o,'EarlyWindow')];
            TarResponseWin = [TarResponseWin  StimEvents(cnt1).StartTime+get(o,'CueWindow')+get(o,'EarlyWindow') ...
                StimEvents(cnt1).StartTime+get(o,'CueWindow')+get(o,'EarlyWindow')+get(o,'ResponseWindow')+...
                postimsilence];
            LightOffWin = [TarResponseWin  StimEvents(cnt1).StartTime+get(o,'CueWindow')+get(o,'EarlyWindow') ...
                StimEvents(cnt1).StartTime+get(o,'CueWindow')+get(o,'EarlyWindow')+get(o,'ResponseWindow')];
        end
    end
end 

if strcmpi(get(o,'TurnOnLight'),'TrialStart')
    [ll,ev] = IOLightSwitch (HW,1,0);
end
CurrentTime = IOGetTimeStamp(HW);
% we monitor the lick until the end plus response time and postargetlick
LastLick = 0;
TimeOutFlag=1;
tarcnt = 1;
refcnt = 1;
while CurrentTime < exptparams.LogDuration
    ThisLick = IOLickRead(HW);  
    Lick = ThisLick && ~LastLick;
    LastLick = ThisLick;
    if ~isempty(LightOffWin) && CurrentTime>(LightOffWin(end)-0.2)
        % this is to fix the problem of stopping in the begining of the target
        StopFlag = 1;
    else
        StopFlag = 0;
    end
    if strcmpi(get(o,'StopStim'),'Immediately'),
        StopFlag = 1;
    end    

    if ~isempty(LightOffWin) && CurrentTime<LightOffWin(end) &&...% find out if we are in the reference or target part
            ~strcmpi(get(o,'FlickerLight'),'RespWin')
        StimPos = length(find(LightOffWin<CurrentTime));
        % stim pos tells us whether we are "IN" the windows calculated above or outside of it
        Ref = 1;  % we are in reference part of the sound
                      
        %set the light off during reference; added by Ling Ma,04/2007.
        if  lightonfreq~=0 && ~strcmp(get(o,'FlickerLight'),'RespWin')
            IOLightSwitch(HW,0);
        end
    else % if we are either in target part or in ref for flicker in RW
        StimPos = length(find(TarResponseWin<CurrentTime));
        EarlyPos = length(find(TarEarlyWin<CurrentTime));
%         LightPos = length(find(TarLightWin<CurrentTime));
        Ref = 0;
        
        % set light flashing during target; added by Ling Ma,04/2007.
        if (tarcnt==1) && lightonfreq~=0 && CurrentTime>LightOffWin(end) 
            IOLightSwitch(HW,1,LightFlashDur,'start',lightonfreq);
            tarcnt = tarcnt+1;
        elseif (tarcnt==1) && CurrentTime>TarResponseWin(1) && strcmpi(get(o,'FlickerLight'),'RespWin')
            if lightonfreq==0 
                [ll,ev] = IOLightSwitch (HW,0,0);
            else
                IOLightSwitch(HW,1,LightFlashDur,'start',lightonfreq);
            end
            tarcnt = tarcnt+1;
        end
    end
    if StopFlag && (FalseAlarm>=StopTargetFA)
        % ineffective sound:
        ev = IOStopSound(HW);
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        ThisTime = clock;
        if strcmpi(get(o,'TurnOffLight'),'Ineffective')
                ev = IOLightSwitch(HW,0);
        end
        break;
%         while etime(clock,ThisTime) < (get(o,'TimeOut')+exptparams.LogDuration-CurrentTime)
%             drawnow;
%         end
%         while(IOGetTimeStamp(HW)<exptparams.LogDuration), end;
%         break;
    end
    if (Lick) && Ref && mod(StimPos,2) && ~isequal(RefFlag,StimPos)
        % RefFlag: we want to add to the FalseAlarm only once for each
        % reference.
        % if she licks in reference response window, add to the false alarm
        % rate
        if strcmpi(get(o,'TurnOnLight'),'FalseAlarm')
            [ll,ev] = IOLightSwitch (HW, 1, .2);            
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
        if strcmpi(get(o,'Shock'),'FalseAlarm')
            ev = IOControlShock (HW, .2, 'Start');
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
        
        RefFlag = StimPos;
%         FalseAlarm = FalseAlarm + diff(TarResponseWin)/diff(LightOffWin); % norm by different duration;
        FalseAlarm = FalseAlarm + 1;
    end
    
    if (Lick) && ~Ref && mod(EarlyPos,2)
        % if she licks in early window, terminate the trial immediately, and give her timeout.
        [ll,ev] = IOLightSwitch (HW,0,0);
        ev = IOStopSound(HW);
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        break;
%         ThisTime = clock;
%         while etime(clock,ThisTime) < (get(o,'TimeOut')+exptparams.LogDuration-CurrentTime)
%             drawnow;
%         end
%         while(IOGetTimeStamp(HW)<exptparams.LogDuration), end;
%         break;
    end
    if (Lick) && mod(StimPos,2) && ~isequal(TarFlag,StimPos) && ~Ref
        % if she licks in target response window
        TimeOutFlag = 0;
        if StopTargetFA<1
            WaterFraction = 1-FalseAlarm;
        else
            WaterFraction = 1;
        end
        PumpDuration = get(o,'Reward')/globalparams.PumpMlPerSec.Pump;
        PumpDuration = PumpDuration * WaterFraction;
        if PumpDuration > 0
            ev = IOControlPump (HW,'start',PumpDuration);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            exptparams.Water = exptparams.Water+PumpDuration;
            if strcmpi(get(exptparams.BehaveObject,'RewardSound'),'Click') && PumpDuration
                ClickSend (PumpDuration/2);
            end
            if strcmpi(get(exptparams.BehaveObject,'TurnOnLight'),'Reward')
                [ll,ev] = IOLightSwitch (HW, 1, get(o,'PumpDuration'));
                
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            end
        end
        TarFlag = StimPos;
    end
    CurrentTime = IOGetTimeStamp(HW);
end
if TimeOutFlag>0
    ThisTime = clock;
    TimeOut = get(o,'TimeOut');
%     TimeOut = TimeOut * (1+2*FalseAlarm);
    while etime(clock,ThisTime) < TimeOut
        drawnow;
    end
end

exptparams.TarResponseWin = TarResponseWin;
exptparams.RefResponseWin = LightOffWin;
exptparams.TarEarlyWin = TarEarlyWin;
