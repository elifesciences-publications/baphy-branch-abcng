function o = ComplexChord(varargin)
% ComplexChord is the constructor for the object ComplexChord which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Frequencies", "Duration"
%
% usage:
% To creates a ComplexChord with default values.
%   t = ComplexChord;
%
% To create a ComplexChord with specified values:
%   t = ComplexChord (Loudness, PreStimSilence, PostStimSilence,
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
    s = SoundObject ('ComplexChord', 40000, 0, 0, 0, ...
        {''}, 1, {'Duration','edit',1,...
        'Frequencies','edit',1000,...
        'AM','edit',0,...
        'FM','edit',0,...
        'ModDepth','edit',1,...
        'FirstToneSubset','edit',[],...
        'SecondToneSubset','edit',[],...
        'ThirdToneSubset','edit',[],...
        'LightSubset','edit',[],...
        'LightPhase','edit',[],...
        'ForcePaired','popupmenu','No|Yes',...
        'FirstToneAtten','edit',0,...
        'SecondToneAtten','edit',-1,...
        'ThirdToneAtten','edit',-1,...
        'RefRepCount','edit',1,...
        'SamplingRate','edit',40000});
    
    o.Duration = 1;
    o.Frequencies = 1000;
    o.AM = 0;
    o.FM = 0;
    o.ModDepth = 1;
    o.FirstToneSubset = [];
    o.SecondToneSubset = [];
    o.ThirdToneSubset = [];
    o.FirstToneAtten = 10;
    o.SecondToneAtten = -1;
    o.ThirdToneAtten = -1;
    o.LightSubset = [];
    o.LightPhase = 0;
    o.ForcePaired = 'No';
    o.RefRepCount = 1;
    o.ToneIdxSet=1;
    o.LightIdxSet=1;
    o.LightPhaseSet=0;
    o.OverrideAutoScale=1;
    o = class(o,'ComplexChord',s);
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