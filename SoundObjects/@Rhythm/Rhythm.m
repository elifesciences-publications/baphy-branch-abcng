function o = Rhythm (varargin);
% Rhythm is the constructor for the object Rhythm which is a child of  
%       SoundObject class
%
%
% usage:
% To creates a Rhythm with default values.
%   t = Tone;     
%
% To create a Rhythm with specified values:
%   t = Rhythm 
%
% To get the waveform and events:
%   [w, events] = waveform(t);  
%
% methods: set, get, waveform, ObjUpdate
% 

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('Rhythm', 40000, 0, 0, 0, ...
        {''}, 1, {'Duration','edit',1,'Count','edit',5,...
                  'ICI','edit',0.2,...
                  'Level','edit',1,...
                  'ClickWidth','edit',0.001,...
        });
    o.ClickWidth = .001;
    o.Count = 5;
    o.PreStimSilence = 0.5; 
    o.PostStimSilence = 0.5;
    o.ICI = 0.2;
    o.Level = 1;
    o.Duration = 1;
    o = class(o,'Rhythm',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 7
    s = SoundObject('Rhythm', ...
        varargin{1},...     % SamplingRate
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'ClickWidth','edit',varargin{5},'ClickRate','edit',varargin{6},...
        'Duration','edit',varargin{7}});
    o.ClickWidth = varargin{5};
    o.ClickRate = varargin{6};
    o.Duration = varargin{7};
    o = class(o,'Rhythm',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end