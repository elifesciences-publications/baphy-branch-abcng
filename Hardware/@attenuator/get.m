function out = get(t,prop)
%See @instrument/get

if isa(t,'attenuator')
    if nargin<2
        disp(['Present attenuation : ', num2str(t.attenuation)]);
        get(t.gpib);
    else
        if strcmpi(prop,'attenuation')
            out = t.attenuation;
        else
            out = get(t.gpib,prop);
        end;
    end;
end;