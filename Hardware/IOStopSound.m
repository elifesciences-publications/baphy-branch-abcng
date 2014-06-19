function ev = IOStopSound (HW);
% function timestamp = IOStopSound (HW)
%
% Stop playing the sound (HW.AO)
% HW - handle of HW card. 
%
% Nima's checklist:
% Tested in test mode
% tested in training rig (2)
%
% Nima, november 2005
% SVD update 2012-05-31 : added Nidaqmx support

if strcmpi(IODriver(HW),'NIDAQMX'),
  if HW.params.HWSetup==0,
      disp('stopping Test mode sound');
      stop(HW.AO);                % stop interfaces
  else
    % Configure Triggers
    aoidx=find(strcmp({HW.Didx.Name},'TrigAO'));
    TriggerDIO=HW.Didx(aoidx).Task;
    AOTriggerChan=HW.Didx(aoidx).Line;
    vstop=niGetValue(HW.DIO(TriggerDIO));
    vstop([AOTriggerChan])=HW.DIO(TriggerDIO).InitState([AOTriggerChan]);
    
    % make sure not triggering
    niPutValue(HW.DIO(TriggerDIO),vstop);
    disp('stopping AO');
    niStop(HW.AO);
    % play brief silence to force output voltage to zero and avoid click for next sound 
    IOStartSound(HW,zeros(6,1));
    niStop(HW.AO);
  end
  if nargout>0,
    ev.Note='STIM,OFF';
    ev.StartTime=IOGetTimeStamp(HW);
    ev.StopTime=[];
  end
  return;
end

switch HW.params.HWSetup
    case {0}
        stop(HW.AO);                % stop interfaces
        ev.Note='STIM,OFF';
        ev.StartTime=IOGetTimeStamp(HW);
        ev.StopTime=[];
    otherwise
        stop(HW.AO);
        % play brief silence to force output voltage to zero and avoid click for next sound 
        % set buffer to match tiny size of stimulus. otherwise matlab will complain
        set(HW.AO, 'BufferingConfig',[4 2]);
        ev=IOStartSound(HW,zeros(6,1));
        
        ev.Note='STIM,OFF';
        ev.StopTime=ev.StartTime;
        pause(0.01);
        
        % set buffer back to auto-sizing
        stop(HW.AO);
        set(HW.AO, 'BufferingMode','Auto');
end

