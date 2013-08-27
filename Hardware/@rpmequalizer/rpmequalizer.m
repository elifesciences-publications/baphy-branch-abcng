function out=rpmequalizer(varargin)

% out=rpmequalizer(tagid) initializes an object for rpm2 equalizer using
% handle for ranesock.exe.The tags for the tagid object are:
%   IPAddress: the ip address of rpm equalizer
%   progID: the progid for RaneSock.exe; default is RaneSock.RaneSocket
%   MemoryNumber: default is zero
%
% Usage:
%   out=rpmequalizer(tagid)
%   out=rpmequalizer(ipaddress)
%   out=rpmequalizer(ipaddress,memoryNumber);





out.handle='';
tag=tagid('IPAddress','128.8.110.200',...
    'progId','RaneSock.RaneSocket','MemoryNumber',0);
listtags=getTags(tag);

switch nargin
    case 0
        out=class(out,'rpmequalizer',tag);
    case 1
        if isa(varargin{1},'rpmequalizer')
            out=varargin{1};
        elseif isa(varargin{1},'tagid')
            tag=varargin{1};
            out=class(out,'rpmequalizer',tag);
        else
            tag=set(tag,listtags{1},varargin{1});
            out=class(out,'rpmequalizer',tag);
        end
    otherwise
        for i=1:length(listtags)
            tag=set(tag,listtag{i},varargin{i});            
        end
        out=class(out,'rpmequalizer',tag);
end






