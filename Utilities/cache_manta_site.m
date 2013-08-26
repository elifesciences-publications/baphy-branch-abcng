
siteid='lim004a';


baphy_set_path;

d=mysql(['select * from gDataRaw where not(bad) and cellid="',siteid,'"']);

fprintf('%d data files at this site:\n',length(d));

for ii=1:length(d),
   evpfile=[d(ii).resppath 'raw' filesep d(ii).respfileevp];
   evpfile=strrep(evpfile,'.evp','.001.1.evp');
   
   [SpikechannelCount]=evpgetinfo(evpfile);
   
   fprintf('(%d) %s: %d channels\n',d(ii).id,evpfile,SpikechannelCount);
   for jj=1:SpikechannelCount,
      e=cacheevpspikes(evpfile,jj,4);
   end
   
end

