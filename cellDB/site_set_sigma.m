% function res=site_set_sigma(siteid,channel,value)
%
% siteid can be the real siteid or the name of a parm file
% collected at that site
%
% created svd 2009-06-01
%
function res=site_set_sigma(siteid,channel,value)

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
if isnumeric(sitedata.sigma),
    sitedata.sigma=num2str(sitedata.sigma);
end
sigmas=strsep(sitedata.sigma,',');
for ii=(length(sigmas)+1):channel,
   sigmas{ii}=0;
end
sigmas{channel}=value;

if length(sigmas)>1,
   sigstr=mat2str(cat(2,sigmas{:}));
   sigstr=sigstr(2:(end-1));
   sigstr=strrep(sigstr,' ',',');
else
   sigstr=num2str(sigmas{1});
end

sql=['UPDATE gCellMaster set sigma="',sigstr,'"',...
     ' WHERE id=',num2str(sitedata.id)]
[dd,res]=mysql(sql);

