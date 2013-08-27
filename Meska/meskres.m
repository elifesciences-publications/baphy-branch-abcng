% meskres.m  ... what seems to be an alternative to meska.

clear

filedata=dbchooserawfile(0,'Choose file to sort');

if isempty(filedata),
    disp('meskres cancelled.');
    return
end

rawid=filedata.rawid;
siteid=filedata.siteid;
evpfile2=filedata.evpfile;
spikefile2=filedata.spikefile;
parmfile2=filedata.parmfile;

chanNum=num2str(filedata.channel); % default

abaflag=0;

disp('choose spike template from already sorted file (or cancel for no template)');
[unitmean,unitstd,spkcount,xaxis,tmplrawid,spkraw,extras]=spk_template(siteid,chanNum);
unitcount=size(unitmean,2);

% load and filter evpfile2
if tmplrawid==rawid & ~isempty(extras),
   % keep currently loaded spkraw and extras
else
   clear spkraw
   [spkraw, extras]=loadevp(parmfile2,evpfile2,chanNum);
end
% save some memory
spkraw=single(spkraw);

chanstr={'a','b','c','d','e'};
cellids={};
for ii=1:12,
   if extras.numChannels>1,
      cellids{ii}=sprintf('%s-%s%d',siteid,chanstr{str2num(chanNum)},ii);
   else
      cellids{ii}=sprintf('%s-%d',siteid,ii);
   end
end

spk_cluster;
