function o = LSSeq(varargin)
%  using one pretection zone

% By Ling Ma, 04/2007

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('LSSeq', 40000, 0,0, 0,{''}, 1, ...
         {'MskCmpNum','edit',8,'TarFreq','edit',3000, 'ToneDur','edit',0.075,...
       'GapDur','edit',0.005,'Burstcnt','edit',[5,10,5],'dBAtten','edit',30,...
       'FreqRangeInOct','edit', [-2 2],'ProtectZoneInSemitone','edit',12,...
       'StepInSemitone','edit',1,'StimListCnt','edit',10,'BurstcntPerTar','edit',2,...
       'SynorAsyn','popupmenu','synchrony|asynchrony'});
%        'Type','popupmenu','reference|target'});  %
    o.MskCmpNum = 8;
    o.TarFreq = 3000;
    o.ToneDur = 0.075;
    o.GapDur = 0.005;
    o.dBAtten=30;
    o.BurstCnt = [5,10,5]; 
    o.ProtectZoneInSemitone = [12];% Width of protected region around signal frequency in # of semitone
    % (e.g. 2 means that there will be two empty semitone below and above the
    % signal)
    o.FreqRangeInOct = [-2 2];
    o.StepInSemitone = 1;
    o.BurstcntPerTar = 2;%1 means every burst has a target played; 2 means every other burst has a target played; 3 means every 3 bursts has a target played;
    o.SynorAsyn = 'asynchrony';
    o.MskTime = [];
%     o.Type = 'target';
    o.seed = datenum(date); % use date as seed;
    o.MskFreqs = [];
    o.IdxSeq = [];
    o.DynamicorStatic = 1; %1:dynamic; 0:static;
    o.StimListCnt = 10;
    o = class(o,'LSSeq',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end