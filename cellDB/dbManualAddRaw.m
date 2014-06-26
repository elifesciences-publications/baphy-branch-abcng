function dbManualAddRaw(siteid,parmfile,evpfile);

dbopen;
LoadMFile(parmfile);

if isfield(exptparams,'Performance'),
    globalparams.Physiology='Yes -- Passive';
else 
    globalparams.Physiology='Yes -- Behavior';
end
globalparams.Ferret='McGinley';
globalparams.SiteID=siteid;
globalparams.NumberOfElectrodes=evpgetinfo(evpfile);

[rawdata,site,celldata,rcunit,rcchan]=dbgetsite(globalparams.SiteID);
globalparams.penname=globalparams.SiteID(1:end-1);

if length(site)==0,
    sql=sprintf('SELECT * FROM gPenetration WHERE penname="%s"',...
                globalparams.penname);
    pdata=mysql(sql);
    
    if length(pdata)==0,
        %yn=questdlg(sprintf('Penetration %s doesn''t exist in cellDB. Create it?',globalparams.penname), ...
        %            'cellDB','Yes','No','Yes');
        yn='Yes';
        if isempty(yn) | strcmp(yn,'Yes'),
            globalparams.penid=dbcreatepen(globalparams);
        else
            globalparams.penid=0;
        end
    else
       globalparams.penid=pdata(1).id;
    end
    
    %yn=questdlg(sprintf('Site %s doesn''t exist in cellDB. Create it?',...
    %                    globalparams.SiteID), ...
    %            'cellDB','Yes','No','Yes');
    yn='Yes';
    if isempty(yn) | strcmp(yn,'Yes'),
       globalparams.masterid=dbcreatesite(globalparams);
    end
else
   globalparams.penid=site(1).penid;
   globalparams.masterid=site(1).id;
end

runclass = exptparams.runclass;
if iscell(runclass),
    % only create one mfile here for multi-stim. This avoids confusion on
    % baphy's part.
    runclass=runclass{1};
end

sql=['SELECT * FROM gDataRaw WHERE parmfile="',basename(parmfile),'"',...
     ' AND not(bad)'];
rawdata=mysql(sql);

if isempty(rawdata),
    % function rawid=dbcreateraw(globalparams,runclass,mfilename,evpfilename)
    globalparams.rawid=dbcreateraw(globalparams,exptparams.runclass,...
                                   parmfile,evpfile);
    dbSaveBaphyData(globalparams,exptparams);
else
    fprintf('gDataRaw entry already exists for parmfile %s\n',...
            basename(parmfile));
end

