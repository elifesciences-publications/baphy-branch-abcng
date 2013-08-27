function a=fclose(a)


if isa(a,'awtcpip')
    if strcmpi(get(a,'Closed'),'Off')
        close(a.socket)
    end
end


