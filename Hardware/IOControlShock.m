function varargout = IOControlShock (HW, Duration, Action)
% function ev = IOControlShock (HW, Duration, Action)
% 
% This function send the shock for the period specified in Duration.
% The function creates a Timer object that runs for Duration and then calls
% the same function for 'Stop' action.

if nargin<3, Action = 'Start';end
if nargin<2, Duration = 0.2;end
if strcmpi(Action,'start')
    ev.Note='BEHAVIOR,SHOCKON';
else
    ev.Note='BEHAVIOR,SHOCKOFF';
end
    % Nima's checklist:
%   

% Nima, November 2005

switch HW.params.HWSetup
    case 0
        % Test mode, no pump
        ev.StartTime=IOGetTimeStamp(HW);
        if strcmp(Action,'Start')
            ev.StopTime=ev.StartTime+Duration;
        else
            ev.StopTime=[];
        end
        
  otherwise
        % should work for all rigs. Requires initializing with appropriate
        % naming scheme
        ShockIndex = min(find(strcmp(HW.DIO.Line.LineName,'Shock')));
        
        if isempty(ShockIndex),
            timestamp = IOGetTimeStamp(HW);
%            warning('Shock digital output channel not defined.');
            return
        end
        
        if strcmpi(Action,'Start')
            putvalue(HW.DIO.Line(ShockIndex), 1);
            t = timer('TimerFcn','IOControlShock(HW, 0, ''Stop'')','StartDelay',Duration);
            start(t);
            ev.StartTime = IOGetTimeStamp(HW);
            ev.StopTime = ev.StartTime+Duration;
        else
            putvalue(HW.DIO.Line(ShockIndex), 0);
            IOShutdownTimers('Shock');
        end
end
if nargout > 0 
    varargout{1} = ev;
end 

