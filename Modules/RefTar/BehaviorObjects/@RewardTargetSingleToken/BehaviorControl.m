function [LickEvents, exptparams] = BehaviorControl(o, HW, StimEvents, ...
    globalparams, exptparams, TrialIndex)

RefResponseWin = [];
TarResponseWin = [];
TarEarlyWin    = [];
RefEarlyWin    = [];
RefLightWin = [];
TarLightWin = [];
RefFlag=[];
TarFlag=[];
FalseAlarm = 0;
LEDTurnedOn = 0; ll = 0;
StopTargetFA = get(o,'StopTargetFA');
RewardAmount = get(o,'RewardAmount');
EarlyWindow = get(o,'EarlyWindow');
MinEarlyWindow = EarlyWindow(1);
if length(EarlyWindow)>1  % variable random delay
    EarlyWindow = EarlyWindow(randi(length(EarlyWindow),1));
    TrialLongerThanSound = 1;
    IniLogDuration = exptparams.LogDuration;
    exptparams.EarlyWindowLst(TrialIndex) = EarlyWindow;
else
    TrialLongerThanSound = 0;
end
exptparams.EarlyWindow = EarlyWindow;
LogDurationExtra = EarlyWindow - MinEarlyWindow;
exptparams.LogDuration = exptparams.LogDuration+LogDurationExtra;
% if strcmpi(class(RH),'TorcToneDiscrim')
%   % for this paradigm (ONLY WITH MAXREF=1), EarLyWindow specifies when
%   %within the Tone the EarlyWindow stops
%   EarlyWindow = EarlyWindow + get(StimEvents(end-2).StartTime);
% end
AutomaticReward = get(o,'AutomaticReward');
RH = get(exptparams.TrialObject,'ReferenceHandle'); TH = get(exptparams.TrialObject,'TargetHandle');
LickEvents = [];
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
  if strcmpi(Type,'Stim')
    
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
        RefLightWin = [RefLightWin StimEvents(cnt1).StartTime StimEvents(cnt1).StartTime+tardur];
        RefEarlyWin = [RefEarlyWin StimEvents(cnt1).StartTime ...
          StimEvents(cnt1).StartTime + EarlyWindow];
      end
    elseif strcmpi(StimRefOrTar,'Target')
      if ~strcmpi(class(TH),'TorcToneDiscrim') || ( strcmpi(class(TH),'TorcToneDiscrim') && isempty(strfind(upper(StimName),'TORC')) )
        TarResponseWin = [TarResponseWin StimEvents(cnt1).StartTime + EarlyWindow ...
          StimEvents(cnt1).StartTime + EarlyWindow + get(o,'ResponseWindow')];
        TarEarlyWin = [TarEarlyWin StimEvents(cnt1).StartTime ...
          StimEvents(cnt1).StartTime + EarlyWindow];
      end
    end
    
  end
end

[LightStateR, ev] = IOLightSwitch(HW,1,0,[],0,0,'LightR');
% we monitor the lick until the end plus response time and postargetlick
LastLick = 0;
TimeOutFlag=0;
tarcnt = 1;
refcnt = 1;
fprintf(['\nRunning Trial [ <=',n2s(exptparams.LogDuration),'s -- ' num2str(~strcmpi(StimRefOrTar,'Reference')) 'tar] ... ']);
fprintf(['LogDuration = ' num2str(exptparams.LogDuration) 's.    '])
ExtraDuration = get(o,'ExtraDuration');
Events = [];
CurrentTime = IOGetTimeStamp(HW);

while CurrentTime < exptparams.LogDuration % BE removed +0.05 here (which screws up acquisition termination)
    if TrialLongerThanSound == 1 & CurrentTime > IniLogDuration & SoundStopped==0
        ev = IOStopSound(HW); SoundStopped = 1;
        TrialLongerThanSound = 0;
    end
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
    
    if ~isempty(RefResponseWin) && CurrentTime<RefResponseWin(end)   % find out if we are in the reference or target part
        StimPos = length(find(RefResponseWin<CurrentTime)); % stim pos tells us whether we
        % are "IN" the windows calculated above or outside of it
        Ref = 1;  % we are in reference part of the sound
        EarlyPos = length(find(RefEarlyWin<CurrentTime)); % not used so far since early exists only for tar
    else % if we are in target part
        StimPos = length(find(TarResponseWin<CurrentTime));
        EarlyPos = length(find(TarEarlyWin<CurrentTime));
        Ref = 0;        
    end
    if StopFlag && (FalseAlarm>=StopTargetFA)
        % ineffective sound:
        if ~SoundStopped
            ev = IOStopSound(HW);
            SoundStopped = 1;
        end
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        ThisTime = clock;
        TimeOutFlag=1;
        break;
    end
    if (Lick) && Ref && mod(StimPos,2) && ~isequal(RefFlag,StimPos) %% for including licks in the ref early window:% & (Ref && mod(EarlyPos,2))
        % RefFlag: we want to add to the FalseAlarm only once for each reference.
        % If she licks in reference response window, add to the false alarm rate.        
        RefFlag = StimPos;
        FalseAlarm = 1;
    end
    if (Lick) && (~Ref && mod(EarlyPos,2))
        % if she licks in early window, terminate the trial immediately, and
        % give her timeout.
        if ~SoundStopped
            ev = IOStopSound(HW); SoundStopped = 1;
        end
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        TimeOutFlag = 1;
        break;
    end
    
    if ~LEDTurnedOn && strcmpi(get(o,'TurnOnLight'),'ResponseWindow') && mod(StimPos,2) && ~isequal(TarFlag,StimPos) % turn on LED when in RespWin
        [ll,ev] = IOLightSwitch (HW, 1, 0);%get(o,'ResponseWindow'));
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        LEDTurnedOn = 1;
    end
    
    if (Lick || AutomaticReward) && mod(StimPos,2) && ~isequal(TarFlag,StimPos) && ~Ref
        % if she licks in target response window
        TimeOutFlag = 0;
        if StopTargetFA<1
            WaterFraction = 1-FalseAlarm;
        else
            WaterFraction = 1-FalseAlarm;
%          WaterFraction = 1;
        end
        PumpDuration = RewardAmount* WaterFraction/globalparams.PumpMlPerSec.Pump;
%         PumpDuration = get(o,'PumpDuration') * WaterFraction;
        if PumpDuration > 0
            ev = IOControlPump (HW,'start',PumpDuration);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
            exptparams.Water = exptparams.Water+RewardAmount* WaterFraction;
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
    if tmp > (CurrentTime+0.030)
      disp('***')
      disp('Problem with trig interval.')
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