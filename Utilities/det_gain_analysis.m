%function res=det_gain_analysis(r,TorcObject,rasterfs,cellid,svd_clean,tar_freq)
%
% baseline/gain analysis
%
% r{1} = response matrix for "pre" phase
% r{2} = matrix for "during" phase
% r{3} = matrix for "post" phase
% TorcObject - reference object structure stored in baphy mfile
% rasterfs - sampling rate of r
% cellid - name of cell (for display)
% svd_clean - default 0, if >1, only keep 1st svd_clean principle components
%
% returns:
% res.strf0 = strf averaged across all behavior conditions (all of r)
% res.snr0 = snr of res.strf0
% res.rgain = relative gain for each repetition of the torc.
% res.rmean = mean firing rate for each repetition of the torc.
% res.phase = phase of each entry in rgain and rmean
%         (ie, 1=pre, 2=during, 3=post)
% res.mgain = gain averaged over each phase
% res.egain = standard error on each value of mgain computed by
%             jackknifing
% res.strfb = freq X lag X phase strf computed separately for each phase
% res.strfd = difference strf, calculated as difference between
%             res.strfb and mgain * strf0 for each phase
% res.zadorindex = r(phase2)-r(phase1&3) / (r(phase2)+r(phase1&3)) 
%                  [whole transient sustained]
% res.rgainsplit = if requested, fit gain for positive (1st col) and
%                  negative coefficients (2nd col) separately.
%
% created SVD 2008-09-15 (ripped out of det_comp_sum.m)
%
function res=det_gain_analysis(r,TorcObject,rasterfs,cellid,svd_count,tar_freq,jackN)

if ~exist('cellid','var'),
   cellid='CELL';
end
if ~exist('svd_count','var'),
   svd_count=0;
end
if ~exist('tar_freq','var'),
   tar_freq=0;
end
if ~exist('jackN','var'),
   jackN=20;
end

INC1STCYCLE=0;
if INC1STCYCLE,
   FirstStimTime=0;
else
   FirstStimTime=250;
end

if length(r)>3,
   rnolick=r{4};
   r={r{1:3}};
end

phasecount=max(3,length(r));
phase=[];
filemissing=zeros(1,phasecount);
for ii=1:phasecount,
   if length(r)<ii || isempty(r{ii}),
      filemissing(ii)=1;
   end
end
maxlen=inf;
for ii=find(~filemissing),
   if 0,
      % use balanced amount of data from each phase
      tr=r{ii};
      if ii==1 || ii==3,
         ar=r{2};
         
         if size(ar,1)<size(tr,1),
            tr=tr(1:size(ar,1),:,:);
         else
            ar=ar(1:size(tr,1),:,:);
         end
         if size(ar,2)<size(tr,2) && ii==1,
            tr=tr(:,(end-size(ar,2)+1):end,:);
         elseif size(ar,2)<size(tr,2),
            tr=tr(:,1:size(ar,2),:);
         else
            ar=ar(:,1:size(tr,2),:);
         end
         
         tr(find(isnan(ar)))=nan;
      end
   else
      % use all data from each phase
      tr=r{ii};
   end
   
   % average in any stray repetitions of a few recs
   ss=sum(isnan(tr(100,:,:)),3);
   maxss=max(find(ss<15));
   if maxss<size(tr,2),
      tr(:,maxss,:)=nanmean(tr(:,maxss:end,:),2);
      tr=tr(:,1:maxss,:);
   end
   
   if ii==min(find(~filemissing)),
      rall=[];
   elseif size(tr,1)>size(rall,1),
      rall(size(rall,1)+1:size(tr,1),:,:)=nan;
   else
      tr(size(tr,1)+1:size(rall,1),:,:)=nan;
   end
   rall=cat(2,rall,tr);
   phase=cat(1,phase,ones(size(tr,2),1).*ii);
   
   maxlen=min(maxlen,size(r{ii},1));
end

tto=TorcObject;
tto.MaxIndex=size(rall,3);
tto.Duration=size(rall,1)./rasterfs;
disp('estimating baseline STRF without jackknifing...');
% no jackknifing

[strf0,snr0,StimParam]=...
    strf_est_core(rall,tto,rasterfs,INC1STCYCLE,0);

if tar_freq>0,
   sbins=size(strf0,1);
   maxoct=log2(StimParam.hfreq./StimParam.lfreq);
   stepsize2=maxoct./((size(strf0,1))+1);
   tarbin=log2(tar_freq./StimParam.lfreq)./stepsize2+0.5;
else
   tarbin=0;
end


% run svd_clean if svd_count>0
if svd_count,
   strf0=svd_clean(strf0,svd_count);
end

% predict before forcing to match 4:4:48 size
pred=strf_torc_pred(strf0,StimParam.StStims);

pstrf0=strf0.*(strf0>0);
nstrf0=strf0.*(strf0<0);
ppred=strf_torc_pred(pstrf0,StimParam.StStims);
npred=strf_torc_pred(nstrf0,StimParam.StStims);

strf0=imresize(strf0,[15 25],'bilinear');

numreps=length(phase);
[stimX,stimT,numstims] = size(StimParam.StStims);

rresamp=zeros(stimT,numstims,numreps);
rgain=zeros(numreps,1);
rgainsplit=zeros(numreps,2);
rmean=zeros(numreps,1);
disp('fitting gain for each rep...');

for rep=1:numreps,
   for rec=1:numstims,
      
      spkdata = rall(1:maxlen,rep,rec);
      %spkdata = rall(:,rep,rec);
      
      % replace FirstStimTime with 0 if want to include
      % first rep of TORC... probably a bad idea.
      [dsum,cnorm]=makepsth(spkdata,1000/StimParam.basep,...
                            FirstStimTime,StimParam.stdur,StimParam.mf);
      dsum = dsum./(cnorm+(cnorm==0));
      rresamp(:,rec,rep)=rresamp(:,rec,rep)+...
          resample(dsum,stimT,length(dsum));
   end
   
   % if certain torcs weren't played on this rep,
   % exclude them from the gain calculation (for DMS support)
   tr=rresamp(:,:,rep);
   keepidx=find(isnan(rall(101,rep,:))==0);
   rmean(rep)=mean(mean(tr(:,keepidx)));
   tr=tr(:,keepidx)-rmean(rep);
   tp=pred(:,keepidx);
   
   % gain is MMSE scaling term to apply to global
   % prediction to match observed response for this rep
   rgain(rep)=tp(:)'*tr(:) ./ (tp(:)'*tp(:));
   
   pp=ppred(:,keepidx);
   pn=npred(:,keepidx);
   
   A=[pp(:)'*pn(:) pn(:)'*pn(:); pp(:)'*pp(:) pp(:)'*pn(:)];
   y=[tr(:)'*pn(:); tr(:)'*pp(:)];
   b=A.^-1 * y;
   rgainsplit(rep,:)=b';
end

bincount=10;
mr=zeros(bincount,3);
mp=zeros(bincount,3);
bootcount=20;
bgain=zeros(bootcount,phasecount);
for pp=unique(phase')
   rphase=rresamp(:,:,find(phase==pp));
   dd=find(~isnan(rphase));
   dd=shuffle(dd);
   
   for bb=1:bootcount,
      tr=rphase;
      b1=round((bb-1).*(length(dd)./bootcount))+1;
      b2=round(bb.*(length(dd)./bootcount));
      tr(dd(b1:b2))=nan;
      tr=nanmean(tr,3);
      tr=tr(:)-nanmean(tr(:));
      xx=find(~isnan(tr));
      tr=tr(xx);
      tp=pred(xx);
      
      bgain(bb,pp)=tp(:)'*tr(:) ./ (tp(:)'*tp(:));
   end
   
   pphase=repmat(pred,[1 1 size(rphase,3)]);
   
   bb=sort(pphase(:));
   bb=bb(round(linspace(1,length(bb),bincount+1)));
   for ii=1:bincount,
      kk=find(pphase>=bb(ii) & pphase<bb(ii+1));
      mr(ii,pp)=nanmean(rphase(kk));
      mp(ii,pp)=nanmean(pphase(kk));
   end
   
end

mresamp=mean(rresamp,3);
tr=mresamp-mean(mresamp(:));
ggain=pred(:)'*tr(:) ./ (pred(:)'*pred(:));
pred=pred.*ggain;

mgain=mean(bgain)' ./ ggain;
egain=std(bgain)'.*sqrt(bootcount-1) ./ ggain;

rgain=rgain./ggain;
rgainsplit=rgainsplit./ggain;

strfb=zeros(15,25,phasecount);
strferr=zeros(15,25,phasecount);
strfd=zeros(15,25,phasecount);
strfg=zeros(15,25,phasecount);
snrb=zeros(phasecount,1);
strfsnrbal=zeros(15,25,phasecount);
snrbal=zeros(phasecount,1);
rmatched={[],[],[]};
z=zeros(phasecount,3);

disp('jackknifing to get error on behavior-conditioned strfs');

% separate STRFs for each condition
for ii=find(~filemissing),
   tto=TorcObject;
   tto.MaxIndex=size(r{ii},3);
   tto.Duration=size(r{ii},1)./rasterfs;
   rr=r{ii};
   [strfest,snrb(ii),StimParam]=...
       strf_est_core(rr,tto,rasterfs,INC1STCYCLE,0);
   [aaa,bbb,ccc,strfee]=...
       strf_est_core(rr,tto,rasterfs,INC1STCYCLE,20);
   
   % resize to cope with 4:4:24 vs 4:4:48 TORCs
   strfest=imresize(strfest,[15 25],'bilinear');
   strfee=imresize(strfee,[15 25],'bilinear');
   
   %gg=mean(rgain(find(phase==ii)));
   gg=mgain(ii);
   
   strfb(:,:,ii)=strfest;
   strferr(:,:,ii)=strfee;
   strfd(:,:,ii)=strfest-gg.*strf0;
   
   ract=rresamp(:,:,find(phase==ii));
   ract=ract-repmat(pred.*gg,[1 1 size(ract,3)]);
   nf=std(ract(:)).*50;
   
   ract=ract./nf;
   
   beta0=[1.5 2 1.5 2];
   f0=tarbin;
   
   opt=optimset('Display','on','MaxFunEvals',2000);
   
   betasflb=[0.3 1.5 0.3 -inf];
   betasfub=[2   5   2    inf];
   tr=mean(ract,3);
   tr=tr(:);
   
   if 0,
      beta=lsqcurvefit('gauss_pred',beta0,StimParam.StStims,tr,betasflb,betasfub,opt,f0)
      beta(4)=beta(4).*nf;
      
      [gp,tstrfg]=gauss_pred(beta,StimParam.StStims,f0);
      
      % scale to match other strfs
      strfg(:,:,ii)=imresize(tstrfg,[15 25],'bilinear')./ggain;
   else
      disp('disabled g nl fit');
      beta=zeros(4,1);
   end
   
   
   %sfigure(2);
   %subplot(3,1,ii);
   %plot(gp);
   %hold on
   %plot(tr.*nf,'r');
   %hold off
   
   if ii==1 || ii==3,
      ar=r{2};
      
      if size(ar,1)<size(rr,1),
         rr=rr(1:size(ar,1),:,:);
      else
         ar=ar(1:size(rr,1),:,:);
      end
      if size(ar,2)<size(rr,2) && ii==1,
         rr=rr(:,(end-size(ar,2)+1):end,:);
      elseif size(ar,2)<size(rr,2),
         rr=rr(:,1:size(ar,2),:);
      else
         ar=ar(:,1:size(rr,2),:);
      end
      
      rr(find(isnan(ar)))=nan;
      
      [strfmatched,snrbal(ii)]=strf_est_core(rr,tto,rasterfs,INC1STCYCLE);
      % resize to cope with 4:4:24 vs 4:4:48 TORCs
      strfsnrbal(:,:,ii)=imresize(strfmatched,[15 25],'bilinear');
      
   else
      strfsnrbal(:,:,ii)=strfest;
      snrbal(ii)=snrb(ii);
   end
   
   rmatched{ii}=rr;
   z(ii,1)=nanmean(rr(:));
   z(ii,2)=nanmean(nanmean(rr(1:250,:)));
   z(ii,3)=nanmean(nanmean(rr(251:end,:)));
end
if ~isempty(rnolick),
   strfnolick=strf_est_core(rnolick,tto,rasterfs,INC1STCYCLE,0);
   strfnolick=imresize(strfnolick,[15 25],'bilinear');
else
   strfnolick=[];
end

% split passive STRF control
if ~filemissing(1) && size(r{1},2)>1 && snrb(1)>snrb(3),
   splitidx=1;
elseif ~filemissing(3) && size(r{3},2)>1,
   splitidx=3;
else
   splitidx=0;
end
strfsplit=zeros(15,25,2);

if splitidx>0,
   fprintf('splitting ii=%d for passive control\n',splitidx);
   rr=r{splitidx};
   
   mm=floor(size(rr,2)./2);
   r1=rr(:,1:mm,:);
   r2=rr(:,(mm+1):end,:);
   ss=strf_est_core(r1,tto,rasterfs,INC1STCYCLE);
   strfsplit(:,:,1)=imresize(ss,[15 25],'bilinear');
   ss=strf_est_core(r2,tto,rasterfs,INC1STCYCLE);
   strfsplit(:,:,2)=imresize(ss,[15 25],'bilinear');
end


strfd(isnan(strfd))=0;
strfb(isnan(strfb))=0;
strfsnrbal(isnan(strfsnrbal))=0;

fex=filemissing;
fex(2)=1;
fex=find(~fex);
res.zadorindex=((z(2,:) - nanmean(z(fex,:)))./(z(2,:) + nanmean(z(fex,:))))';

res.strf0 = strf0;
res.snr0 = snr0;
res.rgain = rgain;
res.rmean = rmean;
res.phase = phase;
res.mgain = mgain;
res.egain = egain;
res.strfb = strfb;
res.strferr = strferr;
res.snrb = snrb;
res.strfd = strfd;
res.strfg = strfg;
res.strfsnrbal = strfsnrbal;
res.strfsplit = strfsplit;
res.snrbal = snrbal;
res.rgainsplit = rgainsplit;
res.StimParam = StimParam;
res.mp=mp;
res.mr=mr;
res.strfnolick=strfnolick;

%sfigure(1);
clf
drawnow
colormap('default');

subplot(5,3,1);
stplot(strf0,StimParam.lfreq,StimParam.basep,1,...
       StimParam.octaves);
hold on
%plot([0 250],log2(paramset(cellidx).Tar_Frequencies(1)./...
%                  StimParam.lfreq).*[1 1],'b-');
hold off
title(sprintf('%s all snr=%.3f',cellid,snr0));

subplot(5,3,2);
plot(rgain);
hold on
plot(phase==2,'r');
hold off
ylabel('gain');
xlabel('rep');
aa=axis;
axis([aa(1:3) aa(4)+1]);
legend('gain','phase');
title(sprintf('ZI=%.3f ZI_t=%.3f ZI_s=%.3f',res.zadorindex))
subplot(5,3,3);
plot(rgainsplit);
hold on
plot(phase==2,'r');
hold off
ylabel('gain');
xlabel('rep');
aa=axis;
axis([aa(1:3) aa(4)+1]);

sphase={'Pre','During','Post'};

ggmax=0;
ggset=[];
gg=zeros(1,phasecount);
mmm=0;
for ii=1:phasecount,
   useidx=find(phase==ii);
   if ~isempty(useidx),
      gg(ii)=mean(rgain(useidx));
      strfi=strf0.*gg(ii);
      ggmax=max(ggmax,max(abs(strfi(:))));
      subplot(5,3,3+ii)
      ggset=[ggset gca];
      stplot(strfi,StimParam.lfreq,StimParam.basep,1,...
             StimParam.octaves);
      title(sprintf('%s gain=%.2f',sphase{ii},gg(ii)));
      
      subplot(5,3,6+ii)
      ggset=[ggset gca];
      stplot(strfd(:,:,ii),StimParam.lfreq,StimParam.basep,1,...
             StimParam.octaves);
      title(sprintf('delta'));
      
      subplot(5,3,9+ii)
      ggset=[ggset gca];
      stplot(strfb(:,:,ii),StimParam.lfreq,StimParam.basep,1,...
             StimParam.octaves);
      title(sprintf('local strf'));
      
      if sum(sum(strfb(:,:,ii)))==0,
         %keyboard
      end
      
      subplot(5,3,12+ii)
      ggset=[ggset gca];
      stplot(strfg(:,:,ii),StimParam.lfreq,StimParam.basep,1,...
             StimParam.octaves);
      title(sprintf('gaussian diff'));
      
      mmm=max([mmm max(abs(strfi(:))) max(max(strfb(:,:,ii)))...
               max(max(strfd(:,:,ii)))]);
   end
end
for ii=ggset,
   set(ii,'CLim',[-1 1].*mmm);
end


