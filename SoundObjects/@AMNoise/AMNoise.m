function o = AMNoise(varargin)
% NoiseBurst is the constructor for the object NoiseBurst which is a child of  
%       SoundObject class
%
% Run class: AMN
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
% To get the waveform and events:
%   [w, events] = waveform(t, idx);  
%
% methods: set, get, waveform, ObjUpdate

% SVD created 2007-08-05, based on ComplexChord object.

switch nargin
case {0,1}
    % if no input arguments, create a default object
    if nargin==1 && isa(varargin{1},'SoundObject')
       o = varargin{1};
       return;
    end
    
    s = SoundObject ('AMNoise', 40000, 0, 0, 0, ...
        {''}, 1, {'Duration','edit',1,...
                  'LowFreq','edit',250,...       
                  'HighFreq','edit',8000,...
                  'AM','edit',0,...
                  'ModDepth','edit',1,...
                  'FirstSubsetIdx','edit',[],...
                  'SecondSubsetIdx','edit',[],...
                  'SecondRelAtten','edit',0,...
                  'Count','edit',15,...
                  'TonesPerOctave','edit',20,...
                  'SimulCount','edit',1,...
                  'RefRepCount','edit',1});
    
    o.PreStimSilence=0.5;
    o.PostStimSilence=0.5;
    o.Duration = 2;
    o.LowFreq = 250;
    o.HighFreq = 8000;
    o.AM=0;
    o.ModDepth=1;
    o.Count=15;
    o.NBCount=15;
    o.FirstSubsetIdx=[];
    o.SecondSubsetIdx=[];
    o.SecondRelAtten=0;
    o.TonesPerOctave=20;
    o.SimulCount=1;
    o.RefRepCount=1;
    o.LoBounds=[];
    o.HiBounds=[];
    
    % if single argument of class SoundObject, return it
    if nargin==1 && isstruct(varargin{1}),
       % if structure, use it to create object, then fill empty
       % fields with defaults
       parms = varargin{1};
       ff=fields(parms);
       for ii=1:length(ff),
          o.(ff{ii})=parms.(ff{ii});
       end
    end
    
    o = class(o,'AMNoise',s);
    o = ObjUpdate (o);
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