function o = ToneInRovingTorc (varargin)

% methods: set, get, waveform
%

% Nima Mesgarani, Oct 2005

switch nargin
    case 0
        % if no input arguments, create a default object
        s = SoundObject ('ToneInRovingTorc', 40000, 0, .4, .8, {}, 1, ...
            {'TorcRates','popupmenu','4:4:24|4:4:48|8:8:48|8:8:96',...
            'TorcFreqRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz',...
            'TorcDuration','edit',1.5,'ToneFreqs','edit',1000,'ToneStart','edit',0,...
            'ToneStop','edit',1.5,'SNR','edit',0});
        % generate the torc fields first::
        o.TorcDuration = 1.5;
        o.TorcFreqRange = 'H:250-8000';
        o.TorcRates = '4:4:48';
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
        o.ToneFreqs = 1000;
        o.ToneStart = 0;    %
        o.ToneStop  = 1.5;  %
        o.SNR = 0;
        o.ShamNorm = 0;
        o.Loudness= 0;
        o.BasedB= 70;
        o.BaseV=5;
        o = class(o,'ToneInRovingTorc',s);
        o = ObjUpdate (o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'ToneInRovingTorc')
            o = varargin{1};
        else
            error('Wrong argument type');
        end
        %%
    case 9
        % if no input arguments, create a default object
        s = SoundObject ('ToneInRovingTorc', varargin{1}, varargin{2}, varargin{3}, varargin{4}, {}, 1, ...
            {'TorcRates','popupmenu','4:4:24|4:4:48|8:8:48|8:8:96',...
            'TorcFreqRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz',...
            'TorcDuration','edit',varargin{5},'ToneFreqs','edit',varargin{6},'ToneStart','edit',varargin{7},...
            'ToneStop','edit',varargin{8},'SNR','edit',varargin{9}});
        % generate the torc fields first::
        o.TorcDuration = varargin{5};
        o.TorcFreqRange = 'H:250-8000';
        o.TorcRates = '4:4:48';
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
        o.ToneFreqs = varargin{6};
        o.ToneStart = varargin{7};    %
        o.ToneStop  = varargin{8};  %
        o.SNR = varargin{9};
        o.ShamNorm = 0;
        o.Loudness= varargin{2};
        o = class(o,'ToneInRovingTorc',s);
        o = ObjUpdate (o);

    otherwise
        error('Wrong number of input arguments');
end