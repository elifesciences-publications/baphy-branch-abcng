% function r=onseil()
%
% returns 1 if on seil cluster
% returns 2 if on OHSU LBHB net
%
function r=onseil()

[s,host]=unix('hostname');
[s,IP]=unix('hostname -I');
if isempty(strtrim(IP)),
   [s,IP]=unix('hostname -I');
end
host=strtrim(host);
if ~isempty(findstr(lower(host),'seil.umd.edu')),
   r=1;
elseif ~isempty(findstr(IP,'137.53.')), % ohsu addresses
   r=2;
elseif ~isempty(findstr(IP,'192.168.')), % private hyrax subnet
   r=2;
else
   r=0;
end
