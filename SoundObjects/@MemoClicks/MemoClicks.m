function o = MemoClicks(varargin)
%  14/05-TP/YB

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('MemoClicks', 100000, 0, 0.4, 0.8, ...
        {''}, 1, {'RateRNPercent', 'edit', 25,...
        'RateRefPercent','edit', 25,...
        'mingap', 'edit', 0.01,...
        'maxgap','edit',0.2,...
        'highfreq','edit',2000,...
        'SNR','edit',12,...
        'SingleTrainDuration','edit',1,...
        'nreps','edit',1,...
        'SequenceGap','edit',0.25,...
        'TorcDuration','edit',1,...
        'FrequencyRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz|U:1000-32000 Hz|W:2000-64000 Hz|Y:1000-32000 Hz|Z:150-38400 Hz',...
        'TorcRates','popupmenu','1:1:8|4:4:24|4:4:48|8:8:48|8:8:96',...       
        'OctaveRange','edit',[0 1],...
        'OctaveStep','edit',0.25,...
        'MaxIndex','edit', 3});
    o.RateRNPercent = 25;
    o.RateRefPercent = 25;
    o.maxgap = 0.2;
    o.mingap = 0.01;
    o.highfreq = 2000; 
    o.SNR = 12;
    o.SingleTrainDuration = 1;
    o.nreps = 1;
    o.OctaveRange=[0 1];      % contour move up/down tange in octave
    o.OctaveStep = 0.25;        % step in octave
    o.SequenceGap = [0.5];
    o.TorcDuration = [1];
    o.FrequencyRange = 'L:125-4000 Hz';
    o.TorcRates = '4:4:48';
    o.MaxIndex = 3;
    o.Key = [];
    o.TrialN = 0;
    o.PastRef = [];
    o.AllTargetPositions = {'center'};
    o.CurrentTargetPositions = {'center'};
    o.DifficultyLvlByInd = [];
    o = class(o,'MemoClicks',s);
    o = ObjUpdate(o);
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