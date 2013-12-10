% function
% [bf,bw,lat,offlat,snr,linpred,strf0]=tor_tuning(parmfile,spikefile,channum,unit,plotaxes);
%
% alternative call:  tor_tuning(cellid)
% queries cellDB to find first torc file for the specified cellid
% and uses that file for tuning anlaysis
%
function [bf,bw,lat,offlat,snr,linpred,strf0]=tor_tuning(parmfile,spikefile,channum,unit,plotaxes);

rasterfs=1000;
if ~exist('plotaxes','var'),
   plotaxes=[];
end

if ~exist(parmfile,'file') && ~exist([parmfile '.m'],'file'),
    % try the database,
    cellid=parmfile;
    sql=['SELECT * FROM sCellFile WHERE cellid="',cellid,'"',...
         ' AND runclassid=1'];
    torfiledata=mysql(sql);
    if ~isempty(torfiledata),
        parmfile=[torfiledata(1).stimpath torfiledata(1).stimfile];
        spikefile=[torfiledata(1).path torfiledata(1).respfile];
        channum=torfiledata(1).channum;
        unit=torfiledata(1).unit;
    else
        disp('TORC data not found');
        return
    end
end

options=[];
options.rasterfs=rasterfs;
options.includeprestim=0;
options.tag_masks={'Reference'};
options.channel=channum;
options.unit=unit;
fprintf('loading TOR raster for %s\n',...
        basename(spikefile));
[r,tags,trialset,exptevents]=loadspikeraster(spikefile,options);

LoadMFile(parmfile);

if isfield(exptparams.TrialObject,'Torchandle'),
   TorcObject=exptparams.TrialObject.Torchandle;
else
   TorcObject=exptparams.TrialObject.ReferenceHandle;
end

% this may be unnecessary....
TorcNames=TorcObject.Names;
for ii=1:length(TorcNames),
   bb=strsep(TorcNames{ii},' ',0);
   TorcNames{ii}=bb{1};
end

rold=r;

r=zeros(size(r,1),size(r,2),length(TorcNames)).*nan;
for ii=1:length(tags),
   bb=strsep(tags{ii},',',1);
   if ~strcmpi(strtrim(bb{3}),'Target')
      bb=strtrim(bb{2});
      jj=find(strcmp(bb,TorcNames));
      if ~isempty(jj),
         minrep=min(find(isnan(r(1,:,jj))));
         r(:,minrep:end,jj)=rold(:,1:(end-minrep+1),ii);
         %tags{ii}
         %[ii jj minrep]
         %r(:,:,jj)=rold(:,:,ii);
         %fprintf('mapping %d -> %d\n',jj,ii);
      end
   end
end

INC1STCYCLE=0;
[strf0,snr,StimParam,strfee]=strf_est_core(r,TorcObject,rasterfs,INC1STCYCLE,16);

pred=strf_torc_pred(strf0,StimParam.StStims);
if INC1STCYCLE,
   FirstStimTime=0;
else
   FirstStimTime=250;
end
numreps=size(r,2);
numstims=size(r,3);
[stimX,stimT,numstims] = size(StimParam.StStims);

ruse=r((FirstStimTime+1):end,:,:);
cyclesperrep=size(ruse,1)./StimParam.basep;
totalreps=numreps.*cyclesperrep;

ruse=reshape(ruse,StimParam.basep,totalreps,numstims);

jackcount=16;
jstrf=zeros([size(strf0) jackcount]);
jackstep=totalreps./jackcount;
mm=round(totalreps./2);
xc=zeros(jackcount,1);
for jj=1:jackcount,
   estidx=(1:mm)+round((jj-1).*jackstep);
   estidx=mod(estidx-1,totalreps)+1;
   validx=setdiff(1:totalreps,estidx);
   tr=nanmean(ruse(:,estidx,:),2);
   trval=squeeze(nanmean(ruse(:,validx,:),2));
   jstrf(:,:,jj)=strf_est_core(tr,TorcObject,rasterfs,1);
   
   pred=strf_torc_pred(jstrf(:,:,jj),StimParam.StStims);
   trval2=zeros(size(pred));
   for ii=1:size(trval,2),
      trval2(:,ii)=resample(trval(:,ii),stimT,StimParam.basep);
   end
   xc(jj)=xcov(trval2(:),pred(:),0,'coeff');
end
linpred=mean(xc);
%strfmm=mean(jstrf,3);
%strfee=std(jstrf,0,3) * sqrt(jackcount-1);


% extract tuning properties

maxoct=log2(StimParam.hfreq./StimParam.lfreq);
stepsize2=maxoct./(size(strf0,1));

smooth = [100 size(strf0,2)];
tstrf0=gsmooth(strf0,[0.5 0.001]);

strfsmooth = interpft(strf0,smooth(1),1);
strfeesmooth = interpft(strfee,smooth(1),1);

ff=exp(linspace(log(StimParam.lfreq),...
                log(StimParam.hfreq),size(strfsmooth,1)));

mm=mean(strfsmooth(:,1:7).*(strfsmooth(:,1:7)>0),2);
if sum(abs(mm))>0,
   bfidx=median(find(mm==max(mm)));
   bf=round(ff(bfidx));
   bfshiftbins=(maxoct./2-log2(bf./StimParam.lfreq))./stepsize2;
else
   bf=0;
   bfshiftbins=0;
end

bw=sum(mm>=max(mm)./2) ./ length(mm).*(maxoct-1);

mmn=mean(strfsmooth(:,1:7).*(strfsmooth(:,1:7)<0),2);
if sum(abs(mmn))>0,
   wfidx=median(find(mmn==min(mmn)));
   wf=round(ff(wfidx));
   wfshiftbins=(maxoct./2-log2(wf./StimParam.lfreq))./stepsize2;
else
   wf=0;
   wfshiftbins=0;
end

if -mmn(wfidx)>mm(bfidx),
   % if stronger negative component, calculate latency with that
   shiftbins=wfshiftbins;
   irsmooth = -interpft(strfsmooth(wfidx,:),250);
   ireesmooth = interpft(strfeesmooth(wfidx),250);
else
   % otherwise use positive
   shiftbins=bfshiftbins;
   irsmooth = interpft(strfsmooth(bfidx,:),250);
   ireesmooth = interpft(strfeesmooth(bfidx),250);
end

mb=0;
% find significantly modulated time bins
sigmod=find(irsmooth-mb>ireesmooth.*2);
% require latency>=8 ms, max latency less than 125 ms;
sigmod=sigmod(sigmod>=8 & sigmod<125);
if length(sigmod)>3,
   latbin=sigmod(1);
   dd=[diff(sigmod) 41];
   durbin=sigmod(min(find(dd(1:end)>40)));
   %durbin=sigmod(end-2);
   lat=round(latbin.*1000./options.rasterfs);
   offlat=round(durbin.*1000./options.rasterfs);
   fprintf('onset/offset latency %d/%d ms\n',lat,offlat);
else
   latbin=0;
   lat=0;
   durbin=0;
   offlat=0;
   fprintf('no significant onset latency\n');
end


if isempty(plotaxes),
    sfigure(1);
   clf
   subplot(1,2,1);
else
   axes(plotaxes(1));
   cla;
end

stplot(strf0,StimParam.lfreq,StimParam.basep,1,...
       StimParam.octaves);
hold on;
aa=axis;
ydiff=aa(4)-aa(3);
ym=aa(3)+ydiff./2;
ybf=ym-shiftbins./size(strf0,1).*ydiff;
plot(aa(1:2),[ybf ybf],'k--');
plot([latbin latbin],aa(3:4),'k--');
plot([durbin durbin],aa(3:4),'k--');
hold off
axis tight
title(sprintf('%s - BF %d Hz',basename(parmfile),bf),...
      'Interpreter','none');
xlabel(sprintf('SNR %.2f linxc %.2f',snr,linpred));

if isempty(plotaxes),
   subplot(1,2,2);
else
   axes(plotaxes(2));
   cla;
end

errorbar(irsmooth,ireesmooth);
hold on
plot([1 length(irsmooth)],[mb mb],'k--');
plot([latbin latbin],[0 max(irsmooth)+max(ireesmooth)],'r--');
plot([durbin durbin],[0 max(irsmooth)+max(ireesmooth)],'r--');
hold off
axis tight
title(sprintf('On/Off Lat %d/%d ms',lat,offlat));
