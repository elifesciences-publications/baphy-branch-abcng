function o = SingleDigits (varargin)
% function t = phoneme(varargin)
% 
% Constructor for the object phoneme
% Object phoneme inherits from SoundObject class
% usage: 
%   p = phoneme; construct an instance of the tone object with default values
%   p = phoneme (descriptor, UserDefinedFields, ) % construct an instance of a phoneme object with given
%   parameters
%   
% methods: set, get, waveform
% 

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('SingleDigits', 40000, 0, 0.4, 0.8, {}, 0, {'Speakers','edit','f1'...
        ,'SNRs','edit',60,'Utterances','edit',1,'Digits','edit','0,1,2,3,4,5,6,7,8,9'});
    o.Speakers = 'f2';
    o.SNRs = 100;
    o.Utterances = 1;
    o.Digits = '0,1,2,3,4,5,6,7,8,9';
    o = class(o,'SingleDigits',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SingleDigits')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 7
    s = SoundObject('SingleDigits', ...
        varargin{1}, ...    % SamplingFrequency
        varargin{2}, ...    % Loudness
        varargin{3}, ...    % PreStimSilence
        varargin{4},...     % PostStimSilence
        '',...              % Names
        1,{'Speakers','edit','','SNRs','edit','',...
        'CVs','edit',''});
    o.Speakers  = varargin{5};
    o.SNRs      = varargin{6};
    o.CVs       = varargin{7};
    o = class(o,'SingleDigits',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end