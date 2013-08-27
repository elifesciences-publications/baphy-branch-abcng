function delete(t)

if strcmpi(get(t.gpib,'Status'),'Open')
    fclose(t.gpib);
end;
delete(t.gpib);