function o = MemoClicks(varargin)
%  14/05-TP/YB
%  Sundeep, Dec. 2014

switch nargin
  
  case 0 % if no input arguments, create a default object
    s = SoundObject ('MemoClicks', 100000, 0, 0.5, 0.5, ...
      {''}, 1, {'RateRCPercent', 'edit', 25,...
      'RateRefRCPercent','edit', 25,...
      'mingap', 'edit', 0.01,...
      'maxgap','edit',0.1,...
      'highfreq','edit',2000,...
      'SNR','edit',100,...
      'ClickTrainDur','edit',0.5,...
      'nreps','edit',3,...
      'SequenceGap','edit',0.25,...
      'IntroduceTORC','popupmenu','yes|no'...
      'TorcDuration','edit',0.5,...
      'FrequencyRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz|U:1000-32000 Hz|W:2000-64000 Hz|Y:1000-32000 Hz|Z:150-38400 Hz',...
      'TorcRates','popupmenu','1:1:8|4:4:24|4:4:48|8:8:48|8:8:96',...
      'OctaveRange','edit',[0 1],...
      'OctaveStep','edit',0.25,...
      'MaxIndex','edit', 3});
    
    % Clicks
    o.RateRCPercent         = 25;
    o.RateRefRCPercent      = 25;
    o.maxgap                = 0.1; % [0.025 0.05 0.1 0.2 0.4]
    o.mingap                = 0.01;
    o.highfreq              = 2000;
    o.SNR                   = 100; % for SNR>99, no pink noise added;
    o.ClickTrainDur         = 0.5;
    o.nreps                 = 3;
    
    % Torc
    o.OctaveRange           = [0 1];      % contour move up/down tange in octave
    o.OctaveStep            = 0.25;        % step in octave
    o.SequenceGap           = [0.25];
    o.TorcDuration          = [1];
    o.FrequencyRange        = 'L:125-4000 Hz';
    o.TorcRates             = '4:4:48';
    o.IntroduceTORC         = 'yes';
    
    % Stim conditions
    o.MaxIndex              = 3;  % no. of conditions
    o.Key                   =  []; % replace seed no. of earlier block for re-test
    o.Seeds                = [];
    o.PastRef               = [];
    o.Stimulus              = [];
    o.AllTargetPositions    = {'center'};
    o.CurrentTargetPositions= {'center'};
    
    o = class(o,'MemoClicks',s);
    o = ObjUpdate(o);
    
  case 1  % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
      s = varargin{1};
    else
      error('Wrong argument type');
    end
    
  otherwise
    error('Wrong number of input arguments');
end