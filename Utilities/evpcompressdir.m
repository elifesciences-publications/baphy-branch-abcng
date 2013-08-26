
cpath='/auto/data/daq/Mars/mar028/';

dd=dir([cpath,'*.evp']);

for ii=1:length(dd),
   evpcompress(fullfile(cpath,dd(ii).name));
   
end
