function out = set(a,varargin)

% overloaded set function for awtcpip function

if isa(a,'awtcpip')
    a.tagid = set(a.tagid,varargin{:});
end;

out=a;