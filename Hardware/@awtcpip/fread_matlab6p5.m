function command=fread(a)

% reads from the input stream involved with the socket defined in the
% awtcpip object provided as input

if ~isa(a,'awtcpip')
    error('The input must belong to awtcpip class');
end

%%%% add for Matlab 7
% if strcmpi(get(a,'Closed'),'on')
%     error('Create an open socket first using fopen')
% end
%%%%%
j=0;
dis=a.ipstream;
if isa(dis,'java.io.DataInputStream')
    inchar = -1;
    availbytes = available(dis);
    while inchar ~= 0 & inchar ~=10 & availbytes ~=0
        inchar = read(dis);
        j = j + 1;
        serv1Res(j) = inchar;
        availbytes = available(dis);
    end

end
if j>0
    %convert array of ascii byte to char
    command = char(serv1Res);
else
    command = '';
end