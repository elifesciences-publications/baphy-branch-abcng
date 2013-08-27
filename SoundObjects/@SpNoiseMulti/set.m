function o = set (o,varargin)
% This is a generic set function for all userdefined classes. Copy this 
% function in your objects directory.

% Nima Mesgarani, October 2005, mnima@umd.edu

% modified svd 2006-11-27 to allow for setting multiple properties at once
% (allowing for just a single ObjUpdate call)

switch nargin
    case 1
    % if one argument, display all the fields
        get(o);
    % or two inputs, just return the field
    case 2 
        get(o,varargin{1});
    case {3,5,7,9,11,13,15,17}
        % if single property, change its value
        fields = fieldnames(o);
        for ii=0:2:(nargin-3)
            index = find(strcmpi (fields,varargin{1+ii})==1);
            if isempty(index)
                object_field = o.(fields{end});
                if isobject(object_field)
                    o.(fields{end}) = set(object_field,varargin{1+ii},varargin{2+ii});
                else
                    error('%s \n%s', ['There is no ''' varargin{1+ii} ''' property in specified class']);
                end
            else
                o.(fields{index})=varargin{2+ii};
            end
        end
    otherwise
        error('%s \n%s','Error using ==> set','Too many input arguments.');
end
caller = dbstack;
if length(caller)>1
    if ~strcmpi(caller(2).name, 'ObjUpdate')
        % if its not called from ObjUpdate function, run it. 
        % without this check, it will become a close loop.
%         disp(sprintf('called by %s',caller(2).name));
        o = ObjUpdate (o);
    end
else
    o = ObjUpdate(o);
end