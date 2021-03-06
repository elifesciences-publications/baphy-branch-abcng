function RefTarO = RepDetect(varargin)
% Stream noise.  Specialize TrialObject for StreamNoise experiment with
% Josh McDermott. Designed specifically to be used with NoiseSample
% SoundObject, but maybe could generalize?
%
% Mode - specifies pattern of repeated/isolated sample conditions
% 'RandSingle' - only random,single stream - for basic measures
%                of tuning and preference for specific samples
% 'RandOnly'   - only random, two streams
% 'RepDetect'  - always two streams, one randomly starts repeating
%                during the trial
% 'RdtWithSingle' - same as rep detect except half the trials only
%                   have a single stream
% 'RandAndRep' - each trial is all random or all repeated, one
%                or two streams
%
% created SVD summer 2013
%
switch nargin
case 0
   % if no input arguments, create a default object
   RefTarO.descriptor = 'RepDetect';
   RefTarO.ReferenceClass = 'none';
   RefTarO.ReferenceHandle = [];
   RefTarO.TargetClass = 'none';
   RefTarO.TargetHandle = [];
   RefTarO.SamplingRate = 100000;
   RefTarO.OveralldB = 65;
   RefTarO.RelativeTarRefdB = 0;
   RefTarO.PreTrialSilence=0.5;
   RefTarO.PostTrialSilence=1;
   RefTarO.TargetIdx=[1 2];
   RefTarO.TargetRepCount=5;
   RefTarO.PreTargetAttenuatedB=0;
   RefTarO.ReferenceCountFreq=[0 0 0 0.4 0.3 0.2 0.1 0];
   RefTarO.RefStaticNoiseFrac=0;
   RefTarO.TarStaticNoiseFrac=0;
   RefTarO.NullTrials=0;
   RefTarO.OnsetRampSec=0;
   RefTarO.ReferenceMaxIndex = 0;
   RefTarO.TargetMaxIndex = 0;
   RefTarO.SequenceCount = 30;
   RefTarO.NumberOfTrials = 30;
   RefTarO.Sequences={};
   RefTarO.SequenceCategories=[];
   RefTarO.ReferenceCount=[];
   RefTarO.SequenceIdx=[];
   RefTarO.ThisRepIdx=[];
   RefTarO.Mode='RepDetect';
   RefTarO.RepIdx=[0 1];
   
   RefTarO.RunClass = 'RDT';
   RefTarO.UserDefinableFields = ...
      {'OveralldB','edit',65,...
      'RelativeTarRefdB','edit',0,...
      'PreTrialSilence','edit',0.5,...
      'PostTrialSilence','edit',1,...
      'SequenceCount','edit',30,...
      'TargetIdx','edit',[1 2],...
      'TargetRepCount','edit',5,...
      'PreTargetAttenuatedB','edit',0,...
      'ReferenceCountFreq','edit',[0 0 0 0.4 0.3 0.2 0.1 0],...
      'RefStaticNoiseFrac','edit',0,...
      'TarStaticNoiseFrac','edit',0,...
      'NullTrials','edit',0,...
      'OnsetRampSec','edit',0,...
      'Mode','popupmenu','RepDetect|RandOnly|RandAndRep|RdtWithSingle|RandSingle|RepRanWithSingle',...
      'RepIdx','edit',[0 1],...
      };
      
   RefTarO = class(RefTarO,'RepDetect');
   RefTarO = ObjUpdate(RefTarO);

otherwise 
    error('Wrong number of input arguments');
end
