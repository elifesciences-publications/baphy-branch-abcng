function [pendata,penx,peny]=dbgetpen(penname);

dbopen

disp(['loading info for ' penname]);

sql=['SELECT * FROM gPenetration WHERE penname="',penname,'"'];
pendata=mysql(sql);

pendata.wellposition=char(pendata.wellposition);
cc=strsep(pendata.wellposition,'+');
penx=zeros(pendata.numchans,1);
peny=zeros(pendata.numchans,1);
for ii=1:pendata.numchans,
    if length(cc)==0,
        xx=0; yy=0;
    else
        xx=strsep(cc{ii},',',0);
        yy=xx{2};
        xx=xx{1};
    end
    peny(ii)=yy;
    penx(ii)=xx;
end

