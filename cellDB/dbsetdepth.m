function dbsetdepth(siteid,channel,depth)

dbopen;
sql=['SELECT depth FROM gCellMaster WHERE siteid="',siteid,'"'];
s=mysql(sql);

if isempty(s),
   error('site not found');
end

dd=strsep(s.depth,',');
if length(dd)<max(channel),
   dd=cell(1,max(channel));
   for ii=1:max(channel),
      dd{ii}=0;
   end
end
for ii=1:length(channel),
   dd{channel(ii)}=depth(ii);
end

sdepth='';
for ii=1:length(dd),
   sdepth=[sdepth,num2str(depth(ii)),','];
end
sdepth=sdepth(1:(end-1));

sql=['UPDATE gCellMaster SET depth="',sdepth,'" WHERE siteid="',siteid,'"'];
mysql(sql);
