function [ev,HW] = IOStartSound(HW,stim);
% function [ev,HW] = IOStartSound(HW,stim);
% 
% This function starts the sound that has been loaded using IOLoadSound.m
% The function works for both trigger types and all rigs.
% HW: Hardware handle
%
% events: 
%
% Nima's checklist:
% tested in test mode
% tested in 2)training setup. 11/19/2005
%
% Nima, Nov 2005
% 
% SVD update 2012-05-30 : added Nidaqmx support.  Still need to fix
% TimeStamp to work accurately!

if exist('stim','var')  HW=IOLoadSound(HW,stim); end

if strcmpi(IODriver(HW),'NIDAQMX'),
    if HW.params.HWSetup==0,
        %play(HW.AO);
        if nargout>0,
            ev.Note='STIM,ON';
            ev.StartTime=IOGetTimeStamp(HW);
            if exist('stim','var'),
                ev.StopTime=ev.StartTime+length(stim)./HW.params.fsAO;
            else
                ev.StopTime=[];
            end
        end
        %while strcmp(HW.AO.Running,'on'); end
    
  else
    
    % Configure Triggers
    aoidx=find(strcmp({HW.Didx.Name},'TrigAO'));
    TriggerDIO=HW.Didx(aoidx).Task;
    AOTriggerChan=HW.Didx(aoidx).Line;
    v=niGetValue(HW.DIO(TriggerDIO));
    v([AOTriggerChan])=1-HW.DIO(TriggerDIO).InitState([AOTriggerChan]);
    
    % task has been started automatically by load sound
    % trigger
    niPutValue(HW.DIO(TriggerDIO),v);
    
    if nargout>0,
      % hack to generate event.  Need to figure out if possible to get more
      % exact time
      ev.Note='STIM,ON';
      ev.StartTime=IOGetTimeStamp(HW);
      if exist('stim','var'),
        ev.StopTime=ev.StartTime+length(stim)./HW.params.fsAO;
      else
        ev.StopTime=[];
      end
    end
  end
  return;
end


switch HW.params.HWSetup
  case {0} ,  % ie, TEST MODE
    play(HW.AO);
    
    ev.Note='STIM,ON';
    ev.StartTime=IOGetTimeStamp(HW);
    if exist('stim','var'),
      ev.StopTime=ev.StartTime+length(stim)./HW.params.fsAO;
    else
      ev.StopTime=[];
    end
    %while strcmp(HW.AO.Running,'on'); end
    
  otherwise % REAL SETUPS
    %% GET TRIGGERLINE OF ANALOG OUTPUT
    TrigIndexAO=find(strcmp(HW.DIO.Line.LineName,'TrigAO'));
    if isempty(TrigIndexAO) error('TrigAO digital output channel not defined.'); end
    
    %% WAIT UNTIL OUTPUT IS FINISHED
    if IOIsPlaying(HW),
      warning('AO is still running. Wait at IOStartSound.m'); while IOIsPlaying(HW); end
    end
    
    %% START ANALOG OUTPUT
    set(HW.AO,'TimerFcn',[]);
    start(HW.AO); 
    
    %% SEND TRIGGER
    TrigValAO = IOGetTriggerValue(HW.AO,'TRIGGER');
    putvalue(HW.DIO.Line(TrigIndexAO),TrigValAO);
    
    %% NOTE EXACT TIMING OF SOUND VS TRIAL
    e=get(HW.AO,'EventLog');
    time1=e(end).Data.AbsTime;
    
    e=get(HW.AI,'EventLog');
    if length(e)>2,
      time0=e(2).Data.AbsTime;
    elseif length(e)>0,
      time0=e(end).Data.AbsTime;
    else
      time0=time1;
    end
    
    ev.Note='STIM,ON';
    ev.StartTime=etime(time1,time0);
    if exist('stim','var'),
      ev.StopTime=ev.StartTime+length(stim)./HW.params.fsAO;
    else
      ev.StopTime=[];
    end
end


