function IOShutdownTimers(varargin);
% function IOShutdownTimers(varargin);
% This function finds the active timers in the memory and clear them.
% Optional input is the name of TimerFcns which has to be cleared, 
% example:  IOShutdownTimers;   clear all timers 
%           IOShutdownTimers('Light','Pump'); clear timers that have Light
%               or pump in their TimerFcn field.

% Nima, nov 2005

t = timerfindall;
if nargin==0 
    for iT = 1:length(t) % LOOP OVER TIMERS
      stop(t(iT)); delete(t(iT)); clear t(iT);
    end
else
  for iS = 1:length(varargin)  % LOOP OVER TARGETS FOR SHUTDOWN
    for iT = 1:length(t) % LOOP OVER TIMERS
      try,
        if ~isempty(strfind(func2str(t(iT).TimerFcn),varargin{iS}))
          stop(t(iT)); delete(t(iT)); clear t(iT);
        end
      end
    end
  end
end

