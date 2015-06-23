function StopExperiment = CanStart (O, HW, StimEvents, globalparams, exptparams, TrialIndex)
% CanStart for RewardTargetMC
% 
% First, alert the animal at the central spout
% Second, wait until no licking at either spout
% 
% BE 2013/10

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
disp(['Waiting for no Lick [ ',n2s(NoResponseTime),'s ] ']);

% WAIT UNTIL NO LICK FOR A CERTAIN TIME
if ~get(O,'Simulick')
  
  while etime(clock,LastTime)<NoResponseTime && ~StopExperiment
    if IOLickRead(HW)
      % if she licks, reset the timer
      LastTime = clock;
    end
    drawnow;
  end
    
%   SensorNames = {HW.DIO.Names};
%   SensorChannels=find(~cellfun(@isempty,strfind(SensorNames,'Touch')));
%   CenterChannel=find(strcmp(SensorNames,'Touch'));
%   while etime(clock,LastTime) < NoResponseTime && ~StopExperiment
%     etime(clock,LastTime)
%     % RESET TIMER IF LICK AT ANY SENSOR
%     cVals = IOLickRead(HW,SensorChannels);
%     if cVals(SensorChannels == CenterChannel)  LastTime = clock; end
%     pause(0.05);
%     drawnow;
%   end
end
