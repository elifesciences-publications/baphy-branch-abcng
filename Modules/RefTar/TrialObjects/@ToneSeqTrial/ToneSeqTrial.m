function o = ToneSeqTrial(varargin)
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
% Pingbo, Feb 1, 2006

switch nargin
case 0
    % if no input arguments, create a default object
    o.descriptor = 'ToneSeqTrial';  %reserved field name
    o.ReferenceClass='none';    %reserved field name
    o.ReferenceHandle = [];     %reserved field name
    o.TargetClass='none';       %reserved field name
    o.TargetHandle = [];        %reserved field name
    o.SamplingRate = 40000;     %reserved field name
    o.OveralldB=65;             %reserved field name
    o.NumberOfTrials=[];        %reserved field name    
    o.RunClass='MTS';           %reserved field name
    o.PreTrialSilence=0.1;
    o.PostTrialSilence=1.0;
    o.RefAttenDB=0;
    o.MultipleGap=0;   %add on 12/15/2006, vary tone gap trial by trial.
    o.ReferenceMaxIndex = [];
    o.TargetMaxIndex = [];    
    o.MaxRefNumPerTrial=5;
    o.TrialIndices=[];
    o.ReferenceIndices = [];
    o.ToneGapIndices=[];
    o.InterStimInterval=1.0;
    o.FrequencyVaried='fixed';
    o.Torc='None';
    o.Torchandle=[];
    o.TorcList=[];
    o.TorcAttenDB=20;
    o.UserDefinableFields = {'OveralldB','edit',65,...
                             'MultipleGap','edit',0,...
                             'InterStimInterval','edit',1.0,...
                             'MaxRefNumPerTrial','edit',5,...
                             'TorcAttenDB','edit',20,...
                             'FrequencyVaried','popupmenu','fixed|byTrial-1|bytrial-2|withinTrial',...
                             'Torc','popupmenu','None|L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz|A:Distractor|B:DIstractor|C:DIStractor'};
    o = class(o,'ToneSeqTrial');
    o = ObjUpdate(o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'ToneSeqTrial')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise 
    error('Wrong number of input arguments');
end
