function fclose(t)

if strcmpi(get(t.gpib,'Status'),'Open')
    fclose(t.gpib);
else
    disp('HP-MUX OBJ already closed');
end;