% function [sitelist,sitedata,mfiles]=dbfindsites(options)
%
% options.XX can be:
%  runclass(es) (comma-separated string)
%  runclassrequired
%  sorted [1]  if 1, only find sites that have been sorted
%  area ['FC']
%  extravars/extrarules = cell arrays of {gData.name}/{sql WHEREs}
%
% TBD:
%  firstbehavioronly
%  animal
function [sitelist,sitedata,mfiles]=dbfindsites(options)

if ~exist('options','var'),
   options=[];
end
options.runclass=getparm(options,'runclass','PTD');
options.runclassrequired=getparm(options,'runclassrequired','');
options.firstbehavioronly=getparm(options,'firstbehavioronly',0);
options.area=getparm(options,'area','FC');
options.sorted=getparm(options,'sorted',1);
options.min_DR=getparm(options,'min_DR',0);
options.requirelfp=getparm(options,'requirelfp',0);
options.extravars=getparm(options,'extravars',{});
options.extrarules=getparm(options,'extrarules',{});

taskstr=['"',strrep(options.runclass,',','","'),'"'];

if ~isempty(options.runclassrequired),
   taskreqstring=[' AND runclass="' options.runclassrequired '"'];
else
   taskreqstring='';
end
if options.sorted,
   sortedstr=[' AND not(isnull(gDataRaw.matlabfile)',...
             '         OR gDataRaw.matlabfile="")'];
else
   sortedstr='';
end
switch options.area,
 case 'FC',
  areastr=[' AND (gCellMaster.siteid like "plu2%"',...
           '      OR gCellMaster.siteid like "plu3%"',...
           '      OR gCellMaster.siteid like "a3%"',...
           '      OR gCellMaster.area like "%FC%")'];
 case 'AC',
  areastr=' AND (gCellMaster.area like "A%" OR gCellMaster.area like "%,A%")';
 case 'A1',
  areastr=' AND gCellMaster.area like "%A1%"';
 case 'NB',
  areastr=' AND (gCellMaster.area like "%NB%")';
 otherwise
  areastr='';
end

if options.requirelfp,
   lfpstr=[' AND not(gCellMaster.siteid like "D0%" OR',...
           ' gCellMaster.siteid like "r2%" OR',...
           ' gCellMaster.siteid like "s1%")'];
else
   lfpstr='';
end

if options.firstbehavioronly,
   error('firstbehavioronly not supported');
   sitelist={'plu205a','plu206e','plu207b','plu208b','plu209b',...
             'plu210b','plu211a','plu214b'};
   sitedata=[];
else
   sql=['SELECT DISTINCT gCellMaster.* FROM gCellMaster,gDataRaw',...
        ' WHERE gDataRaw.masterid=gCellMaster.id',...
        ' AND gDataRaw.runclass in (',taskstr,')',...
        ' AND gDataRaw.behavior="active"',...
        ' AND not(gDataRaw.bad)',...
        ' AND not(gDataRaw.training)',...
        ' AND not(gCellMaster.animal="Test")',...
        taskreqstring,...
        areastr,...
        sortedstr,...
        lfpstr,...
        ' ORDER BY gDataRaw.id'];
end

dbopen;
sitedata=mysql(sql);

keepidx=zeros(length(sitedata),1);
if options.min_DR>0,
   for ii=1:length(sitedata),
      sql=['select * from gData where masterid=',num2str(sitedata(ii).id),...
           ' AND name="DiscriminationRate"'];
      drdata=mysql(sql);
      dr=cat(1,drdata.value);
      max_dr=max(dr);
      
      if max_dr>=options.min_DR,
         fprintf('site %s DR %.1f > %.1f\n',sitedata(ii).siteid,max_dr,options.min_DR);
         keepidx(ii)=1;
      else
         fprintf('site %s DR %.1f < %.1f. excluded.\n',sitedata(ii).siteid,max_dr,options.min_DR);
      end
   end
   sitedata=sitedata(find(keepidx));
end

for ii=1:length(options.extravars),
   varname=options.extravars{ii};
   rule=options.extrarules{ii};
   keepidx=zeros(length(sitedata),1);
   
   for ii=1:length(sitedata),
      sql=['select * from gData where masterid=',num2str(sitedata(ii).id),...
           ' AND name="',varname,'" AND ',rule];
      drdata=mysql(sql);
      
      if length(drdata)>0,
         keepidx(ii)=1;
         fprintf('site %s matches rule: %s : %s\n',...
                 sitedata(ii).siteid,varname,rule);
      else
         fprintf('site %s fails rule: %s : %s\n',...
                 sitedata(ii).siteid,varname,rule);
      end
   end
   sitedata=sitedata(find(keepidx));
end


sitelist=cell(1,length(sitedata));
[sitelist{:}]=deal(sitedata.siteid);

if nargout>2,

   mfiles={};
   for ii=1:length(sitelist),
      [rawdata,site,celldata,rcunit,rcchan]=dbgetsite(sitelist{ii});
      
      mfiles{ii}={};
      for jj=1:length(rawdata),
         if ~isempty(rawdata(jj).matlabfile) & ...
               exist(rawdata(jj).matlabfile,'file') & ...
            ~isempty(findstr(options.runclass,rawdata(jj).runclass)),
            
            mfiles{ii}{length(mfiles{ii})+1}=[rawdata(jj).resppath ...
                    rawdata(jj).parmfile];
         end
      end
   end
end


