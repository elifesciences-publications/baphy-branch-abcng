function o = TorcToneDiscrim (varargin)

% methods: set, get, waveform
% 

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('TorcToneDiscrim', 100000, 0, 0.4, 0.8, {}, 1, ...
        {'TorcRates','popupmenu','4:4:24|4:4:48|8:8:48|8:8:96',...
        'TorcFreqRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz',...
        'TorcDuration','edit',3,'ToneFreqs','edit',1000,'ToneDuration','edit',1,...
        'TorcToneGap','edit',0,'ToneGap','edit',0,'TorcToneDB','edit',0,...
        'RandomInterval','popupmenu','yes|no'});
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
    o.CurrentToneFreq = 1000;
    o.ToneFreqs = 1000;
    o.ToneDuration = 1.5;  %
    %
    o.TorcToneGap = 0;
    o.ToneGap=0;
    o.TorcToneDB = 0;
    o.RandomInterval = 'no';
    o.InterToneSilenceList = 1:3;
    o = class(o,'TorcToneDiscrim',s);
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