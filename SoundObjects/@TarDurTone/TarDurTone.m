function o = TarDurTone(varargin)
% TarDurTone is the constructor for the object TarDurTone which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Frequencies", "Duration"
%
% usage:
% To creates a TarDurTone with default values.
%   t = TarDurTone;     
%
% To create a TarDurTone with specified values:
%   t = TarDurTone (Loudness, PreStimSilence, PostStimSilence,
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
    s = SoundObject ('TarDurTone', 40000, 0, 0, 0, ...
        {''}, 1, {'Frequencies','edit',1000,...        
        'Duration','edit',1,'AMRate','edit',4});
    o.Frequencies = 1000;
    o.Duration = 1;  %
    o.AMRate = 4;
    o = class(o,'TarDurTone',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
    s = SoundObject('TarDurTone', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Frequencies','edit',1000,...
        'Duration','edit',1});
    o.Frequencies = varargin{5};
    o.Duration = varargin{6};
    o = class(o,'TarDurTone',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end