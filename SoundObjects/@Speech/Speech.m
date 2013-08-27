function o = Speech(varargin)
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
    s = SoundObject ('Speech', 40000, 0, 0, 0, {}, 1, ...
                {'Subsets','edit',1,'SNR','edit',1000,...
                 'NoiseType','popupmenu',...
                 'None|White|Pink|Jet2|F16|MachineGun|City|SpectSmooth',...
                 'ReverbTime','edit',0,...
                 'Duration','edit',3});
    o.Subsets = 1;
    o.SNR = 1000;
    o.NoiseType = 'White';
    o.ReverbTime = 0;
    o.Phonemes = {struct('Note','','StartTime',0,'StopTime',0)};
    o.Words= {struct('Note','','StartTime',0,'StopTime',0)};    
    o.Sentences = {''};
    o.Duration = 3;
    o = class(o,'Speech',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'Speech')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 7
    s = SoundObject('Speech', ...
        varargin{1}, ...    % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',...              % Names
        1,{'Subsets','edit',1,'SNR','edit',1000,'Duration','edit',3});
    o.Subsets   = varargin{5};
    o.SNR       = varargin{6};
    o.Duration  = varargin{7};
    o.Phonemes = {struct('Note','','StartTime',0,'StopTime',0)};
    o.Words= {struct('Note','','StartTime',0,'StopTime',0)};    
    o.Sentences = {''};
    o = class(o,'Speech',s);
    o = ObjUpdate (o);

    %%
otherwise
    error('Wrong number of input arguments');
end