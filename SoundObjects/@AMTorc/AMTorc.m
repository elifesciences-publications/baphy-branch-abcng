function o = AMTorc (varargin)

% methods: set, get, waveform
% 

% Yao Li, July 2006

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('AMTorc', 40000, 0, 0.4, 0.8, {}, 1, ...
        {'TorcRates','popupmenu','4:4:24|4:4:48|8:8:48|8:8:96',...
        'TorcFreqRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz',...
        'TorcDuration','edit',3,...    %Torc
        'BaseFundamental','edit',1000,...
        'OctaveBelow','edit',2,...
        'OctaveAbove','edit',3,...
        'TonesPerOctave','edit',6,...
        'NumOfHarmonics','edit',0,...
        'ToneDuration','edit',1,...    %Random Tone
        'AMFreq','edit',40,...
        'AMDepth','edit',1,... %AM infor 
        'TorcToneGap','edit',0});
     
    
    % generate the torc fields first::
    o.TorcDuration = 3;
    o.TorcFreqRange = 'L:125-4000';
    o.TorcRates = '4:4:24';
    o.Params.RipplePeak = 90;
    o.Params.LowestFrequency = 125;
    o.Params.HighestFrequency = 4000;
    o.Params.NumberOfComponents = 500;
    o.Params.HarmonicallySpaced = 0;
    o.Params.SpectralPowerDecay = 0;
    o.Params.ComponentRandomPhase = 1;
    o.Params.TimeDuration = 3;
    o.Params.RippleAmplitude = {1 1 1 1 1 1};
    o.Params.Scales = {1.4 1.4 1.4 1.4 1.4 1.4};
    o.Params.Rates = {8:8:48};
    o.Params.Phase = {0 0 0 0 0 0};
    
    % now tone properties:
         
    o.BaseFundamental = 1000;
    o.OctaveBelow = 2;
    o.OctaveAbove = 3;
    o.TonesPerOctave = 6;
    o.NumOfHarmonics = 0;
    o.ToneDuration = 1;  
    
    o.AMFreq = 40;  % Amplitude Modulation frquency
    o.AMDepth = 0.5;  % Amplitude modulation depth
    
    o.TorcToneGap = 0;
    o = class(o,'AMTorc',s);
    o = ObjUpdate (o);
    
    
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'TorcToneDiscrim')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
    %%
otherwise
    error('Wrong number of input arguments');
end