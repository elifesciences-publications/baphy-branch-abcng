function o = Passive (varargin);
% Passive behavior control does not do anything

switch nargin
    case 0
        % if no input arguments, create a default object
        % this is the constructor:
        o.descriptor = 'Passive';
        o.RandomReward = 0;
        o.RewardAmount = 0.2;
        o.RewardInterval = 1;                  % in s
        o.RewardIntervalStd = 50;              % in percent
        o.RewardIntervalLaw = 'Uniform';       % could be exponentially decaying for flat hazard rate
        o.ExtraDuration = 0;
        o.UserDefinableFields = {...
          'RandomReward','edit',0,...
          'RewardInterval','edit',1,...
          'RewardIntervalStd','edit',50,...
          'RewardAmount','edit',0.2,...
          'ExtraDuration','edit',0};
        o = class(o,'Passive');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'Passive')
            s = varargin{1};
        else
            error('Wrong argument type');
        end
    otherwise
        error('Wrong number of input arguments');
end
