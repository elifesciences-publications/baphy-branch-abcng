function o = AMTone(varargin)
% AMTone is the constructor for the object AMTone which is a child of  
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
    
    s = SoundObject ('AMTone', 100000, 0, 0, 0, ...
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
                  'RefRepCount','edit',1,...
                  'LightStimPerRep','edit',0,...
                  'SilentStimPerRep','edit',0});
    
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
    o.LightStimPerRep=0;
    o.SilentStimPerRep=0;
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
    
    o = class(o,'AMTone',s);
    o = ObjUpdate (o);
        
otherwise
    error('Wrong number of input arguments');
end