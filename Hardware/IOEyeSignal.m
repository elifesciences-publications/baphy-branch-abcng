function varargout = IOEyeSignal(HW,EyeSignal)
% function ev = IOEyeSignal(HW,EyeSignal)
%
% This function sends a digital signal to the PsyToolBox computer for EyeSignal:
% -- 'start': EyeFixation initiated
% -- 'stop': EyeFixation terminated
%
% Yves, December 2015 (from IOControlPump)


switch HW.params.HWSetup
  case 0  % Test mode
    
  otherwise % Real Setups
    if strcmpi(IODriver(HW),'NIDAQMX'),
      switch lower(EyeSignal)
        case {'start',1}
          pumpidx=find(strcmp('EyeFixationInitiated',{HW.Didx.Name}));
        case {'stop',0}
          pumpidx=find(strcmp('EyeFixationTerminated',{HW.Didx.Name}));
      end
      
      if ~isempty(pumpidx),
        taskidx=HW.Didx(pumpidx).Task;
        lineidx=HW.Didx(pumpidx).Line;
        v=niGetValue(HW.DIO(taskidx));
      end
    else
    end
    
    if isempty(pumpidx),
      timestamp = IOGetTimeStamp(HW);
      warning('Output channel for EyeSignal''',EyeSignal,''' not defined.');
      return;
    end
    
    EventTiming = IOGetTimeStamp(HW);
    if strcmpi(IODriver(HW),'NIDAQMX'),
          v(lineidx)=1;
          niPutValue(HW.DIO(taskidx),v);
          v(lineidx)=0;
          niPutValue(HW.DIO(taskidx),v);
    else
    end
        
    switch lower(EyeSignal)
      case {'start',1}
        ev = struct('Note',['BEHAVIOR,EYESTART'],'StartTime',EventTiming,'StopTime',EventTiming);        
        fprintf('[ Start eye fixating @ %.2fs ]\n',EventTiming);
      case {'stop',0}
        ev = struct('Note',['BEHAVIOR,EYESTOP'],'StartTime',EventTiming,'StopTime',EventTiming);
        fprintf('[ Stop eye fixating @ %.2fs ]\n',EventTiming);        
      otherwise error('PumpAction not implemented!');
    end
    
end

if nargout > 0 varargout{1} = ev; else varargout = []; end