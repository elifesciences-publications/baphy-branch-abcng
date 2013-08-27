function o = NoiseBurst(varargin)
% NoiseBurst is the constructor for the object NoiseBurst which is a child of  
%       SoundObject class
%
% Run class: BNB
%
% A set of Count bandpass noise signals, center frequencies spaced
% logorithmically from LowFreq to HighFreq.  Bandwidth 1.0 fills in space
% exactly. Values>1 cause overlap between adjacent bursts, <1 leave space
% in between.  SimulCount is how many bursts to include in each instance.
% So MaxIndex is Count^SimulCount.
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Duration", "LowFreq", "HighFreq", "Count",
%       "Bandwidth", "SimulCount",
%
% usage:
% To create a NoiseBurst with default values.
%   t = NoiseBurst;
%
% (NOT SUPPORTED YET) To create a NoiseBurst with specified values:
%   t = ComplexChord (Loudness, PreStimSilence, PostStimSilence,
%       frequencies, Duration);
%
% To get the waveform and events:
%   [w, events] = waveform(t);  
%
% methods: set, get, waveform, ObjUpdate

% SVD created 2007-08-05, based on ComplexChord object.

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('NoiseBurst', 100000, 0, 0, 0, ...
        {''}, 1, {'Duration','edit',1,...
        'LowFreq','edit',250,...       
        'HighFreq','edit',8000,...       
        'Count','edit',15,...
        'Bandwidth','edit',1,...
        'NoiseBand', 'edit', 0, ...
        'TonesPerBurst','edit',20,...
        'SimulCount','edit',1,...
        'RefRepCount','edit',1});
    o.LowFreq = 250;
    o.HighFreq = 8000;
    o.Count=15;
    o.Bandwidth=1;
    o.NoiseBand= 0; 
    o.TonesPerBurst=20;
    o.SimulCount=1;
    o.RefRepCount=1;
    o.Duration = 1;
    o = class(o,'NoiseBurst',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 12
    s = SoundObject('NoiseBurst', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Duration','edit',0.4});
    
    o.LowFreq = varargin{5};
    o.HighFreq = varargin{6};
    o.Count=varargin{6};
    o.Bandwidth=varargin{7};
    o.NoiseBand= varargin{8}; % added by Serin Atiani 07/08 to activate the bandpass white noise option
    o.TonesPerBurst=varargin{9};
    o.SimulCount=varargin{10};
    o.RefRepCount=varargin{11};
    o.Duration = varargin{12};
    o = class(o,'NoiseBurst',s);
    o = ObjUpdate (o);
        
otherwise
    error('Wrong number of input arguments');
end