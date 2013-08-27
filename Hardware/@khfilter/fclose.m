function fclose(t)
%See @instrument/fclose

if isa(t,'khfilter')
    for i = 1:length(t)
        fclose(t(i).gpib)
    end
end;