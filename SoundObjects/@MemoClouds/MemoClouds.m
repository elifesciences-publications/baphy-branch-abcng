function o = MemoClouds(varargin)
%  Sundeep Teki. 16.01.2015
%  based on MemoClicks, gentonecloud22

switch nargin
  
  case 0 % if no input arguments, create a default object
    s = SoundObject ('MemoClouds', 100000, 0, 0.4, 0.0, ... % sampling rate same as psychophysics
      {''}, 1, {'RateRTCPercent', 'edit', 25,...
      'RateRefRTCPercent','edit', 25,...
      'SegDur','edit',0.5,...
      'nreps','edit',3,... % same as MemoClicks
      'tonespersecond','edit',4,... 
      'chperoctave','edit',2,...     
      'lowchannel','edit',86.1328,...% 22050/2^8
      'highchannel','edit',22050,...
      'ReseedKey','edit',[],...
      'MaxIndex','edit', 1});
    
    % ToneCloud
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
    o.tonedur                = 0.05;
    
    % Stim conditions    
    o.MaxIndex                    = 1;  % no. of conditions
    o.ReseedKey                   = [];
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