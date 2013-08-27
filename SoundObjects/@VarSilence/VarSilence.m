function o = VarSilence (o);
% This function is the constructor of the blank object. It produces silence
% which can be used as reference. example: a ReferenceTarget module
% without reference.

% Nima Mesgarani, Oct 2005%
% variable silence length; added by Ling Ma, 08/2007


switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('Silence', 40000, 0, 0, 0, {'Silence'}, 30, {'SamplingRate','edit',40000, 'Duration','edit',0.5:0.3:2});
    o.Duration = 0.5:0.3:2;
    o = class(o,'VarSilence',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'VarSilence')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
    %%
otherwise
    error('Wrong number of input arguments');
end