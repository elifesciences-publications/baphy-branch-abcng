function BehaviorEvents = CanStart(o, HW, StimEvents, globalparams, exptparams, TrialIndex)

BehaviorEvents=1;

TrialStartSec=get(o,'PreBlockSilence')+get(o,'TR').*(TrialIndex-1);
PrevTrialStartSec=get(o,'PreBlockSilence')+get(o,'TR').*(TrialIndex-2);
fprintf('Waiting until %d sec to start trial %d ',TrialStartSec,TrialIndex);
while BehaviorEvents,
   SecSinceStart=etime(clock,exptparams.StartTime);
   if SecSinceStart>PrevTrialStartSec,
      fprintf('.');
      PrevTrialStartSec=PrevTrialStartSec+1;
   end
   
   if etime(clock,exptparams.StartTime)>=TrialStartSec,
      BehaviorEvents=0;
   end
   pause(0.01);
end

fprintf(' starting stimulus...\n');
BehaviorEvents=0;