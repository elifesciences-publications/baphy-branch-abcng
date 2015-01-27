function StopExperiment = CanStart (O, HW, StimEvents, globalparams, exptparams, TrialIndex)
% CanStart for RewardTargetMC
% 
% First, alert the animal at the central spout
% Second, wait until no licking at either spout
% 
% BE 2010/7

global StopExperiment;

PauseDuration = get(O,'InterTrialInterval');
pause(PauseDuration*(1+rand)); % WAIT FOR SOME TIME BETWEEN TRIALS

% ATTRACT THE ANIMAL ATTENTION ON THE FIRST TRIAL AT CENTRAL SPOUT
if TrialIndex==1
  PrewardAmount = 2*get(O,'PrewardAmount');
  PrewardPumps = {'Pump'};
  if PrewardAmount > 0
    for i=1:length(PrewardPumps)
      cPumpDurations(i) = PrewardAmount/globalparams.PumpMlPerSec.(PrewardPumps{i});
      IOControlPump(HW,'start',cPumpDurations(i),PrewardPumps{i});
    end
  end
end

NoResponseTime = get(O,'NoResponseTime'); LastTime = clock; 
disp(['Waiting for stable center position [ ',n2s(NoResponseTime),'s ] ']);

% PROVIDE CENTER REWARD ON EVERY TRIAL FOR CENTERING
if get(O,'CenteringRewardDelay')==0
  CenterRewardAmount = get(O,'CenterRewardAmount');
  if CenterRewardAmount
    cPumpDuration = CenterRewardAmount/globalparams.PumpMlPerSec.Pump;
    IOControlPump(HW,'start',cPumpDuration,'Pump');
    exptparams.Water = exptparams.Water+CenterRewardAmount;
  end
end

if ~get(O,'Simulick')
  % WAIT UNTIL CENTERED FOR LONG ENOUGH
  % Old syntax
%   SensorNames = HW.DIO.Line.LineName;
%   SensorChannels=find(~cellfun(@isempty,strfind(SensorNames,'Light')));
  
  SensorNames = {HW.Didx.Name};
  SensorChannels = find(strcmp(SensorNames,'Light'));

  LeftChannel=find(strcmp(SensorNames,'TouchL'));
  RightChannel=find(strcmp(SensorNames,'TouchR'));
  %CenterChannel=find(strcmp(SensorNames,'Touch'));
  while etime(clock,LastTime) < NoResponseTime && ~StopExperiment
    % RESET TIMER IF LICK AT ANY SENSOR
    cVals = IOLickRead(HW,SensorChannels);
    %if cVals(SensorChannels == LeftChannel) || cVals(SensorChannels == RightChannel) || ~cVals(SensorChannels == CenterChannel)
%     if cVals(SensorChannels == LeftChannel) || cVals(SensorChannels ==  RightChannel)  % Bernhard's version
    if ~cVals
      LastTime = clock;
    end
    pause(0.05);
    drawnow;
  end
   
  % Taken from @RewardTargetCont
  while etime(clock,LastTime)<NoResponseTime && ~StopExperiment
    if IOLickRead(HW)
      % if she licks, reset the timer
      LastTime = clock;
    end
    drawnow;
  end
  
end