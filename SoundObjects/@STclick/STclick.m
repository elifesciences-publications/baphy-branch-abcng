function o = STclick (varargin)
% STclick is the constructor for the object STclick which is a child of SoundObject class

% usage:
% To create a Click with specified values:
%   t = STclick
%
% To get the waveform and events:
%   [w, events] = waveform(t);
%
% methods: set, get, waveform, ObjUpdate

% Nima Mesgarani, Oct 2005
% Sundeep Teki, May 2015: added functionality for irregular click trains


switch nargin
    
    case 0
        % if no input arguments, create a default object
        s = SoundObject ('STclick', 40000, 0, 0, 0, ...
            {''}, 1, ...
            {'ClickWidth','edit',0.001,...
             'ClickRate','edit',10,...
             'Duration','edit',1,...
             'ClickJitter','edit',20,...
             'JitterRange','edit',5,...
             'ClickJitterPos','edit',0.5,...             
             });
         
        o.ClickWidth      = 0.001;
        o.ClickRate       = 10;
        o.Duration        = 1;
        o.ClickJitter     = 20;  % percentage jitter        
        o.JitterRange     = 5;   % jitter drawn from a range: ClickJitter-JitterRange : ClickJitter+JitterRange, e.g. 15-25 here
        o.ClickJitterPos  = 0.5; % percentage of click train at which point jitter is introduced, e.g. halfway through here
        o = class(o,'STclick',s);
        o = ObjUpdate (o);
    
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'SoundObject')
            o = varargin{1};
        else
            error('Wrong argument type');
        end
        
    case 10
        s = SoundObject('STclick', ...
            varargin{1},...     % SamplingRate
            varargin{2}, ...    % Loudness
            varargin{3}, ...    % PreStimSilence
            varargin{4},...     % PostStimSilence
            '',1,...
           {'ClickWidth','edit',varargin{5},...
            'ClickRate','edit',varargin{6},...
            'Duration','edit',varargin{7}, ...
            'ClickJitter','edit',varargin{8},...
            'JitterRange','edit',varargin{9},...
            'ClickJitterPos','edit',varargin{10}});
        
        o.ClickWidth     = varargin{5};
        o.ClickRate      = varargin{6};
        o.Duration       = varargin{7};
        o.ClickJitter    = varargin{8};
        o.JitterRange    = varargin{9};
        o.ClickJitterPos = varargin{10};        
        o = class(o,'STclick',s);
        o = ObjUpdate (o);
    
    otherwise
        error('Wrong number of input arguments');
end