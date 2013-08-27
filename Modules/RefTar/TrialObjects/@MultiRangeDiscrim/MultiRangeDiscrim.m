function o = MultiRangeDiscrim(varargin)
% ToneSeqTrialObject Creates a reference-target base class. 
% The properties of StreamTrialObject are:
%   descriptor: The name of experiment
%   ReferenceClass: Class(es) of reference
%   TargetClass: Class(es) of Target
%   NumberOfTrials : number of trials in each repetition
%   ReferenceMaxIndex: maximum possible index for reference object. 
%   TargetMaxIndex: maximum possible index for target object.
%   ShamIndex: an array of all combinations for sham trials.
%   TrialIndex: an array of all combinations for stim trials(c1-ref,
%               c2-target, 0 for sham)
%   TrialRandom: an array of trials randomization for one block.
%   TrialRepetition: repetition# for a block
%   CurrentReps: an indicator for repetition position, which keeping
%                                   updating during waveform generation.
%   ShamPercentage: percentage of sham trials
% Pingbo, July, 2009 from 'ToneSeqTrial'

switch nargin
case 0
    % if no input arguments, create a default object
    o.descriptor = 'MultiRangeDiscrim';  %reserved field name
    o.ReferenceClass='none';    %reserved field name
    o.ReferenceHandle = [];     %reserved field name
    o.TargetClass='none';       %reserved field name
    o.TargetHandle = [];        %reserved field name
    o.SamplingRate = 40000;     %reserved field name
    o.OveralldB=65;             %reserved field name
    o.NumberOfTrials=[];        %reserved field name    
    o.RunClass='MRD';           %reserved field name
    o.PreTrialSilence=0.2;
    o.PostTrialSilence=1.0;
    o.RefAttenDB=0;
    o.FlowRate_mlPmin=0.0;   %for constant flow rate (use for avoidance-task through AO1
    o.RefIndices=[];
    o.TrialIndices=[];
    o.UserDefinableFields = {'OveralldB','edit',65,...
                             'RefAttenDB','edit',0,...
                             'FlowRate_mlPmin','edit',0,...
                             'PreTrialSilence','edit',0.2,...
                             'PostTrialSilence','edit',1.0}
    o = class(o,'MultiRangeDiscrim');
    o = ObjUpdate(o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'MultiRangeDiscrim')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise 
    error('Wrong number of input arguments');
end
