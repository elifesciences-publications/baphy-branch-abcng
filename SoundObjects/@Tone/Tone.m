function o = Tone(varargin)
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
    s = SoundObject ('Tone', 40000, 0, 0, 0, ...
        {''}, 1, {'Frequencies','edit',1000,...        
        'Duration','edit',1,'Gap','edit',[0]});
    o.Frequencies = 1000;
    o.Duration = 1;  %
    o.Gap=[0];  %gapdur in the middle, or [st et] in the tone if 2 elements
    o = class(o,'Tone',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
 case 6
    s = SoundObject('Tone', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Frequencies','edit',1000,...
        'Duration','edit',1,'Gap','edit',0});
    o.Frequencies = varargin{5};
    o.Duration = varargin{6};
    o.Gap = 0;
    o = class(o,'Tone',s);
    o = ObjUpdate (o);
case 7
    s = SoundObject('Tone', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Frequencies','edit',1000,...
        'Duration','edit',1,'Gap','edit',0});
    o.Frequencies = varargin{5};
    o.Duration = varargin{6};
    o.Gap = varargin{7};
    o = class(o,'Tone',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end