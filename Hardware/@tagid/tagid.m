function t = tagid(varargin)
% tagid - create a tagid object specifying stimulus level parameters
% t = TAGID, without input arguments creates a default object
% t = TAGID(obj), sets t = obj, if obj is an object of class tagid
% t = TAGID(tag1,tagval1,tag2,tagval2,...)
%   tag    - string identifier
%   tagval - value associated with tag

if nargin==0
    %if no input arguments, create a default object
    t.tags = '';
    t.tagval = [];
    t = class(t,'tagid');
elseif nargin==1 
    %if single argument of class tagid, return it
    if isa(varargin{1},'tagid')
        t = varargin{1};
    end
elseif mod(nargin,2)==0 
    t.tags = varargin(1:2:end);
    t.tagval = varargin(2:2:end);
    t = class(t,'tagid');
else  
    error(nargchk(0,2,nargin))
end
