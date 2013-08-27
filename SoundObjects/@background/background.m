function o = background(varargin)
%   
% By Ling Ma, 3/2008

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('background', 40000, 0,0, 0,{''}, 1, ...
         {'MskCmpNum','edit',8,'TarFreq','edit',3000, 'ToneDur','edit',0.07,...
       'GapDur','edit',0.02,'Burstcnt','edit',22:6:46,...
       'FreqRangeInOct','edit', [-2 2],'ProtectZoneInSemitone','edit',[8 12],...
       'StepInSemitone','edit',1,'BurstcntPerTar','edit',1,...
       'DynamicorStatic','edit',1,'SynorAsyn','popupmenu','asynchrony|synchrony',...
       'BindingFreq','edit',0,'Binding','popupmenu','alt|syn',...
       'Type','popupmenu','reference|reftar'});  
    o.MskCmpNum = 8;
    o.TarFreq = 3000;
    o.ToneDur = 0.07;
    o.GapDur = 0.02;
%     o.dBAtten_M2T=10;
    o.BurstCnt = 22:6:46; 
    o.ProtectZoneInSemitone = [8 12];% Width of protected region around signal frequency in # of semitone
    % (e.g. 2 means that there will be two empty semitone below and above the
    % signal)
    o.FreqRangeInOct = [-2 2];
    o.StepInSemitone = 1;
    o.BurstcntPerTar = 2;%1 means every burst has a target played; 2 means every other burst has a target played; 3 means every 3 bursts has a target played;
    o.MskTime = [];
    o.Type = 'reference';
    o.seed = datenum(date); % use date as seed;
    o.SynorAsyn = 'asynchrony';
    o.MskFreqs = [];
    o.IdxSeq = [];
    o.DynamicorStatic = 1; %1:dynamic; 0:static;
    o.BindingFreq = 0;
    o.Binding = 'syn';
    o = class(o,'background',s);
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