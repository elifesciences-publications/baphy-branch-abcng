baphy_set_path
dbopen;

animal='lim034';
sql=['SELECT * FROM gDataRaw where cellid like "',animal,'%"',...
     ' AND not(training)'];
rawdata=mysql(sql);

for ii=1:length(rawdata),
   fprintf('parmfile: %s%s\n',rawdata(ii).resppath, ...
           rawdata(ii).parmfile);
   tmpfile=[rawdata(ii).resppath 'tmp' filesep ...
            strrep(rawdata(ii).parmfile,'.m','') '.mat'];
   if exist(tmpfile,'file'),
      fprintf('deleting tmp: %s\n',tmpfile);
      delete(tmpfile);
   end
end
