function o = NoiseBand(varargin)
% NoiseBurst is the constructor for the object NoiseBurst which is a child of  
%       SoundObject class
%
% Run class: BND
%
% A set of Count bandpass noise signals, center frequencies spaced
% logorithmically from LowFreq to HighFreq.  BandwidthOverlap 1.0 fills in space
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
% To create a NoiseBand with default values.
%   t = NoiseBand;
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
    s = SoundObject ('NoiseBand', 40000, 0, 0, 0, ...
        {''}, 1, {'Duration','edit',1,...
        'Frequencies','edit',[125 250 500 1000 2000 4000 8000],...       
        'Bandwidth', 'edit', [0.125 0.25 0.5 1 2], ...
        'NoiseBand', 'edit', 0,...
        'TonesPerBurst','edit',20});
    
    o.Frequencies = [125 250 500 1000 2000 4000 8000];
    o.Bandwidth=[0.125 0.25 0.5 1 2];
    o.NoiseBand= 0; 
    o.TonesPerBurst=20;
    o.Duration = 1;
    o.CombinationSet= [];
    o = class(o,'NoiseBand',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 10
    s = SoundObject('NoiseBand', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Duration','edit',0.4});
    
    o.Frequencies = varargin{5};
    o.Bandwidth=varargin{6};
    o.NoiseBand= varargin{7}; % added by Serin Atiani 07/08 to activate the bandpass white noise option
    o.TonesPerBurst=varargin{8};
    o.Duration = varargin{9};
    o.CombinationSet=varargin{10};
    o = class(o,'NoiseBurst',s);
    o = ObjUpdate (o);
        
otherwise
    error('Wrong number of input arguments');
end