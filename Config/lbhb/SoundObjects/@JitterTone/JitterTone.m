function o = JitterTone(varargin)
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
    s = SoundObject ('JitterTone', 100000, 0, 0, 0, ...
        {''}, 1, {...
        'Frequencies','edit',1000,...
        'SplitChannels','popupmenu','No|Yes',...
        'ChordCount','edit',1,...
        'ChordWidth','edit',0.2,...
        'JitterOctaves','edit',0,...
        'Duration','edit',1});
    o.Frequencies = 1000;
    o.SplitChannels = 'No';
    o.ChordCount=1;
    o.ChordWidth=0.2;
    o.JitterOctaves = 0;
    o.Duration = 1;  %
    o = class(o,'JitterTone',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end