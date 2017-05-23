function o = RewardEyeFixation (varargin)
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
        o.Shock             = 'Never';
        o.StopStim          = 'Target';
        o.StopTargetFA = 1;
        o.PumpDuration      = 1;
        o.RewardAmount = 0.2;
        o.RewardInterval = 1;                        % in s
        o.RewardIntervalStd = 50;                 % in percent
        o.RewardIntervalLaw = 'Uniform';       % could be exponentially decaying for flat hazard rate
        o.AllowedRadius = 100;                      % in px
        o.Calibration = 0;
        o.StimType = 'MseqMono';
        o.UserDefinableFields = {'NoResponseTime','edit',0.2, 'EarlyWindow','edit',0.2,...
            'ResponseWindow','edit',1,'TimeOut','edit',4,...
            'RewardInterval','edit',1,'RewardIntervalStd','edit',50,'AllowedRadius','edit',100,...
            'RewardSound','popupmenu','None|Click|Water',...
            'StopStim','popupmenu','Target|Immediately',...
            'StopTargetFA','edit',1,'RewardAmount','edit',0.2,...
            'Calibration','edit',0,...
            'StimType','popupmenu','MseqMono|MseqBino|HartleyMono|HartleyBino|Training|approxRFbar|approxRFlfp'};
        o = class(o,'RewardEyeFixation');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'RewardEyeFixation')
            o = varargin{1};
        else
            error('Wrong argument type'); 
        end
    otherwise
        error('Wrong number of input arguments');
end
