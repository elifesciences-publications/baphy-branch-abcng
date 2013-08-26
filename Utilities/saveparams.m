function saveparms(outfile,params,stim,events);

%fid=fopen(outfile,'w');
fid=1;  % stdout
fprintf(fid,'% main parameters\n');

ff=fieldnames(params);
for ii=1:length(ff),
    writefield(fid,'params',ff{ii},getfield(params,ff{ii}));
end

fprintf(fid,'% stimulus parameters\n');
ff=fieldnames(stim);
for jj=1:length(stim),
    for ii=1:length(ff),
        writefield(fid,'stim',ff{ii},getfield(stim,{jj},ff{ii}));
    end
end

fprintf(fid,'% event list\n');
ff=fieldnames(events);
for jj=1:length(events),
    for ii=1:length(ff),
        writefield(fid,'events',ff{ii},getfield(events,{jj},ff{ii}));
    end
end


function writefield(fid,name,ff,dd,jj);

if exist('jj','var'),
    extra=sprintf('(%d)',jj);
else
    extra='';
end 

if isnumeric(dd),
    fprintf(fid,'%s.%s%s=%s;\n',name,ff,extra,mat2string(dd));
elseif iscell(dd),
    fprintf(fid,'%s.%s%s=%s;\n',name,ff,extra,mat2string(dd));
else
    fprintf(fid,'%s.%s%s=''%s'';\n',name,ff,extra,dd);
end
