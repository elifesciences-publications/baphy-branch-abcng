function fopen(t)

if strcmpi(get(t.gpib,'Status'),'Closed')
    fopen(t.gpib);
else
    disp('HP-MUX OBJ already open');
end;