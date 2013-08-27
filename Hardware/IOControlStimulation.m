function varargout = IOControlStimulation (HW, Duration, Action)
% function ev = IOStimulation (HW, Duration, Action)

if nargin<3, Action = 'Start';end
if nargin<2, Duration = 0.2;end
if strcmpi(Action,'start')
    ev.Note='STIMULATION,ON';
else
    ev.Note='STIMULATION,OFF';
end

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
        StimulationIndex = min(find(strcmp(HW.DIO.Line.LineName,'Stimulation')));
        
        if isempty(StimulationIndex),
            timestamp = IOGetTimeStamp(HW);
            warning('Stimulation digital output channel not defined.');
            return
        end
        
        if strcmpi(Action,'Start')
            ev.StartTime = IOGetTimeStamp(HW);
            putvalue(HW.DIO.Line(StimulationIndex), 1);
            t = timer('TimerFcn','IOControlStimulation (HW, 0, ''Stop'')','StartDelay',Duration);
            start(t);
            ev.StopTime = ev.StartTime+Duration;
        else
            putvalue(HW.DIO.Line(StimulationIndex), 0);
            IOShutdownTimers('Stimulation');
        end
end
if nargout > 0 
    varargout{1} = ev;
end 

