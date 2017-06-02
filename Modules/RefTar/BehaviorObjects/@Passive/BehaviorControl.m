function [Events, exptparams] = BehaviorControl (o, HW, StimEvents, globalparams, exptparams, TrialIndex);
CurrentTime = IOGetTimeStamp(HW);
[LightState, ev] = IOLightSwitch(HW,1,0.0,[],0,0,'LightR');

Events = [];
if get(o,'RandomReward')
  RewardOccured = 1;
  LastReportTiming = CurrentTime;
  RewardAmount = get(o,'RewardAmount');
  RewardInterval = get(o,'RewardInterval');
  RewardIntervalStd = get(o,'RewardIntervalStd');
  RewardIntervalLaw = get(o,'RewardIntervalLaw');
  exptparams.WaterUnits = 'milliliter';
end
if ~isnumeric(get(o,'ExtraDuration'))
  ExtraDuration = str2num(get(o,'ExtraDuration'));
else
  ExtraDuration = get(o,'ExtraDuration');
end

while CurrentTime < (exptparams.LogDuration) % BE removed +0.05 here (which screws up acquisition termination)
  % added by YB and CB 01/12/2016
  % send trig every second 
   if (mod(CurrentTime,1) < 0.005) && (LightState == 0)
     [LightState, ev] = IOLightSwitch(HW,1,0.0,[],0,0,'LightR');
   elseif LightState == 1
     [LightState, ev] = IOLightSwitch(HW,0,0.0,[],0,0,'LightR');
   end
   

	if ~get(o,'CalibrationPupil')
	  LickEvents = [];
	end

   if get(o,'RandomReward')
     if RewardOccured
       % Calculate next reward timing
       switch RewardIntervalLaw
         case 'Uniform'
           LawRange = sqrt(12)*RewardIntervalStd; % variance for uniform law
           RewardInterval = max(1,(RewardInterval-LawRange/2) + rand(1,1)*LawRange);
         otherwise
           disp('Lick probability law not yet implemented')
       end
       NextRewardTiming = CurrentTime+RewardInterval;
       RewardOccured = 0;
     end
     if (LastReportTiming+5)<CurrentTime
       fprintf([num2str(CurrentTime) 's ... ']);
       LastReportTiming = CurrentTime;
     end
     
     % Deliver reward
     if NextRewardTiming<CurrentTime
       PumpDuration = RewardAmount/globalparams.PumpMlPerSec.Pump;
       if PumpDuration > 0
         ev = IOControlPump (HW,'start',PumpDuration);
         Events = AddEvent(Events, ev, TrialIndex);
         exptparams.Water = exptparams.Water+RewardAmount;
         %     if strcmpi(get(exptparams.BehaveObject,'RewardSound'),'Click') && PumpDuration
         %       ClickSend (PumpDuration/2);
         %     end
         fprintf(['R @ ',num2str(CurrentTime),'s [interval=' num2str(RewardInterval) 's] ... ']);
         RewardOccured = 1;
       end
     end
   end

   tmp = IOGetTimeStamp(HW);

   % leave it here in case something goes wrong
   if tmp > (CurrentTime+0.1)
     disp('***')
     disp('Problem with trig interval.')
     disp('***')
   end
   CurrentTime = tmp;
end

% added by YB and CB 12/12/2016
if ExtraDuration~=0
  ev = IOStopSound(HW);
  Events = AddEvent(Events, ev, TrialIndex);
  while CurrentTime < (exptparams.LogDuration+ExtraDuration)
    if (mod(CurrentTime,1) < 0.005) && ( (exptparams.LogDuration+ExtraDuration-3)>CurrentTime ) && (LightState == 0)
      [LightState, ev] = IOLightSwitch(HW,1,0.0,[],0,0,'LightR');
    elseif LightState == 1
      [LightState, ev] = IOLightSwitch(HW,0,0.0,[],0,0,'LightR');
    end
    CurrentTime = IOGetTimeStamp(HW);
  end
end
if ~get(o,'CalibrationPupil')
  LickEvents = [];
end
