function o = FMSweep(varargin)
% Tone is the constructor for the object Tone which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Frequencies", "Duration"
%
% usage:
% To creates a tone with default values.
%   t = Tone;     
%
% To create a tone with specified values:
%   t = Tone (Loudness, PreStimSilence, PostStimSilence,
%       frequencies, Duration);
%
% To get the waveform and events:
%   [w, events] = waveform(t);  
%
% methods: set, get, waveform, ObjUpdate


% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('FMSweep', 100000, 0, 0.4, 0.8, ...
        {''}, 1, {'StartFrequency','edit',1000,...        
        'EndFrequency','edit',2000,'Duration','edit',1});
    o.StartFrequency = 1000;
    o.EndFrequency = 2000;
    o.Duration = 1.5;  %
    o = class(o,'FMSweep',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 7
    s = SoundObject ('FMSweep', varargin{1}, varargin{2}, varargin{3}, varargin{4}, ...
        {''}, 1, {'StartFrequency','edit',varargin{5},...        
        'EndFrequency','edit',varargin{6},'Duration','edit',varargin{7}});
    o.StartFrequency = varargin{5};
    o.EndFrequency = varargin{6};
    o.Duration = varargin{7};  %
    o = class(o,'FMSweep',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end