function dbupdateparams (globalparams, Parameters, Performance)
% function dbupdateparams (globalparams, Parameters, Performance)
%
% This function update the parameters and comment entries in the database.
% Parameters and Performance should be single structures

% copied from dms_run, Nima 2006

if isfield(globalparams,'rawid') & globalparams.rawid>0,
    dbopen;
    sql=['SELECT * FROM gDataRaw WHERE id=',num2str(globalparams.rawid)];
    rawdata=mysql(sql);
    parmstring = [];
    parmfields = fieldnames(Parameters);
    for cnt1 = 1:length(parmfields)
        parmstring = [parmstring sprintf([parmfields(cnt1) ': %.1f \n'] , Parameters.(parmfields(cnt1)))];
    end
    perfstring = [];
    perffields = fieldnames(Performance);
    for cnt1 = 1:length(perffields)
        perfstring = [perfstring sprintf([perffields(cnt1) ': %.1f \n' ], Parameters.(perffields(cnt1)))];
    end
    sql=['UPDATE gDataRaw SET',...
        ' parameters=''',parmstring,''','...
        ' corrtrials=',num2str(ccount),',',...
        ' trials=',num2str(count),...
        ' WHERE id=',num2str(globalparams.rawid)];
    mysql(sql);

    % the following lines are for water, it writes them into a different
    % table that is generated for one day, this way the water is recorded
    % per day and not per session:
%     sql=['SELECT gPenetration.* FROM gPenetration,gCellMaster',...
%         ' WHERE gPenetration.id=gCellMaster.penid',...
%         ' AND gCellMaster.id=',num2str(rawdata.masterid)];
%     pendata=mysql(sql);
%     if isempty(pendata.water) | strcmp(char(pendata.water),'NULL'),
%         pendata.water=0;
%     end
% 
%     sql=['UPDATE gPenetration SET',...
%         ' water=',sprintf('%.2f',pendata.water+exptparams.volreward-exptparams.lastreward),...
%         ' WHERE id=',num2str(pendata.id)];
%     mysql(sql);
%     exptparams.lastreward=exptparams.volreward;
end