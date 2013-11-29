function Path =  sysPathConcat(Path,varargin)

if iscell(varargin) & length(varargin)>0 & iscell(varargin{1}) varargin = varargin{1}; end
if isunix PathSep = '/';
elseif strcmp(computer,'PCWIN') PathSep = '\';
else error('Unknown OS-Type!'); end

if length(varargin)>0
 for i=1:length(varargin)
  if (length(Path)>0 & Path(end)==PathSep) Path = Path(1:end-1); end
  Path = [Path,PathSep,varargin{i}];
 end
 Path = [Path,PathSep];
else
 if Path(end)~=PathSep Path = [Path,PathSep]; end  
end
%concatenate path with needed seperators