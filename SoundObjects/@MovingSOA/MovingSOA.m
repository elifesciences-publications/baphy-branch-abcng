function o = SOA(varargin)
% SOA is a series of alternation of two tones (ToneA & ToneB)
% The onset difference of ToneA and ToneB is a variable.
% related function: set, get, waveform
%   
% Ling Ma modified based on Stream_ab (pingbo), Jun. 2006

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('MovingSOA', 40000, 0,0, 0, ...
        {''}, 1, {'BF','edit',750,'Step_num','edit',5,'Width_oct','edit',[0.25 0.5 1],...
        'ToneDur','edit',0.075,'ToneGap','edit',0.025,'SOA','edit',[0 0.04 0.1],...
        'ComplexNum','edit',[15],'dBAtten_A2B','edit',0});
    o.BF = 1750;
    o.Step_num = 5;
    o.ToneDur = 0.075;
    o.ToneGap = 0.025;
    o.dBAtten_A2B=0;
    o.ComplexNum = 15; 
    o.Width_oct = [0.25 0.5 1];
%     o.Type='referenceAA';
%     o.ToneA_alone = 'yes';
%     o.ToneB_alone = 'No';
    o.SOA = [0 0.04 0.1]; 
    o.ReferenceClass = 'MovingSOA';
    o = class(o,'MovingSOA',s);
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