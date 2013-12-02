function O = RewardTargetMC(varargin)
% Positive Reinforcement behavior control with multiple spouts
% NoResponseTime: the time period for no-lick before a trial start, which is necessary for a trial initiation.
% EarlyWindow: a time period starting from the onset of target sequence.
% ResponseWindow: a time period following Early window.
% TimeOut: silent period, use as a penalty for incorrect response to target sequence.
% PumpDuration: the duration of water stream give to animal for a correct response. 
%
% BE 2010/7

switch nargin
  case 0
    % if no input arguments, create a default object
    O.InterTrialInterval   = 0.1; % seconds
    O.NoResponseTime   = 0.5; % seconds
    O.LightCueDuration          = 0.0; % seconds
    O.EarlyWindow         = 0.25; % seconds
    O.ResponseWindow  = 2; % seconds
    O.TimeOutError             = 3; % seconds
    O.TimeOutEarly             = 1; % seconds
    O.CenterRewardAmount = 0.02;% ml
    O.CenteringRewardDelay = 0.5; % s (time after trial onset to give the centering delay)
    O.PrewardAmount      = 0.0; % ml
    O.RewardAmount       = 0.2; % ml
    O.AfterResponseDuration = 2; % s (Record for this time after response);
    O.ShockDuration = 0; % seconds
    O.PunishSound        = 'Noise'; 
    O.Simulick               = 0; % simulate licks
    O.UserDefinableFields = {...
      'InterTrialInterval','edit',NaN,...
      'NoResponseTime','edit',NaN,...
      'LightCueDuration','edit',NaN,...
      'EarlyWindow','edit',NaN,...
      'ResponseWindow','edit',NaN,...
      'TimeOutError','edit',NaN,...
      'TimeOutEarly','edit',NaN,...
      'CenterRewardAmount','edit',NaN,...
      'CenteringRewardDelay','edit',NaN,...
      'PrewardAmount','edit',NaN,...
      'RewardAmount','edit',NaN,...
      'AfterResponseDuration','edit',NaN,...
      'ShockDuration','edit',NaN,...
      'PunishSound','popupmenu','None|Noise',...
      'Simulick','edit',1};
    O = class(O,'RewardTargetCont');
    O = ObjUpdate(O);
  case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'RewardTargetCont')
      O = varargin{1};
    else
      error('Wrong argument type');
    end
  otherwise
    error('Wrong number of input arguments');
end
