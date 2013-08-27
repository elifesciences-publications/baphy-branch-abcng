function o = Stream_AB(varargin)
% Stream_AB is a series of alternation of two tones (ToneA & ToneB)
% related function: set, get, waveform
%   
% Pingbo, Decemebr 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('Stream_AB', 40000, 0,0, 0, ...
        {''}, 1, {'ToneA','edit',750,'ToneB','edit',1500,...
        'ToneDur','edit',0.075,'ToneGap','edit',0.025,...
        'ComplexNum','edit',[4],'tardB','edit',[5 10 15],'dBAtten_A2B','edit',0,...
        'Type','popupmenu','referenceBB|referenceAA|targetAA|targetBB|RefTar'});  %
    o.ToneA = 5000;
    o.ToneB = 1000;
    o.ToneDur = 0.075;
    o.ToneGap = 0.025;
    o.tardB = [5 10 15];
    o.dBAtten_A2B=0;
    o.ComplexNum = [5 8]; 
    o.Type='referenceBB';
    o = class(o,'Stream_AB',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
%     s = SoundObject(varargin{1},varargin{2},varargin{3});
%     o.frequency = varargin{4};
%     o.duration = varargin{5};
%     o.loudness = varargin{6};
%     o = class(t,'Tone',s);
otherwise
    error('Wrong number of input arguments');
end