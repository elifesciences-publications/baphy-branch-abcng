function BehaviorEvents = CanStart(o, HW, StimEvents, globalparams, exptparams, TrialIndex)

BehaviorEvents=1;

par=get(o);
if par.DelayAfterScanTTL>0,
    %HW=IOMicTTLStart(HW);
    %start(HW.AI);  % taken care of in IOStartAcquisition now?
    if TrialIndex==1
        TTLrequired=par.InitTTLCount;
    else
        TTLrequired=1;
    end
    
    fprintf('Waiting for %d scan TTLs...\n',TTLrequired);
    lastTTL=par.ScanTTLValue;
    TTLCount=par.TTLCount;
    while TTLCount<TTLrequired,
        pause(0.1);
        TTL=IOMicTTL(HW);
        if TTL~=lastTTL,
            if TTL==1,
                TTLCount=TTLCount+1;
                fprintf('TTLCount=%d\n',TTLCount);
            end
            lastTTL=TTL;
        end
    end
    
    set(o,'TTLCount',TTLCount);

    StartTime=clock();
    fprintf('Now waiting %d sec after TTL\n',par.DelayAfterScanTTL);
    while BehaviorEvents,
       if etime(clock,StartTime)>=par.DelayAfterScanTTL,
          BehaviorEvents=0;
       end
       pause(0.01);
    end
    
else
    if isempty(par.TR),
        par.TR=10;
    end
    if isempty(par.PreBlockSilence),
        par.PreBlockSilence=34;
    end
    par.TR=10;
    par.PreBlockSec=24;
    par
    TrialStartSec=par.PreBlockSilence+par.TR.*(TrialIndex-1);
    PrevTrialStartSec=par.PreBlockSilence+par.TR.*(TrialIndex-2);
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
end

fprintf(' starting stimulus...\n');
BehaviorEvents=0;