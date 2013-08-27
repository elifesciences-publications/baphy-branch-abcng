function o = TorcGap(varargin)

% Nima Mesgarani, Nov 2005

switch nargin
    case 0
        % if no input arguments, create a default object
        s = SoundObject ('TorcGap', 40000, 0, 0, 0, {}, 1, ...
            {'Rates','popupmenu','4:4:24|4:4:48|8:8:48|8:8:96',...
            'FreqRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz',...
            'Duration','edit',1.5,'GapDuration','edit',.2,'GapStartTime','edit',.75});
        % generate the torc fields first::
        o.Duration = 3;
        o.FreqRange = 'L:125-4000';
        o.Rates = '4:4:24';
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
        o.GapDuration = .2;
        o.GapStartTime = 0.75;
        %
        o = class(o,'TorcGap',s);
        o = ObjUpdate (o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'TorcGap')
            o = varargin{1};
        else
            error('Wrong argument type');
        end
    case 7
    otherwise
        error('Wrong number of input arguments');
end