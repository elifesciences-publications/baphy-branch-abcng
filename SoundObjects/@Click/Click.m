function o = Click (varargin)
% Click is the constructor for the object Click which is a child of  
%       SoundObject class
%
%
% usage:
% To creates a Click with default values.
%   t = Tone;     
%
% To create a Click with specified values:
%   t = Click 
%
% To get the waveform and events:
%   [w, events] = waveform(t);  
%
% methods: set, get, waveform, ObjUpdate


% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('Click', 100000, 0, 0, 0, ...
        {''}, 1, {'ClickWidth','edit',0.001,'ClickRate','edit',10,...        
        'Duration','edit',1,...
        'IrregularCT','popupmenu','no|uniform'});
    o.ClickWidth = .001;
    o.ClickRate = 10;
    o.Duration = 1;  %
    o.IrregularCT = 'no';  %
    o.MinICI = 0.005;  %
    o = class(o,'Click',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 7
    s = SoundObject('Click', ...
        varargin{1},...     % SamplingRate
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'ClickWidth','edit',varargin{5},'ClickRate','edit',varargin{6},...
        'Duration','edit',varargin{7}});
    o.ClickWidth = varargin{5};
    o.ClickRate = varargin{6};
    o.Duration = varargin{7};
    o = class(o,'Click',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end