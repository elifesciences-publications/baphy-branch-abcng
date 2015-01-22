function o = MemoClouds(varargin)
%  Sundeep Teki. 16.01.2015
%  based on MemoClicks, gentonecloud22

switch nargin
  
  case 0 % if no input arguments, create a default object
    s = SoundObject ('MemoClouds', 44100, 0, 0.4, 0.0, ... % sampling rate same as psychophysics
      {''}, 1, {'RateRTCPercent', 'edit', 25,...
      'RateRefRTCPercent','edit', 25,...      
      'ToneCloudDur','edit',1,...
      'SegDur','edit',0.5,...
      'nreps','edit',3,... % same as MemoClicks
      'tonespersecond','edit',20,... 
      'chperoctave','edit',3,...     
      'lowchannel','edit',186.1328,...% 22050/2^8
      'highchannel','edit',22050,...
      'key','edit',[],...
      'SequenceGap','edit',0.25,...
      'IntroduceTORC','popupmenu','yes|no'...
      'TorcDuration','edit',0.5,...
      'FrequencyRange','popupmenu','L:125-4000 Hz|H:250-8000 Hz|V:500-16000 Hz|U:1000-32000 Hz|W:2000-64000 Hz|Y:1000-32000 Hz|Z:150-38400 Hz',...
      'TorcRates','popupmenu','1:1:8|4:4:24|4:4:48|8:8:48|8:8:96',...
      'OctaveRange','edit',[0 1],...
      'OctaveStep','edit',0.25,...
      'MaxIndex','edit', 1}); 
    
    % Clicks
    o.RateRTCPercent         = 25;
    o.RateRefRTCPercent      = 25;
    o.SegDur                 = 0.5;
    o.nreps                  = 3;
    o.ToneCloudDur           = o.SegDur*o.nreps;
    o.tonespersecond         = 4; % 4, 8, 16, 32, 128, 512
    o.chperoctave            = 2;  % 2, 4,  8, 16,  64, 256
    o.density                = o.tonespersecond*o.chperoctave;
    o.lowchannel             = 86.1328; % = 22050/2^8
    o.highchannel            = 22050;
    
    % Torc
    o.OctaveRange            = [0 1];      % contour move up/down tange in octave
    o.OctaveStep             = 0.25;        % step in octave
    o.SequenceGap            = 0.25;
    o.TorcDuration           = 0.5;
    o.FrequencyRange         = 'H:250-8000 Hz';
    o.TorcRates              = '4:4:48';
    o.IntroduceTORC          = 'yes';
    
    % Stim conditions
    o.MaxIndex                    = 1;  % no. of conditions
    o.Key                         = []; % replace seed no. of earlier block for re-test
    o.Seeds                       = [];
    o.PastRef                     = [];
    o.Stimulus                    = [];
    o.AllTargetPositions          = {'center'};
    o.CurrentTargetPositions      = {'center'};
    
    o = class(o,'MemoClouds',s);
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