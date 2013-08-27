function o = MultiRangeTask (varargin)

% methods: set, get, waveform
%   
% usage: 

% pingbo yin, July 2007

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('MultiRangeTask', 40000, 0,0, 0, ...
        {''}, 1, {'NumFreqRange','edit',3,'LowFrequency','edit',359,...
        'PctSeparation','edit',3,'Duration','edit',0.4,'TarRange','edit',2,...
        'ToneNumber','edit',27,'Type','popupmenu','Tone|aMtone|aMtOne2|AmTOne2a|AMtoNe2c|Gaptone|Click|Harm|Mistuned','BackgroundNoise','edit',0});
    o.NumFreqRange = 3;
    o.LowFrequency = 359;  %2nd element for AM mudulation depth (in percent) for tone/WN (if 1st is 0) as the carrier 
    o.PctSeparation = 6;    
    o.Duration = 0.4;  %sec, 2nd element are gap duration inserted into tone at 100 ms. 
    o.TarRange=2;    %2nd range as target
    o.ToneNumber = 27;
    o.Type='Tone';
    o.BackgroundNoise=-80;   %dB attenuation
    o = class(o,'MultiRangeTask',s);
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