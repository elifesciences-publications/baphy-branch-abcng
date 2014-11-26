function o = RewardTargetLBHB (varargin)
%
% Positive Reinforcement behavior control, hacked from RewardTarget
%
% SVD 2012-06-01

switch nargin
    case 0
        % if no input arguments, create a default object
        o.NoResponseTimeFixed    = 1;
        o.NoResponseTimeVar    = 0.2;
        o.EarlyWindow       = 0.2;
        o.ResponseWindow    = 1;
        o.TimeOut           = 4;
        o.MissTimeOut           = 4;
        o.CorrectITI = 1;
        o.TurnOnLight       = 'Never';
        o.TurnOffLight      = 'Never';
        o.Light1      = 'Never';
        o.Light2      = 'Never';
        o.Light3      = 'Never';
        o.Shock             = 'Never';
        o.StopStim          = 'Immediately';
        o.StopTargetFA = 0.001;
        o.TrainingPumpDur   = 0;
        o.PumpDuration      = 1;
        o.LightOnFreq = 0;
        o.ReferenceDuringPreTrial= 'No';
        o.ITICarryOverToPreTrial='No';
        o.RewardTargetMinFrequency=0;
        o.RewardNullTrials='No';
        o.UserDefinableFields = {...
          'NoResponseTimeFixed','edit',0.2,...
          'NoResponseTimeVar','edit',0.2,...
          'EarlyWindow','edit',0.2,...
          'ResponseWindow','edit',1,...
          'TimeOut','edit',4,...
          'MissTimeOut','edit',4,...
          'CorrectITI','edit',1,...
          'PumpDuration','edit',1,...
          'TrainingPumpDur','edit',0,...
          'TurnOnLight','popupmenu','Never|BehaveOrPassive|FalseAlarm|Reward',...
          'TurnOffLight','popupmenu','Never|FalseAlarm',...
          'Light1','popupmenu','Never|OnReward|OffFalseAlarm|OnTarget1Blocks|OnTarget2Blocks',...
          'Light2','popupmenu','Never|OnReward|OffFalseAlarm|OnTarget1Blocks|OnTarget2Blocks',...
          'Light3','popupmenu','Never|OnReward|OffFalseAlarm|OnTarget1Blocks|OnTarget2Blocks',...
          'ReferenceDuringPreTrial','popupmenu','Yes|No',...
          'ITICarryOverToPreTrial','popupmenu','Yes|No',...
          'RewardTargetMinFrequency','edit',0,...
          'RewardNullTrials','popupmenu','Yes|No',...
        };
    
        o = class(o,'RewardTargetLBHB');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'RewardTargetLBHB')
            o = varargin{1};
        else
            error('Wrong argument type'); 
        end
    otherwise
        error('Wrong number of input arguments');
end
