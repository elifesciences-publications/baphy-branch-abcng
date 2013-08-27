% function dbWriteTuning(cellid,t,append);
%
% cellid - name of cell (entry in gSingleCell)
% t - structure with each field either a scalar, matrix or string
% append - if 1, append contents of t to existing structure
%          (but overwrite any matching field names, default 0)
%
% created SVD 2011-10-29
%
function dbWriteTuning(cellid,t,append);

dbopen;

if ~exist('append','var'),
   append=0;
end

fn=fieldnames(t);

if append,
   tnew=dbReadTuning(cellid);
   tnew=rmfield(tnew,'cellid');
   for ii=1:length(fn),
      tnew.(fn{ii})=t.(fn{ii})
   end
   t=tnew;
   fn=fieldnames(t);
end

tuningstr=[];
for ii=1:length(fn),
   val=getfield(t,fn{ii});
   
   if isnumeric(val),
      ts=sprintf('t.%s=%s;',fn{ii},mat2str(val));
   else
      ts=sprintf('t.%s=''%s'';',fn{ii},val);
   end
   
   tuningstr=[tuningstr ts];
   
end

sql=['UPDATE gSingleCell set tuningstring="',tuningstr,'"',...
     ' WHERE cellid="',cellid,'"'];
mysql(sql);

fprintf('Saved %d tuning parameters for cellid %s\n',length(fn),cellid);
