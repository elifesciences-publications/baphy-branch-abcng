function o = Silence (o);
% This function is the constructor of the blank object. It produces silence
% which can be used as reference. example: a ReferenceTarget module
% without reference.

% Nima Mesgarani, Oct 2005

switch nargin
case 0
    % if no input arguments, create a default object
    s = SoundObject ('Silence', 100000, 0, 0, 0, {'Silence'}, 1, {'SamplingRate','edit',100000, 'Duration','edit',1});
    o.Duration = 1;
    o = class(o,'Silence',s);
    o = ObjUpdate (o);
case 1
    % if single argument of class SoundObject, return it
    if isa(varargin{1},'Silence')
        o = varargin{1};
    else
        error('Wrong argument type');
    end
case 6
    %%
otherwise
    error('Wrong number of input arguments');
end