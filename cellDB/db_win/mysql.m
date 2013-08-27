% function [res,affected,insertid]=mysql(sql,mysql_path);
%
% access mysql client directly from matlab without a mex
% file. slow, but it works.
%
% important globals: 
%   NET_DATA_ROOT - path to /afs/.../nsl/ from local machine [??]
%   MYSQL_BIN_PATH - local path to mysql client [c:\mysql\bin\]
%   DB_SERVER - name of celldb server [bhangra.isr.umd.edu]
%
% created SVD 2005-10-16
% modified SVD 2005-11-21 -- hacked to deal with <cr> in field values.
%                            still can't deal with tabs!
%
function [res,affected,insertid]=mysql(sql,mysql_path);

global NET_DATA_ROOT DB_DATA_ROOT DB_FILESEP MYSQL_BIN_PATH SERVER_PATH
global DB_USER DB_SERVER DB_PASSWORD DB_NAME

if ~exist('sql','var'),
   error('No query specified');
end
if exist('mysql_path','var'),
   MYSQL_BIN_PATH=mysql_path;
elseif isempty(MYSQL_BIN_PATH),
    baphy_set_path;
end
if isempty(MYSQL_BIN_PATH),
   MYSQL_BIN_PATH='c:\mysql\bin\';
end

if (MYSQL_BIN_PATH(end)~=filesep),
   MYSQL_BIN_PATH=[MYSQL_BIN_PATH filesep];
end

% this is what SERVER_PATH looks like in the database... Presumably
% equivalent to LINUX_SERVER_PATH
if isempty(DB_DATA_ROOT),
   DB_DATA_ROOT='/auto/data/';
   DB_FILESEP='/';
end

% NET_DATA_ROOT should be synonymous with SERVER_PATH -- SVD 2012-05-25
if isempty(NET_DATA_ROOT),
  NET_DATA_ROOT=SERVER_PATH;
end

if ~exist(NET_DATA_ROOT,'dir')
    NEW_NET_DATA_ROOT=[fileparts(tempname) filesep];
    warning(sprintf('NET_DATA_ROOT %s not available! guessing %s\n',...
        NET_DATA_ROOT,NEW_NET_DATA_ROOT));
    NET_DATA_ROOT=NEW_NET_DATA_ROOT;
    % disabled this b/c it's a hassle
    if 0
        tt=input(sprintf('path to /afs/...nsl/ [%s\\]: ',strrep(fileparts(tempname),'\','\\')),'s');
        if ~isempty(tt),
            NET_DATA_ROOT=tt;
        else
            NET_DATA_ROOT=[fileparts(tempname) filesep];
        end
        if ~exist(NET_DATA_ROOT,'dir'),
            fprintf('%s does not exist.\n',NET_DATA_ROOT);
        end
    end
end

if (NET_DATA_ROOT(end)~=filesep),
   NET_DATA_ROOT=[NET_DATA_ROOT filesep];
end

% set to defaults if not set
if isempty(DB_SERVER),
   DB_SERVER='bhangra.isr.umd.edu';
end
if isempty(DB_USER),
   DB_USER='david';
end
if isempty(DB_PASSWORD),
   DB_PASSWORD='nine1997';
end
if isempty(DB_NAME),
   DB_NAME='cell';
end

% figure out type of query
parse=strsep(deblank(sql),' ',1);
if strcmp(upper(parse{1}),'INSERT'),
   querytype=1;
   sql=[sql,'; SELECT LAST_INSERT_ID();'];
elseif strcmp(upper(parse{1}),'UPDATE'),
   querytype=2;
   %sql=[sql,'; SELECT ROW_COUNT(),LAST_INSERT_ID();'];
else
   querytype=0;
end

if querytype>0 && ~strcmp(NET_DATA_ROOT,DB_DATA_ROOT),
   sql=strrep(sql,NET_DATA_ROOT,DB_DATA_ROOT);
   sql=strrep(sql,filesep,DB_FILESEP);
end

% avoid quoting problems
sql=strrep(sql,'\','\\');
% sql=strrep(sql,'>','^>');
% sql=strrep(sql,'<','^<');
sql=strrep(sql,'"','\"');
sql=strrep(sql,char(10),'\n');

Port=strsep(DB_SERVER,':',1);
if length(Port)>1,
    tserver=Port{1};
    Port=Port{2};
else
    tserver=DB_SERVER;
    Port='3306';
end
% construct mysql command-line query
cmd=[MYSQL_BIN_PATH,'mysql --host="',tserver, ...
    '" --user=',DB_USER,' --password=',DB_PASSWORD,...
    ' --port=',Port,...
    ' --raw --column-names' ...
    ' --database=',DB_NAME ...
    ' --exec="',sql,'"'];
[w,s]=system(cmd);

if w,
   error(sprintf('Error running external mysql: %s for SQL: %s',s,sql));
   return
end

if querytype==2,
   % special coping with UPDATE
   res=1;
   affected=0;
   insertid=0;
   return
end

% populate a results structure. NOTE: all values are currently saved as strings
ts=strsep(s,char(10),1);
if length(ts)>0,
    titles=strsep(deblank(ts{1}),char(9));
    %fprintf('%d rows...\n',length(s)-2);
else
    titles={};
    %disp('no results...');
end
fieldcount=length(titles);

if querytype==1,
   % special coping with INSERT
   res=1;
   affected=1;
   insertid=str2num(ts{2});
   return
end

if length(s)<2,  % ie, no matches
   if 0,
      tstr='res=struct(';
      for ii=1:length(titles),
         tstr=[tstr,titles{ii},',{},'];
      end
      tstr(end)=')';
      tstr=[tstr,';']
      eval(tstr);
   else
      res=struct('id',{},'cellid',{});
   end
   return
end

if ~strcmp(NET_DATA_ROOT,DB_DATA_ROOT),
   % identify target fields for fixing path
   fstat=zeros(length(titles),1);
   for jj=1:length(titles),
      if ~isempty([findstr(titles{jj},'file') findstr(titles{jj},'path')]),
         fstat(jj)=1;
      end
   end
end
ts=s(min(find(s==char(10)))+1:end);

ii=1;
while length(ts)>0,
    ii=ii+1;
    ff=find(ts==char(9));
    if length(ff)>=fieldcount,
        rowend=max(find(ts(1:ff(fieldcount))==char(10)));
    else
        rowend=length(ts);
    end
    ss=strsep(ts(1:rowend-1),char(9),1);
    ts=ts(rowend+1:end);
    
    if length(ss)>=length(titles),
      tres=[];
      for jj=1:length(titles),
         if length(ss{jj})==0 | strcmp(ss{jj},'NULL'),
            tres=setfield(tres,titles{jj},'');
         elseif fstat(jj),
            tv=strrep(ss{jj},DB_DATA_ROOT,NET_DATA_ROOT);
            tv=strrep(tv,DB_FILESEP,filesep);
            tres=setfield(tres,titles{jj},tv);
         elseif ss{jj}=='j',
            tres=setfield(tres,titles{jj},'j');
         else
            
            try,
               tts=str2double(ss{jj});
               if ~isnan(tts),
                  tres=setfield(tres,titles{jj},tts);
               else
                  tres=setfield(tres,titles{jj},ss{jj});
               end
            catch
               tres=setfield(tres,titles{jj},ss{jj});
            end
         end
      end
      if ii==2,
         res=tres;
      else
         res(ii-1)=tres;
      end
   end
end
