function O = RefTarMC(varargin)
% RefTarMC Creates a reference-target base class. All the experiments in this
% paradigm inherit from this class (including passive experiments). 
% The properties of referenceTarget objects are:
%   descriptor: The name of experiment
%   ReferenceClass: Class(es) of reference
%   TargetClass: Class(es) of Target
%   NumberOfTrials : number of trials in each experiment
%   NumberOfReferencesPerTrial : numberf of of references in each trial.
%   NumberOfTargetsPerTrial : number of targets in each trial. Set to zero for
%       passive
%   ReferenceMaxIndex: maximum possible index for reference object. 
%   TargetMaxIndex: maximum possible index for target object.
%   ReferenceIndex: is an array of arrays. ReferenceIndex is a one-by-NumberOfTrials array, 
%       with each element being an array of
%       one-by-NumberOfReferencesPerTrial indication the index of
%       References in that trial
%   TargetIndex: is an array of arrays. TargetIndex is a
%       one-by-NumberOfTrials array, whit each element being an array of
%       one-by-NumberOfTargetsPerTrial indicating the index of Targets in that
%       trial
%   ReferenceMaxIndex: maximum index for reference
%   TargetMaxIndex: maximum index for targets
%   ShamPercentage: percentage of sham trials
%   OnsetGap: is the gap before individual sounds(objects) in the trial
%   DelayGap: is the gap after individual sounds(objects) in the trial
%
% Methods of RefTarMC objects are:
%   Randomize
%   waveform
%
% BE, 2010/7

switch nargin
case 0
    % if no input arguments, create a default object
    O.descriptor = 'none';
    O.ReferenceClass = 'none';
    O.ReferenceHandle = [];
    O.TargetClass = 'none';
    O.TargetHandle = [];
    O.SamplingRate = 40000;
    O.OveralldB = 65;
    O.RelativeTarRefdB = 0;
    O.NumberOfTrials = 30;  % In memory of Torcs!
    O.NumberOfRefDistrib = NaN; 
    O.ReferenceMaxIndex = 0;
    O.TargetMaxIndex = 0;
    O.ReferenceIndices = '[]'; 
    O.TargetIndices = '[]';
    O.TrialTags = '[]';
    O.ShamPercentage = 0;
    O.RunClass = '[]';
    O.UserDefinableFields = {...
      'OveralldB','edit',O.OveralldB,...
      'RelativeTarRefdB','edit',O.RelativeTarRefdB,...
      'NumberOfRefDistrib','edit',O.NumberOfRefDistrib};
    O = class(O,'RefTarMC');
    O = ObjUpdate(O);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'RefTarMC') O = varargin{1};
    else        error('Wrong argument type');
    end
otherwise 
    error('Wrong number of input arguments');
end
