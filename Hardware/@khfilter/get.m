function out = get(t,prop)
%See @instrument/get

if isa(t,'khfilter')
    if nargin<2
        get(t.gpib)
    elseif strcmpi(prop,'specs')
        out = updateSpecs(t);
    else
        out = get(t.gpib,prop);
    end;
end;