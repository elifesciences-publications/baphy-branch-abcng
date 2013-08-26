
dbopen;

sql=['SELECT * FROM gDataRaw WHERE not(bad) AND not(training) AND cellid like "ele1%"'];
rawdata=mysql(sql);

for ii=1:length(rawdata),
   evpfile=[rawdata(ii).resppath rawdata(ii).respfileevp];
   dd=dir(evpfile);
   
   if length(dd)>0,
      fprintf('compressing %s ...\n',evpfile);
      gzevpfile=evpcompress(evpfile);
   end
end

