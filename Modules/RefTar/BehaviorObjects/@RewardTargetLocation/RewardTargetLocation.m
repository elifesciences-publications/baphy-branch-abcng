function O = RewardTargetLocation(varargin)
% Positive Reinforcement behavior control with multiple spouts
% NoResponseTime: the time period for no-lick before a trial start, which is necessary for a trial initiation.
% EarlyWindow: a time period starting from the onset of target sequence.
% ResponseWindow: a time period following Early window.
% TimeOut: silent period, use as a penalty for incorrect response to target sequence.
% PumpDuration: the duration of water stream give to animal for a correct response. 
%
% YB/JN 2017/09

switch nargin
  case 0
    % if no input arguments, create a default object
    O.InterTrialInterval   = 0.1; % seconds
    O.NoResponseTime   = 0.5; % seconds
    O.LightCueDuration          = 0.0; % seconds
    O.ResponseWindow  = 2; % seconds
    O.TimeOutError             = 3; % seconds
    O.TimeOutEarly             = 1; % seconds
    O.RewardAmount       = 0.2; % ml
    O.MinimalDelayResponse = 0.07;
    O.AfterResponseDuration = 2; % s (Record for this time after response);
    O.TargetChannel = 2; % s (Record for this time after response);
    O.AutomaticReward = 0; % s (Record for this time after response);
    O.PunishSound = 'None';
    O.UserDefinableFields = {...
      'InterTrialInterval','edit',NaN,...
      'NoResponseTime','edit',NaN,...
      'LightCueDuration','edit',NaN,...
      'ResponseWindow','edit',NaN,...
      'TimeOutError','edit',NaN,...
      'TimeOutEarly','edit',NaN,...
      'RewardAmount','edit',NaN,...
      'MinimalDelayResponse','edit',NaN,...
      'AfterResponseDuration','edit',NaN,...
      'TargetChannel','edit',1,...
      'AutomaticReward','edit',0,...
      'PunishSound','popupmenu','None|Buzz|FABuzz|EarlyBuzz'};
    O = class(O,'RewardTargetLocation');
    O = ObjUpdate(O);
  case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'RewardTargetLocation')
      O = varargin{1};
    else
      error('Wrong argument type');
    end
  otherwise
    error('Wrong number of input arguments');
end
