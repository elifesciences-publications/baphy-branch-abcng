function o = Masktone(varargin)


switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('Masktone', 40000, 0,0, 0,{''}, 1, ...
         {'MskCmpNum','edit',8,...
         'FstFreq','edit',3000,...
         'ToneDur','edit',0.07,...
       'GapDur','edit',0.02,...
       'Burstcnt','edit',12,...
       'FreqRangeInOct','edit', [-2.5 2.5], ...
       'StepInSemitone','edit',1,'BurstcntPerTar','edit',1,...
       'DynamicorStatic','edit',1,'tardB','edit',[0:2:8]});  
    o.MskCmpNum = 8;
    o.FstFreq = 3000;
    o.ToneDur = 0.075;
    o.GapDur = 0.125;
    o.BurstCnt = 12; 
    o.FreqRangeInOct = [-2.5 2.5];
    o.StepInSemitone = 1;
    o.BurstcntPerTar = 2;%1 means every burst has a target played; 2 means every other burst has a target played; 3 means every 3 bursts has a target played;
    o.MskFs = [];
    o.Type = 'reference';
    o.seed = datenum(date); % use date as seed;
    o.tardB = [0:2:8];
    o.MskFreqs = [];
    o.IdxSeq = [];
    o.idx = [];
    o.DynamicorStatic = 1; %1:dynamic; 0:static;
    o = class(o,'Masktone',s);
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