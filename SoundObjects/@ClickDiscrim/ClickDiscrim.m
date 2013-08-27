function o = ClickDiscrim (varargin)

% methods: set, get, waveform
% 

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('ClickDiscrim', 40000, 0, 0, 0, {}, 1, ...
        {'TorcRates','popupmenu','4:4:24|4:4:48|8:8:48|8:8:96',...
        'TorcFreqRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz',...
        'TorcDuration','edit',3,'ClickRate','edit',9,'ClickDuration','edit',1,'ClickWidth','edit',.001,...
        'TorcClickGap','edit',0});
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
    
    o.ClickWidth = 0.001;
    o.ClickRate = 10;
    o.ClickDuration = 1;  %
    %
    o.TorcClickGap = 0;
    o = class(o,'ClickDiscrim',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'ClickDiscrim')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
    %%
otherwise
    error('Wrong number of input arguments');
end