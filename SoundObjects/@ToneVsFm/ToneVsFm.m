function o = ToneVsFm(varargin)
% ToneVsFm is the constructor for the object ToneVsFm which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Frequencies", "Duration"
%
% usage:
% To creates a tone with default values.
%   t = ToneVsFm;     
%
% To create a tone with specified values:
%   t = ToneVsFm (Loudness, PreStimSilence, PostStimSilence,
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
    s = SoundObject ('ToneVsFm', 40000, 0, 0, 0, ...
        {''}, 1, {'Frequencies','edit',1000,'TarProb','edit',[.5 .5],'Duration','edit',[1 2],'RandBand','edit',1});
    o.Frequencies = 1000;
    o.Duration = [1 2];
    o.TarProb = [.5 .5];
    o.FMorTone = 1;
    o.RandBand = 1;
    o = class(o,'ToneVsFm',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
    s = SoundObject('ToneVsFm', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Frequencies','edit',1000,...
        'Duration','edit',1});
    o.Frequencies = varargin{5};
    o.Duration = varargin{6};
    o = class(o,'ToneVsFm',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end