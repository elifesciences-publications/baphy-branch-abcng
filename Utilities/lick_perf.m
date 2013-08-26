function [dr,di,di_snr,lickrate,snr_list]=lick_perf(parmfile,verbose)

global ES_SHADE

options=[];
if ~exist('rasterfs','var'),
   rasterfs=40;
end
if ~exist('verbose','var'),
   verbose=0;
end

dbopen;
parmbase=basename(parmfile);
if ~strcmp(parmbase((end-1):end),'.m'),
   parmbase=[parmbase,'.m'];
end

sql=['SELECT * FROM gDataRaw WHERE parmfile="',parmbase,'"'];
rawdata=mysql(sql);

[parm,perf]=dbReadData(rawdata.id);

dr=perf.DiscriminationRate;
if 1 && isfield(perf,'DI'),
   di=perf.DI;
   di_snr=perf.DI_err;
   return
end

options.rasterfs=rasterfs;
options.lfp=2;
options.includeincorrect=1;
options.includeprestim=1;
options.tag_masks={'SPECIAL-COLLAPSE-BOTH'};
[r,tags,trialidx,exptevents]=loadevpraster(parmfile,options);
rnan=isnan(r);
options.tag_masks={'TARGET'};
[rtar,tags,tartrialidx]=loadevpraster(parmfile,options);

if ~isempty(findstr(tags{1},'SNR:'));
   %size of tags gets number of trials? or stimulus, snr stores SNR values for all targets
   snr=zeros(size(tags));
   torc_stim=zeros(size(tags));
   repcount=zeros(size(tags));
   for ii=1:length(tags),
      %strsep= string separate using ',' as separator.  tt=trial tags?
      tt=strsep(tags{ii},',');
      if isempty(findstr('SNR',tt{4}))~=1,
         if length(tt)>3
            tt2=strsep(tt{4},' ');
            snr(ii)=tt2{3};
         end
      end
      if ~isempty(findstr(tt{2},'TORC')),
         torc_stim(ii)=1;
      end
      
      % how many times was this target repeated
      repcount(ii)=sum(~isnan(rtar(1,:,ii)));
   end
   keeptar=find(~torc_stim);
   snr=snr(keeptar);
   [snr,bb]=sort(snr);
   keeptar=keeptar(bb);
   rtarsnr=rtar(:,:,keeptar);
   tartrialidx=tartrialidx(:,keeptar);
   snrcount=length(snr);
else
   disp('not SNR task');
   snrcount=0;
   di_snr=[];
end


LoadMFile(parmfile);

PreStim=exptparams.TrialObject.ReferenceHandle.PreStimSilence;
Dur=exptparams.TrialObject.ReferenceHandle.Duration;
PostStim=exptparams.TrialObject.ReferenceHandle.PostStimSilence;
if PostStim>0.8,
   PostStim=0.8;
   radjlen=round((PreStim+Dur+PostStim).*rasterfs);
   r=r(1:radjlen,:,:);
end

prebins=round(PreStim.*rasterfs);
lastbin=round((PreStim+Dur+0.4).*rasterfs);

% index of last reference on every trial in r
nn1=[find(diff(trialidx(:,1))==1);size(trialidx,1)];
nn2=find(trialidx(:,2)>0);  % index of every target in r
tartrials=find(ismember(trialidx(nn1,1),trialidx(nn2,2)));
nn1=nn1(tartrials); 

% average lick rate before ref/tar
prelickrate_ref=squeeze(nanmean(nanmean(r(1:prebins,nn1,1))));
prelickrate_tar=squeeze(nanmean(nanmean(r(1:prebins,nn2,2))));

tar_lick_adjust=prelickrate_ref-prelickrate_tar;

lickrate=squeeze(nanmean(r(prebins+1:end,:,1:2)));
lickrate(:,2)=lickrate(:,2)+tar_lick_adjust;

bincount=40;
threshrange=linspace(0,1,bincount+1);
jcount=20;
fa=zeros(bincount+2,jcount);
ht=zeros(bincount+2,jcount);
fa(end,:)=1;
ht(end,:)=1;

%nn1=find(~isnan(lickrate(:,1)));
%nn2=find(~isnan(lickrate(:,2)));
js1=length(nn1)./jcount;
js2=length(nn2)./jcount;

jdi=zeros(jcount,1);

for jj=1:jcount,
   nnn1=nn1([1:round((jj-1)*js1) round(jj*js1+1):end]);
   nnn2=nn2([1:round((jj-1)*js2) round(jj*js2+1):end]);
   
   for thidx=1:bincount,
      fa(thidx+1,jj)=mean(lickrate(nnn1,1)<threshrange(thidx+1));
      ht(thidx+1,jj)=mean(lickrate(nnn2,2)<threshrange(thidx+1));
   end
   w=([0;diff(fa(:,jj))]+[diff(fa(:,jj));0])./2;
   di=sum(w.*ht(:,jj));
   w2=([0;diff(ht(:,jj))]+[diff(ht(:,jj));0])./2;
   di2=1-sum(w2.*fa(:,jj));

   jdi(jj)=(di+di2)./2;
end

di=mean(jdi);
di_err=std(jdi).*sqrt(jcount-1);

if snrcount>0,
   di_snr=zeros(snrcount,1);
   fa_snr=zeros(bincount+2,snrcount);
   ht_snr=zeros(bincount+2,snrcount);
   fa_snr(end,:)=1;
   ht_snr(end,:)=1;
   snr_list=zeros(size(nn1));
   for jj=1:snrcount,
      nnn1=nn1(find(ismember(trialidx(nn1,1),tartrialidx(:,jj))));
      nnn2=nn2(find(ismember(trialidx(nn2,2),tartrialidx(:,jj))));
      snr_list(find(ismember(trialidx(nn1,1),tartrialidx(:,jj))))=...
          snr(jj);
      for thidx=1:bincount,
         fa_snr(thidx+1,jj)=mean(lickrate(nnn1,1)<threshrange(thidx+1));
         ht_snr(thidx+1,jj)=mean(lickrate(nnn2,2)<threshrange(thidx+1));
      end
      
      w=([0;diff(fa_snr(:,jj))]+[diff(fa_snr(:,jj));0])./2;
      di1=sum(w.*ht_snr(:,jj));
      w2=([0;diff(ht_snr(:,jj))]+[diff(ht_snr(:,jj));0])./2;
      di2=1-sum(w2.*fa_snr(:,jj));
      
      di_snr(jj)=(di1+di2)./2;
   end
   
else
   di_snr=di_err;
end

lickrate=[lickrate(nn1,1) lickrate(nn2,2)];

nperf=[];
nperf.DI=di;
nperf.DI_err=di_err;

if ~isnan(di),
   dbWriteData(rawdata.id,nperf,1,1);
end

if ~verbose, 
   return
end

figure;

subplot(2,3,1);
tt=(1:size(r,1))./rasterfs - PreStim;

plot([0 0],[0 100],'g--');
hold on
plot([0 0]+Dur,[0 100],'g--');
plot(tt,nanmean(r(:,:,1),2).*100,'b','LineWidth',2);
plot(tt,nanmean(r(:,:,2),2).*100,'r','LineWidth',2);

hold off
axis([tt([1 end]) 0 100]);
title(basename(parmfile),'Interpreter','none');

subplot(2,3,2);
plot(fa,ht,'o');
hold on
plot([0 1],[0 1],'r--');
plot(fa,ht);
mfa=max(fa,[],2);
mht=min(ht,[],2);
for thr=1:length(threshrange),
   if fa(thr)>0 && fa(thr)<1,
      text(mfa(thr)+0.01,mht(thr)-0.04,sprintf('%.0f',threshrange(thr).*100));
   end
end

hold off
xlabel('p(FA)');
ylabel('p(hit)');
title(sprintf('DI=%.2f +/- %.2f',di,di_err));

subplot(2,3,3);
nn=linspace(0,1,11);
b1=hist(lickrate(:,1),nn);
b2=hist(lickrate(:,2),nn);
bar(nn,[b1' b2']);
aa=axis;
axis([-0.05 1.05 aa(3:4)]);
legend('ref','tar');
xlabel('lick rate');
ylabel('number of trials');

if snrcount>0,
   subplot(2,3,4);
   plot([0 0],[0 100],'g--');
   hold on
   plot([0 0]+Dur,[0 100],'g--');
   hr=plot(tt,nanmean(r(:,:,1),2).*100,'k--','LineWidth',2);
   ht=plot(tt,squeeze(nanmean(rtarsnr(:,:,:),2)).*100,'LineWidth',2);
   hold off
   axis([tt([1 end]) 0 100]);
   
   snr_string=strsep(mat2str(snr),' ',1);
   snr_string{1}=snr_string{1}(2:end);
   snr_string{end}=snr_string{end}(1:(end-1));
   legend(ht,snr_string);
   
   subplot(2,3,5);
   plot(fa_snr,ht_snr,'o');
   hold on
   plot([0 1],[0 1],'r--');
   h_di=plot(fa_snr,ht_snr);
   
   hold off
   xlabel('p(FA)');
   ylabel('p(hit)');
   
   di_string=strsep(mat2str(di_snr,2),';',1);
   di_string{1}=di_string{1}(2:end);
   di_string{end}=di_string{end}(1:(end-1));
   legend(h_di,di_string,'Location','southeast');
end



