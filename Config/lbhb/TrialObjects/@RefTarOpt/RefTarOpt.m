function RefTarO = RefTarOpt(varargin)
% RefTarOpt -Trial object for simultaneous sound and optical (visual
% and/or optogenetic) stimulation.  Uses an analog out channel to
% send the light control signals synchronized with the sound.
%
% created SVD 2014-05, ripped off of ReferenceTarget
%

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
    
    RefTarO.LightPulseRate=50;
    RefTarO.LightPulseDuration=0.01;
    RefTarO.LightPulseShift=0;
    RefTarO.LightEpoch='Sound';
    
    RefTarO.NumberOfTrials = 30;  % In memory of Torcs!
    RefTarO.NumberOfRefPerTrial = []; 
    RefTarO.NumberOfTarPerTrial = 1; % default 
    RefTarO.ReferenceMaxIndex = 0;
    RefTarO.TargetMaxIndex = 0;
    RefTarO.ReferenceIndices = '[]'; 
    RefTarO.TargetIndices = '[]';
    RefTarO.ShamPercentage = 0;
    RefTarO.LightTrial=[];
    
    % old (unused)
    RefTarO.NoPreStimForFirstRef = 0; % if 1, the first reference will not 
        %have a prestim silence. Good for extended shock for example. 
    RefTarO.NumOfEvPerStim = 3;  % how many stim each event produces??
    % having the two following fields is enough, we actually do not need
    % NumOfEvPerStim anymore, but for backward compatibility we keep it!
    RefTarO.NumOfEvPerRef = 3;  % how many stim each reference produces??
    RefTarO.NumOfEvPerTar = 3;  % how many stim each Target produces??
    RefTarO.RunClass = '[]';
    RefTarO.UserDefinableFields = ...
        {'OveralldB','edit',65,...
         'RelativeTarRefdB','edit',0,...
         'LightPulseRate','edit',50,...
         'LightPulseDuration','edit',0.01,...
         'LightPulseShift','edit',0,...
         'LightEpoch','popupmenu','Sound|Sound Onset|Whole Trial'};
    
    RefTarO = class(RefTarO,'RefTarOpt');
    RefTarO = ObjUpdate(RefTarO);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'RefTarOpt')
        RefTarO = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise 
    error('Wrong number of input arguments');
end
