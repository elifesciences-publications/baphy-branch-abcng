function o = SpNoiseMulti(varargin)
% SpNoise is based on the Speech object, but the carrier is band-pass noise
% (like BNB).
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
    s = SoundObject ('SpNoiseMulti', 100000, 0, 0, 0, {}, 1, ...
                     {'LowFreq','edit',1000,...
                      'HighFreq','edit',2000,...
                      'BandCount','edit',1,...
                      'BaseSound','popupmenu','Speech|FerretVocal',...
                      'Subsets','edit',1,...
                      'TonesPerOctave','edit',0,...
                      'UseBPNoise','edit',1,...
                      'ShuffleOnset','edit',1,...
                      'SetSizeMult','edit',2,...
                      'StreamCount','edit',2,...
                      'CoherentFrac','edit',0.1,...
                      'BaselineFrac','edit',0,...
                      'RepIdx','edit',[0 1],...
                      'Duration','edit',3});
    o.LowFreq = 250;
    o.HighFreq = 8000;
    o.BandCount=15;
    o.StreamCount=2;
    o.RelAttenuatedB=0;
    o.SplitChannels='No';
    o.IterateStepMS = 0;  % if zero, don't iterate. no effect if TonesPerOctave>0
    o.IterationCount = 0;  % if zero, don't iterate. no effect if TonesPerOctave>0
    o.TonesPerOctave = 0;  % if zero, use BP noise
    o.BaseSound = 'Speech';
    o.TonesPerBurst=round(log2(o.HighFreq./o.LowFreq).*o.TonesPerOctave./o.BandCount);
    o.UseBPNoise=1;
    o.Subsets = 1;
    o.SNR = 1000;
    o.ShuffleOnset=0;  % if 1, randomly rotate stimulus waveforms in time
    o.SetSizeMult=1;  % for multi-channel stim, how many times larger should MaxIndex be than the original set
    o.CoherentFrac=0.1;  % for multi-channel stim, what fraction should be the same in all channels
    o.BaselineFrac=0;  % minimum sound level (as a fraction of peak)
    
    o.Phonemes = {struct('Note','','StartTime',0,'StopTime',0)};
    %o.Words= {struct('Note','','StartTime',0,'StopTime',0)};    
    %o.Sentences = {''};
    o.emtx=[];
    o.idxset=[];
    o.streamset=[];
    o.ShuffledOnsetTimes=[];
    o.SamplingRateEnv=2000;
    o.Duration = 3;
    o.SamplingRate=100000;
    o.RepIdx=[0 1];
    %
    o = class(o,'SpNoiseMulti',s);
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