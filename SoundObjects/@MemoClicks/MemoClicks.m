function o = MemoClicks(varargin)
%  14/05-TP/YB

%  Dec. 2014. Sundeep. 
%  Changes: Noise instead of TORC. Single click train per trial.

switch nargin
    
case 0   % if no input arguments, create a default object
    
    s = SoundObject ('MemoClicks', 100000, 0, 0.5, 0.5, {''}, 1,...
       {'RateRCPercent', 'edit', 25,...
        'RateRefRCPercent','edit', 25,...
        'mingap', 'edit', 0.05,...
        'maxgap','edit',0.5,...
        'highfreq','edit',2000,...
        'SNR','edit',20,...
        'ClickTrainDur','edit',1,...
        'nreps','edit',3,...
        'SequenceGap','edit',0.25,...
        'NoisePreStim','edit',0,...
        'NoisePostStim','edit',0,...
        'NoiseDur','edit',0.5,...
        'NoiseHPF','edit',250,...
        'NoiseLPF','edit',8000,...
        'NoiseFilter','popupmenu','yes|no',...
        'MaxIndex','edit', 3});
    
    o.RateRCPercent     = 25;
    o.RateRefRCPercent  = 25;
    o.maxgap            = 0.5;
    o.mingap            = 0.05;
    o.highfreq          = 2000; 
    o.SNR               = 20; %12;
    o.ClickTrainDur     = 1;
    o.nreps             = 1;    
    o.SequenceGap       = [0.25];
    
    o.NoisePreStim      = 0;
    o.NoisePostStim     = 0;
    o.NoiseDur          = 0.5;
    o.NoiseHPF          = 250;
    o.NoiseLPF          = 8000;
    o.NoiseFilter       = 'yes';
    
    o.MaxIndex          = 3;
    o.Key               = [];
    o.PastRef           = [];
    o.AllTargetPositions = {'center'};
    o.CurrentTargetPositions = {'center'};
    o = class(o,'MemoClicks',s);
    o = ObjUpdate(o);
    
case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
    
otherwise
    error('Wrong number of input arguments');
end