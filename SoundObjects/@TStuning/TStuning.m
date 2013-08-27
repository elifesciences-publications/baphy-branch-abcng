function o = TStuning (varargin)

% methods: set, get, waveform
%   
% usage: 

% pingbo yin, July 2007

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('TSTuning', 40000, 0,0, 0, ...
        {''}, 1, {'BaseFrequency','edit',2000,'SemiToneRange','edit',[-18 18],...
        'SemiToneStep','edit',3,'Duration','edit',0.15,'ToneNumber','edit',2,'ToneGap','edit',0,...
        'dBattenRange','edit',0,'dBattenStep','edit',5});
    o.BaseFrequency = 1000;   %if two elements, tone chords if 2nd element>50
                              %or bandpass noise if <=48
    o.SemiToneRange = [-18 18];
    o.SemiToneStep = 4;    
    o.Duration = 0.15;  %sec
    o.ToneNumber = 2;   %0 for FM sweep (logarithmic)
    o.ToneGap = 0.0;    %silence duration between the tone; if 2 elemnts, it denoted incremment(1) and maxmuim silence duration 
    o.dBattenRange=0;
    o.dBattenStep=5;
    o = class(o,'TStuning',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end