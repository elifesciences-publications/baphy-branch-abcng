function o = RewardTarget (varargin)
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
        o.RewardSound       = 'None';
        o.TurnOnLight       = 'Never';
        o.TurnOffLight      = 'Never';
        o.Shock             = 'Never';
        o.StopStim          = 'Target';
        o.StopTargetFA = 1;
        o.PumpDuration      = 1;
        o.AutomaticReward      = 0;
        o.LightOnFreq = 0;
        o.RewardAmount = 0.2;
        o.NoRecExtraDuration = 0;
        o.ExtraDuration = 0;
        o.StopOnEarly = 1; % 2 is lick on Ref Early counts as FA and cuts trials
        o.UserDefinableFields = {'NoResponseTime','edit',0.2, 'EarlyWindow', ...
            'edit',0.2, 'ResponseWindow','edit',1,'TimeOut','edit',4,...
            'RewardSound','popupmenu','None|Click|Water','TurnOnLight','popupmenu',...
            'Never|BehaveOrPassive|FalseAlarm|Reward|ResponseWindow','TurnOffLight','popupmenu','Never|Ineffective',...
            'Shock','popupmenu','Never|FalseAlarm','StopStim','popupmenu','Target|Immediately','StopTargetFA','edit',1,...
            'AutomaticReward','edit',0,'LightOnFreq','edit',0,'RewardAmount','edit',0.2,...
            'ExtraDuration','edit',0,'StopOnEarly','edit',1};
        o = class(o,'RewardTarget');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'RewardTarget')
            o = varargin{1};
        else
            error('Wrong argument type'); 
        end
    otherwise
        error('Wrong number of input arguments');
end
