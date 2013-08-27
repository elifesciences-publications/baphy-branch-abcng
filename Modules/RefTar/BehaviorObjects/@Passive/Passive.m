function o = PunishTarget (varargin);
% Passive behavior control does not do anything

switch nargin
    case 0
        % if no input arguments, create a default object
        % this is the constructor:
        o.descriptor = 'Passive';
        o.UserDefinableFields = {};
        o = class(o,'Passive');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'Passive')
            s = varargin{1};
        else
            error('Wrong argument type');
        end
    otherwise
        error('Wrong number of input arguments');
end
