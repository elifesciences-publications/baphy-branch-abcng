function o = SpeechPhoneme (varargin)

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    o.descriptor = 'SpeechPhoneme';
    o.ReferenceClass = 'none';
    o.ReferenceHandle = [];
    o.TargetClass = 'none';
    o.TargetHandle = [];
    o.SamplingRate = 40000;
    o.OveralldB = 65;
    o.RelativeRefTardB = 0;
    o.NumberOfTrials = 30;  % In memory of Torcs!
    o.ReferenceMaxIndex = 0;
    o.TargetMaxIndex = 0;
    o.ReferenceIndices = '[]'; 
    o.TargetIndices = '[]';
    o.AdaptiveLearning = 'No';
    o.TrialBlockName = [];
    o.Comment = [];
    o.NumOfEvPerStim = 3;
    o.MaxNumberOfRef = 2; % temporarily feature use in positive reinforcement
    o.TrainingMode = 'Negative';
    o.SNRs = 100;
    o.TrialSNRs = '[]';
    o.RunClass = '[]';
    o.UserDefinableFields = {'OveralldB','edit',65,'RelativeRefTardB',...
        'edit',0,'AdaptiveLearning','popupmenu','No|Yes|Random','TrainingMode',...
        'popupmenu','Negative|Positive','MaxNumberOfRef','edit',2,'SNRs','edit',100};
    o = class(o,'SpeechPhoneme');
    o = ObjUpdate(o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SpeechPhoneme')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise 
    error('Wrong number of input arguments');
end
