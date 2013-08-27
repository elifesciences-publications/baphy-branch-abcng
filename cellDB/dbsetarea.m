% function dbsetarea(penname/siteid,areastr)
%
% update area at penetration penname or site siteid.  if areastr is a
% single string, all channels set to that area.  if comma-deliminated,
% each channel set to separate area.
%
% created SVD 2011-06-03
%
function dbsetarea(penname,areastr)

dbopen;

if nargin<2,
   error('two parameters required:  dbsetarea(penname,areastr)');
end
sql=['SELECT gCellMaster.*,gPenetration.numchans',...
     ' FROM gCellMaster INNER JOIN gPenetration',...
     ' ON gCellMaster.penid=gPenetration.id',...
     ' WHERE gCellMaster.penname like "',penname,'"',...
     ' OR gCellMaster.siteid like "',penname,'"'];
sitedata=mysql(sql);

if isempty(sitedata),
   disp('no matching sites...');
   return
end

numchans=sitedata(1).numchans;
masterid=cat(2,sitedata.id);
masterstr=strrep(mat2str(masterid),'[','');
masterstr=strrep(masterstr,']','');
masterstr=strrep(masterstr,' ',',');

newastr='';
a=strsep(areastr,',');
for ii=1:numchans
   if length(a)<ii,
      a{ii}=a{end};
   end
   newastr=[newastr,',',a{ii}];
end
newastr=newastr(2:end);

if ~isempty(sitedata(1).area),
   fprintf('%s overwriting previous area: %s\n',penname,sitedata(1).area);
end
fprintf('%s channels 1-%d areas set to: %s\n',penname,numchans,newastr);

sql=['UPDATE gCellMaster set area="',newastr,'" WHERE id in (', ...
     masterstr,')']
mysql(sql);

for cc=1:numchans,
   sql=['UPDATE gSingleCell SET area="',a{cc},'" WHERE masterid in (', ...
        masterstr,') AND channum=',num2str(cc)];
   mysql(sql);
   sql=['UPDATE sCellFile SET area="',a{cc},'" WHERE masterid in (', ...
        masterstr,') AND channum=',num2str(cc)];
   mysql(sql);
end

