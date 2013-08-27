% function sigma=site_get_sigma(siteid,channel)
%
% siteid can be the real siteid or the name of a parm file
% collected at that site
%
% created svd 2009-06-01
%
function sigma=site_get_sigma(siteid,channel)

dbopen;

sql=['SELECT * FROM gCellMaster WHERE siteid="',siteid,'"'];
sitedata=mysql(sql);
if isempty(sitedata),
   parmfile=basename(siteid);
   if ~strcmp(parmfile((end-1):end),'.m'),
      parmfile=[parmfile '.m'];
   end
   
   sql=['SELECT gCellMaster.* FROM gCellMaster,gDataRaw',...
        ' WHERE gDataRaw.parmfile="',parmfile,'"',...
        ' AND gCellMaster.id=gDataRaw.masterid'];
   sitedata=mysql(sql);
end

if isempty(sitedata),
   error('site not found');
end

sigmas=strsep(num2str(sitedata.sigma),',');

if length(sigmas)<channel,
   sigma=0;
else
   sigma=sigmas{channel};
end
