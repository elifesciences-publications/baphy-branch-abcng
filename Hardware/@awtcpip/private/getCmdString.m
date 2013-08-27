function cmdstr=getCmdString(action,module,varargin)

% this gives the exact command string for various modules in the alphaomega
% system for the common commands

if nargin<2
    module='alphamap';
end
if nargin<1
    action='peerinfo';
end

switch lower(module)
    case 'alphamap'
        switch lower(action)
            case 'startacq'
                cmdstr = 'a=START_ACQ';
            case 'stopacq'
                cmdstr = 'a=STOP_ACQ';
            case 'startsave'
                if length(varargin)<2
                    fpath='C:\Logging_Data\test';
                else
                    fpath=varargin{2};
                end
                if length(varargin)<1
                    error('Please input the map file name ...');
                else
                    mapfilename=varargin{1};
                end
                cmdstr = ['a=START_SAVE&FILE_PATH=',fpath,'&FILE_NAME=',mapfilename];
            case 'stopsave'
                cmdstr = 'a=STOP_SAVE';
            case {'cltpeerinfo','peerinfo'}
                cmdstr = 'a=PEER_INFO&TCP_APP_NAME=AMap Clt&TCP_SERVICE_TYPE=STREAMER&TCP_CONN_BLOCKED=-1';
            case 'servpeerinfo'
                cmdstr = 'a=PEER_INFO&TCP_APP_NAME=AMap&TCP_SERVICE_TYPE=&TCP_CONN_BLOCKED=-1';
            otherwise
                cmdstr='';
        end
    case 'eps'
    case 'mcp'
end