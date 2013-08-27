function o = MultipleTones(varargin)
%
% methods: set, get, waveform, ObjUpdate


% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('MultipleTones', 40000, 0, .40, .80, ...
        {''}, 1, {'Frequencies','edit',1000,...        
        'Duration','edit',1});
    o.Frequencies = 1000;
    o.Duration = 1;  %
    o = class(o,'MultipleTones',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
    s = SoundObject('MultipleTones', ...
        varargin{1}, ...         % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',1,{'Frequencies','edit',varargin{5},...
        'Duration','edit',varargin{6}});
    o.Frequencies = varargin{5};
    o.Duration = varargin{6};
    o = class(o,'MultipleTones',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end