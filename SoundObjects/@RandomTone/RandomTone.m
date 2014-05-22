function o = RandomTone (varargin)

% methods: set, get, waveform
%   
% usage: 

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('RandomTone', 40000, 0,0, 0, ...
        {''}, 1, {'BaseFrequency','edit',1000,'OctaveBelow','edit',2,...
        'OctaveAbove','edit',3,'TonesPerOctave','edit',5,...
        'Duration','edit',1000,'SamplingRate','edit',40000,...
        'GapDuration','edit',.1,'NumberOfTones','edit',3,...
        'RefRepCount','edit',1});
    o.BaseFrequency = 1000;
    o.OctaveBelow = 2;
    o.OctaveAbove = 3;
    o.TonesPerOctave = 5;
    o.Duration = 1;  %ms
    o.GapDuration = 0.1;
    o.NumberOfTones = 1;
    o.NumOfEvPerTar = 3;
    o.RefRepCount=1;
    o = class(o,'RandomTone',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 9
    s = SoundObject ('RandomTone', varargin{1}, varargin{2},varargin{3}, varargin{4}, ...
        {''}, 1, {'BaseFrequency','edit',varargin{5},'OctaveBelow','edit',varargin{6},...
        'OctaveAbove','edit',varargin{7},'TonesPerOctave','edit',varargin{8},...
        'Duration','edit',varargin{9},'SamplingRate','edit',varargin{1}});
    o.BaseFrequency = varargin{5};
    o.OctaveBelow = varargin{6};
    o.OctaveAbove = varargin{7};
    o.TonesPerOctave = varargin{8};
    o.Duration = varargin{9};  %ms
    o = class(o,'RandomTone',s);
    o = ObjUpdate (o);        
otherwise
    error('Wrong number of input arguments');
end