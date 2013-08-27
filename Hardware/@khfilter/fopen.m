function fopen(t)
%See @instrument/fopen

if isa(t,'khfilter')
    fopen(t.gpib);
end;