function RefTarO = TwoStreamRefTar(varargin)
% MultiRefTar -- modeled on WM trial object which itself was hacked from
% ReferenceTarget
%
switch nargin
case 0
    % if no input arguments, create a default object
    RefTarO.descriptor = 'TwoStreamRefTar';
    RefTarO.ReferenceClass = 'none';
    RefTarO.ReferenceHandle = [];
    RefTarO.TargetClass = 'none';
    RefTarO.TargetHandle = [];
    RefTarO.SamplingRate = 100000;
    RefTarO.OveralldB = 65;
    RefTarO.RelativeTarRefdB = 0;
    RefTarO.Ref1Parms=[500 1000];
    RefTarO.Ref2Parms=[2000 4000];
    RefTarO.Tar1Index=1;
    RefTarO.Tar2Index=2;
    RefTarO.ReferenceCountFreq=[0.4 0.3 0.2 0.1];
    RefTarO.TargetIdxFreq=[1];
    RefTarO.SingleRefSegmentLen = 0;
    RefTarO.RefIdx=[];
    RefTarO.TarIdx=[];
    RefTarO.OverlapRefTar='No';
    RefTarO.PostTrialSilence=0;
    RefTarO.OnsetRampTime=0;
    RefTarO.SaveData='Yes';
    RefTarO.TargetMatchContour='No';
    
    RefTarO.NumberOfTrials = 30;  % In memory of Torcs!
    RefTarO.NumberOfRefPerTrial = []; 
    RefTarO.NumberOfTarPerTrial = 1; % default 
    RefTarO.ReferenceMaxIndex = 0;
    RefTarO.TargetMaxIndex = 0;
    RefTarO.ReferenceIndices = {};
    RefTarO.TargetIndices = {};
    RefTarO.SingleRefDuration=0;
    
    RefTarO.NumOfEvPerStim = 3;  % how many stim each event produces??
    % having the two following fields is enough, we actually do not need
    % NumOfEvPerStim anymore, but for backward compatibility we keep it!
    RefTarO.NumOfEvPerRef = 3;  % how many stim each reference produces??
    RefTarO.NumOfEvPerTar = 3;  % how many stim each Target produces??
    RefTarO.RunClass = '[]';
    RefTarO.UserDefinableFields = ...
        {'OveralldB','edit',65,...
         'RelativeTarRefdB','edit',0,...
         'Ref1Parms','edit',[500 1000],...
         'Ref2Parms','edit',[2000 4000],...
         'Tar1Index','edit',1,...
         'Tar2Index','edit',2,...
         'ReferenceCountFreq','edit',[0.5 0.5],...
         'SingleRefSegmentLen','edit',0,...
         'OverlapRefTar','popupmenu','Yes|No',...
         'TargetIdxFreq','edit','1',...
         'OnsetRampTime','edit',0,...
         'PostTrialSilence','edit',0,...
         'SaveData','popupmenu','Yes|No',...
         'TargetMatchContour','popupmenu','Yes|No',...
        };

    RefTarO = class(RefTarO,'TwoStreamRefTar');
    RefTarO = ObjUpdate(RefTarO);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'TwoStreamRefTar')
        RefTarO = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise 
    error('Wrong number of input arguments');
end
