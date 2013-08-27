function out = get(a,prop)

% overloaded get method for awtcpip object

if nargin<2
    if isa(a,'awtcpip')
        get(a.tagid);
    end
else
    try
        out=get(a.tagid,prop);
    catch
        out=get(a.socket,prop);
    end
end
