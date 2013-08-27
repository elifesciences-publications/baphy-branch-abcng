function o = LightEnvelope(varargin)
% LightEnvelope is the constructor for the object LightEnvelope which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Frequencies", "Duration"
%
% usage:
% To creates a LightEnvelope with default values.
%   t = LightEnvelope;
%
% To create a LightEnvelope with specified values:
%   t = LightEnvelope (Loudness, PreStimSilence, PostStimSilence,
%       frequencies, Duration);
%
% To get the waveform and events:
%   [w, events] = waveform(t);  
%
% methods: set, get, waveform, ObjUpdate


% SVD created 2007-03-30, based on Tone object.

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('LightEnvelope', 40000, 0, 0, 0, ...
        {''}, 1, {'Duration','edit',1,...
        'ModLow','edit',2,...
        'ModHigh','edit',20,...
        'ModDepth','edit',1,...
        'LightAmp','edit',[],...
        'LowFreq','edit',250,...       
        'HighFreq','edit',8000,...       
        'NoiseCount','edit',1,...
        'TonesPerBurst','edit',20,...
        'Bandwidth','edit',1,...
        'SimulCount','edit',1,...
        'RefRepCount','edit',1,...
        'SamplingRate','edit',40000});
    
    o.Duration = 1;
    o.ModLow = 2;
    o.ModHigh = 20;
    o.ModDepth = 1;
    o.LightAmp=[0 5];
    o.LowFreq = 250;
    o.HighFreq = 8000;
    o.NoiseCount=1;
    o.TonesPerBurst=20;
    o.Bandwidth=1;
    o.SimulCount=1;
    o.RefRepCount = 5;
    o.Frequencies=[];

    o = class(o,'LightEnvelope',s);
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