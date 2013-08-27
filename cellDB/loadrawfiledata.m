function outdata=loadrawfiledata(rawid,channel)

sql=['SELECT * FROM gDataRaw WHERE id=',num2str(rawid)];
rawdata=mysql(sql);

outdata.rawid=rawid;
outdata.siteid=rawdata.cellid;
outdata.evpfile=rawdata.respfileevp;
outdata.spikefile=rawdata.matlabfile;
outdata.parmfile=rawdata.parmfile;
if ~exist(outdata.evpfile,'file'),
    outdata.evpfile=[rawdata.resppath basename(outdata.evpfile)];
end 
fileparts(outdata.parmfile)

if isempty(fileparts(outdata.parmfile)) || ~exist(outdata.parmfile,'file'),
    outdata.parmfile=[rawdata.resppath basename(outdata.parmfile)];
end
if strcmp(outdata.parmfile(end-1:end),'.m'),
   outdata.parmfile=outdata.parmfile(1:end-2);
end
   
sql=['SELECT gCellMaster.id, numchans FROM gCellMaster,gPenetration',...
     ' WHERE siteid="',outdata.siteid,'" AND gCellMaster.penid=gPenetration.id'];
site=mysql(sql);
outdata.numchans=site.numchans;

sql=['SELECT gSingleCell.* FROM gSingleCell',...
     ' WHERE siteid="',outdata.siteid,'" AND channum=',num2str(channel)];
site=mysql(sql);
outdata.cellcount=length(site);
outdata.channel=channel;
%outdata.sigthresh=str2num(get(handles.editSigmaThreshold,'String'));
%outdata.globalsigma=get(handles.checkGlobalSigma,'Value');

sql=['SELECT * FROM gData WHERE rawid=',num2str(rawid)];
datadata=mysql(sql);
for ii=1:length(datadata),
   if datadata(ii).datatype==0,
      outdata=setfield(outdata,datadata(ii).name,datadata(ii).value);
   else
      outdata=setfield(outdata,datadata(ii).name,datadata(ii).svalue);
   end
end
