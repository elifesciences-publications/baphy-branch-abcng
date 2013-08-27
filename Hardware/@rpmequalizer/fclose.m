function a=fclose(a)

if isa(a,'rpmequalizer')
    if isa(a.handle,'COM.RaneSock_RaneSocket')|isa(a.handle,'COM.ranesock.ranesocket')
        sendcommand(a,'stop')
        a.handle.release;
        a.handle='';
    end
end