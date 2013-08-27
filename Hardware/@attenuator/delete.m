function delete(t)
%See @instrument/delete

if isa(t,'attenuator')
    delete(t.gpib);
    clear t;
end;