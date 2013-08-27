function o = IRN(varargin)
% IRN = Iterated Rippled Noise a la Yost
%
% Properties: "descriptor",  "SamplingRate",  "Loudness",
%       "PreStimSilence",  "PostStimSilence", "Names", "MaxIndex",
%       "UserDefinableFields", "LowFreq", "HighFreq", "Duration"
%
% SVD 2013-03-28

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('IRN', 100000, 0, 0, 0, ...
        {''}, 1, {...
        'LowFreq','edit',250,...
        'HighFreq','edit',8000,...
        'SplitChannels','popupmenu','No|Yes',...
        'StepMS','edit',3,...
        'Gain','edit',1,...
        'Iterations','edit',10,...
        'Duration','edit',1});
    o.LowFreq = 250;
    o.HighFreq = 8000;
    o.SplitChannels = 'No';
    o.StepMS=3;
    o.Gain=1;
    o.Iterations = 10;
    o.Duration = 1;  %
    o.OverrideAutoScale=1;
    o = class(o,'IRN',s);
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