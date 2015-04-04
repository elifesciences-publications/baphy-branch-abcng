function o = SSA(varargin)
% SSA is the constructor for the object SSA which is a child of  
%       SoundObject class
%
% Run class: SSA
%
% SVD created 2015-03-05, based on NoiseBurst object.
%
switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('SSA', 100000, 0, 0.5, 0.5, ...
        {''}, 1, {'Duration','edit',5,...
        'PipDuration','edit',0.03,...
        'PipInterval','edit',0.3,...
        'SequenceCount','edit',20,...
        'F1Rates','edit','0.95 0.05',...
        'Frequencies','edit','1000 2000',...
        'Bandwidth','edit',0,...
        });
    o.PipDuration = 0.03;
    o.PipInterval = 0.3;
    o.SequenceCount=20;
    o.F1Rates=[0.95 0.05];
    o.Bandwidth=0;
    o.Frequencies= [1000 2000]; 
    o.Duration = 5;
    o.Sequences = [];
    o = class(o,'SSA',s);
    o = ObjUpdate (o);
        
otherwise
    error('Wrong number of input arguments');
end