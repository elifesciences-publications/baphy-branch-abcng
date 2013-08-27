function o = GOnonGO_punish (varargin)
%
% Go/non-Go task behavior control
% NoResponseTime: the time period for no-lick before a trial start, which is necessary for a trial initiation.
% EarlyWindow: a time period starting from the onset of target sequence.
% ResponseWindow: a time period following Early window.
% TimeOut: silent period, use as a penalty for incorrect response to target sequence.
% PumpDuration: the duration of water stream give to animal for a correct response. 

% Pingbo, Augest 3, 2009, NSL

switch nargin
    case 0
        % if no input arguments, create a default object
        o.NoResponseTime    = 0.2;
        o.EarlyWindow       = 0.2;
        o.ShockWindow    = 1;
        o.TimeOut           = 4;
        o.PunishSound       = 'Click';
        o.TurnOnLight       = 'Never';
        o.TurnOffLight      = 'Never';
        o.LightOnFreq = 0;
        o.UserDefinableFields = {'NoResponseTime','edit',0.2, 'EarlyWindow', ...
            'edit',1.0, 'ShockWindow','edit',0.5,'TimeOut','edit',4,...
            'PunishSound','popupmenu','None|Click','TurnOnLight','popupmenu',...
            'Never|BehaveOrPassive|FalseAlarm|Shock','TurnOffLight','popupmenu','Never|FalseAlarm|Shock',...
            'LightOnFreq','edit',0};
        o = class(o,'GOnonGO_punish');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'GOnonGO_punish')
            o = varargin{1};
        else
            error('Wrong argument type'); 
        end
    otherwise
        error('Wrong number of input arguments');
end
