function o = PipSequence(varargin)
% Random sequence of tone pips for reverse correlation.
%
% The parameters are listed in the code.
%
% SVD 2013-04-26

% Technical Note:


switch nargin
  case 0  % if no input arguments, create a default object
    s = SoundObject ('PipSequence', 100000, 0, 0.5, 0.5, ...
        {''}, 1, {...
      'Duration','edit',1,... 
      'LowFrequency','edit',500,... 
      'HighFrequency','edit',20000,...
      'BandCount','edit',20,...
      'PipDuration','edit',0.01,... % in seconds
      'PipRate','edit',20,...  %pips per second
      'PipsEachPerRep','edit',30,...
      'UserRandSeed','edit',0,...
      'NoiseBand','edit',0,...
      'SimultaneousCount','edit',1,...  %pips per event
      'AttenuationLevels','edit',0,...
      });
    o.Duration = 20;  %  how long each Sequence is (presumably this will be 1.0 if you slot it into behavior)
    o.LowFrequency=500;
    o.HighFrequency=20000;
    o.BandCount=20;   % number of distinct tones
    o.PipDuration=0.01;   % how long each pip is in seconds
    o.PipRate=20;   % pips per second
    o.PipsEachPerRep=90;   % how many times each pip needs to play to complete a rep.  
                           % 90 * 20 bands / 20 pips/sec /3 sec/waveform = 30 stim per rep 
    o.UserRandSeed=0;  % if >0, use this as rand seed
    o.NoiseBand=0;  % if 1, use bandpass noise rather than pure tones
    o.SimultaneousCount=1;    % if 2, always play two random tones together
    % AttenuationLevels: if you enter two numbers here, half the tones will
    % be attenuated by each of those dB.  So you if you set this to [0 10]
    % and leave OveralldB=70 in the trial object, then half the tones will
    % be played at 70 dB and the other half will be played at 60 dB.  May
    % be useful for studying adaptation/depression
    o.AttenuationLevels=0;     
    o.PipSet=[];
    o.Frequencies=[];
    
    o = class(o,'PipSequence',s);
    o = ObjUpdate(o);
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   s = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end