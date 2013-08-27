function o = LevelTuning(varargin)
% Level Tuning 

% methods: set, get, waveform
%   
% usage: 
% 
% 

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('LevelTuning', 40000, 0, 0.1, 0.4, ...
        {''}, 1, {'BaseFrequency','edit',1000,'LowdB','edit',50,...
        'HighdB','edit',80,'Steps','edit',3,...
        'Duration','edit',1000});
    o.BaseFrequency = 1000;
    o.LowdB = 30;
    o.HighdB = 80;
    o.Steps = 5;
    o.Duration = 0.1;  %ms
    o.Names = {'50'};
    o.MaxIndex = 1;
    o = class(o,'LevelTuning',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
%     s = SoundObject(varargin{1},varargin{2},varargin{3});
%     o.frequency = varargin{4};
%     o.duration = varargin{5};
%     o.loudness = varargin{6};
%     o = class(t,'Tone',s);
otherwise
    error('Wrong number of input arguments');
end