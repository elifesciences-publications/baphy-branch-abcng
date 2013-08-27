function a=fopen(a)

% instantiate the handle for ranesock.exe

if isa(a,'rpmequalizer')
    a.handle=actxserver(get(a,'progId'));
    if ~ishandle(a.handle)        
        error('The handle obtained using the progID is not a RaneSock com handle');
    end
end