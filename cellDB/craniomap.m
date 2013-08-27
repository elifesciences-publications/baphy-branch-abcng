% function craniomap(penname,mapidx);
%
% shows craniotomy map for all penetrations that share wellimage with
% penetration penname
%
% penetration locations should be specified using penlocate gui interface
%
% mapidx - 1 penetration names
%        - 2 best frequency at each location (stored in celldb, unit #1)
%
% created SVD 2007-03-15
%
function craniomap(penname,mapidx);

if ~exist('mapidx','var'),
    mapidx=1;
end

sql=['SELECT * FROM gPenetration WHERE penname="',penname,'"']
pendata=mysql(sql);

if length(pendata)==0,
    errordlg('penetration does not exist!');
    return
end

wellimfile=pendata.wellimfile;

if isempty(wellimfile),
    errordlg('no well image!');
    return
end
animal=pendata.animal;
wellimfilebase=basename(wellimfile);

if mapidx==1,
    % plot penetration name
    sql=['SELECT penname,wellposition,wellfirstspike,numchans FROM gPenetration',...
        ' WHERE animal="',animal,'" and wellimfile like "%',wellimfilebase,'"']
elseif mapidx==2,
    % plot bf (aka "cf" in celldb)
    sql=['SELECT penname,wellposition,wellfirstspike,numchans,avg(cf) as cf',...
        ' FROM gPenetration LEFT JOIN gSingleCell ON gPenetration.id=gSingleCell.penid',...
        ' WHERE animal="',animal,'" and wellimfile like "%',wellimfilebase,'"',...
        ' GROUP BY penname,wellposition,wellfirstspike,numchans'];

else
end

pendata=mysql(sql);

im=imread(wellimfile);
figure
imagesc(im);
axis off;
axis image;
hold on
for ii=1:length(pendata),
    cc=strsep(pendata(ii).wellposition,'+');
    for chanidx=1:pendata(ii).numchans,
        if length(cc)==0,
            xx=0; yy=0;
        else
            xx=strsep(cc{chanidx},',',0);
            yy=xx{2};
            xx=xx{1};
        end
        if mapidx==1, % ie, penname
            if pendata(ii).numchans>1,
                pstring=sprintf('%s-%d',pendata(ii).penname,chanidx);
            else
                pstring=pendata(ii).penname;
            end
        else
            pstring=sprintf('%.0f',pendata(ii).cf);
        end
        
        text(xx,yy,pstring,'HorizontalAlignment','center','VerticalAlignment','middle',...
            'Color',[1 1 1]);
        fprintf('%s: (%d,%d) %s\n',pendata(ii).penname,xx,yy,pstring);
    end
end