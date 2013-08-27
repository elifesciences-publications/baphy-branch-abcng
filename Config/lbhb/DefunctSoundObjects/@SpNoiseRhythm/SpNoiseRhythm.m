function o = SpNoiseRhythm(varargin)
% SpNoiseRhythm is concatenation of SpNoise and Rhythm
%
% 
% methods: waveform, set, get
% 

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('SpNoiseRhythm', 16000, 0, 0, 0, {}, 1, ...
                     {'LowFreq','edit',1000,...
                      'HighFreq','edit',2000,...
                      'TonesPerOctave','edit',50,...
                      'BaseSound','popupmenu','Speech|FerretVocal',...
                      'Subsets','edit',1,...
                      'SpAtten','edit',0,...
                      'SpDuration','edit',3,...
                      'Count','edit',5,...
                      'ICI','edit',0.2,...
                      'Level','edit',1,...
                      'ClickWidth','edit',0.001,...
                      'RhDuration','edit',3,...
                     });
    % properties from SpNoise
    o.LowFreq = 250;
    o.HighFreq = 8000;
    o.TonesPerOctave = 50;
    o.SpAtten = 0;
    o.BaseSound = 'Speech';
    o.TonesPerBurst=round(log2(o.HighFreq./o.LowFreq).*o.TonesPerOctave);
    o.Subsets = 1;
    o.SNR = 1000;
    o.Phonemes = {struct('Note','','StartTime',0,'StopTime',0)};
    o.emtx=[];
    o.SamplingRateEnv=2000;
    o.SpDuration = 1;
    
    % Properties from Rhythm
    o.ClickWidth = .001;
    o.Count = 5;
    o.ICI = 0.2;
    o.Level = 1;
    o.RhDuration = 1;
    
    o.Duration = o.SpDuration + o.RhDuration;
    
    o.spnoiseobj=SpNoise;
    o.rhythmobj=Rhythm;
    
    o = class(o,'SpNoiseRhythm',s);
    o = ObjUpdate(o);
    
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SpNoise')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
    
case 7
    error('SpeechPhoneme format not supported for this object');
    
otherwise
    error('Wrong number of input arguments');
end