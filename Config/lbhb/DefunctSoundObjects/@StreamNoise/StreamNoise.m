function o = StreamNoise(varargin)
% StreamNoise is the constructor for the object StreamNoise which is a
% child of SoundObject class
%
% Run class: SNS
%
% Streaming Noise stimulus based on Josh McDermotts PNAS 2011
% study.  Noise samples are frozen for any given
% LowFreq/HighFreq/Count/GapDur/Duration condition (ie, fixed
% across varying values of RepIdx and ShuffleCount)
%
% usage:
% To create a StreamNoise with default values.
%   t = StreamNoise;
%
% To get the waveform and events:
%   [w, events] = waveform(t, idx);  
%
% standard methods: set, get, waveform, ObjUpdate,
% object-specific methods:
%       specgram(o,index): returns spectogram of noise sample index
%       sample(o,index): returns waveform for noise sample index
%
% SVD created 2011-08-10, based on code from JM
%
switch nargin
case {0,1}
    % if no input arguments, create a default object
    if nargin==1 && isa(varargin{1},'SoundObject')
       o = varargin{1};
       return;
    end
    
    s = SoundObject('StreamNoise', 80000, 0, 0, 0, {''}, 1, ...
                    {'Duration','edit',6,...
                     'LowFreq','edit',20,...       
                     'HighFreq','edit',8000,...
                     'Count','edit',20,...
                     'GapDur','edit',0,...
                     'RepeatIdx','edit',1,...
                     'ShuffleCount','edit',5,...
                    });
    
    o.FreqCorr=1./13.3*1.4528;
    o.TempCorr=1./15.3;
    
    o.PreStimSilence=0.5;
    o.PostStimSilence=0.5;
    o.Duration = 6;
    o.SamplingRate=80000;
    o.LowFreq = 20;
    o.HighFreq = 8000;
    o.Count=20;
    o.GapDur=0;
    o.RepeatIdx=1;
    o.ShuffleCount=1;
    o.SampleDuration=o.Duration./o.Count;
    o.IdxSet=[];
    o.SampleIdentifier=[0 0 0 0 0 0];
    
    % if single argument of class SoundObject, return it
    if nargin==1 && isstruct(varargin{1}),
       % if structure, use it to create object, then fill empty
       % fields with defaults
       parms = varargin{1};
       ff=fields(parms);
       for ii=1:length(ff),
          o.(ff{ii})=parms.(ff{ii});
       end
    end
    
    o = class(o,'StreamNoise',s);
    o = ObjUpdate (o);
       
otherwise
    error('Wrong number of input arguments');
end