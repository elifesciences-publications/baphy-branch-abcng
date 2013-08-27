function o = LSStrial (varargin)
% using RefernceMaxIndex==1; 
% 
% By Ling Ma, 10/2006, modified from Pingbo

switch nargin
case 0
    % if no input arguments, create a default object
    o.descriptor = 'LSStrial';  %reserved field name
    o.ReferenceClass='none';    %reserved field name
    o.ReferenceHandle = [];     %reserved field name
    o.TargetClass='none';       %reserved field name
    o.TargetHandle = [];        %reserved field name
    o.SamplingRate = 40000;     %reserved field name
    o.OveralldB=65;             %reserved field name
    o.NumberOfTrials=[];        %reserved field name    
    o.RunClass='LSS';           %reserved field name
    o.PreTrialSilence=0;
    o.PostTrialSilence=0.5;
    o.ReferenceMaxIndex = [];
    o.TargetMaxIndex = [];    
    o.MaxRefNumPerTrial=1;
    o.TrialIndices=[];
    o.ReferenceIndices = [];
    o.ReferenceIdx = [];
    o.InterStimInterval=1;
%     o.StaticPercent=30;
%     o.Lookuptable = [];
%     o.TargetIndices = [];
    o.TargetIdx = [];
%     o.StaticIndices = [];
    o.Reinforcement='Positive';
%     o.Varied = 'AcrossTrial';
    o.UserDefinableFields = {'OveralldB','edit',65,...
                             'InterStimInterval','edit',1,...
                             'PreTrialSilence','edit',0,...
                             'PostTrialSilence','edit',0.5,...
                             'MaxRefNumPerTrial','edit',1};
%                              'StaticPercent','edit',30};
%                              'Varied','popupmenu','WithinTrial|AcrossTrial'};
    o = class(o,'LSStrial');
    o = ObjUpdate(o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'LSStrial')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise 
    error('Wrong number of input arguments');
end
