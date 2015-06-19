function o = Torc(varargin)
% Torc is the constructor for the object Torc which is a child of  
%       SoundObject class
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Duration", "FrequencyRange", "Rates", 
%       "Params"
% usage:
%   t = Torc;     creates an instance of class torc with default values.
%   t = Torc (Loudness, PreStimSilence, PostStimSilence,
%       Duration, FrequencyRange, Rates);
%  
% methods: set, get, waveform, ObjUpdate

% Nima Mesgarani, Nov 2005

switch nargin
    case 0
        % if no input arguments, create a default object
        % First create an instance of SoundObject with appropriate fields:
        s = SoundObject ('Torc', 100000, 0, 0.4, 0.8, {}, 1, {'Rates','popupmenu','1:1:8|4:4:24|4:4:48|8:8:48|8:8:96',...
            'FrequencyRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz|U:1000-32000 Hz|W:2000-64000 Hz|Y:1000-32000 Hz|Z:150-38400 Hz','Duration','edit',3});
        o.Duration = 3;
        o.FrequencyRange = 'L:125-4000 Hz';
        o.Rates = '4:4:48';
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
        %
        o = class(o,'Torc',s);
        o = ObjUpdate (o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'Torc')
            o = varargin{1};
        else
            error('Wrong argument type');
        end
    case 7
        s = SoundObject('Torc', ...
            varargin{1}, ...          % SamplingFrequency
            varargin{2}, ...    % Loudness
            varargin{3}, ...    % PreStimSilence
            varargin{4},...     % PostStimSilence
            '',...              % Names
            1,{'Rates','popupmenu','1:1:8|4:4:24|4:4:48|8:8:48|8:8:96',...    % MaxIndex, UserDefinableFields
            'FrequencyRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz|U:1000-32000 Hz|W:2000-64000 Hz|Y:1000-32000 Hz|Z:150-38400 Hz','Duration','edit',3});
        o.Duration = varargin{5};
        o.FrequencyRange = varargin{6};
        o.Rates = varargin{7};
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
        o = class(o,'Torc',s);
        o = ObjUpdate(o);
    otherwise
        error('Wrong number of input arguments');
end