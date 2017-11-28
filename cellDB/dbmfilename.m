% function [mfile,evpfilename,rawid]=dbmfilename(globalparams,exptparams)
%
% inputs:
% globalparams.siteid is string name of site.
% globalparams.Physiology is 'No', 'Yes -- Passive', or 'Yes -- Behavior'
% runclass is abbreviated name of stim/task, eg FTC, TOR, DMS, etc.
%
% outputs:
% appropriate mfile and evpfilename for next expt at this site
%
% created SVD 2005-11-21
%
function [mfile,evpfilename,rawid]=dbmfilename(globalparams,exptparams)

runclass = exptparams.runclass;
if iscell(runclass),
    % only create one mfile here for multi-stim. This avoids confusion on
    % baphy's part.
    runclass=runclass{1};
end

% June 10 2008. to add the stimulation 's' to the filename now we pass
% exptparams to this script. if exptparams.Stimulation exists and its 1,
% add 's' to the 'a' 'p' extention
if ~isfield(exptparams,'Stimulation')   
    Stimulation = [];
else
    Stimulation = exptparams.Stimulation;
end

dbopen;

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

% guess passive for now
if strcmp(globalparams.Physiology,'No'),
    babbr='t';
elseif strcmp(globalparams.Physiology,'Yes -- Passive'),
    babbr='p';
elseif strcmp(globalparams.Physiology,'Yes -- Behavior'),
    babbr='a';
end
if Stimulation
    babbr = [babbr 's'];
end
% count ALL gDataRaw entries (including bad ones)
sql=['SELECT id,cellid FROM gDataRaw WHERE cellid="',globalparams.SiteID,'"'];
trawdata=mysql(sql);
rawcount=length(trawdata);

ii=find(globalparams.penname>='0' & globalparams.penname<='9');
mm=max(find(globalparams.penname=='_'));
if ~isempty(mm),
    ii=ii(ii>mm);
end

pennum=str2num(globalparams.penname(ii));
if strcmpi(globalparams.Physiology,'no'),
    % for training, just save in a big training directory
    subdir=['training' datestr(now,'YYYY')];
else
    % for physiology, one directory per penetration
    subdir=sprintf('%s%03d%s',globalparams.penname(1:(ii(1)-1)),...
        pennum,globalparams.penname((ii(end)+1):end));
    % uncomment to go back to one directory per ten penetrations
    % SVD 2006-07-26
    %pennum=round(floor(pennum./10)).*10;
end

if babbr=='t',
    rawdata=mysql(['SELECT gDataRaw.* FROM gDataRaw,gCellMaster',...
        ' where penid=',num2str(globalparams.penid),...
        ' AND gDataRaw.masterid=gCellMaster.id']);
    rawcount=length(rawdata);
    mfile=sprintf('%s%s%s%s%s%s_%s_%s_%d.m',globalparams.outpath,...
                      globalparams.Ferret,filesep,...
                      subdir,filesep,...
                      globalparams.Ferret,datestr(now,'yyyy_mm_dd'), ...
                      runclass,rawcount+1);
    evpfilename=sprintf('%s%s%s%s%s%s_%s_%s_%d.evp',globalparams.outpath,...
                        globalparams.Ferret,filesep,...
                        subdir,filesep,...
                        globalparams.Ferret,datestr(now,'yyyy_mm_dd'), ...
                        runclass,rawcount+1);
else
    mfile=sprintf('%s%s%s%s%s%s%02d_%s_%s.m',globalparams.outpath,...
                      globalparams.Ferret,filesep,...
                      subdir,filesep,...
                      globalparams.SiteID,rawcount+1,babbr,runclass);
    evpfilename=sprintf('%s%s%s%s%s%s%02d_%s_%s.evp',globalparams.outpath,...
                        globalparams.Ferret,filesep,...
                        subdir,filesep,...
                        globalparams.SiteID,rawcount+1,babbr,runclass);
end

if 1,
    prompt={'Save to:                                                         _'};
    name='m-file name';
    numlines=1;
    defaultanswer={mfile};
    options.Resize='off';
    options.Interpreter='none';
    switch lower(globalparams.Tester)
		case {'yves','jennifer','jonatan','anna','thibaut','celian','rupesh','jeff','xinhe'}; answer = defaultanswer;      otherwise
        answer=inputdlg(prompt,name,numlines,defaultanswer,options);
    end
    if ~isempty(answer),
        mfile=answer{1};
        [t1,t2,t3]=fileparts(mfile);
        evpfilename = [t1 filesep t2 '.evp'];
        rawid=dbcreateraw(globalparams,runclass,mfile,evpfilename);
    else
        mfile='';
        rawid=-1;
    end
else
    yn=questdlg(sprintf('File %s doesn''t exist in cellDB. Create it?',mfile), ...
        'cellDB','Yes','No','Cancel','Yes');
    if isempty(yn) | strcmp(yn,'Yes'),
        rawid=dbcreateraw(globalparams,runclass,mfile,evpfilename);
    elseif strcmp(yn,'Cancel'),
        rawid=-1;
    else
        rawid=0;
    end
end
