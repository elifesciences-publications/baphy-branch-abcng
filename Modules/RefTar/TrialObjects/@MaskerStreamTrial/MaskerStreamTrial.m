function o = MaskerStreamTrial (varargin)
% MaskerStreamObject Creates a reference-target base class. 
% By Ling Ma, 10/2006, modified from Pingbo

switch nargin
case 0
    % if no input arguments, create a default object
    o.descriptor = 'MaskerStreamTrial';  %reserved field name
    o.ReferenceClass='none';    %reserved field name
    o.ReferenceHandle = [];     %reserved field name
    o.TargetClass='none';       %reserved field name
    o.TargetHandle = [];        %reserved field name
    o.SamplingRate = 40000;     %reserved field name
    o.OveralldB=65;             %reserved field name
    o.NumberOfTrials=[];        %reserved field name    
    o.RunClass='MSB';           %reserved field name
    o.PreTrialSilence=0.05;
    o.PostTrialSilence=0.05;
    o.ReferenceMaxIndex = [];
    o.TargetMaxIndex = [];    
    o.MaxRefNumPerTrial=5;
    o.TrialIndices=[];
    o.ReferenceIndices = [];
    o.ReferenceIdx = [];
    o.InterStimInterval=1;
    o.StaticPercent=0;
    o.Lookuptable = [];
%     o.TargetIndices = [];
    o.TargetIdx = [];
%     o.StaticIndices = [];
    o.Reinforcement='Positive';
    o.Varied = 'AcrossTrial';
    o.dBAttRef2Tar = 15;
    o.UserDefinableFields = {'OveralldB','edit',65,...
                             'InterStimInterval','edit',1,...
                             'PreTrialSilence','edit',0.05,...
                             'PostTrialSilence','edit',0.05,...
                             'MaxRefNumPerTrial','edit',5,...
                             'dBAttRef2Tar','edit',15};
%                              'StaticPercent','edit',30};
%                              'Varied','popupmenu','WithinTrial|AcrossTrial'};
    o = class(o,'MaskerStreamTrial');
    o = ObjUpdate(o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'MaskerStreamTrial')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise 
    error('Wrong number of input arguments');
end
