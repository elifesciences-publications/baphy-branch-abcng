function r=onseil()

[s,host]=unix('hostname');
[s,IP]=unix('hostname -I');
host=strtrim(host);
if ~isempty(findstr(lower(host),'seil.umd.edu')),
   r=1;
elseif ~isempty(findstr(IP,'137.53.')),
   r=2;
else
   r=0;
end
