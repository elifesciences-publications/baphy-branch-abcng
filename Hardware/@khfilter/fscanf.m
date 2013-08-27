function out = fscanf(t)
% write to KH

if isa(t,'khfilter')
    out = fscanf(t.gpib);
end;
