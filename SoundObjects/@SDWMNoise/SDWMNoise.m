function o = SDWMNoise(varargin)
% SDWMNoise is the constructor for the object SDWMNoise which is a child of  
%       SoundObject class
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "Frequencies", "Duration"
%
% usage:
% To creates a SDWMNoise with default values.
%   t = SDWMNoise;     
%
% To create a SDWMNoise with specified values:
%   t = SDWMNoise (Loudness, PreStimSilence, PostStimSilence,
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
    s = SoundObject ('SDWMNoise', 40000, 0, 0, 0, ...
        {''}, 1, {'Frequencies','edit',[5500 10500],'Distance','edit',1000,'Duration', 'edit',[1 1.5]});
    o.Frequencies =[5500 10500];
    o.Distance = 1000;
    o.Duration = [1 1.5];
    o = class(o,'SDWMNoise',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
    s = SoundObject('SDWMNoise', ...
        varargin{1} , ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Frequencies','edit',1000,...
        'Duration','edit',1});
    o.Frequencies = varargin{5};
    o.Duration = varargin{6};
    o = class(o,'SDWMNoise',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end