function o = Sporc(varargin)
% Speech is a child of SoundObject class. It manages all the necessary
% routines for object speech.
%
% properties:
%   PreStimSilcence
%   PostStimSilence
%   SamplingRate
%   Loudness
%   Subsets: can be 1, 2, 3 or 4. each contains 30 different sentences from
%       Timit database. each subset is 30 sentences spoken by 30 different
%       speakers (15 male 15 female). sentences in subset 1 and 4 are three
%       seconds long, subset 2 and 3 are four seconds. Subset 4 is all the
%       same sentence: "She had your dark suit in greasy wash water all
%       year"
%   Phonemes: contains the phoneme events for the specified names.
%   Words: contains the word events for the specified names.
%   Sentences: contains the sentece events for the specified names.
% 
% methods: waveform, LabelAxis, set, get
% 

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('Sporc', 16000, 0, 0, 0, {}, 1, ...
                     {'Rates','popupmenu','4:4:24|4:4:48|8:8:48|8:8:96',...
                      'FrequencyRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz',...
                      'Subsets','edit',1,'SNR','edit',1000,'Duration','edit',3});
    o.Subsets = 1;
    o.SNR = 1000;
    o.Phonemes = {struct('Note','','StartTime',0,'StopTime',0)};
    o.Words= {struct('Note','','StartTime',0,'StopTime',0)};    
    o.Sentences = {''};
    o.FrequencyRange = 'L:125-4000 Hz';
    o.Rates = '4:4:24';
    o.Duration = 3;
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
    
    o.speechobj=Speech;
    o.torcobj=Torc;
    %
    o = class(o,'Sporc',s);
    o = ObjUpdate(o);
    
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'Sporc')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
    
case 7
    error('SpeechPhoneme format not supported for this object');
    
otherwise
    error('Wrong number of input arguments');
end