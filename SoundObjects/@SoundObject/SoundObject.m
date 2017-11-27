function s = SoundObject(varargin)
% SoundObject Creates a sound object that is the base class of any sound used in
% baphy
% the properties of s are:
%   SamplingRate: default=40000

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s.descriptor = 'none';
    s.SamplingRate = 100000;
    s.Loudness = 0;
    s.PreStimSilence = 0;
    s.PostStimSilence = 0;
    s.Names = {'none'};
    s.MaxIndex = 1;
    s.UserDefinableFields = {'SamplingRate','edit',100000,'PreStimSilence','edit',0,'PostStimSilence','edit',0};
    s = class(s,'SoundObject');
    s = ObjUpdate (s);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')
        s = varargin{1};
    else
        error('Wrong argument type');
    end
case 8
    s.descriptor = varargin{1};
    s.SamplingRate = varargin{2};
    s.Loudness = varargin{3};
    s.PreStimSilence = varargin{4};
    s.PostStimSilence = varargin{5};
    s.Names = varargin{6};
    s.MaxIndex = varargin{7};
    s.UserDefinableFields = {'PreStimSilence','edit',0,'PostStimSilence','edit',0, varargin{8}{:}};
    s = class(s,'SoundObject');
    s = ObjUpdate (s);
otherwise 
    error('Wrong number of input arguments');
end
