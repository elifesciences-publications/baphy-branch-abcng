function o = SOA(varargin)
% SOA is a series of alternation of two tones (ToneA & ToneB)
% The onset difference of ToneA and ToneB is a variable.
% related function: set, get, waveform
%   
% Ling Ma modified based on Stream_ab (pingbo), Jun. 2006

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('SOA', 40000, 0,0, 0, ...
        {''}, 1, {'ToneA','edit',750,'ToneB','edit',1500,'ToneA_alone','popupmenu','yes|no',...
        'ToneB_alone','popupmenu','yes|no','ToneDur','edit',0.075,'ToneGap','edit',0.025,'SOA','edit',0,...
        'ComplexNum','edit',[8 12 16 20 24],'dBAtten_A2B','edit',1,...
        'Type','popupmenu','referenceAA|targetAA'});  %
    o.ToneA = 750;
    o.ToneB = 1500;
    o.ToneDur = 0.075;
    o.ToneGap = 0.025;
    o.dBAtten_A2B=0;
    o.ComplexNum = [8 12 16 20 24]; 
    o.Type='referenceAA';
    o.ToneA_alone = 'yes';
    o.ToneB_alone = 'No';
    o.SOA = 0; 
    o.ReferenceClass = 'SOA';
    o = class(o,'SOA',s);
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