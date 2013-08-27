function [unitmean,unitstd,spkcount,xaxis,tmplrawid,spkraw,extras]=spk_template(siteid,chanNum);

[rawdata,site,celldata,rcunit,rcchan]=dbgetsite(siteid);

for ii=1:length(rawdata),
   spikefile=basename(rawdata(ii).matlabfile);
   fprintf('%2d. %s (%s)\n',ii, ...
           basename(rawdata(ii).parmfile),spikefile);
end
disp('');
filedata=dbchooserawfile(1,'Choose template file');

drawnow;

if ~isempty(filedata),
    tmplrawid=filedata.rawid;
    evpfile1=filedata.evpfile;
    spikefile1=filedata.spikefile;
    parmfile1=filedata.parmfile;
else
    tmplrawid=-1;
end

abaflag=0;

if tmplrawid>0 & exist(spikefile1),
   disp('loading full meskres template');
   spkdata=load(spikefile1);
   cn=str2num(chanNum);
   if isfield(spkdata,'sortextras') & length(spkdata.sortextras)>=cn &...
          ~isempty(spkdata.sortextras{cn}),
      unitmean=spkdata.sortextras{cn}.unitmean;
      unitstd=spkdata.sortextras{cn}.unitstd;
      xaxis=spkdata.sortinfo{cn}{1}(1).xaxis;
      unitcount=spkdata.sortinfo{cn}{1}(1).Ncl;
      
      for ii=1:unitcount,
         spkcount(ii)=size(spkdata.sortinfo{cn}{1}(ii).unitSpikes,2);
      end
      extras=[];
      spkraw=[];
      return
   end
end

if tmplrawid>0,
   disp('loading dumb, clunky template');
   
   % load and filter evp file1
   [spkraw, extras]=loadevp(parmfile1,evpfile1,chanNum);
   [spfile,sppath]=basename(spikefile1);
   classtot = 12;
   
   [Ws, Wt, Ss, St, st, spiketemp, spktemp, xaxis]=...
       importfile(spfile,sppath,[],spkraw,classtot,str2num(chanNum),abaflag);
   
   % figure out what spike templates look like
   unitcount=0;
   spikeid=zeros(size(st));
   for ii=1:length(spktemp),
      if length(spktemp{ii})>0,
         unitcount=ii;
         spikeid(find(ismember(st,spktemp{ii})))=ii;
      end
   end
   
   unitmean=zeros(size(spiketemp,1),unitcount);
   unitstd=zeros(size(spiketemp,1),unitcount);
   spikecount=zeros(unitcount,1);
   
   for ii=1:unitcount,
      matchspikes=find(spikeid==ii);
      
      unitmean(:,ii,1)=mean(spiketemp(:,matchspikes),2);
      unitstd(:,ii,1)=std(spiketemp(:,matchspikes),0,2);
      spkcount(ii)=length(matchspikes);
   end
   
else
   
   disp('no template');
   unitcount=0;
   spkcount=[];
   unitmean=[];
   unitstd=[];
   xaxis=[-10 20];
   extras=[];
   spkraw=[];
end

