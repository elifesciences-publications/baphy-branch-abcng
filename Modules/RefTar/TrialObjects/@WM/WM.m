function RefTarO = WM(varargin)
% ReferenceTarget Creates a reference-target base class. All the experiments in this
% paradigm inherit from this class (including passive experiments). 
% The properties of referenceTarget objects are:
%   descriptor: The name of experiment
%   ReferenceClass: Class(es) of reference
%   TargetClass: Class(es) of Target
%   NumberOfTrials : number of trials in each experiment
%   NumberOfReferencesPerTrial : numberf of of references in each trial.
%   NumberOfTargetsPerTrial : number of targets in each trial. Set to zero for
%       passive
%   RefereneMaxIndex: maximum possible index for reference object. 
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
% Methods of referenceTarget objects are:
%   generateRandomIndex

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    RefTarO.descriptor = 'none';
    RefTarO.ReferenceClass = 'none';
    RefTarO.ReferenceHandle = [];
    RefTarO.TargetClass = 'none';
    RefTarO.TargetHandle = [];
    RefTarO.SamplingRate = 40000;
    RefTarO.OveralldB = 65;
    RefTarO.RelativeTarRefdB = 0;
    RefTarO.RefTarFlipFreq = 0;  % fraction of trials in which reference and target classes are reversed
    RefTarO.ReferenceCountFreq=[0.5 0.5];
    RefTarO.RefIdx=[];
    RefTarO.TarIdx=[];
    RefTarO.PostTrialSilence=0;
    RefTarO.PumpProfile=0;   %control the speed of MASTERFLEX. 1-3 elements
                             %element1-0 not used, 
                      %element1-1 high flow rate during, and low rate intertrial
    
    RefTarO.NumberOfTrials = 30;  % In memory of Torcs!
    RefTarO.NumberOfRefPerTrial = []; 
    RefTarO.NumberOfTarPerTrial = 1; % default 
    RefTarO.ReferenceMaxIndex = 0;
    RefTarO.TargetMaxIndex = 0;
    RefTarO.ReferenceIndices = '[]';
    RefTarO.TargetIndices = '[]';
    RefTarO.FlipFlag=[];
    RefTarO.ShamPercentage = 0;
    
    RefTarO.NumOfEvPerStim = 3;  % how many stim each event produces??
    % having the two following fields is enough, we actually do not need
    % NumOfEvPerStim anymore, but for backward compatibility we keep it!
    RefTarO.NumOfEvPerRef = 3;  % how many stim each reference produces??
    RefTarO.NumOfEvPerTar = 3;  % how many stim each Target produces??
    RefTarO.RunClass = '[]';
    RefTarO.UserDefinableFields = ...
        {'OveralldB','edit',65,...
         'RelativeTarRefdB','edit',0,...
         'RefTarFlipFreq','edit',0,...
         'ReferenceCountFreq','edit',[0.5 0.5],...
         'RefIdx','edit',[],...
         'TarIdx','edit',[],...
         'PostTrialSilence','edit',0,...
         'PumpProfile','edit',[],...
        };
    RefTarO = class(RefTarO,'WM');
    RefTarO = ObjUpdate(RefTarO);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'ReferenceTarget')
        RefTarO = varargin{1};
    else
        error('Wrong argument type');
    end
case 14
    RefTarO.descriptor = varargin{1};
    RefTarO.ReferenceClass = varargin{2};
    RefTarO.TargetClass = varargin{3};
    RefTarO.NumberOfTrials = varargin{4};  % In memory of Torcs!
    RefTarO.NumberOfRefPerTrial = varargin{5}; 
    RefTarO.NumberOfTarTrial = varargin{6}; % default is passive
    RefTarO.ReferenceMaxIndex = varargin{7};
    RefTarO.TargetMaxIndex = varargin{8};
    RefTarO.ReferenceIndices = varargin{9}; 
    RefTarO.TargetIndices = varargin{10};
    RefTarO.ShamPercentage = varargin{11};
    RefTarO.OnsetGap = varargin{12}; 
    RefTarO.DelayGap = varargin{13}; 
    RefTarO.UserDefinableFields = varargin{14};
    RefTarO = class(RefTarO,'RefTarLight');
    RefTarO = ObjUpdate(RefTarO);
otherwise 
    error('Wrong number of input arguments');
end
