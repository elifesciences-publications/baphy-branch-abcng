function o = MultiSound (varargin)

% methods: set, get, waveform
% This object is meant to be a collection of different sound objects. Each
% time its called, it randomly choose from a set of targets:
% random tones, tones, tone-in-noise, chords, clicks, FM sweeps
% the way its implemented is: 


% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('MultiSound', 40000, 0, .4, .8, {}, 1, ...
        {'Duration','edit',1.5,'IncTone','checkbox',0,'TFreqs','edit',0,'IncToneInTorc','checkbox',0,...
        'TNTFreqs','edit',1000,'TNTSNR','edit',0,'IncMultipleTones','checkbox',0,...
        'MTFreqs','edit',0,'IncRandomTone','checkbox',0,'RTBaseFreq','edit',1000,'RTOctaveBelow','edit',2,...
        'RTOctaveAbove','edit',3,'RTTonesPerOctave','edit',5,'IncClick','checkbox',0,'ClickRate','edit',10,...
        'IncFMSweep','checkbox',0,'FMStartFreq','edit',1000,'FMEndFreq','edit',2000});
    % common field 
    o.Duration = 1.5;
    % Define tone object fields:
    o.IncTone = 0;
    o.TFreqs = 1000;    
    % Define tone in torc object fields:
    o.IncToneInTorc = 0;
    o.TNTFreqs = 1000;    
    o.TNTSNR = 0;
    % Define multitone object fields:
    o.IncMultipleTones = 0;
    o.MTFreqs = 1000;
    % define random tone object fields:
    o.IncRandomTone = 0;
    o.RTBaseFreq = 1000;
    o.RTOctaveBelow = 2;
    o.RTOctaveAbove = 3;
    o.RTTonesPerOctave = 5;    
    % define click object fields:
    o.IncClick = 0;
    o.ClickRate = 10;
    % define FM sweep object fields:
    o.IncFMSweep = 0;
    o.FMStartFreq = 1000;
    o.FMEndFreq = 2000;
    % none user-definable fields:
    o.TargetObjects = 0;
    o = class(o,'MultiSOund',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'MultiSound')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
    %%
otherwise
    error('Wrong number of input arguments');
end