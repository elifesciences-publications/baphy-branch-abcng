% function rawid=dbcreateraw(globalparams,runclass,mfilename,evpfilename)
%
% created SVD 2005-11-21
%
function rawid=dbcreateraw(globalparams,runclass,mfilename,evpfilename)

dbopen;

sql=sprintf('SELECT * FROM gRunClass WHERE name="%s"',runclass);
rdata=mysql(sql);
if length(rdata)==0;
   error('runclass not found in cellDB!');
end

sql=sprintf('SELECT * FROM gCellMaster WHERE id=%d',globalparams.masterid);
sdata=mysql(sql);
if length(sdata)==0,
   error('Site not found in cellDB!');
end
sql=sprintf('SELECT * FROM gSingleCell WHERE masterid=%d',globalparams.masterid);
celldata=mysql(sql);
if length(celldata)==0,
   error('Cell not found in cellDB!');
end

[respfile,resppath]=basename(mfilename);

% avoid losing backslashes in SQL
% don't need to do this since it's taken care of in mysql.m
%resppath=strrep(resppath,'\','\\');
%evpfilename=strrep(evpfilename,'\','\\');

if strcmp(globalparams.Physiology,'No'),
    behavior='active';
elseif strcmp(globalparams.Physiology,'Yes -- Passive'),
    behavior='passive';
elseif strcmp(globalparams.Physiology,'Yes -- Behavior'),
    behavior='active';
end

[aff,rawid]=sqlinsert('gDataRaw',...
                      'cellid',globalparams.SiteID,...
                      'masterid',globalparams.masterid,...
                      'runclass',runclass,...
                      'runclassid',rdata.id,...
                      'task',rdata.task,...
                      'training',sdata.training,...
                      'respfileevp',evpfilename,...
                      'respfile','*SAVE MAP FILE NAME HERE*',...
                      'parmfile',respfile,...
                      'resppath',resppath,...
                      'fixtime',datestr(now,'HH:MM'),...
                      'behavior',behavior,...
                      'stimclass',rdata.stimclass,...
                      'time',datestr(now,'HH:MM'),...
                      'timejuice',globalparams.PumpMlPerSec.Pump,...
                      'addedby',sdata.addedby,...
                      'info','dbcreatepen.m');
fprintf('added gDataRaw entry %d\n',rawid);

[aff,singlerawid]=sqlinsert('gSingleRaw',...
                         'cellid',celldata(1).cellid,...
                         'masterid',globalparams.masterid,...
                         'singleid',celldata(1).id,...
                         'penid',globalparams.penid,...
                         'rawid',rawid,...
                         'channel','a',...
                         'unit',1,...
                         'channum',1,...
                         'addedby',sdata.addedby,...
                         'info','dbcreatepen.m');
fprintf('added gSingleRaw entry %d\n',singlerawid);

