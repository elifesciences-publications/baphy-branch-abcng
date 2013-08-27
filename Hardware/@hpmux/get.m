function out = get(t,prop)
if nargin<2
    get(t.gpib)
else
    out = get(t.gpib,prop);
end;