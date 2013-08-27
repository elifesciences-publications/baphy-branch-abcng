function a = set(a,varargin)
% SET Set specified tagid properties and return the object
% a = set(a,prop_name,prop_val)
%   a -> an object from the class - tagid
%   Multiple pairs of PROP_NAME and PROP_VAL are allowed
%   The following values are allowed for PROP_NAME
%   'Tag'        - identification tag, usually string
%   'Tag value'  - value associated with tag identifier

if nargin<2,
    error('Enter input as set(tagid,prop_name,prop_val)');
end;

if nargin==2        % If there exist set values then display options
                    % else say no set values
    n = find(strcmpi(a.tags(:),varargin{1}));
    if ~isempty(n),
        prop_val = a.tagval{n}(2:end);
    end;
    if length(prop_val)-1,
        disp(prop_val(1:end));
    else
        disp('no set values');
    end;
elseif rem(length(varargin),2)
    error('Properties and values must come in pairs');
end;

inargs = varargin;

while length(inargs) >= 2
    prop_name= inargs{1};
    prop_val = inargs{2};
    inargs   = inargs(3:end);
    n = find(strcmpi(a.tags(:),prop_name));
    if isempty(n),
        a.tags{end+1}=prop_name;
        n = length(a.tags);
        a.tagval{n} = prop_val;
    elseif iscell(a.tagval{n})&length(a.tagval{n})>1,
        a.tagval{n}{1} = prop_val;
    else
        a.tagval{n} = prop_val;
    end;
end;

