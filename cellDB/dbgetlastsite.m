% function siteid=dbgetlastsite(Ferret, doingphysiology);
function siteid=dbgetlastsite(Ferret, doingphysiology);

if ~dbopen,
   siteid='';
   return;
end
sql=sprintf('SELECT * FROM gAnimal WHERE animal like "%s"',Ferret);
adata=mysql(sql);
if length(adata)==0,
    warning('%s not in celldb\n',Ferret);
    siteid='';
    return;
end
animal=adata(1).animal;

% find most recent penetration and time that last site was updated in DB
sql=['SELECT gPenetration.id as maxid,',...
     ' time_to_sec(timediff(now(),gCellMaster.lastmod))/86400 as daylag',...
     ' FROM gPenetration,gCellMaster',...
     ' WHERE gPenetration.id=gCellMaster.penid',...
     ' AND gPenetration.training=',num2str(1-doingphysiology),...
     ' AND gPenetration.animal="',animal,'"'...
     ' ORDER BY gPenetration.id DESC,gCellMaster.id DESC LIMIT 1'];
lastpendata=mysql(sql);
if length(lastpendata)>0,
    daylag=lastpendata.daylag;
else
    daylag=1; % force new site
end

if length(lastpendata)==0 || isempty(lastpendata.maxid) | strcmp(lastpendata.maxid,'NULL'),

    warning(['No penetrations exist for this animal. Guessing SiteID' ...
        ' from scratch.']);
    if doingphysiology,
        siteid=[adata(1).cellprefix,'001a'];
    else
        siteid=[adata(1).cellprefix,'001Ta'];
    end
    return
else
    sql=['SELECT penid,max(siteid) as siteid FROM gCellMaster'...
        ' WHERE penid=',num2str(lastpendata.maxid),' GROUP BY penid'];
    tpendata=mysql(sql);

    if length(tpendata)==0,
        siteid='';
    else
        siteid=tpendata.siteid;
    end
    if isempty(siteid),
        % no sites for this penetration yet
        sql=['SELECT * FROM gPenetration'...
            ' WHERE id=',num2str(lastpendata.maxid)];
        lastpendata=mysql(sql);
        if doingphysiology,
            siteid=[lastpendata.penname,'a'];
        else
            siteid=[lastpendata.penname,'Ta'];
        end
    end

    % if more than 12 hours since last change to gCellMaster, assume that
    % this is a new site.
    if daylag>=0.5,
        numidx=find(siteid>='0' & siteid<='9');
        pennum=str2num(siteid(numidx));

        if doingphysiology,
            siteid=[siteid(1:numidx(1)-1) sprintf('%03d',pennum+1) 'a'];
        else
            siteid=[siteid(1:numidx(1)-1) sprintf('%03d',pennum+1) 'Ta'];
        end
        %fprintf('guessing new penetration/site: %s\n',siteid);
    end
end
