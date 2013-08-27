function RefTarO = StreamNoise(varargin)
% Stream noise.  Specialize TrialObject for StreamNoise experiment with
% Josh McDermott. Designed specifically to be used with NoiseSample
% SoundObject, but maybe could generalize?
%
switch nargin
case 0
    % if no input arguments, create a default object
    RefTarO.descriptor = 'StreamNoise';
    RefTarO.ReferenceClass = 'none';
    RefTarO.ReferenceHandle = [];
    RefTarO.TargetClass = 'none';
    RefTarO.TargetHandle = [];
    RefTarO.SamplingRate = 100000;
    RefTarO.OveralldB = 65;
    % In memory of Torcs! but gets reset, actually by RandomizeSequence
    RefTarO.NumberOfTrials = 30;  
    %RefTarO.NumberOfRefPerTrial = []; 
    %RefTarO.NumberOfTarPerTrial = 1; % default 
    RefTarO.ReferenceMaxIndex = 0;
    RefTarO.TargetMaxIndex = 0;
    %RefTarO.ReferenceIndices = '[]'; 
    %RefTarO.TargetIndices = '[]';
    
    RefTarO.PreTrialSilence=0.5;
    RefTarO.PostTrialSilence=0.5;
    RefTarO.TargetCount=2;
    RefTarO.DistracterCount=5;
    RefTarO.TarNestedReps=5;
    RefTarO.SamplesPerTrial=10;
    RefTarO.Sequences={};
    RefTarO.SequenceCategories=[];
    RefTarO.SequenceIdx=[];
    RefTarO.ThisRepIdx=[];
    
    %RefTarO.NumOfEvPerStim = 3;  % how many stim each event produces??
    % having the two following fields is enough, we actually do not need
    % NumOfEvPerStim anymore, but for backward compatibility we keep it!
    RefTarO.NumOfEvPerRef = 3;  % how many stim each reference produces??
    RefTarO.NumOfEvPerTar = 3;  % how many stim each Target produces??
    RefTarO.RunClass = '[]';
    RefTarO.UserDefinableFields = ...
        {'OveralldB','edit',65,...
         'PreTrialSilence','edit',0.5,...
         'PostTrialSilence','edit',0.5,...
         'TargetCount','edit',2,...
         'TarNestedReps','edit',5,...
         'SamplesPerTrial','edit',10,...
         };
    
    RefTarO = class(RefTarO,'StreamNoise');
    RefTarO = ObjUpdate(RefTarO);

otherwise 
    error('Wrong number of input arguments');
end
