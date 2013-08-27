% function cch_demo(mfile,channel,unit,axeshandle,options);
%
% reverse correlation for complex chord stimuli.
%
% SVD 2007-04-12 -- ripped off raster_online & strf_online
%
function [on_mat,off_mat,unique_freq] = cch_demo(mfile,channel,unit,axeshandle,options);

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
if ~isfield(options,'PreStimSilence'),
    options.PreStimSilence=0.0;
end
if ~isfield(options,'PostStimSilence'),
    options.PostStimSilence=0.1;
end


options.channel=channel;
options.unit=unit;

fprintf('%s: Analyzing channel %d (rasterfs %d, spike thresh %.1f std)\n',...
    mfilename,channel,options.rasterfs,options.sigthreshold);
LoadMFile(mfile);

PreStimSilence=options.PreStimSilence;
PostStimSilence=options.PostStimSilence;

tic;
disp('Loading response...');
[r,tags]=raster_load(mfile,channel,unit,options);

toc

for ii=1:length(tags),
    tt=strsep(tags{ii},',',1);
    tt=strsep(tt{2},'+');
    if ii==1,
        fset=zeros(length(tags),length(tt));
    end
    fset(ii,:)=cat(2,tt{:});
end
unique_freq=unique(fset(:));
freqcount=length(unique_freq);

fprintf('%d unique frequencies, %d simultaneous\n',...
    freqcount,size(fset,2));

disp('Estimating STRF...');
realrepcount=size(r,2);

p=squeeze(nanmean(r,2));
pe=squeeze(nanstd(r,0,2))./sqrt(size(r,2));

baseline=mean(mean(p([1:5 (end-10):end],:)));
filtwidth=round(0.01.*options.rasterfs);
psth=rconv2(mean(p,2),ones(filtwidth,1)./filtwidth);

plot(psth);
hold on;
plot([1 length(psth)],baseline.*[1 1],'r');
plot([1 length(psth)],(baseline+std(psth)).*[1 1],'r--');
plot([1 length(psth)],(baseline-std(psth)).*[1 1],'r--');
hold off

on_timewindow=round((PreStimSilence.*options.rasterfs+1):(size(r,1)-PostStimSilence.*options.rasterfs));
off_timewindow=(size(r,1)-PostStimSilence.*options.rasterfs+1):size(r,1);

on_timewindow=on_timewindow(find(abs(psth(on_timewindow)-baseline)>std(psth)));
if 1 | isempty(on_timewindow),
   on_timewindow=round(PreStimSilence.*options.rasterfs+(11:100));
else
   on_timewindow=on_timewindow(1):on_timewindow(end);
end

off_timewindow=off_timewindow(find(abs(psth(off_timewindow)-baseline)>std(psth)));
if 1 | isempty(off_timewindow),
   off_timewindow=(size(r,1)-PostStimSilence.*options.rasterfs)+(11:100);
else
   off_timewindow=off_timewindow(1):off_timewindow(end);
end

on_mat=zeros(freqcount);
off_mat=zeros(freqcount);
for ii=1:size(fset,1),
    f1=find(unique_freq==fset(ii,1));
    f2=find(unique_freq==fset(ii,2));

    on_mat(f1,f2)=nanmean(p(on_timewindow,ii)).*options.rasterfs;
    off_mat(f1,f2)=nanmean(p(off_timewindow,ii)).*options.rasterfs;
    
    %on_mat(f2,f1)=on_mat(f1,f2);
    %off_mat(f2,f1)=off_mat(f1,f2);
end

% improve SNR by taking advantage of two tones' symmetry
on_mat=(on_mat+on_mat')./2;
off_mat=(off_mat+off_mat')./2;

mm=[on_mat; off_mat]-baseline;
mmax=max(abs(mm(:)));

if ~options.showdetails
   
   figure(get(axeshandle,'Parent'));
   axes(axeshandle);
   imagesc(mm.*abs(mm),[-1 1].*mmax.^2);
   
   xlabel(sprintf('f1 (Hz) -- thresh=%.1f sig -- %d spikes',options.sigthreshold,nansum(r(:))));
   ylabel(sprintf('f2 (Hz)'));
   
   aa=axis;
   set(axeshandle,'YTick',floor([linspace(1,freqcount,4) linspace(1,freqcount,4)+freqcount]));
   set(axeshandle,'YTickLabel',repmat(unique_freq(round(linspace(1,freqcount,4))),[2 1]));
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

b_on=regress(yy,xx);
on_mat_linpred=repmat(b_on,[1 freqcount])+repmat(b_on',[freqcount 1]);

yy=off_mat(:);
yy=yy-mean(yy);
b_off=regress(yy,xx);
off_mat_linpred=repmat(b_off,[1 freqcount])+repmat(b_off',[freqcount 1]);


mm_linpred=[on_mat_linpred; off_mat_linpred];
mmax_linpred=max(abs(mm_linpred(:)));

figure(ff);
clf
subplot(1,3,1);
imagesc(mm,[-1 1].*mmax);

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
imagesc(mm_linpred,[-1 1].*mmax);
title('linear prediction');
set(gca,'YTick',floor([linspace(1,freqcount,4) linspace(1,freqcount,4)+freqcount]));
set(gca,'YTickLabel',repmat(unique_freq(round(linspace(1,freqcount,4))),[2 1]));
set(gca,'XTick',floor(linspace(1,freqcount,3)));
set(gca,'XTickLabel',unique_freq(round(linspace(1,freqcount,3))));

axis image
