function o = TargetSwitch(varargin)
% TargetSwitch is the constructor for the object TargetSwitch which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Frequencies", "Duration"
%
% usage:
% To creates a tone with default values.
%   t = TargetSwitch;     
%
% To create a tone with specified values:
%   t = TargetSwitch (Loudness, PreStimSilence, PostStimSilence,
%       frequencies, Duration);
%
% To get the waveform and events:
%   [w, events] = waveform(t);  
%
% methods: set, get, waveform, ObjUpdate


% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('TargetSwitch', 40000, 0, 0, 0, ...
        {''}, 1, {'ExpType','popupmenu','FDL|PRD','Frequencies','edit',1000,'TarProb','edit',[.5 .5]...        
        'Duration','edit',1,'SilenceProb','edit',.5,'CorPchSwp','edit',0,'PunishTone','edit',0,'FixTrialFreq','edit',0,'onlytones','edit',0  });
    o.ExpType = 'PRD';
    o.Frequencies = 1000;
    o.TarProb = [.5 .5];
    o.Duration = [1];  %
    o.FMorTone=1;
    o.SilenceProb=.5;
    o.TarPresent=[1; 1];
    o.CorPchSwp=0;
    o.PunishTone=0;
    o.FixTrialFreq=0;
    o.onlytones=0;
    o = class(o,'TargetSwitch',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
    s = SoundObject('TargetSwitch', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Frequencies','edit',1000,...
        'Duration','edit',1});
    o.Frequencies = varargin{5};
    o.Duration = varargin{6};
    o = class(o,'TargetSwitch',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end