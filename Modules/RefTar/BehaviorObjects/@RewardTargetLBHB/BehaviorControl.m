function [LickEvents, exptparams] = BehaviorControl(o, HW, StimEvents, ...
    globalparams, exptparams, TrialIndex)
% Behavior Object for RewardTargetLBHB object
%
% SVD, July 2012, LBHB
% algorithm:
%   Define time windows for FA (reference window) and hits (target window)
%   monitor the lick,
%     if animal licks in response window or early window, terminate the
%     sound and stop the trial
%     if animal licks in the response window after target, give water
%     turn on light at appropriate phases
BehaviorParms=get(o);
NumRef = 0;
BehaviorParms.TrainingPumpDur=ifstr2num(BehaviorParms.TrainingPumpDur);

for cnt1 = 1:length(StimEvents);
    [Type, ~, StimRefOrTar] = ParseStimEvent(StimEvents(cnt1));
    if strcmpi(Type,'Stim')
        if strcmpi(StimRefOrTar,'Reference') && ~NumRef,
            NumRef=NumRef+1;
            RefEarlyWin=[StimEvents(cnt1).StartTime ...
                StimEvents(cnt1).StartTime + BehaviorParms.EarlyWindow];
            RefResponseWin = StimEvents(cnt1).StartTime + BehaviorParms.EarlyWindow;
        elseif strcmpi(StimRefOrTar,'Target'),
            TarResponseWin = [StimEvents(cnt1).StartTime + BehaviorParms.EarlyWindow ...
                StimEvents(cnt1).StartTime + BehaviorParms.ResponseWindow + BehaviorParms.EarlyWindow];
            TarEarlyWin = [StimEvents(cnt1).StartTime ...
                StimEvents(cnt1).StartTime + BehaviorParms.EarlyWindow];
            % force end of reference window to match begining of early
            % window.  no FAs allowed at all.
            RefResponseWin(2)=TarEarlyWin(1);
            TarOffTime=StimEvents(cnt1).StopTime;
        end
    end
end

disp('');
disp('------------------------------------------------------------------');
fprintf('  BehaviorControl --- starting trial %d (%d for this rep)\n',...
   exptparams.TotalTrials,exptparams.InRepTrials);
disp('------------------------------------------------------------------');
disp('');

RewardThisTrial=1;

TrialObject=exptparams.TrialObject;
TrialObjectParms=get(TrialObject);

if strcmp(TrialObjectParms.descriptor,'MultiRefTar'),
  TargetIndices = get(TrialObject,'TargetIndices');
  ThisTargetIdx = TargetIndices{exptparams.InRepTrials};
  TargetIdxFreq = get(TrialObject,'TargetIdxFreq');
  TargetMaxIndex = get(TrialObject,'TargetMaxIndex');
  
  if isempty(TargetIdxFreq),
    TargetIdxFreq=1;
  elseif length(TargetIdxFreq)>TargetMaxIndex,
    TargetIdxFreq=TargetIdxFreq(1:TargetMaxIndex);
  end
  if sum(TargetIdxFreq)==0,
    TargetIdxFreq(:)=1;
  end
  TargetIdxFreq=TargetIdxFreq./sum(TargetIdxFreq);
  if TargetIdxFreq(ThisTargetIdx)<BehaviorParms.RewardTargetMinFrequency,
    RewardThisTrial=0;
    disp('Rare target: Not rewarding this trial');
  end
end

CommonTarget=1;
if isfield(HW.AO,'NumChannels'),
   AOChannels=HW.AO.NumChannels;
   if AOChannels>1,
      ChannelNames=strsep(HW.AO.Names,',',1);
      AOChannelOrder=zeros(AOChannels,1);
      for ii=1:AOChannels,
         tc=find(strcmp(['SoundOut',num2str(ii)],ChannelNames));
         if ~isempty(tc),
            AOChannelOrder(ii)=tc;
         else
            AOChannelOrder(ii)=ii;
         end
      end
      if isfield(TrialObjectParms,'TargetIdxFreq') && isfield(TrialObjectParms,'TargetChannel'),
         CommonTarget=find(TrialObjectParms.TargetIdxFreq==max(TrialObjectParms.TargetIdxFreq),1);
         if CommonTarget>length(TrialObjectParms.TargetChannel),
            CommonTarget=AOChannelOrder(1);
         else
            CommonTarget=AOChannelOrder(TrialObjectParms.TargetChannel(CommonTarget));
         end
      else
         CommonTarget=1;
      end
   end
end

% turn on trial-length lights
if strcmpi(BehaviorParms.Light1,'OnTarget1Blocks') && CommonTarget==1,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light');
elseif strcmpi(BehaviorParms.Light2,'OnTarget1Blocks') && CommonTarget==1,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light2');
elseif strcmpi(BehaviorParms.Light3,'OnTarget1Blocks') && CommonTarget==1,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light3');
elseif strcmpi(BehaviorParms.Light1,'OnTarget2Blocks') && CommonTarget==2,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light');
elseif strcmpi(BehaviorParms.Light2,'OnTarget2Blocks') && CommonTarget==2,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light2');
elseif strcmpi(BehaviorParms.Light3,'OnTarget2Blocks') && CommonTarget==2,
    IOLightSwitch(HW, 1, 0,'Start',0,0,'Light3');
end


% save parameters for PerformanceAnalysis:
exptparams.RefResponseWin  = RefResponseWin;
exptparams.RefEarlyWin  = RefEarlyWin;
exptparams.TarResponseWin = TarResponseWin;
exptparams.TarEarlyWin = TarEarlyWin;
exptparams.NumRef=NumRef;

RefFlag=[];
TarFlag=[];
FalseAlarm = 0;
StopTargetFA = BehaviorParms.StopTargetFA;
LickEvents = [];
if ~isfield(exptparams,'Water'), exptparams.Water = 0; end
% we monitor the lick until the end plus response time and postargetlick
LastLick = 0;
HitThisTrial=0;
FAThisTrial=0;
if BehaviorParms.TrainingPumpDur>0,
  TrainingRewardGiven=0;
else
  TrainingRewardGiven=1;
end

CurrentTime = IOGetTimeStamp(HW);
if strcmpi(get(o,'StopStim'),'Immediately'),
   StopFlag = 1;
else
   StopFlag=0;
end
fprintf('Target window: %.1f-%.1f sec\n',TarResponseWin(1:2));
while CurrentTime < exptparams.LogDuration  % while trial is not over
    ThisLick = IOLickRead(HW);  
    Lick = ThisLick & ~LastLick;
    if Lick,
        ev=[];
        ev.Note='LICK';
        ev.StartTime=IOGetTimeStamp(HW);
        ev.StopTime=ev.StartTime;
        LickEvents=AddEvent(LickEvents,ev,TrialIndex);
        fprintf('Lick %.1f sec\n',CurrentTime);
    end
    LastLick = ThisLick;
    
    % find out if we are in the reference or target part
    if ~isempty(RefResponseWin) && CurrentTime<RefResponseWin(end)   
        StimPos = length(find(RefResponseWin<CurrentTime)); 
        % stim pos tells us whether we
        % are "IN" the windows calculated above or outside of it
        Ref = 1;  % we are in reference part of the sound
        
    else % if we are in target part
        StimPos = length(find(TarResponseWin<CurrentTime));
        EarlyPos = length(find(TarEarlyWin<CurrentTime));
        Ref = 0;
    end
    
    % CHECK FOR FALSE ALARM - Any lick before target window
    if Lick && (Ref || mod(EarlyPos,2))
        FalseAlarm=1;
        ev=[];
        ev.Note='OUTCOME,FALSEALARM';
        ev.StartTime=IOGetTimeStamp(HW);
        ev.StopTime=ev.StartTime;
        LickEvents=AddEvent(LickEvents,ev,TrialIndex);
        if strcmpi(get(o,'TurnOnLight'),'FalseAlarm')
            [~,ev] = IOLightSwitch (HW, 1, .2);
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
        if strcmpi(get(o,'TurnOffLight'),'FalseAlarm'),
           ev = IOLightSwitch(HW,1,ifstr2num(get(o,'TimeOut')),'Start',0,0,'Light2');
        end
        if strcmpi(get(o,'Shock'),'FalseAlarm')
            ev = IOControlShock (HW, .2, 'Start');
            LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        end
        disp('Stopping sound');
        ev = IOStopSound(HW);
        LickEvents = AddEvent(LickEvents, ev, TrialIndex);
        FAThisTrial=1;
        break;
    end

    % CHECK FOR HIT - Lick in target response window
    if (Lick) && mod(StimPos,2) && ~isequal(TarFlag,StimPos) && ~Ref && RewardThisTrial,
       HitThisTrial = 1;
       if RewardThisTrial, 
          disp('Hit -- Starting pump.');
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
             if strcmpi(get(exptparams.BehaveObject,'TurnOnLight'),'Reward')
                [~,ev] = IOLightSwitch (HW, 1, get(o,'PumpDuration'),'Start',0,0);
                LickEvents = AddEvent(LickEvents, ev, TrialIndex);
             end
          end
          TarFlag = StimPos;
       end
       
       % DON'T BREAK YET. WAIT FOR TARGET TO STOP PLAYING. -- NOW WAIT FOR
       % ALL SOUNDS TO STOP PLAYING.
    end
    
    % IF HIT AND SOUND IS COMPLETE, QUIT THIS LOOP
    % disabled SVD 2013-05-14.  Want to play complete sound for recording
    %if ~isempty(TarFlag) && CurrentTime>TarOffTime(end),
    %  disp('Target done, stopping sound');
    %  break;
    %end
    
    % FIXED REWARD FOR TRAINING
    if BehaviorParms.TrainingPumpDur>0 && ~TrainingRewardGiven && ...
        CurrentTime>mean(TarResponseWin(1:2)),
      disp('Giving training auto-reward in middle of target response window');
      PumpDuration = BehaviorParms.TrainingPumpDur;
      ev = IOControlPump(HW,'start',PumpDuration);
      TrainingRewardGiven=1;
    end
    
    CurrentTime = IOGetTimeStamp(HW);
end
IOStopSound(HW);

if FAThisTrial,
  PauseTime = ifstr2num(get(o,'TimeOut'));
  fprintf('FA -- time out %.1f sec\n',PauseTime);

elseif HitThisTrial && RewardThisTrial,
  PauseTime = ifstr2num(get(o,'CorrectITI'));
  fprintf('Hit -- pausing %.1f sec\n',PauseTime);
  
elseif HitThisTrial && ~RewardThisTrial,
  PauseTime = ifstr2num(get(o,'CorrectITI'));
  fprintf('Hit -- not rewarded -- pausing %.1f sec\n',PauseTime);
  
elseif RewardThisTrial,
  % TRUE MISS
  PauseTime = ifstr2num(get(o,'TimeOut'));
  ev=[];
  ev.Note='OUTCOME,MISS';
  ev.StartTime=IOGetTimeStamp(HW);
  ev.StopTime=ev.StartTime;
  LickEvents=AddEvent(LickEvents,ev,TrialIndex);
  fprintf('Miss -- time out %.1f sec\n',PauseTime);
  
else
  PauseTime = ifstr2num(get(o,'CorrectITI'));
  fprintf('Correct reject -- pausing %.1f sec\n',PauseTime);
end

% if ~HitThisTrial && RewardThisTrial,
%   PauseTime = ifstr2num(get(o,'TimeOut'));
%   if ~FAThisTrial, % not a hit or FA so must be a MISS
%     ev=[];
%     ev.Note='OUTCOME,MISS';
%     ev.StartTime=IOGetTimeStamp(HW);
%     ev.StopTime=ev.StartTime;
%     LickEvents=AddEvent(LickEvents,ev,TrialIndex);
%     fprintf('Miss -- time out %.1f sec\n',PauseTime);
%   else
%   end
%   %TimeOut = TimeOut * (1+2*FalseAlarm);
% else
%   PauseTime = ifstr2num(get(o,'CorrectITI'));
%   fprintf('Hit / successful no response  -- pausing %.1f sec\n',PauseTime);
% end

if strcmpi(BehaviorParms.ITICarryOverToPreTrial,'No'),
    ThisTime = clock;
    while etime(clock,ThisTime) < PauseTime,
        drawnow;
    end
    exptparams.NeutralPreTrialDelay=0;
else
    exptparams.NeutralPreTrialDelay=PauseTime;
end

%disp('Block lights off?');
if strcmpi(BehaviorParms.Light1,'OnTarget1Blocks') || strcmpi(BehaviorParms.Light1,'OnTarget2Blocks'),
    [~,ev] = IOLightSwitch(HW, 0, 0,'Stop',0,0,'Light');
end
if strcmpi(BehaviorParms.Light2,'OnTarget1Blocks') || strcmpi(BehaviorParms.Light2,'OnTarget2Blocks'),
    [~,ev] = IOLightSwitch(HW, 0, 0,'Stop',0,0,'Light2');
end
if strcmpi(BehaviorParms.Light3,'OnTarget1Blocks') || strcmpi(BehaviorParms.Light3,'OnTarget2Blocks'),
    [~,ev] = IOLightSwitch(HW, 0, 0,'Stop',0,0,'Light3');
end
