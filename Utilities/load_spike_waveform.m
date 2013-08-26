% function [ms,es]=load_spike_waveform(spkfile,channel,unit);
%
% alternative syntax: [ms,es]=load_spike_waveform(cellid);
%  (loads waveform for first sorted data file)
%
% created SVD 2009-07-28
%
function [ms,es]=load_spike_waveform(spkfile,channel,unit);

dbopen;

% see if cellid passed first

cellid=spkfile;
sql=['SELECT * FROM sCellFile WHERE cellid="',cellid,'"',...
     ' ORDER BY rawid'];
cellfiledata=mysql(sql);

if length(cellfiledata)>0,
   spkfile=[cellfiledata(1).path cellfiledata(1).respfile];
   channel=cellfiledata(1).channum;
   unit=cellfiledata(1).unit;
end

load(spkfile);

ms=sortextras{channel}.unitmean(:,unit);
es=sortextras{channel}.unitstd(:,unit);
