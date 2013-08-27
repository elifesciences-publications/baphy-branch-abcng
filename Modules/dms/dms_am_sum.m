%function dms_summ(animal,startdate,phys);

baphy_set_path

if ~exist('animals','var'),
   animals={'cassandra','ming'};
end
if ~exist('startdate','var'),
   startdate='2008-01-01'
end
if ~exist('phys','var'),
   phys=0;
end
if ~exist('HWSetup','var'),
   HWSetup=[]
   %HWSetup=[1 3]
end

HWSetupString='(';
for ii=1:length(HWSetup),
    HWSetupString=[HWSetupString,num2str(HWSetup(ii)),','];
end
HWSetupString(end)=')';
if phys==0,
   phys_str=' AND gDataRaw.training';
elseif phys==1,
   phys_str=' AND not(gDataRaw.training)';
else,
   phys_str='';
end

dbopen;

if strcmp(computer,'PCWIN'),
   resppathbase='/auto/data/';
   %resppathbase='M:\';
else
   resppathbase='/auto/data/';
end


animalcount=length(animals);
mm=zeros(4,animalcount);
ee=zeros(4,animalcount);
   

for animalidx=1:animalcount,
   
   animal=animals{animalidx};
   
   if ~isempty(HWSetup),
      sql=['SELECT gDataRaw.*',...
           ' FROM (gDataRaw INNER JOIN gCellMaster',...
           ' ON gDataRaw.masterid=gCellMaster.id)',...
           ' INNER JOIN gPenetration ON gCellMaster.penid=gPenetration.id',...
           ' INNER JOIN gData ON (gData.rawid=gDataRaw.id AND gData.name="HWSetup")',...
         ' WHERE gPenetration.animal like "',animal,'"',...
           ' AND gPenetration.pendate >= "',startdate,'"',...
           ' AND not(gDataRaw.bad)',...
           ' AND gDataRaw.runclass="DMS" AND corrtrials>0',...
           ' AND gDataRaw.resppath like "',resppathbase,'%"',...
           ' AND gData.value in ',HWSetupString,...
           phys_str,...
           ' ORDER BY pendate,gCellMaster.siteid,gDataRaw.id'];
   elseif phys==0 || strcmp(animal,'bom'),
      sql=['SELECT gDataRaw.*',...
           ' FROM (gDataRaw INNER JOIN gCellMaster',...
           ' ON gDataRaw.masterid=gCellMaster.id)',...
           ' INNER JOIN gPenetration ON gCellMaster.penid=gPenetration.id',...
           ' WHERE gPenetration.animal like "',animal,'"',...
           ' AND gPenetration.pendate >= "',startdate,'"',...
           ' AND not(gDataRaw.bad)',...
           ' AND gDataRaw.runclass="DMS" AND corrtrials>0',...
           ' AND gDataRaw.resppath like "',resppathbase,'%"',...
           phys_str,...
           ' ORDER BY pendate,gCellMaster.siteid,gDataRaw.id'];
   else
      sql=['SELECT gDataRaw.*',...
           ' FROM (gDataRaw INNER JOIN gCellMaster',...
           ' ON gDataRaw.masterid=gCellMaster.id)',...
           ' INNER JOIN gPenetration ON gCellMaster.penid=gPenetration.id',...
           ' LEFT JOIN gData ON gData.rawid=gDataRaw.id',...
           ' WHERE gPenetration.animal like "',animal,'"',...
           ' AND gPenetration.pendate >= "',startdate,'"',...
           ' AND not(gDataRaw.bad)',...
           ' AND (gData.name="Overlay_Ref_Tar" AND gData.value=0)',...
           ' AND gDataRaw.runclass="DMS" AND corrtrials>0',...
        ' AND gDataRaw.resppath like "',resppathbase,'%"',...
           phys_str,...
           ' ORDER BY pendate,gCellMaster.siteid,gDataRaw.id'];
   end
   rawdata=mysql(sql);
   filecount=length(rawdata);

   di=zeros(filecount,1);
   di_err=zeros(filecount,1);
   acount=zeros(filecount,1);
   dcount=zeros(filecount,1);
   am=zeros(filecount,1);
   
   for ii=1:filecount,
      sql=['SELECT * FROM gData WHERE rawid=',num2str(rawdata(ii).id),...
           ' AND name in ("DI","DI_err","Tar_AM","Tar_FirstToneSubset",',...
           '"Tar_SecondToneSubset")',...
           ' ORDER BY name'];
      datadata=mysql(sql);
      if length(datadata)==5,
         for jj=1:length(datadata),
            if datadata(jj).datatype==1,
               datadata(jj).value=str2num(datadata(jj).svalue);
            end
         end
         di(ii)=(datadata(1).value);
         di_err(ii)=(datadata(2).value);
         am(ii)=max(datadata(3).value);
         acount(ii)=length(datadata(4).value);
         dcount(ii)=length(datadata(5).value);
         
         fprintf('%s: AM: %d  A carriers: %d  D carriers: %d\n',...
                 rawdata(ii).parmfile,am(ii),acount(ii),dcount(ii));
         
      else
      % bad
      end
   end
   
   [mm(1,animalidx),ee(1,animalidx)]=...
       jackmeanerr(di(find(acount==1 & dcount==1)));
   [mm(2,animalidx),ee(2,animalidx)]=...
       jackmeanerr(di(find(acount==1 & dcount==5)));
   [mm(3,animalidx),ee(3,animalidx)]=...
       jackmeanerr(di(find(acount==5 & dcount==1)));
   [mm(4,animalidx),ee(4,animalidx)]=...
       jackmeanerr(di(find(acount==5 & dcount==5)));
end

figure(1);
clf
bar(mm');
hold on
for jj=1:4,
   errorbar((1:animalcount)+(jj-2.5)./5.5,mm(jj,:),ee(jj,:),'sk');
end
hold off
aa=axis;
axis([0.5 animalcount+0.5 0.5 1]);

legend('C_A=1,C_F=1','C_A=1,C_F=5','C_A=5,C_F=1','C_A=5,C_F=5');

