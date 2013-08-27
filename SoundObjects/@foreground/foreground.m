function o = foreground(varargin)
   
% By Ling Ma, 3/2008

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('foreground', 40000, 0,0, 0,{''}, 1, ...
         {'MskCmpNum','edit',8,'TarFreq','edit',3000, 'ToneDur','edit',0.07,...
       'GapDur','edit',0.02,'BurstCnt','edit',16,...
       'BurstcntPerTar','edit',2,'tardB','edit',[0:2:8],...
       'Type','popupmenu','reference|target'});  
    o.MskCmpNum = 8;
    o.TarFreq = 3000;
    o.ToneDur = 0.07;
    o.GapDur = 0.02;
    o.BurstCnt = 16; 
    o.tardB = [0:2:8];
    o.BurstcntPerTar = 2;%1 means every burst has a target played; 2 means every other burst has a target played; 3 means every 3 bursts has a target played;
    o.Type = 'target';
    o = class(o,'foreground',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
% case 6
%     s = SoundObject(varargin{1},varargin{2},varargin{3});
%     o.frequency = varargin{4};
%     o.duration = varargin{5};
%     o.loudness = varargin{6};
%     o = class(t,'Tone',s);
otherwise
    error('Wrong number of input arguments');
end