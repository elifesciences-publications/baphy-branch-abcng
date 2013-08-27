% function t=dbReadTuning(cellid);
%
% cellid - name of cell (entry in gSingleCell)
%
% t - structure with each field either a scalar, matrix or string
%
% created SVD 2011-10-29
%
function t=dbReadTuning(cellid);

t=struct('cellid',cellid);
sql=['SELECT * FROM gSingleCell WHERE cellid="',cellid,'"'];
singledata=mysql(sql);
if isempty(singledata),
   warning(['no match for cellid ',cellid]);
else
   eval(char(singledata.tuningstring));
end
