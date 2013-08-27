function o = StreamingBehavior (varargin);
%
% Streaming behavior control
% PreTargetWindow: Specifies the duration of the time window before the beginning of the target (or sham) stimulus that is used for calculation of performance.
%
% PostTargetWindow: Specifies the duration of the time window after the end of the target (or sham) stimulus that is used for calculation of performance.
%
% ShockDuration: Specifies the duration of the fixed shock signal.

% Nima, November 2005. 

switch nargin
    case 0
        % if no input arguments, create a default object
        o.PreTargetWindow     = 0.4;
        o.PostTargetWindow    = 0.4;
        o.ShockDuration     = 0.2;
        o.UserDefinableFields = {'PreTargetWindow','edit',0.4, 'PostTargetWindow', ...
            'edit',0.4, 'ShockDuration','edit',0.2};
        o = class(o,'StreamingBehavior');
        o = ObjUpdate(o);
    case 1
        % if single argument of class SoundObject, return it
        if isa(varargin{1},'StreamingBehavior')
            s = varargin{1};
        else
            error('Wrong argument type'); 
        end
    otherwise
        error('Wrong number of input arguments');
end
