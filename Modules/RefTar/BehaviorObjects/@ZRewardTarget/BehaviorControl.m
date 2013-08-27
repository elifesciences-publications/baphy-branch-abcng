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

% Nima, april 2006, NSL
% algorithm:
%   find the response window for all ref sounds from StimEvents
%   find the early window and response window from StimEvents
%   monitor the lick,
%     if animal licks in response window after the
%     reference, increase the False Alarm. As soon as its one, terminate
%     the sound
%     if animal licks in early window, stop the trial
%     if animal licks in the response window after target, give water

% added light signal by Ling Ma, 04/2007;
% light flash during reference; and light on during target;

RefResponseWin = [];
TarResponseWin = [];
TarEarlyWin    = [];
RefLightWin = [];
TarLightWin = [];
NumRef = 0;
RefFlag=[];
TarFlag=[];
FalseAlarm = 0;
StopTargetFA = get(o,'StopTargetFA');
LickEvents = [];
if ~isfield(exptparams,'Water'), exptparams.Water = 0;end
% calculate target duratioin; added by Ling Ma,04/2007.
[t,trial,Note,toff,TarIndex] = evtimes(StimEvents,'*Target*');
[t,trial,Note,toff,StimIndex] = evtimes(StimEvents,'Stim*');
index = intersect(TarIndex,StimIndex);
if ~isempty(index)
    tardur = StimEvents(index(end)).StopTime-StimEvents(index(1)).StartTime; end

for cnt1 = 1:length(StimEvents);
    [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
    if strcmpi(Type,'Stim') && ~isempty(strfind(StimName,'$'))
        if ~isempty(RefResponseWin)  % the response window should not go to the next sound!
            RefResponseWin(end) = min(RefResponseWin(end), StimEvents(cnt1).StartTime);
        end
        if strcmpi(StimRefOrTar,'Reference')
            RefResponseWin = [RefResponseWin StimEvents(cnt1).StartTime + get(o,'EarlyWindow') ...
                StimEvents(cnt1).StartTime + get(o,'ResponseWindow') + get(o,'EarlyWindow')];
            NumRef = NumRef + 1;
            RefLightWin = [RefLightWin StimEvents(cnt1).StartTime StimEvents(cnt1).StartTime+tardur];
        else
            TarResponseWin = [TarResponseWin StimEvents(cnt1).StartTime + get(o,'EarlyWindow') ...
                StimEvents(cnt1).StartTime + get(o,'ResponseWindow') + get(o,'EarlyWindow')];
            TarEarlyWin = [TarEarlyWin StimEvents(cnt1).StartTime ...
                StimEvents(cnt1).StartTime + get(o,'EarlyWindow')];
            TarLightWin = [TarLightWin StimEvents(cnt1).StartTime StimEvents(cnt1).StartTime+tardur];
        end
    end
end 

CurrentTime = IOGetTimeStamp(HW);
% we monitor the lick until the end plus response time and postargetlick
LastLick = 0;
TimeOutFlag=1;
lightonfreq = get(o,'LightOnFreq');
tarcnt = 1;
refcnt = 1;
while CurrentTime < exptparams.LogDuration
    ThisLick = IoLickRead (HW);  
    Lick = ThisLick && ~LastLick;
    LastLick = ThisLick;
    if ~isempty(RefResponseWin) && CurrentTime>(RefResponseWin(end)-0.2)
        % this is to fix the problem of stopping in the begining of the
        % target
        StopFlag = 1;
    else
        StopFlag = 0;
    end
    if strcmpi(get(o,'StopStim'),'Immediately'),
        StopFlag = 1;
    end
    
%     lightdur0 = [lightonfreq;tardur];
    if ~isempty(RefResponseWin) && CurrentTime<RefResponseWin(end)   % find out if we are in the reference or target part
        StimPos = length(find(RefResponseWin<CurrentTime)); % stim pos tells us whether we
        % are "IN" the windows calculated above or outside of it
        Ref = 1;  % we are in reference part of the sound
                      
        %set the light on during reference; added by Ling Ma,04/2007.
%         LightPos = length(find(RefLightWin<CurrentTime));
%         if (refcnt==1) && ~(lightonfreq==0) && Ref==1
%            IOLightSwitch(HW,1,tardur,'Start',lightonfreq);
%            refcnt = refcnt+1;
%         end
        if  ~(lightonfreq==0) 
            IOLightSwitch(HW,0);
        end
    else % if we are in target part
        StimPos = length(find(TarResponseWin<CurrentTime));
        EarlyPos = length(find(TarEarlyWin<CurrentTime));
        LightPos = length(find(TarLightWin<CurrentTime));
        Ref = 0;
        
        %set light flashing during target; added by Ling Ma,04/2007.
        if (tarcnt==1) & ~(lightonfreq==0) & CurrentTime>TarLightWin(1) 
           IOLightSwitch(HW,1,tardur,'start',lightonfreq);
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
        FalseAlarm = FalseAlarm + 1/NumRef;
    end
    if (Lick) && ~Ref && mod(EarlyPos,2)
        % if she licks in early window, terminate the trial immediately, and
        % give her timeout.
        % ev = IOStopSound(HW);
        % LickEvents = AddEvent(LickEvents, ev, TrialIndex);
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
        PumpDuration = get(o,'PumpDuration') * WaterFraction;
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
    TimeOut = ifstr2num(get(o,'TimeOut'));
    TimeOut = TimeOut * (1+2*FalseAlarm);
    while etime(clock,ThisTime) < (TimeOut+exptparams.LogDuration-CurrentTime)
        drawnow;
    end
end