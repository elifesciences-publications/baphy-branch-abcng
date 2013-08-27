function o = Phoneme(varargin)
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
    s = SoundObject ('Phoneme', 40000, 0, 0.3, 0.3, {}, 1, {'Speakers','edit','f106','SNRs','edit',60,...
        'CVs','edit','ba,sa,ta,ma,ka,fa,pa,na,xa,ga,va,za,da'});
    o.Speakers = 'f106';
    o.SNRs = 60;
    o.CVs = 'ba,sa,ta,ma,ka,fa,pa,na,xa,ga,va,za,da';
    o = class(o,'Phoneme',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'Phoneme')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 7
    s = SoundObject('Phoneme', ...
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
    o = class(o,'Phoneme',s);
    o = ObjUpdate (o);
otherwise
    error('Wrong number of input arguments');
end