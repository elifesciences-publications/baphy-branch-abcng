function o = ClickCloudTarget(varargin)
% Click is the constructor for the object Click which is a child of  
%       SoundObject class
%
%
% usage:
% To creates a Click with default values.
%   t = Tone;     
%
% To create a Click with specified values:
%   t = Click 
%
% To get the waveform and events:
%   [w, events] = waveform(t);  
%
% methods: set, get, waveform, ObjUpdate


% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('ClickCloudTarget', 100000, 0, 0, 0, ...
        {''}, 1, {'ClickWidth','edit',0.001,...
        'MeanICI','edit',0.30,...
        'StdICI','edit',0.10,...
        'ClickCloudMinDuration','edit',1,...
        'ClickCloudMaxDuration','edit',4,...
        'ClickCloudMeanDuration','edit',2.5,...
        'CCDurationBin','edit',6,...
        'ProbeSound','popupmenu','TORC|Noise',...
        'ProbeDuration','edit',1,...
        'CuedChannel','edit',[],...
        'TargetChannel','edit',[],...
        'RefTarRel_dB','edit','0',...
        'BlockCondition','edit',0});
    o.ClickWidth = .001;
    o.MeanICI = 0.30;
    o.StdICI = 0.10;
    o.ClickCloudMinDuration = 1;
    o.ClickCloudMaxDuration = 4;
    o.ClickCloudMeanDuration = 2.5;
    o.CCDurationBin = 6;
    o.ProbeSound = 'TORC';
    o.ProbeDuration = 1;
    o.ChannelNumber = 2;
    o.CuedChannel = [];
    o.TargetChannel = [];
    o.RefTarRel_dB = [];
    o.BlockCondition = 0;
    o.MaxIndex = o.ChannelNumber;
    o = class(o,'ClickCloudTarget',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 7
    s = SoundObject('ClickCloudTarget', ...
        varargin{1},...     % SamplingRate
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'ClickWidth','edit',varargin{5},'ClickRate','edit',varargin{6},...
        'Duration','edit',varargin{7}});
    o.ClickWidth = varargin{5};
    o.ClickRate = varargin{6};
    o.Duration = varargin{7};
    o = class(o,'ClickCloudTarget',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end