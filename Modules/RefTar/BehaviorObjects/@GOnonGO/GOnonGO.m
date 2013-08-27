function o = GOnonGO (varargin)
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
        o.ResponseWindow    = 1;
        o.TimeOut           = 4;
        o.RewardSound       = 'Click';
        o.TurnOnLight       = 'Never';
        o.TurnOffLight      = 'Never';
        o.Shock             = 'Never';
        o.PumpDuration      = [1 0];  %reward (1) and conditioning drop(2)
        o.TarStimulation    =0;
        o.TarStimulationOnset=0;      %ref to target onset
        o.TarStimulationDur =0.5;     %
        o.LightOnFreq = 0;
        o.UserDefinableFields = {'NoResponseTime','edit',0.2, 'EarlyWindow', ...
            'edit',0.2, 'ResponseWindow','edit',1,'TimeOut','edit',4,'PumpDuration','edit',[1 0],...
            'RewardSound','popupmenu','None|Click|Water','TurnOnLight','popupmenu',...
            'Never|BehaveOrPassive|FalseAlarm|Reward','TurnOffLight','popupmenu','Never|FalseAlarm|Reward',...
            'Shock','popupmenu','Never|FalseAlarm','TarStimulation','checkbox',0,'TarStimulationOnset','edit','0',...
            'TarStimulationDur','edit',0.5,'LightOnFreq','edit',0};
        o = class(o,'GOnonGO');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'GOnonGO')
            o = varargin{1};
        else
            error('Wrong argument type'); 
        end
    otherwise
        error('Wrong number of input arguments');
end
