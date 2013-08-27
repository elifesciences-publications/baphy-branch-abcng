function fprintf(t,str)
% write to KH

if isa(t,'khfilter')
    fprintf(t.gpib,str);
end;
