function o = NoiseMask(varargin)
% NoiseMask is the constructor for the object NoiseMask which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Frequencies", "Duration"
%
% usage:
% To creates a* two spectral bands of noise cenered around probe frequency with default values.
%   t = NoiseMask;     
%
% To create a tone with specified values:
%   t = NoiseMask (Loudness, PreStimSilence, PostStimSilence,
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
    s = SoundObject ('NoiseMask', 40000, 0, 0, 0, ...
        {''}, 1, {'Duration','edit',0.4, 'NotchWidth', 'popupmenu', '0f|0.2f|0.3f|0.4f', ....
        'ProbeFreq', 'edit', 1000});
    o.ProbeFreq = 1000;
    o.NotchWidth = '0f';
    o.Duration = 0.4;  %
    o = class(o,'NoiseMask',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
    s = SoundObject('NoiseMask', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Duration','edit',0.4, 'NotchWidth', 'popupmenu', '0f|0.2f|0.3f|0.3f', ....
        'ProbeFreq', 'edit', 1000});
    o.ProbeFreq = varargin{5};
    o.Duration = varargin{6};
    o.NotchWidth = varargin{7};
    o = class(o,'NoiseMask',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end