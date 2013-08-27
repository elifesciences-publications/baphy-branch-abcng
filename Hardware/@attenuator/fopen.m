function fopen(t)
%See @instrument/fopen

if isa(t,'attenuator')
    fopen(t.gpib);
end;