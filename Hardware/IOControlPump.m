function varargout = IOControlPump (HW,PumpAction,Duration,PumpName)
% function ev = IOControlPump (HW,PumpAction,Duration,PumpName)
% 
% This function runs the pump for the period specified in Duration.
% The function creates a Timer object that runs for Duration and then calls
% the same function for 'Stop' action.
% PumpAction can be 'Start' or 'Stop'
% it also returns the time stamp from begining of the trial which is gotten from
% from toc now, but might changed in future
%
% Nima, November 2005
% SVD, 2005-11-20 - generic recording setup support
% BE, 2010/7 multiple spout support
% SVD update 2012-05-31 : added Nidaqmx support

if ~exist('Duration','var') Duration = 0; end
if ~exist('PumpName','var') PumpName = 'Pump'; end 

Duration = round(Duration*1000)/1000; % TO AVOID A WARNING MESSAGE ABOUT MS PRECISION

switch HW.params.HWSetup
  case 0  % Test mode, no pump
    global PUMPSTATE0
    tic;
    ev.StartTime=IOGetTimeStamp(HW);
    switch lower(PumpAction)
      case 'start';
        ev = struct('Note',['BEHAVIOR,PUMPON,',PumpName],'StartTime',IOGetTimeStamp(HW));
        ev.StopTime=ev.StartTime+Duration;
        PUMPSTATE0=1;
      case 'stop'
        ev = struct('Note','BEHAVIOR,PUMPOFF','StartTime',IOGetTimeStamp(HW),'StopTime',[]);
        PUMPSTATE0=0;
      otherwise error('PumpAction not implemented!');        
    end
    
  otherwise % Real Setups
    if strcmpi(IODriver(HW),'NIDAQMX'),
      pumpidx=find(strcmp(PumpName,{HW.Didx.Name}));
      if ~isempty(pumpidx),
        taskidx=HW.Didx(pumpidx).Task;
        lineidx=HW.Didx(pumpidx).Line;
        v=niGetValue(HW.DIO(taskidx));
      end
    else
      pumpidx=min(find(strcmpi(HW.DIO.Line.LineName,PumpName)));
    end
    
    if isempty(pumpidx),
      timestamp = IOGetTimeStamp(HW);
      warning('Pump digital output channel ''',PumpName,''' not defined.');
      return;
    end
    
    switch lower(PumpAction)
      case 'start';
        ev = struct('Note',['BEHAVIOR,PUMPON,',PumpName],'StartTime',IOGetTimeStamp(HW));
        if strcmpi(IODriver(HW),'NIDAQMX'),
          v(lineidx)=1;
          niPutValue(HW.DIO(taskidx),v);
        else
          putvalue(HW.DIO.Line(pumpidx), 1);
        end
        
        % set the timer ONLY if Duration is greater than 0
        if Duration>0
          t = timer('TimerFcn',@(Handle,Event)IOControlPump(HW,'Stop',[],PumpName),'StartDelay',Duration);
          start(t);
        end
        ev.StopTime = ev.StartTime+Duration;
        fprintf('[ %s on for %.2fs ]\n',PumpName,Duration);
      case {'stop',0};
        if strcmpi(IODriver(HW),'NIDAQMX'),
          v(lineidx)=0;
          niPutValue(HW.DIO(taskidx),v);
          ev = struct('Note',['BEHAVIOR,PUMPOFF,',PumpName],'StartTime',0,'StopTime',[]);
       else
          putvalue(HW.DIO.Line(pumpidx), 0);
          ev = struct('Note',['BEHAVIOR,PUMPOFF,',PumpName],'StartTime',IOGetTimeStamp(HW),'StopTime',[]);
        end
        IOShutdownTimers(PumpName);
      otherwise error('PumpAction not implemented!');
    end
    
end

if nargout > 0 varargout{1} = ev; else varargout = []; end