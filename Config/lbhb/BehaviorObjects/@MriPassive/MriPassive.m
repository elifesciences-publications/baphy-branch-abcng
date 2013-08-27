function o = MriPassive (varargin)
% Passive behavior control does not do anything

switch nargin
    case 0
        % if no input arguments, create a default object
        % this is the constructor:
        o.descriptor = 'MriPassive';
        o.UserDefinableFields = {'TR','edit',10,'PreBlockSilence','edit',34};
        o.TR=10;
        o.PreBlockSilence=34;
        o.TrialStartTime=[];
        o = class(o,'MriPassive');
        o = ObjUpdate(o);
        
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'MriPassive')
            s = varargin{1};
        else
            error('Wrong argument type');
        end
    otherwise
        error('Wrong number of input arguments');
end
