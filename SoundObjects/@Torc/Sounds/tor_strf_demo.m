function [strf0,bf,bw,lat,offlat,snr,linpred]=tor_strf_demo(r,TorcObject,rasterfs);

if ~exist('rasterfs','var'),
    rasterfs=1000;
end

% compute the strf
INC1STCYCLE=0;
[strf0,snr,StimParam,strfee]=strf_est_core(r,TorcObject,rasterfs,INC1STCYCLE,16);

% do a bunch of jackknifing to get error bars on the STRF
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
   lat=round(latbin.*1000./rasterfs);
   offlat=round(durbin.*1000./rasterfs);
   fprintf('onset/offset latency %d/%d ms\n',lat,offlat);
else
   latbin=0;
   lat=0;
   durbin=0;
   offlat=0;
   fprintf('no significant onset latency\n');
end

% show some results

figure;
subplot(1,2,1);

% plot the strf
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
title(sprintf('%s - BF %d Hz','STRF',bf),...
      'Interpreter','none');
xlabel(sprintf('SNR %.2f linxc %.2f',snr,linpred));

% plot temporal response
subplot(1,2,2);

errorbar(irsmooth,ireesmooth);
hold on
plot([1 length(irsmooth)],[mb mb],'k--');
plot([latbin latbin],[0 max(irsmooth)+max(ireesmooth)],'r--');
plot([durbin durbin],[0 max(irsmooth)+max(ireesmooth)],'r--');
hold off
axis tight
title(sprintf('On/Off Lat %d/%d ms',lat,offlat));
