function fwrite(a,cmd,varargin)

% fwrite(a,command/commandstr,commandparams)
% writes cmd to the output stream of the socket associated with the awtcpip
% object given as input. 
% 
% Usage:
% cmd - it can be one of the common commands(startacq, stopacq, startsave,
%       stopsave, peerinfo) or it can be the actual cmdstr (e.g
%       a=START_ACQ)


if ~isa(a,'awtcpip')
    error('The input must belong to awtcpip class');
end

%%%% add for Matlab 7
if strcmpi(get(a,'Closed'),'on')
    error('Create an open socket first using fopen')
end
%%%%

% get the actual commandString if command is given
module=get(a,'modulename');
module=module{1}{1};
commandStr=getCmdString(cmd,module,varargin{:});
if strcmpi(commandStr,'')
    commandStr=cmd;
end

bufferWriter=a.opstream;
str_len = length(commandStr);
for  i= 1:str_len
    write(bufferWriter,commandStr(i));
end
%write '\0' at the end of command packet
write(bufferWriter,0);
%flush the buffer
flush(bufferWriter);
