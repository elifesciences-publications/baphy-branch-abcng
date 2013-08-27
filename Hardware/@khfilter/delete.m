function delete(t)
%See @instrument/delete

if isa(t,'khfilter')
    delete(t.gpib);
    clear t;
end;