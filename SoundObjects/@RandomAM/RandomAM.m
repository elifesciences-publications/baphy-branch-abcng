function o = RandomAM (varargin)

% methods: set, get, waveform
%   
% usage: 

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('RandomAM', 40000, 0,0.4, 0.8, ...
        {''}, 1, {'BaseFundamental','edit',1000,...
        'OctaveBelow','edit',2,...
        'OctaveAbove','edit',3,...
        'TonesPerOctave','edit',5,...
        'Duration','edit',1,...
        'AMFreq','edit',40,...
        'AMDepth','edit',1,...
        'NumOfHarmonics','edit',0,...
        'SamplingRate','edit',100000}); % is the harmonic really necessary
    
    
    o.BaseFundamental = 1000;
    o.OctaveBelow = 2;
    o.OctaveAbove = 3;
    o.TonesPerOctave = 6;
    o.Duration = 1;  %ms
    o.AMFreq = 40;  % Amplitude Modulation frequency
    o.AMDepth = 0.5;  % Amplitude Modulation depth
    o.NumOfHarmonics = 0;
    o = class(o,'RandomAM',s);
    o = ObjUpdate (o);
    
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
    
 case 8
    s = SoundObject ('RandomAM', 40000, 0,... 
        varargin{1}, ... % PreStimSilence
        varargin{2}, ... % PostStimSilence
        {''},...
        1,...
        {'BaseFundamental','edit',1000,...
        'OctaveBelow','edit',2,...
        'OctaveAbove','edit',3,...
        'TonesPerOctave','edit',5,...
        'Duration','edit',1,...
        'AMFreq','edit',40,...
        'AMDepth','edit',1,...
        'NumOfHarmonics','edit',0}); % is the harmonic really necessary
    
    
    o.BaseFundamental = varargin{3}; % fundamental
    o.OctaveBelow = 2;
    o.OctaveAbove = 3;
    o.TonesPerOctave = varargin{4}; % num of tones
    o.Duration = varargin{5};  % duration
    o.AMFreq = varargin{6};   % Amplitude Modulation frquency
    o.AMDepth = varargin{7}; % Amplitude modulation depth
    o.NumOfHarmonics = varargin{8}; % num of harmonic
    o = class(o,'RandomAM',s);
    o = ObjUpdate (o);
        
    otherwise
    error('Wrong number of input arguments');
end