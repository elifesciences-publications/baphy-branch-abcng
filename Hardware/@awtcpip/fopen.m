function out = fopen(a)

% opens a socket between parent computer and alphaomega system.

if ~isa(a, 'awtcpip')
    error('The input should be a awtcpip object')
end

if nargout<1
    error('please provide an output variable');
end

out=a;
baseport=get(a,'ModuleBasePort');
connNo=get(a,'AWConnNo');
urlstr=get(a,'AWMachineName');


port=baseport+connNo-1;


valid=0;
isconnected=0;
while ~valid
    try
        soc = java.net.Socket(urlstr,port);
        valid = 1;
        isconnected=1;
    catch
        disp(['Either a TCPIP connection already exists for port# ',...
            num2str(connNo), ' on the alphaomega system']);
        disp(' or the alphaomega system is not turned on');
        disp('Stop and restart the connection at that port number ...');
        instr = input('Try reconnecting ? [Return,y|n]','s');
        if strcmpi(instr,'n')
            valid=1;
        end
    end
end

if (isconnected)
    %get input stream   
    dis = java.io.DataInputStream(getInputStream(soc));
    %get output stream
    bw = java.io.BufferedWriter(java.io.OutputStreamWriter...
        (getOutputStream(soc)));
    out.socket=soc;
    out.ipstream=dis;
    out.opstream=bw;
end




