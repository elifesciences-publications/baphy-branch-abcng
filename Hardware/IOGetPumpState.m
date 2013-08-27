function varargout = IOControlPump (HW,PumpAction,Duration)
% function ev = IOControlPump (HW,PumpAction,Duration)
% 
% This function runs the pump for the period specified in Duration.
% The function creates a Timer object that runs for Duration and then calls
% the same function for 'Stop' action.
% PumpAction can be 'Start' or 'Stop'
% it also returns the time stamp from begining of the trial which is gotten from
% from toc now, but might changed in future

% Nima's checklist:
%   Tested in Test mode
%   Tested in Training setup (2), 11/19/2005

% Nima, November 2005
% SVD, 2005-11-20 - generic recording setup support

if strcmp(PumpAction,'Start')
    ev.Note='BEHAVIOR,PUMPON';
else
    ev.Note='BEHAVIOR,PUMPOFF';
end

switch HW.params.HWSetup
    case 0
        % Test mode, no pump
        ev.StartTime=IOGetTimeStamp(HW);
        if strcmp(PumpAction,'Start')
            ev.Stoptime=ev.StartTime+Duration;
        else
            ev.Stoptime=[];
        end
    otherwise
        
        % should work for all rigs. Requires initializing with appropriate
        % naming scheme
        pumpidx=min(find(strcmp(HW.DIO.Line.LineName,'Pump')));
        
        if isempty(pumpidx),
            timestamp = IOGetTimeStamp(HW);
            warning('Pump digital output channel not defined.');
            return;
        end
        
        if strcmp(PumpAction,'Start')
            putvalue(HW.DIO.Line(pumpidx), 1);
            t = timer('TimerFcn','IOControlPump(HW, ''Stop'')','StartDelay',Duration);
            start(t);
            ev.StartTime = IOGetTimeStamp(HW);
            ev.StopTime = ev.StartTime+Duration;
        else
            putvalue(HW.DIO.Line(pumpidx), 0);
            ev.StartTime = IOGetTimeStamp(HW);
            ev.Stoptime=[];
            IOShutdownTimers('Pump');
        end
        
end

if nargout > 0 
    varargout{1} = ev;
end 


