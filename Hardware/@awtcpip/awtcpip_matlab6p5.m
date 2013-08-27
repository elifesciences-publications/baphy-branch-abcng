function t = awtcpip(varargin)

% t=awtcpip(portno) -  Creates a awtcpip object which can be used to
% communicate with alphaomega system using tcpip
%
% Usage:
% t=awtcpip(connNo,baseport,urlstr)
% where  connNo   - A value between 1 to 5 denoting which connection number
%                   to use with a module of alphaomega system
%        baseport - starting port no for that particular module of
%                   alphaomega system. e.g. for alphamap it is 8090.
%                   The actual  port used for the tcpip connection is given
%                   by baseport+portno-1.
%        urlstr   - the ipaddress or the machine name for the alphaomega
%                   system. eg : avw2202c.isr.umd.edu or 128.8.140.88
%
% Default values:
% connNo   = 2
% baseport = 8090
% urlstr   = avw2202c.isr.umd.edu


machinename = 'avw2202c.isr.umd.edu';
connectionNo = 2;
modulebaseport = 8090;
tag = tagid('AWMachineName',machinename,...
    'AWConnNo',connectionNo,'ModuleBasePort',modulebaseport,...
    'ModuleName',{'Alphamap','Alphamap','EPS','MCP'});
t.ipstream='';
t.opstream='';
%t.socket = java.net.Socket(); % for matlab 7
t.socket = ''; % for matlab 6
listtags=getTags(tag);

switch nargin
    case 0
        t = class(t,'awtcpip',tag);
    case 1
        if isa(varargin{1},'awtcpip')
            t = varargin{1};
        elseif isa(varargin,'tagid')
            t.tag=varargin{1};
            t = class(t,'awtcpip');
        elseif (varargin{1}<=5)&(varargin{1}>=1)
            t.tag = set(t.tag,'AWConnNo',varargin{1});
            t = class(t,'awtcpip');
        else
            error('Sorry incorrect first argument');
        end;
        t = class(t,'awtcpip',tag);
    case 2,3
        if isa(varargin{1},'tagid') & isa(varargin{2},'java.net.Socket')
            t.tag=varargin{1};
            t.socket=varargin{2};
            if strcmpi(get(t.socket,'Connected'),'On')
                t.ipstream=java.io.DataInputStream(getInputStream(t.socket));
                t.opstream=java.io.BufferedWriter(java.io.OutputStreamWriter...
                    (getOutputStream(t.socket)));
            end
            else
            for i = 1:nargin
                t.tag = set(t.tag,listtags{i},varargin{i});
            end;
        end
         t = class(t,'awtcpip',tag);
    otherwise
        error('Incorrect input arguments');
end;