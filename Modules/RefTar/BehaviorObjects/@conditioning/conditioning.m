function o = conditioning (varargin)
%
% Positive Reinforcement behavior control
% NoResponseTime: the time period for no-lick before a trial start, which is necessary for a trial initiation.
% EarlyWindow: a time period starting from the onset of target sequence.
% ResponseWindow: a time period following Early window.
% TimeOut: silent period, use as a penalty for incorrect response to target sequence.
% Dropsize: the duration of water stream give to animal for a correct response. 

% Nima, april 2006, NSL

switch nargin
    case 0
        % if no input arguments, create a default object
        o.NoResponseTime    = 0.2;
        o.EarlyWindow       = 0.2;
        o.ResponseWindow    = 1;
        o.TimeOut           = 4;
        o.RewardSound       = 'Click';
        o.TurnOnLight       = 'Never';
        o.TurnOffLight      = 'Never';
        o.Shock             = 'Never';
        o.StopStim          = 'Target';
        o.StopTargetFA = 1;
        o.PumpDuration      = [1 0];
        o.LightOnFreq = 0;
        o.UserDefinableFields = {'NoResponseTime','edit',0.2, 'EarlyWindow', ...
            'edit',0.2, 'ResponseWindow','edit',1,'TimeOut','edit',4,'PumpDuration','edit',[1 0],...
            'RewardSound','popupmenu','None|Click|Water','TurnOnLight','popupmenu',...
            'Never|BehaveOrPassive|FalseAlarm|Reward','TurnOffLight','popupmenu','Never|Ineffective',...
            'Shock','popupmenu','Never|FalseAlarm','StopStim','popupmenu','Target|Immediately','StopTargetFA','edit',1,...
            'LightOnFreq','edit',0};
        o = class(o,'conditioning');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'conditioning')
            o = varargin{1};
        else
            error('Wrong argument type'); 
        end
    otherwise
        error('Wrong number of input arguments');
end
