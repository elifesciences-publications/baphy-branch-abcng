% function dbWriteData(rawid,data,parmtype,keep_existing);
%
% rawid - index into gDataRaw table (stored in globalparams.rawid)
% data - structure with each field either a scalar, matrix or string
% parmtype - 'parm' (or 0) - parameters
%            'perf' (of 1) - performance data
% keep_existing - if 1, keep existing data for this rawid (default 0)
%
% created SVD 2006-02-23
%
function dbWriteData(rawid,data,parmtype,keep_existing);

dbopen;
global DB_USER

if ~exist('parmtype','var'),
   parmtype=0;
end
if ~exist('keep_existing','var'),
   keep_existing=0;
end
if ~isnumeric(parmtype) & strcmp(lower(parmtype),'parm'),
   parmtype=0;
elseif ~isnumeric(parmtype) & strcmp(lower(parmtype),'perf'),
   parmtype=1;
elseif ~isnumeric(parmtype),
   parmtype=0;
end

if ~isstruct(data),
   ff=inputname(2);
   if isempty(ff),
      ff='data';
   end
   td=struct(ff,data);
   data=td;
end

fn=fieldnames(data);

if keep_existing,
    % only delete entries that are getting replaced
    namestr='(';
    for ii=1:length(fn),
        namestr=[namestr,'"',fn{ii},'",'];
    end
    namestr(end)=')';
    
    sql=['DELETE FROM gData WHERE rawid=',num2str(rawid),...
        ' AND name in ',namestr,...
        ' AND parmtype=',num2str(parmtype)];
    mysql(sql);
else
    sql=['DELETE FROM gData WHERE rawid=',num2str(rawid),...
        ' AND parmtype=',num2str(parmtype)];
    mysql(sql);
end

rawdata=mysql(['select * FROM gDataRaw WHERE id=', ...
               num2str(rawid)]);

if length(rawdata)==0,
   error(['gRawData.id=',num2str(rawid),' does not exist.']);
end


sql=['INSERT INTO gData (masterid,rawid,name,value,svalue,' ...
     'datatype,parmtype,addedby,info) VALUES '];
for ii=1:length(fn),
   val=getfield(data,fn{ii});
   
   if isnumeric(val) & length(val)==1,
      sql2=sprintf('(%d,%d,"%s",%f,NULL,0,%d,"%s","dbWriteData.m")',...
                   rawdata.masterid,rawid,fn{ii},val,parmtype,...
                   DB_USER);
      
   elseif isnumeric(val),
      ss=mat2str(val);
      sql2=sprintf('(%d,%d,"%s",NULL,"%s",1,%d,"%s","dbWriteData.m")',...
                   rawdata.masterid,rawid,fn{ii},ss,parmtype,...
                   DB_USER);
   elseif ~iscell(val)
      sql2=sprintf('(%d,%d,"%s",NULL,"%s",2,%d,"%s","dbWriteData.m")',...
                   rawdata.masterid,rawid,fn{ii},val,parmtype,...
                   DB_USER);
   end
   
   sql=[sql sql2 ','];
   
end

% remove last comma
sql=sql(1:end-1);
mysql(sql);
fprintf('Saved %d data items for rawid %d\n',length(fn),rawid);