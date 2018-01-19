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
RefEarlyWin    = [];
RefLightWin = [];
TarLightWin = [];
NumRef = 0;
RefFlag=[];
TarFlag=[];
FalseAlarm = 0;
LEDTurnedOn = 0;
StopTargetFA = get(o,'StopTargetFA');
RewardAmount = get(o,'RewardAmount');
EarlyWindow = get(o,'EarlyWindow');
% if strcmpi(class(RH),'TorcToneDiscrim')
%   % for this paradigm (ONLY WITH MAXREF=1), EarLyWindow specifies when
%   %within the Tone the EarlyWindow stops
%   EarlyWindow = EarlyWindow + get(StimEvents(end-2).StartTime);
% end
AutomaticReward = get(o,'AutomaticReward');
DelayAutomaticReward = 0.2;
RH = get(exptparams.TrialObject,'ReferenceHandle'); TH = get(exptparams.TrialObject,'TargetHandle');
FirstRef = 1;
LickEvents = [];
tardur=0;   %added by py @ 9/6/2012
SoundStopped = 0;
if ~isfield(exptparams,'Water'), exptparams.Water = 0;end
exptparams.WaterUnits = 'milliliter';
% calculate target duration; added by Ling Ma,04/2007.
[t,trial,Note,toff,TarIndex] = evtimes(StimEvents,'*Target*');
[t,trial,Note,toff,StimIndex] = evtimes(StimEvents,'Stim*');
index = intersect(TarIndex,StimIndex);
if ~isempty(index)
    tardur = StimEvents(index(end)).StopTime-StimEvents(index(1)).StartTime; else
    tardur = StimEvents(StimIndex(end)).StopTime-StimEvents(StimIndex(end)).StartTime;   %refdur
end
 
for cnt1 = 1:length(StimEvents)
  [Type, StimName, StimRefOrTar] = ParseStimEvent (StimEvents(cnt1));
  if strcmpi(Type,'Stim') %&& ~isempty(strfind(StimName,'$'))  % 15/06: YB (condition never filled in for TORC/Tone at least)
    
    if ~isempty(RefResponseWin) %&& ~strcmpi(class(RH),'TorcToneDiscrim') % the response window should not go to the next sound!
      RefResponseWin(end) = min(RefResponseWin(end), StimEvents(cnt1).StartTime);
%     elseif strcmpi(class(RH),'TorcToneDiscrim') && ...
%         ( (get(o,'ResponseWindow') + EarlyWindow) > get(RH,'PreStimSilence')+get(RH,'TorcDuration')+max(get(RH,'TorcToneGap'))+get(RH,'ToneDuration')+get(RH,'PostStimSilence') )
%       error('Response window too long: overlaps next sound')
    end
    
    if strcmpi(StimRefOrTar,'Reference')
      if ~strcmpi(class(RH),'TorcToneDiscrim') || ( strcmpi(class(RH),'TorcToneDiscrim') && isempty(strfind(upper(StimName),'TORC')) )
        RefResponseWin = [RefResponseWin StimEvents(cnt1).StartTime + EarlyWindow ...
          StimEvents(cnt1).StartTime + EarlyWindow + get(o,'ResponseWindow')];
        NumRef = NumRef + 1;
        RefLightWin = [RefLightWin StimEvents(cnt1).StartTime StimEvents(cnt1).StartTime+tardur];
        RefEarlyWin = [RefEarlyWin StimEvents(cnt1).StartTime ...
          StimEvents(cnt1).StartTime + EarlyWindow];
%         FirstRef = 0;
%       else
%         FirstRef = 1;
      end
    elseif strcmpi(StimRefOrTar,'Target')
      if ~strcmpi(class(TH),'TorcToneDiscrim') || ( strcmpi(class(TH),'TorcToneDiscrim') && isempty(strfind(upper(StimName),'TORC')) )
        TarResponseWin = [TarResponseWin StimEvents(cnt1).StartTime + EarlyWindow ...
          StimEvents(cnt1).StartTime + EarlyWindow + get(o,'ResponseWindow')];
        TarEarlyWin = [TarEarlyWin StimEvents(cnt1).StartTime ...
          StimEvents(cnt1).StartTime + EarlyWindow];
        TarLightWin = [TarLightWin StimEvents(cnt1).StartTime StimEvents(cnt1).StartTime+tardur];
      end
    end
    
  end
end

[LightStateR, ev] = IOLightSwitch(HW,1,0,[],0,0,'LightR');
% we monitor the lick until the end plus response time and postargetlick
LastLick = 0;
ll = 0;
TimeOutFlag=1;
lightonfreq = get(o,'LightOnFreq');
tarcnt = 1;
refcnt = 1;
fprintf(['\nRunning Trial [ <=',n2s(exptparams.LogDuration),'s -- ' num2str(NumRef) 'ref & ' num2str(~strcmpi(StimRefOrTar,'Reference')) 'tar] ... ']);
fprintf(['LogDuration = ' num2str(exptparams.LogDuration) 's.    '])
ExtraDuration = get(o,'ExtraDuration');
Events = [];
CurrentTime = IOGetTimeStamp(HW);

while CurrentTime < exptparams.LogDuration % BE removed +0.05 here (which screws up acquisition termination)
    % added by YB and CB 01/12/2016
    % send trig every second
    if (LightStateR == 0) && (mod(CurrentTime,1) < 0.005)
      [LightStateR, ev] = IOLightSwitch(HW,1,0,[],0,0,'LightR');
    elseif LightStateR == 1
      [LightStateR, ev] = IOLightSwitch(HW,0,0,[],0,0,'LightR');
    end
    
    ThisLick = IOLickRead(HW);
    Lick = ThisLick && ~LastLick;
    LastLick = ThisLick;
    if ~isempty(RefResponseWin) && CurrentTime>(RefResponseWin(end)-0.2)
        % this is to fix the problem of stopping in the begining of the target
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
%         if  ~(lightonfreq==0) 
%             IOLightSwitch(HW,0);
%         end
        EarlyPos = length(find(RefEarlyWin<CurrentTime)); % not used so far since early exists only for tar
    else % if we are in target part
        StimPos = length(find(TarResponseWin<CurrentTime));
        EarlyPos = length(find(TarEarlyWin<CurrentTime));
        LightPos = length(find(TarLightWin<CurrentTime));
        Ref = 0;
        
        %set light flashing during target; added by Ling Ma,04/2007.
        if (tarcnt==1) && ~(lightonfreq==0) && CurrentTime>TarLightWin(1) 
%            IOLightSwitch(HW,1,tardur,'start',lightonfreq);
           tarcnt = tarcnt+1;
        end
    end
    if StopFlag && (FalseAlarm>=StopTargetFA)
        % ineffective sound:
        ev = IOStopSound(HW);
        SoundStopped = 1;
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
    if (Lick) && Ref && mod(StimPos,2) && ~isequal(RefFlag,StimPos) %% for including licks in the ref early window:% & (Ref && mod(EarlyPos,2))
        % RefFlag: we want to add to the FalseAlarm only once for each
        % reference.
        % if she licks in reference response window, add to the false alarm
        % rate
        if strcmpi(get(o,'TurnOnLight'),'FalseAlarm')
            [ll,ev] = IOLightSwitch (HW, 1, .2);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
        if strcmpi(get(o,'Shock'),'FalseAlarm') && StimPos>length(StimIndex)-2 %apply only to last ref
            ev = IOControlShock (HW, .2, 'Start');
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
        
        RefFlag = StimPos;
        FalseAlarm = FalseAlarm + 1/NumRef;
    end
    if (Lick) && (~Ref && mod(EarlyPos,2))
        % if she licks in early window, terminate the trial immediately, and
        % give her timeout.
        ev = IOStopSound(HW); SoundStopped = 1;
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        TimeOutFlag = 1;
        break;
%         ThisTime = clock;
%         while etime(clock,ThisTime) < (get(o,'TimeOut')+exptparams.LogDuration-CurrentTime)
%             drawnow;
%         end
%         while(IOGetTimeStamp(HW)<exptparams.LogDuration), end;
%         break;
    end
    
    if ~LEDTurnedOn && strcmpi(get(o,'TurnOnLight'),'ResponseWindow') && mod(StimPos,2) && ~isequal(TarFlag,StimPos) % turn on LED when in RespWin
        [ll,ev] = IOLightSwitch (HW, 1, 0);%get(o,'ResponseWindow'));
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        LEDTurnedOn = 1;
    end
    
    if mod(StimPos,2) && ~Ref && (Lick || (AutomaticReward&&(CurrentTime>(TarResponseWin(1)+DelayAutomaticReward)))) && ...
            ~isequal(TarFlag,StimPos)
        % if she licks in target response window
        TimeOutFlag = 0;
        if StopTargetFA<1
            WaterFraction = 1-FalseAlarm;
        else
            WaterFraction = 1-FalseAlarm;
%             WaterFraction = 1;
        end
        PumpDuration = RewardAmount* WaterFraction/globalparams.PumpMlPerSec.Pump;
%         PumpDuration = get(o,'PumpDuration') * WaterFraction;
        if PumpDuration > 0
            ev = IOControlPump (HW,'start',PumpDuration);     
            if (AutomaticReward&&(CurrentTime>(TarResponseWin(1)+DelayAutomaticReward)))
                ev.Note = [ev.Note ',AUTOMATICREWARD'];
            end
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            exptparams.Water = exptparams.Water+RewardAmount* WaterFraction;
            if strcmpi(get(exptparams.BehaveObject,'RewardSound'),'Click') && PumpDuration
                ClickSend (PumpDuration/2);
            end
            if strcmpi(get(exptparams.BehaveObject,'TurnOnLight'),'Reward')
                tic;
                [ll,ev] = IOLightSwitch (HW, 1, 0);
                while toc<get(o,'PumpDuration')
                    pause(0.05)
                end
                [ll] = IOLightSwitch (HW, 0, 0);
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            end
            if ~isempty(RefResponseWin) 
              fprintf(['\t Lick on Target detected @ ',num2str(CurrentTime-RefResponseWin(end)),'s ... ']);
            else
              fprintf(['\t Lick on Target detected @ ',num2str(CurrentTime),'s ... ']);
            end
        end
        TarFlag = StimPos;
    end
    
    %CurrentTime = IOGetTimeStamp(HW);
    tmp = IOGetTimeStamp(HW);
    
    % leave it here in case something goes wrong
    if tmp > (CurrentTime+0.05)
      disp('***')
      disp('Problem with interval.')
      disp('***')
    end
    CurrentTime = tmp;
    
end

if ~SoundStopped
  evStopSound = IOStopSound(HW);
end
if LEDTurnedOn || ll
    [ll,evLED] = IOLightSwitch (HW, 0, 0);
end

% added by YB and CB 12/12/2016
if ExtraDuration~=0
  Events = AddEvent(Events, ev, TrialIndex);
  while CurrentTime < (exptparams.LogDuration+ExtraDuration)
    if (mod(CurrentTime,1) < 0.005) && ( (exptparams.LogDuration+ExtraDuration-3)>CurrentTime ) && (LightStateR == 0)
      [LightStateR, ev] = IOLightSwitch(HW,1,0,[],0,0,'LightR');
    elseif LightStateR == 1
      [LightStateR, ev] = IOLightSwitch(HW,0,0,[],0,0,'LightR');
    end
    CurrentTime = IOGetTimeStamp(HW);
  end
end

if LightStateR
    [LightStateR,evLED] = IOLightSwitch (HW, 0, 0,[],0,0,'LightR');
end

if TimeOutFlag>0
    ThisTime = clock;
    TimeOut = ifstr2num(get(o,'TimeOut'));
%     TimeOut = TimeOut * (1+2*FalseAlarm);  % 16/10-YB
    while etime(clock,ThisTime) < (TimeOut+exptparams.LogDuration+ExtraDuration-CurrentTime)
        drawnow;
    end
end