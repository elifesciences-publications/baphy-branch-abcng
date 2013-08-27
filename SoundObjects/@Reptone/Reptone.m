function o = Reptone(varargin)

% By Ling Ma, 3/2008

switch nargin
    case 0
        % if no input arguments, create a default object
        s = SoundObject ('Reptone', 40000, 0,0, 0,{''}, 1, ...
            {'FstFreq','edit',3000, ...
            'Freqcnt','edit',2,...
            'SndRelative','edit',0.5 , ...
            'TdRelative','edit', 1, ...
            'flagSym','edit',0,...
            'ShiftTime','edit',0.1,...
            'ShiftLastTone', 'edit',0.1,...
            'ToneDur','edit',0.075,...
            'GapDur','edit',0.125,'BurstCnt','edit',[24:12:48],...
            'BurstcntPerTar','edit',2,...
            'TrainPhase','edit',1,...
            'TrainRange','edit',[-2 2]});
        o.SndRelative = 0.5;
        o.TdRelative = 1;
        o.FstFreq = 3000;
        o.Freqcnt = 2;
        o.flagSym = 0;
        o.ShiftTime = 0.1;
        o.ShiftLastTone = 0.1;
        o.ToneDur = 0.075;
        o.GapDur = 0.125;
        o.BurstCnt = [24:12:48];
        o.BurstcntPerTar = 2;%1 means every burst has a target played; 2 means every other burst has a target played; 3 means every 3 bursts has a target played;
        o.TrainPhase = 1;
        o.TrainRange = [-2 2];
        o.refBegin = 0;
        o = class(o,'Reptone',s);
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