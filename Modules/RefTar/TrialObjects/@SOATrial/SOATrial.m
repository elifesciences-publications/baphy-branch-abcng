function o = SOATrial(varargin)
% StreamTrialObject Creates a reference-target base class. 
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
% Ling Ma modified, Jun. 2006

switch nargin
case 0
    % if no input arguments, create a default object
    o.descriptor = 'SOATrial';
    o.ReferenceClass='none';
    o.ReferenceHandle = [];
    o.TargetClass='none';
    o.TargetHandle = [];
    o.SamplingRate = 40000;
    o.OveralldB=65;
    o.RelativeRefTardB=0;
    o.NumberOfTrials=[];
    o.ReferenceMaxIndex = []; 
    o.TargetMaxIndex = [];
    o.ShamIndex = [];
    o.ShamTrialNum=0;
    o.ShamPercentage =0;
    o.TrialIndices=[];
    o.TrialRandom = [];
    o.CurrentReps=1;    
    o.RunClass='SOA'; %Sound Onset Asynchrony
    o.Reinforcement='Positive';
    o.UserDefinableFields = {'OveralldB','edit',65,'RelativeRefTardB',...
        'edit',0,'ShamPercentage',...
        'edit',[20],...
        'Reinforcement','popupmenu','Positive|Negative'};
    o = class(o,'SOATrial');
    o = ObjUpdate(o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SOATrial')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 9
%     o.descriptor = varargin{1};
%     o.Reference = varargin{2};
%     o.Target = varargin{3};
%     o.ShamPercentage = varargin{4};
%     o.SamplingRate = varargin{5};     
%     o.RefMaxIndex = varargin{6}; 
%     o.TarMaxIndex = varargin{7};
%     o.ShamIndex = varargin{8};  
%     o.TrialIndex=varargin{9};
%     o.TrialRandom=varargin{10};
%     o.TrialRepetition=varargin{11};
%     o = class(o,'StreamTrialObject');
%     o = ObjUpdate(o);
otherwise 
    error('Wrong number of input arguments');
end
