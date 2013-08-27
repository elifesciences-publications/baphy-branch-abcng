function o = SameDiffTone(varargin)
% SameDiffTone is the constructor for the object SameDiffTone which is a child of  
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
    s = SoundObject ('SameDiffTone', 40000, 0, 0, 0, ...
        {''}, 1, {'Frequencies','edit',1000,...        
        'Duration','edit',1,'Pedestal','edit',60,'LevelDiff','edit',0,'ToneGap','edit',0});
    o.Frequencies = 1000;
    o.Duration = 1;  %
    o.Pedestal = 60;
    o.LevelDiff = 0;
    o.ToneGap=0.5;
    o.SameDiff=[];
    o = class(o,'SameDiffTone',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
    s = SoundObject('SameDiffTone', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Frequencies','edit',1000,...
        'Duration','edit',1});
    o.Frequencies = varargin{5};
    o.Duration = varargin{6};
    o.ScaleFactor = [55 65 75];  %
    o = class(o,'SameDiffTone',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end