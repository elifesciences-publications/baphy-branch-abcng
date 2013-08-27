function [LightState, ev] = IOLightSwitch(HW,LightSwitch,Duration,Action,Frequency,Gap,LightName)
% function [LightState, ev] = IOLightSwitch(HW,LightSwitch,Duration,Action,Frequency,Gap.LightName)
%
% Control the state of the Light Output
% 
% Arguments:
%  HW                            : Hardware Structure
%  LightSwitch [0/1]         : State of the light  
%  Duration [number]      : Duration the light should be on
%  Action ['Start'/'Stop']   : Internal Use, pass [] if later arguments are used
%  Frequency                 : Pulsing frequency
%  Gap                          : Something Nima used
%  LightName ['Light']      : Name of the LightChannel to use
%
% Output :
%  LightState  [0/1]        :  Whether Light is on or off
%  ev [struct]                 :   Struct containing the events
%
% SVD update 2012-06-01 : added Nidaqmx support

global LIGHTSWITCH0
if nargin<7 || isempty(LightName) LightName = 'Light'; end
if nargin<6 || isempty(Gap) Gap = 0;end
if nargin<5 || isempty(Frequency) Frequency = 0;end
if nargin<4 || isempty(Action) Action = 'Start';end
if nargin<3 || isempty(Duration)  Duration = 0; Action='None';end % zero means for ever, dont set the timer
if nargin<2, LightState=LIGHTSWITCH0; ev=[]; return; end

if LightSwitch==1
   ev.Note=['BEHAVIOR,LIGHTON,',LightName];
else
   ev.Note=['BEHAVIOR,LIGHTOFF,',LightName];
end

if Frequency>0
    NumOfFlashes = 2*ceil(Frequency*Duration);
    SwitchTime = 0.5/Frequency;
end
switch HW.params.HWSetup
  case 0 % TEST MODE
    LIGHTSWITCH0=LightSwitch;
    fprintf('TESTMODE: Light %s = %d\n',LightName,LightSwitch);
    ev.StartTime=IOGetTimeStamp(HW);
    if strcmp(Action,'Start') ev.StopTime=ev.StartTime+Duration;
    else                     ev.StopTime=[];
    end
  otherwise % ALL RIGS
    if strcmpi(IODriver(HW),'NIDAQMX'),
      lightidx=find(strcmp(LightName,{HW.Didx.Name}));
      if ~isempty(lightidx),
        taskidx=HW.Didx(lightidx).Task;
        lineidx=HW.Didx(lightidx).Line;
        v=niGetValue(HW.DIO(taskidx));
      else
        warning(['light channel ',Lightname,' not found.  skipping IOLightSwitch']);
      end
    else
      lightidx=min(find(strcmp(HW.DIO.Line.LineName,LightName)));
    end
    
    if isempty(lightidx) error(['Digital output channel [ ',LightName,' ] not defined.']); end
    % Now, if action is start, start the timer. otherwise change the light back
    if Duration == 0
      if strcmpi(IODriver(HW),'NIDAQMX'),
        v(lineidx)=LightSwitch;
        niPutValue(HW.DIO(taskidx),v);
      else
        putvalue(HW.DIO.Line(lightidx),LightSwitch);
      end
      LIGHTSWITCH0=LightSwitch;
      if nargout>=2,
          ev.StartTime = IOGetTimeStamp(HW);
          ev.StopTime = [];
      end
      IOShutdownTimers('Light');
    elseif strcmpi(Action,'Start') && ~Frequency
      if nargout>=2,
          ev.StartTime = IOGetTimeStamp(HW);
      end
      if strcmpi(IODriver(HW),'NIDAQMX'),
        v(lineidx)=LightSwitch;
        niPutValue(HW.DIO(taskidx),v);
      else
        putvalue(HW.DIO.Line(lightidx),LightSwitch);
      end
      StopCommand = ['IOLightSwitch(HW,' num2str(~LightSwitch) ',[],[],[],[],''',LightName,''');'];
      t = timer('TimerFcn',StopCommand,'StartDelay',Duration);
      start(t);
      if nargout>=2,
          ev.StopTime = ev.StartTime+Duration;
      end
    elseif Frequency>0  % means its the first time, pass the on time and off time in gap!
      gapstr = [num2str(SwitchTime) ' ' num2str(SwitchTime)];
      if strcmpi(IODriver(HW),'NIDAQMX'),
        v(lineidx)=LightSwitch;
        niPutValue(HW.DIO(taskidx),v);
      else
        putvalue(HW.DIO.Line(lightidx),LightSwitch);
      end
      StopCommand = ['IOLightSwitch(HW,' num2str(~LightSwitch) ',' ...
        num2str(SwitchTime) ',''start'',' num2str(-NumOfFlashes) ',[' gapstr '],''',LightName,''');'];
      t = timer('TimerFcn',StopCommand,'StartDelay',SwitchTime);
      start(t);
      if nargout>=2,
          ev.StartTime = IOGetTimeStamp(HW);
          ev.StopTime = ev.StartTime+Duration;
          ev.Note = [ev.Note ', ' num2str(Frequency) ' Hz'];
      end
    else  % its not the first, Now the frequency means number of flashes.
      if Frequency == -1, LightSwitch=0;end    % if its the last time turn the light off.
      if strcmpi(IODriver(HW),'NIDAQMX'),
        v(lineidx)=LightSwitch;
        niPutValue(HW.DIO(taskidx),v);
      else
        putvalue(HW.DIO.Line(lightidx),LightSwitch);
      end
      if Frequency == -1; return; end
      Frequency=Frequency+1;
      if LightSwitch, Duration = Gap(1);, else Duration=Gap(2);end
      StopCommand = ['IOLightSwitch(HW,' num2str(~LightSwitch) ',' ...
        num2str(Duration) ',''start'',' num2str(Frequency) ',[' num2str(Gap) '],''',LightName,''');'];
      t = timer('TimerFcn',StopCommand,'StartDelay',Duration);
      start(t);
      if nargout>=2,
          ev.StartTime = IOGetTimeStamp(HW);
          ev.StopTime = ev.StartTime+Duration;
      end
    end
end
if nargout>0  LightState=LIGHTSWITCH0; end
