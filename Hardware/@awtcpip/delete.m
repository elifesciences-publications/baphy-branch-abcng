function delete(a)

if isa(a,'awtcpip')
   close(a.socket);
   clear a
end

