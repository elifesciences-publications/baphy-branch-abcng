% function [res] = alm_online(mfile,channel,unit,axeshandle,options);
%
% tuning plot for light/AM combo stimulus
%
% SVD 2009-07-08 -- ripped off chord_strf_online
%
function [res] = alm_online(mfile,channel,unit,axeshandle,options);

if ~exist('channel','var'),
    channel=1;
end
if ~exist('unit','var'),
    unit=1;
end
if ~exist('axeshandle','var'),
    axeshandle=gca;
end
ff=get(axeshandle,'Parent');

if ~exist('options','var'),
    options=[];
end
if ~isfield(options,'rasterfs'),
    options.rasterfs=1000;
end
if ~isfield(options,'sigthreshold'),
    options.sigthreshold=4;
end
if ~isfield(options,'datause'),
    options.datause='Reference';
end
if ~isfield(options,'psth'),
    options.psth=0;
end
if ~isfield(options,'psthfs'),
    options.psthfs=20;
end
if ~isfield(options,'lfp'),
    options.lfp=0;
end
if ~isfield(options,'usesorted'),
    options.usesorted=0;
end
if ~isfield(options,'showdetails'),
    options.showdetails=0;
end


fprintf('%s: Analyzing channel %d (rasterfs %d, spike thresh %.1f std)\n',...
    mfilename,channel,options.rasterfs,options.sigthreshold);
LoadMFile(mfile);

options.PreStimSilence=getparm(options,'PreStimSilence',...
               exptparams.TrialObject.ReferenceHandle.PreStimSilence);
options.PostStimSilence=getparm(options,'PostStimSilence',...
               exptparams.TrialObject.ReferenceHandle.PostStimSilence);

%options.PreStimSilence=0;
%options.PostStimSilence=0;


options.channel=channel;
options.unit=unit;
PreStimSilence=options.PreStimSilence;
PostStimSilence=options.PostStimSilence;

tic;
disp('Loading response...');
[r,tags]=raster_load(mfile,channel,unit,options);

realrepcount=size(r,2);

freq=zeros(length(tags),1);
lam=zeros(length(tags),1);
tam=-ones(length(tags),1);
ph=zeros(length(tags),1);
md=ones(length(tags),1);

for ii=1:length(tags),
   tt=strsep(tags{ii},',',1);
   tt=strsep(tt{2},':');
   freq(ii)=tt{1};
   lmatch=find(strcmp(tt,'L'));
   if ~isempty(lmatch),
      lam(ii)=tt{lmatch+1};
   end
   tmatch=find(strcmp(tt,'A'));
   if ~isempty(tmatch),
      tam(ii)=tt{tmatch+1};
   end
   tmatch=find(strcmp(tt,'Ph'));
   if ~isempty(tmatch),
      ph(ii)=tt{tmatch+1};
   end
   tmatch=find(strcmp(tt,'D'));
   if ~isempty(tmatch),
      md(ii)=tt{tmatch+1};
   end
end

freqset=unique(freq);
lamset=unique(lam);
tamset=unique(tam);
phset=unique(ph);
mdset=unique(md);

startidx=round(PreStimSilence.*options.rasterfs)+1;
stopidx=size(r,1)-round(PostStimSilence.*options.rasterfs);
rri=startidx:stopidx;

sfigure(get(axeshandle,'Parent'));
set(get(axeshandle,'Parent'),'CurrentAxes',axeshandle)

if length(phset)>1 || length(mdset)>1,
   
   vs=zeros(size(tam));
   vse=zeros(size(tam));
   for ii=1:length(tam),
      [vs(ii),vse(ii)]=vector_strength(r(rri,:,ii),tam(ii),options.rasterfs) ;
   end
   
   if length(phset)>1,
      dd=sortrows([freq tam lam md ph vs vse]);
      indep_count=length(freqset).*length(lamset).*length(tamset).*length(mdset);
   elseif length(mdset)>1
      dd=sortrows([freq tam lam ph md vs vse]);
      indep_count=length(freqset).*length(lamset).*length(tamset).*length(phset);
   end
   
   stepsize=size(dd,1)./indep_count;
   
   pp=reshape(dd(:,5),size(dd,1)./indep_count,indep_count);
   vv=reshape(dd(:,6),size(dd,1)./indep_count,indep_count);
   vve=reshape(dd(:,7),size(dd,1)./indep_count,indep_count);
   
   errorbar(pp,vv,vve);
   
   labelset={};
   for ii=1:indep_count,
      if length(freqset)>0,
         labelset{ii}=sprintf('F:%d:',dd(ii*stepsize,1));
      end
      if length(tamset)>0,
         labelset{ii}=sprintf('%sA:%d:',labelset{ii},dd(ii*stepsize,2));
      end
      if length(lamset)>0,
         labelset{ii}=sprintf('%sL:%d:',labelset{ii},dd(ii*stepsize,3));
      end
      if length(phset)>1,
         labelset{ii}=sprintf('%sD:%.2f:',labelset{ii},dd(ii*stepsize,4));
      elseif length(mdset)>1,
         labelset{ii}=sprintf('%sPh:%d:',labelset{ii},dd(ii*stepsize,4));
      end
      labelset{ii}=labelset{ii}(1:(end-1));
      
   end
   legend(labelset,'Location','southeast');
   xlabel('light precede time (ms)');
   ylabel('vector strength');
else
   ltune=zeros(length(tamset),length(lamset));
   ttune=zeros(length(tamset),length(lamset));
   ltune_err=zeros(length(tamset),length(lamset));
   ttune_err=zeros(length(tamset),length(lamset));
   
   %% VECTOR STRENGTH
   % formula used: vs = (1/n)*sqrt(sum(cos(2(pi)t/T))^2+sum(sin(2(pi)t/T))^2)
   % t=time b/w first noise pulse and ith spike (total n spikes)
   % T=period b/w 2 consecutive noise pulses
   for ii=1:length(tam),
      [vs,vse]=vector_strength(r(:,:,ii),tam(ii),options.rasterfs) ;
      ttune(find(tam(ii)==tamset),lam(ii)==lamset)=vs;
      ttune_err(find(tam(ii)==tamset),lam(ii)==lamset)=vse;
      [vs,vse]=vector_strength(r(:,:,ii),lam(ii),options.rasterfs); 
      ltune(find(tam(ii)==tamset),lam(ii)==lamset)=vs;
      ltune_err(find(tam(ii)==tamset),lam(ii)==lamset)=vse;
   end
   
   alltune=[ttune; ltune];
   
   t_alone=ttune(:,1);
   t_alone_err=ttune_err(:,1);
   tl_match=diag(ttune);
   tl_match_err=diag(ttune_err);
   tt=ttune+diag(ones(size(tamset)).*nan);
   tl_mismatch=nanmean(tt,2);
   tt=ttune_err+diag(ones(size(tamset)).*nan);
   tl_mismatch_err=nanmean(tt,2);
   
   l_alone=ltune(1,:)';
   l_alone_err=ltune_err(1,:)';
   tt=ltune+diag(ones(size(lamset)).*nan);
   lt_mismatch=nanmean(tt,1)';
   tt=ltune_err+diag(ones(size(lamset)).*nan);
   lt_mismatch_err=nanmean(tt,1)';
   
   tt_set=[t_alone tl_match tl_mismatch l_alone lt_mismatch];
   tt_err=[t_alone_err tl_match_err tl_mismatch_err l_alone_err lt_mismatch_err];
   
   errorbar(tt_set(2:end,:),tt_err(2:end,:));
   
   set(axeshandle,'XTick',1:length(lamset));
   set(axeshandle,'XTickLabel',lamset(2:end));
   aa=axis;
   axis([0.5 size(tt_set,1)-0.5 aa(3:4)]);
   xlabel('modulation frequency');
   ylabel('vector strength');
   
   legend('T','TLm','TLnm','L','LTnm','Location','SouthEast');
   
end

ht=title(sprintf('%s chan %d rep %d',basename(mfile),channel,realrepcount));
set(ht,'Interpreter','none');

set(gcf,'Name',sprintf('%s(%d)',basename(mfile),realrepcount));

return

axes(axeshandle);
imagesc(alltune,[0 1]);

axis equal
axis tight
xlabel('Light AM');
ylabel('Sound AM');

aa=axis;
set(axeshandle,'YTick',1:(length(tamset).*2));
set(axeshandle,'YTickLabel',repmat(tamset,[2 1]));
set(axeshandle,'XTick',1:length(lamset));
set(axeshandle,'XTickLabel',lamset);

ht=title(sprintf('%s chan %d rep %d',basename(mfile),channel,realrepcount));
set(ht,'Interpreter','none');

set(gcf,'Name',sprintf('%s(%d)',basename(mfile),realrepcount));

drawnow;
return

if ~options.showdetails
   
   sfigure(get(axeshandle,'Parent'));
   axes(axeshandle);
   imagesc(mm.*abs(mm),[-1 1].*mmax.^2);
   
   xlabel(sprintf('f1 (Hz) -- thresh=%.1f sig -- %d spikes',options.sigthreshold,nansum(r(:))));
   ylabel(sprintf('f2 (Hz)'));
   
   aa=axis;
   set(axeshandle,'YTick',floor([linspace(1,freqcount,3) linspace(1,freqcount,3)+freqcount]));
   set(axeshandle,'YTickLabel',repmat(unique_freq(round(linspace(1,freqcount,3))),[2 1]));
   set(axeshandle,'XTick',floor(linspace(1,freqcount,3)));
   set(axeshandle,'XTickLabel',unique_freq(round(linspace(1,freqcount,3))));
   
   if ~isfield(exptparams,'Repetition'),
      exptparams.Repetition=0;
   end
   ht=title(sprintf('%s chan %d rep %d',basename(mfile),channel,realrepcount));
   set(ht,'Interpreter','none');
   
   set(gcf,'Name',sprintf('%s(%d)',basename(mfile),realrepcount));
   axis image
   drawnow;
   return
   
end


xx=zeros(freqcount.^2,freqcount);
for ii=1:freqcount,
   xx((ii-1).*freqcount+(1:freqcount),ii)=xx((ii-1).*freqcount+(1:freqcount),ii)+1;
   xx(ii:freqcount:freqcount.^2,ii)=xx(ii:freqcount:freqcount.^2,ii)+1;
end
%xx(:,freqcount+1)=0;

yy=on_mat(:);
yy=yy-mean(yy);

% don't include pure 2x tones because of likely nonlinear gain
dd=eye(size(on_mat,1));
keepidx=find(~dd);

b_on=regress(yy(keepidx),xx(keepidx,:));
on_mat_linpred=repmat(b_on,[1 freqcount])+repmat(b_on',[freqcount 1]);

yy=off_mat(:);
yy=yy-mean(yy);
b_off=regress(yy(keepidx),xx(keepidx,:));
off_mat_linpred=repmat(b_off,[1 freqcount])+repmat(b_off',[freqcount 1]);

res.on_mat_linpred=on_mat_linpred;
res.off_mat_linpred=off_mat_linpred;

mm_linpred=[on_mat_linpred; off_mat_linpred];
mmax_linpred=max(abs(mm_linpred(:)));

sfigure(ff);
clf
subplot(1,3,1);
imagesc(mm.*abs(mm),[-1 1].*mmax.^2);

xlabel(sprintf('f1 (Hz) -- thresh=%.1f sig -- %d spikes',options.sigthreshold,nansum(r(:))));
ylabel(sprintf('f2 (Hz)'));
ht=title(sprintf('%s chan %d unit %d',basename(mfile),channel,unit));
set(ht,'Interpreter','none');
set(gca,'YTick',floor([linspace(1,freqcount,4) linspace(1,freqcount,4)+freqcount]));
set(gca,'YTickLabel',repmat(unique_freq(round(linspace(1,freqcount,4))),[2 1]));
set(gca,'XTick',floor(linspace(1,freqcount,3)));
set(gca,'XTickLabel',unique_freq(round(linspace(1,freqcount,3))));

axis image

subplot(1,3,2);
imagesc(mm_linpred.*abs(mm_linpred),[-1 1].*mmax_linpred.^2);
title('linear prediction');
set(gca,'YTick',floor([linspace(1,freqcount,4) linspace(1,freqcount,4)+freqcount]));
set(gca,'YTickLabel',repmat(unique_freq(round(linspace(1,freqcount,4))),[2 1]));
set(gca,'XTick',floor(linspace(1,freqcount,3)));
set(gca,'XTickLabel',unique_freq(round(linspace(1,freqcount,3))));

axis image

d_on=diag(on_mat);
d_on_sum=sum(on_mat,2);
d_on_sum=d_on_sum./sum(d_on_sum).*sum(d_on);
d_off=diag(off_mat);
d_off_sum=sum(off_mat,2);
d_off_sum=d_off_sum./sum(d_off_sum).*sum(d_off);

subplot(2,3,3);
semilogx(unique_freq,d_on);
hold on
semilogx(unique_freq,d_on_sum,'r');
hold off

subplot(2,3,6);
semilogx(unique_freq,d_off);
hold on
semilogx(unique_freq,d_off_sum,'r');
hold off

