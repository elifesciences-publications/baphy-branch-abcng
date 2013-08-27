function RefTarO = MultiRefTarStaircase(varargin)
% MultiRefTarStaircase --- branched (temporarily?) from MultiRefTar 
%
% User-editable fields:
% OveralldB - Max sound level of any stimulus (reference target)
% RelativeTarRefdB - If a list of numbers, relative dB sound level of each
%  target to reference. If only one value, all targets have same level.
% ReferenceCountFrequency - Probability distribution of trial lengths.
%  Units are either integer number of references (if SingleRefSegmentLen=0)
%  or reference steps (if SingleRefSegmentLen>0).
% OverlapRefTar
% TargetIdxFreq
% OnsetRampTime - Duration of target onset ramp in sec (to reduce pop-out)
% PostTrialSilence - Tack on this many sec of silence after target and
%  reference are complete.
% SaveData - If no, test stimuli without saving anything (for debugging!)
% TargetMatchContour - May not be working. Match envelope of target to
%  reference (if it does work, it will require SpNoise reference or any
%  sound object with an env() method)
%
% created SVD - 2012-10
%
switch nargin
case 0
    % if no input arguments, create a default object
    RefTarO.descriptor = 'MultiRefTarStaircase';
    RefTarO.ReferenceClass = 'none';
    RefTarO.ReferenceHandle = [];
    RefTarO.TargetClass = 'none';
    RefTarO.TargetHandle = [];
    RefTarO.SamplingRate = 100000;
    RefTarO.OveralldB = 60;
    RefTarO.RelativeTarRefdB = 0;
    RefTarO.UpdateSnrFrequency = 10;
    RefTarO.UpdateSnrHR = 0.5;
    RefTarO.UpdateSnrStep = 5;
    RefTarO.RefTarFlipFreq = 0;  % fraction of trials in which reference and target classes are reversed
    RefTarO.ReferenceCountFreq=[0 0.4 0.3 0.2 0.1 0];
    RefTarO.TargetIdxFreq=1;
    RefTarO.TargetChannel=1;
    RefTarO.CueTrialCount=5;
    RefTarO.SingleRefSegmentLen = 0;
    RefTarO.RefIdx=[];
    RefTarO.TarIdx=[];
    RefTarO.TarSnr=[];
    
    RefTarO.TarIdxSet=[];
    RefTarO.OverlapRefTar='No';
    RefTarO.PostTrialSilence=1;
    RefTarO.OnsetRampTime=0;
    RefTarO.SaveData='Yes';
    RefTarO.TargetMatchContour='No';

    % following are a bunch of old parameters that are mostly here for
    % backwards compatibility....
    RefTarO.NumberOfTrials = 30;  % In memory of Torcs!
    RefTarO.NumberOfRefPerTrial = []; 
    RefTarO.NumberOfTarPerTrial = 1; % default 
    RefTarO.ReferenceMaxIndex = 0;
    RefTarO.TargetMaxIndex = 0;
    RefTarO.ReferenceIndices = '[]';
    RefTarO.TargetIndices = '[]';
    RefTarO.FlipFlag=[];
    RefTarO.SingleRefDuration=[];
    
    RefTarO.RunClass = '[]';
    RefTarO.UserDefinableFields = ...
        {'OveralldB','edit',60,...
         'RelativeTarRefdB','edit',0,...
         'UpdateSnrFrequency','edit',5,...
         'UpdateSnrHR','edit',0.4,...
         'UpdateSnrStep','edit',5,...
         'ReferenceCountFreq','edit',[0 0.4 0.3 0.2 0.1 0],...
         'SingleRefSegmentLen','edit',0,...
         'CueTrialCount','edit','5',...
         'OverlapRefTar','popupmenu','Yes|No',...
         'TargetIdxFreq','edit','1',...
         'TargetChannel','edit','1',...
         'OnsetRampTime','edit',0,...
         'TargetMatchContour','popupmenu','Yes|No',...
         'PostTrialSilence','edit',1,...
         'SaveData','popupmenu','Yes|No',...
        };

    RefTarO = class(RefTarO,'MultiRefTarStaircase');
    RefTarO = ObjUpdate(RefTarO);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'ReferenceTarget')
        RefTarO = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise 
    error('Wrong number of input arguments');
end
