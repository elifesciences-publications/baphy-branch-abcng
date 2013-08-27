function o = AbrTone(varargin)
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
    s = SoundObject ('AbrTone', 100000, 0, 0.05, 0.03, ...
        {''}, 1, {...
        'Frequencies','edit',[125 250 500 1000 2000 4000 8000 16000 32000],...
        'Levels','edit',[30 40 50 60 70],...
        'Duration','edit',0.02,...
        'RampDuration','edit',0.01,...
        'RefRepCount','edit',1,...
});
    o.Frequencies = [125 250 500 1000 2000 4000 8000 16000 32000];
    o.Levels = [30 40 50 60 70];
    o.RampDuration=0.01;
    o.Duration = 0.02;
    o.RefRepCount=45;
    o.OverrideAutoScale=1;  % set level in waveform.
    o = class(o,'AbrTone',s);
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