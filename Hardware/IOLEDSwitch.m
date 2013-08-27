function [ll, ev] = IOLEDSwitch(HW,lightswitch,LEDName,Duration,Action,Frequency)
% function [ll, ev] = IOLEDSwitch(HW,lightswitch,Duration,Action)
%
% set light to lightswitch or return existing light setting
% Duration is optional, if specified, the light goes back to previous state
% after duration
% Action: for internal use, dont pass it

% created SVD 2005-11-20 ripped off IOPumpControl.m
% Revision Nima, added timer and TimeStamp. Are we gonna keep ll??
% BE 2011, updated for multiple lights

global LIGHTSWITCH0
if nargin<6, Frequency = 0;end
if nargin<5, Action = 'Start';end
if nargin<4, Duration = 0; Action='None';end % zero means for ever, dont set the timer
if nargin<3, LEDName = 'LED'; end
if nargin<2, ll=LIGHTSWITCH0; ev=[]; return; end

if lightswitch==1,
    ev.Note='BEHAVIOR,LIGHTON';
else
    ev.Note='BEHAVIOR,LIGHTOFF';
end
if Frequency>0
    NumOfFlashes = ceil(Frequency*Duration);
    SwitchTime = .5/Frequency;
end
switch HW.params.HWSetup
    case 0,
        % Test mode
        LIGHTSWITCH0=lightswitch;
        ev.StartTime=IOGetTimeStamp(HW);
        if strcmp(Action,'Start')
            ev.StopTime=ev.StartTime+Duration;
        else
            ev.StopTime=[];
        end
    otherwise
        % should work for all rigs. Requires initializing with appropriate naming scheme
        lightidx=min(find(strcmp(HW.DIO.Line.LineName,LEDName)));
        if isempty(lightidx),
            error('Light digital output channel not defined.');
        end
        % Now, if action is start, start the timer. otherwise change the light back
        if Duration == 0
            putvalue(HW.DIO.Line(lightidx),lightswitch);
            LIGHTSWITCH0=lightswitch;
            ev.StartTime = IOGetTimeStamp(HW);
            ev.StopTime = [];
            IOShutdownTimers('Light');
        elseif strcmpi(Action,'Start') && ~Frequency
            putvalue(HW.DIO.Line(lightidx),lightswitch);
            StopCommand = ['IOLEDSwitch(HW,' num2str(~lightswitch) ',''',LEDName,''');'];
            t = timer('TimerFcn',StopCommand,'StartDelay',Duration);
            start(t);
            ev.StartTime = IOGetTimeStamp(HW);
            ev.StopTime = ev.StartTime+Duration;
        elseif Frequency>0  % means its the first time
            putvalue(HW.DIO.Line(lightidx),lightswitch);
            StopCommand = ['IOLEDSwitch(HW,' num2str(~lightswitch) ',''',LEDName,''',' ...
                num2str(SwitchTime) ',''start'',' num2str(-NumOfFlashes) ');'];
            t = timer('TimerFcn',StopCommand,'StartDelay',SwitchTime);
            start(t);
            ev.StartTime = IOGetTimeStamp(HW);
            ev.StopTime = ev.StartTime+Duration;            
            ev.Note = [ev.Note ', ' num2str(Frequency) ' Hz'];
        else    % its not the first, Now the frequency means number of flashes.
            if Frequency == -1, lightswitch=0; end    % if its the last time turn the light off.
            putvalue(HW.DIO.Line(lightidx),lightswitch);
            if Frequency == -1; return;end
            Frequency=Frequency+1;
            StopCommand = ['IOLEDSwitch(HW,' num2str(~lightswitch) ',''',LEDName,''',' ...
                num2str(Duration) ',''start'',' num2str(Frequency) ');'];
            t = timer('TimerFcn',StopCommand,'StartDelay',Duration);
            start(t);
            ev.StartTime = IOGetTimeStamp(HW);
            ev.StopTime = ev.StartTime+Duration;
        end
end
if nargout>0,
    ll=LIGHTSWITCH0;
end