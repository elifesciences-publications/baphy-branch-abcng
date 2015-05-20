% function [on_mat,off_mat,unique_freq,res] = chord_strf_online(mfile,channel,unit,axeshandle,options);
%
% reverse correlation for complex chord stimuli.
%
% SVD 2007-04-12 -- ripped off raster_online & strf_online
%
function [on_mat,off_mat,unique_freq,res] = chord_strf_online(mfile,channel,unit,axeshandle,options);

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

options.channel=channel;
options.unit=unit;


fprintf('%s: Analyzing channel %d (rasterfs %d, spike thresh %.1f std)\n',...
    mfilename,channel,options.rasterfs,options.sigthreshold);
LoadMFile(mfile);

if strcmpi(exptparams.TrialObject.ReferenceClass,'RandomTone') || ...
        ~isfield(exptparams.TrialObject.ReferenceHandle,'SimulCount') || ...
        exptparams.TrialObject.ReferenceHandle.SimulCount==1,
    
    ReferencePreStimSilence=max(exptparams.TrialObject.ReferenceHandle.PreStimSilence,0.1);
    ReferenceDuration=exptparams.TrialObject.ReferenceHandle.Duration;
    ReferencePostStimSilence=max(exptparams.TrialObject.ReferenceHandle.PostStimSilence,0.1);
    
    options.PreStimSilence=ReferencePreStimSilence;
    options.PostStimSilence=ReferencePostStimSilence;
    options.rasterfs=1000;
    disp('chord_strf_online: Loading response...');
    [r_ref,tags_ref]=raster_load(mfile,channel,unit,options);
    
    fset=[];
    for ii=1:length(tags_ref),
        tt=strsep(tags_ref{ii},',',1);
        fset=cat(1,fset,str2num(tt{2}));
    end
    [unique_freq,~,mapidx]=unique(fset);
    freqcount=length(unique_freq);
    
    TrialCount=sum(~isnan(r_ref(1,:)));
    MaxFreq=min(TrialCount./4,30);
    if freqcount>MaxFreq,
        newidx=round(linspace(1,freqcount+1,MaxFreq+1));
        newfreq=zeros(MaxFreq,1);
        for jj=1:MaxFreq,
            newfreq(jj)=round(2.^mean(log2(unique_freq(newidx(jj):(newidx(jj+1)-1)))));
            ff=find(ismember(fset,unique_freq(newidx(jj):(newidx(jj+1)-1))));
            fset(ff)=newfreq(jj);
        end
        [unique_freq,~,mapidx]=unique(fset);
        freqcount=length(unique_freq);
    end
    stimuluscount=freqcount;
    repcount=size(r_ref,2);
    stimulusvalues=unique_freq;
    
    % find the time bins for the pre-stimulus epoch
    spontbins=1:round(ReferencePreStimSilence*options.rasterfs);
    onsetbins=round(ReferencePreStimSilence*options.rasterfs+1):...
       round((ReferencePreStimSilence+0.05)*options.rasterfs);
    sustbins=round((ReferencePreStimSilence+0.05)*options.rasterfs+1):...
       round((ReferencePreStimSilence+0.1)*options.rasterfs);
    offsetbins=round((ReferencePreStimSilence+ReferenceDuration)*options.rasterfs+1):...
       round((ReferencePreStimSilence+ReferenceDuration+0.05)*options.rasterfs);
    meanspontaneous=zeros(freqcount,1);
    semspontaneous=zeros(freqcount,1);
    meanonset=zeros(freqcount,1);
    semonset=zeros(freqcount,1);
    meansustained=zeros(freqcount,1);
    semsustained=zeros(freqcount,1);
    meanoffset=zeros(freqcount,1);
    semoffset=zeros(freqcount,1);

    if strcmpi(exptparams.TrialObject.ReferenceClass,'NoiseSample'),
        RISVAR=1;  % response = PSTH variance
        %baseline=nanmean(nanstd(nanmean(r_ref(spontbins,:,:),2),0,1));
        %sembaseline=nanstd(nanstd(nanmean(r_ref(spontbins,:,:),2),0,1))./sqrt(stimuluscount);
        globalmean=nanmean(nanmean(r_ref(spontbins,:)));
        baseline=nanmean(nanmean((r_ref(spontbins,:)-globalmean).^2));
        sembaseline=nanmean(nanmean((r_ref(spontbins,:)-globalmean).^2))./sqrt(sum(~isnan(r_ref(1,:))));
    else
        RISVAR=0;  % response = mean firing rate
        baseline=nanmean(nanmean(r_ref(spontbins,:)));
    end
    
    
    for ii=1:freqcount,
        if RISVAR,
            meanspontaneous(ii)=baseline;
            semspontaneous(ii)=sembaseline;
            tr=r_ref(onsetbins,:,mapidx==ii);
            meanonset(ii)=nanmean(nanmean((tr(:,:)-globalmean).^2));
            semonset(ii)=nanstd(nanmean((tr(:,:)-globalmean).^2))./sqrt(sum(~isnan(tr(1,:))));
            tr=r_ref(sustbins,:,mapidx==ii);
            meansustained(ii)=nanmean(nanmean((tr(:,:)-globalmean).^2));
            semsustained(ii)=nanstd(nanmean((tr(:,:)-globalmean).^2))./sqrt(sum(~isnan(tr(1,:))));
            tr=r_ref(offsetbins,:,mapidx==ii);
            meanoffset(ii)=nanmean(nanmean((tr(:,:)-globalmean).^2));
            semoffset(ii)=nanstd(nanmean((tr(:,:)-globalmean).^2))./sqrt(sum(~isnan(tr(1,:))));
        else
            tr=r_ref(spontbins,:,mapidx==ii);
            meanspontaneous(ii)=nanmean(tr(:));
            semspontaneous(ii)=nanstd(tr(:))./sqrt(sum(~isnan(tr(:))));
            tr=r_ref(onsetbins,:,mapidx==ii);
            meanonset(ii)=nanmean(tr(:))-meanspontaneous(ii)+baseline;
            semonset(ii)=nanstd(tr(:))./sqrt(sum(~isnan(tr(:))));
            tr=r_ref(sustbins,:,mapidx==ii);
            meansustained(ii)=nanmean(tr(:))-meanspontaneous(ii)+baseline;
            semsustained(ii)=nanstd(tr(:))./sqrt(sum(~isnan(tr(:))));
            tr=r_ref(offsetbins,:,mapidx==ii);
            meanoffset(ii)=nanmean(tr(:))-meanspontaneous(ii)+baseline;
            semoffset(ii)=nanstd(tr(:))./sqrt(sum(~isnan(tr(:))));
        end
        
    end
    
    bf=0; bf_sust=0;
    ps=gsmooth(meanonset,freqcount./40);
    mm=find(ps==max(ps), 1 );
    if meanonset(mm)-2*semonset(mm)>baseline,
        bf=unique_freq(mm);
    end
    ps=gsmooth(meansustained,freqcount./40);
    mm_sust=find(ps==max(ps), 1 );
    if meansustained(mm_sust)-2*semsustained(mm_sust)>baseline,
        bf_sust=unique_freq(mm_sust);
    end
    
    sfigure(get(axeshandle,'Parent'));
    axes(axeshandle);
    if RISVAR,
        errorbar(repmat((1:stimuluscount)',[1 2]),...
            [meanonset meansustained],...
            [semonset semsustained]);
    else
        errorbar(repmat((1:stimuluscount)',[1 3]),...
            [meanonset meansustained meanoffset],...
            [semonset semsustained semoffset]);
    end
    hold on
    plot([1 stimuluscount],[0 0]+mean(meanspontaneous),'b--');
    if bf>0,
        plot(mm,meanonset(mm),'bo');
    end
    if bf_sust>0,
        plot(mm_sust,meansustained(mm_sust),'go');
    end
    hold off
    set(gca,'XLim',[0 stimuluscount+1]);  % make x axis look nice
    if max(stimulusvalues)>4000,
        stimulusKHz=round(stimulusvalues./100)./10;
    elseif max(stimulusvalues)>100
        stimulusKHz=round(stimulusvalues./10)./100;
    else
        stimulusKHz=stimulusvalues;
    end
    stimlabelidx=1:2:stimuluscount;
    set(gca,'XTick',stimlabelidx,'XTickLabel',stimulusKHz(stimlabelidx));
    
    if RISVAR,
        hl=legend('Onset','Sust');
        ylabel('Spike std (spikes/sec)');
    else
        hl=legend('Onset','Sust','Offset');
        ylabel('Spike rate (spikes/sec)');
    end
    legend(gca,'boxoff');
    set(hl,'FontSize',5);
    if max(stimulusvalues)>100
        xlabel('Stimulus frequency (KHz)');
    else
        xlabel('Stimulus ID');
    end
    if bf>0 || bf_sust>0,
        ht=title(sprintf('E%d Rep%d BF=%.0f (on) %.0f (sust)',channel,repcount,bf,bf_sust));
    else
        ht=title(sprintf('E%d Rep%d BF=nan',channel,repcount));
    end
    set(ht,'Interpreter','none');
    set(gcf,'Name',sprintf('%s(%d)',basename(mfile),repcount));
    
    return
end

if ~isfield(options,'PreStimSilence'),
    options.PreStimSilence=0.0;
end
if ~isfield(options,'PostStimSilence'),
    options.PostStimSilence=0.1;
end

PreStimSilence=options.PreStimSilence;
PostStimSilence=options.PostStimSilence;

disp('chord_strf_online: Loading response...');
[r,tags]=raster_load(mfile,channel,unit,options);

for ii=1:length(tags),
    tt=strsep(tags{ii},',',1);
    tt=strsep(tt{2},'+');
    if ~isempty(findstr(':',tt{1})),
        tt{1}=strsep(tt{1},':');
        tt{1}=tt{1}{1};
    end
    if ~isempty(findstr(':',tt{2})),
        tt{2}=strsep(tt{2},':');
        tt{2}=tt{2}{1};
    end
    if ii==1,
        fset=zeros(length(tags),length(tt));
    end
    fset(ii,:)=cat(2,tt{:});
end
unique_freq=unique(fset(:));
freqcount=length(unique_freq);

fprintf('%d unique frequencies, %d simultaneous\n',freqcount,size(fset,2));

disp('Estimating STRF...');
realrepcount=size(r,2);

p=squeeze(nanmean(r,2));
pe=squeeze(nanstd(r,0,2))./sqrt(size(r,2));

baseline=mean(mean(p([1:5 (end-10):end],:)));
filtwidth=round(0.01.*options.rasterfs);
%psth=rconv2(mean(p,2),ones(filtwidth,1)./filtwidth);
psth=mean(p,2);

if 0,
    plot(psth);
    hold on;
    plot([1 length(psth)],baseline.*[1 1],'r');
    plot([1 length(psth)],(baseline+std(psth)).*[1 1],'r--');
    plot([1 length(psth)],(baseline-std(psth)).*[1 1],'r--');
    hold off
end

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

p_on=nanmean(p(on_timewindow,:));
p_off=nanmean(p(off_timewindow,:));
r_on=squeeze(nanmean(r(on_timewindow,:,:)));
r_off=squeeze(nanmean(r(off_timewindow,:,:)));
e_on=sum(r_on.^2);
e_off=sum(r_off.^2);
e_count=size(r_on,1);

on_mat=zeros(freqcount);
off_mat=zeros(freqcount);
on_mat_a=zeros(freqcount,freqcount,e_count);
off_mat_a=zeros(freqcount,freqcount,e_count);
on_snr=zeros(freqcount);
off_snr=zeros(freqcount);
on_full=zeros(length(psth)./10,freqcount,freqcount);

for ii=1:size(fset,1),
    f1=find(unique_freq==fset(ii,1));
    f2=find(unique_freq==fset(ii,2));
    
    on_mat(f1,f2)=p_on(ii);
    off_mat(f1,f2)=p_off(ii);
    
    tpsth=rconv2(p(:,ii),ones(10,1)./10);
    on_full(:,f1,f2)=tpsth(5:10:end);
    on_full(:,f2,f1)=on_full(:,f1,f2);
    
    if length(e_on)>1,
        on_snr(f1,f2)=e_on(ii);
        off_snr(f1,f2)=e_off(ii);
    end

    for jackidx=1:e_count,
       %incidx=[1:(jackidx-1) (jackidx+1):e_count];
       on_mat_a(f1,f2,jackidx)=(r_on(jackidx,ii));
       off_mat_a(f1,f2,jackidx)=(r_off(jackidx,ii));
    end
end

res=[];

% improve SNR by taking advantage of two tones' symmetry
on_mat=(on_mat+on_mat')./2;
off_mat=(off_mat+off_mat')./2;

e_count2=e_count.*2;
on_snr=((on_snr+on_snr')./e_count2 - on_mat.^2);
off_snr=((off_snr+off_snr')./e_count2 - off_mat.^2);

res.on_full=on_full;
res.baseline=baseline;
res.snr=(sum(on_mat(:).^2)+sum(off_mat(:).^2))./...
        (sum(on_snr(:))+sum(off_snr(:))) - 1;

on_snr=on_mat./(on_snr+(on_snr==0)) - 1;
off_snr=off_mat./(off_snr+(off_snr==0)) - 1;

%jackknifed linearity test
lin_idx_a=zeros(e_count,1);
lin_idx_b=zeros(e_count,1);
l2d=zeros(size(on_mat,1).*2,size(on_mat,2),e_count);
e_half=floor(e_count./2);
for ii=1:e_count,
   incidx=mod(ii+(1:(e_count-e_half))-1,e_count)+1;
   excidx=setdiff(1:e_count,incidx);
   
   mm=nanmean(on_mat_a(:,:,incidx),3);
   mm=(mm+mm')./2;
   mm_off=nanmean(off_mat_a(:,:,incidx),3);
   mm_off=(mm_off+mm_off')./2;
   
   xx=zeros(freqcount.^2,freqcount);
   for jj=1:freqcount,
      xx((jj-1).*freqcount+(1:freqcount),jj)=xx((jj-1).*freqcount+(1:freqcount),jj)+1;
      xx(jj:freqcount:freqcount.^2,jj)=xx(jj:freqcount:freqcount.^2,jj)+1;
   end
   %xx(:,freqcount+1)=0;
   
   yy=mm(:);
   %yy=yy-mean(yy);
   
   % don't include pure 2x tones because of likely nonlinear gain
   dd=eye(size(mm,1));
   keepidx=find(~dd);
   
   b_on=regress(yy(keepidx),xx(keepidx,:));
   on_mat_linpred=repmat(b_on,[1 freqcount])+repmat(b_on',[freqcount 1]);
   
   yy=mm_off(:);
   %yy=yy-mean(yy);
   
   b_off=regress(yy(keepidx),xx(keepidx,:));
   off_mat_linpred=repmat(b_off,[1 freqcount])+repmat(b_off',[freqcount 1]);
   
   t2=[mm(:);mm_off(:)];
   l2=[on_mat_linpred(:);off_mat_linpred(:)];
   
   mmx=mean(on_mat_a(:,:,excidx),3);
   mmx=(mmx+mmx')./2;
   mmx_off=mean(off_mat_a(:,:,excidx),3);
   mmx_off=(mmx_off+mmx_off')./2;
   x2=[mmx(:);mmx_off(:)];
   
   t2=t2(keepidx);
   l2=l2(keepidx);
   x2=x2(keepidx);
   
   l2=l2+shuffle(t2-l2);
   
   % correlation between linear model and other half of 2nd order data
   lin_idx_a(ii)=xcov(x2,l2,0,'coeff');
   % correlation between 2 halves of 2nd order data
   lin_idx_b(ii)=xcov(x2,t2,0,'coeff');
   
   
   %lin_idx_a(ii)=mean((t2-l2).^2)./mean(t2.^2);
   
   l2d(:,:,ii)=[mm;mm_off]-[on_mat_linpred;off_mat_linpred];
   
end
res.lin_idx=mean(lin_idx_b.^2-lin_idx_a.^2);
res.lin_idx_err=sqrt(std(lin_idx_b.^2-lin_idx_a.^2))./sqrt(e_count);
res.psth=psth;

%l2m=mean(l2d,3);
%l2e=std(l2d,0,3).^2 .*(e_count-1);
%lin_idx=mean(l2m(keepidx).^2)./mean(l2e(keepidx))-1;
%res.lin_idx=lin_idx;
%keyboard


% scale to spikes/sec
on_mat=on_mat.*options.rasterfs;
off_mat=off_mat.*options.rasterfs;

mm=[on_mat; off_mat]-baseline;
mmax=max(abs(mm(:)));

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

