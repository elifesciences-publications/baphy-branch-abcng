function o = LongToneSequence(varargin)
% Tone is the constructor for the object Tone which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Frequencies", "Duration"
%
% usage:
% To creates a tone with default values.
%   t = Tone;     
%
% To create a tone with specified values:
%   t = Tone (Loudness, PreStimSilence, PostStimSilence,
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
    s = SoundObject ('LongToneSequence', 100000, 0, 0, 0, ...
        {''}, 1, {...
        'Frequencies','edit',[1000 2000],...
        'ToneDuration','edit',0.2,...
        'MinGap','edit',0.2,...
        'MaxGap','edit',1.2,...
        'SequenceCount','edit',2,...
        'RelativeAttenuation','edit',0,...
        'SplitChannels','popupmenu','No|Yes',...
        'Duration','edit',10});
    o.Frequencies = [1000 2000];
    o.SplitChannels = 'No';
    o.ToneDuration=0.1;
    o.MinGap=0.1;
    o.MaxGap=0.7;
    o.RelativeAttenuation=0;
    o.SequenceCount=2;
    o.Duration = 10;
    o.OnsetTimes={};
    o.AttenuateChan=[];
    o = class(o,'LongToneSequence',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
otherwise
    error('Wrong number of input arguments');
end