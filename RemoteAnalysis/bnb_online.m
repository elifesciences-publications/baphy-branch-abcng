% function [on_mat,off_mat,unique_freq,res] = bnb_online(mfile,channel,unit,axeshandle,options);
%
% display tuning curve, find best frequency and tuning width
%
% SVD/ZPS 2015-6-23 - combined chord_strf_online and bnb_tuning

function [on_mat,off_mat,unique_freq,res] = bnb_online(mfile,channel,unit,axeshandle,options);

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

options.PreStimSilence=exptparams.TrialObject.ReferenceHandle.PreStimSilence;
options.PostStimSilence=exptparams.TrialObject.ReferenceHandle.PostStimSilence;

[r,tags]=raster_load(mfile,options.channel,options.unit,options);

fset=[];
for ii=1:length(tags),
    tt=strsep(tags{ii},',',1);
    fset=cat(1,fset,str2num(tt{2}));
end
[unique_freq,~,mapidx]=unique(fset);
freqcount=length(unique_freq);

TrialCount=sum(~isnan(r(1,:)));
MaxFreq=round(min(TrialCount./4,32));

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

b=zeros(freqcount,1);
p=zeros(freqcount,1);
pe=zeros(freqcount,1);
bbase=1:round(options.PreStimSilence.*options.rasterfs+1);
bb=round(options.PreStimSilence.*options.rasterfs+1):... %response over entire stimulus
    round(size(r,1)-options.PostStimSilence.*options.rasterfs);
baseline=nanmean(nanmean(r(1:bb(1),:)));

for ii=1:freqcount,
    tr=r(bbase,:,find(mapidx==ii));
    b(ii)=nanmean(tr(:));
    tr=r(bb,:,find(mapidx==ii));
    p(ii)=nanmean(tr(:))-b(ii)+baseline;
    pe(ii)=nanstd(tr(:))./sqrt(sum(~isnan(tr(:))));
end

ps=gsmooth(p,freqcount./40);

mm=min(find(ps==max(ps)));
if p(mm)-2.*pe(mm)>baseline,
    bf=unique_freq(mm);
    
    % resample to find lo and hi bands
    xx=1:0.5:freqcount;
    prs=interp1(1:freqcount,ps,xx);
    pers=interp1(1:freqcount,pe,xx);
    freqrs=round(2.^interp1(1:freqcount,log2(unique_freq),xx));
    mm2=min(find(prs==max(prs)));
    
    % march down the frequency axis until not significant or tuning curve
    % is less than half-max
    lidx=mm2;
    while lidx>1 && prs(lidx-1)-2.*pers(lidx)>baseline &&...
            prs(lidx-1)-baseline>=(prs(mm2)-baseline)./2,
        lidx=lidx-1;
    end
    
    % now march up the frequency axis until not significant or tuning curve
    % is less than half-max
    hidx=mm2;
    while hidx<length(prs) && prs(hidx+1)-2.*pers(hidx+1)>baseline &&...
            prs(hidx+1)-baseline>=(prs(mm2)-baseline)./2
        hidx=hidx+1;
    end
    blo=freqrs(lidx);
    bhi=freqrs(hidx);
    
else
    bf=0;
    blo=0;
    bhi=0;
    lidx=0;
    hidx=0;
end

%fit a gaussian to the tuning curve
if exist('fitgauss1d','file'),
    beta=fitgauss1d(log2(unique_freq),p,pe);
    p_fit=gauss1(beta,log2(unique_freq));
else
    p_fit=zeros(size(p));
end

%plot
sfigure(get(axeshandle,'Parent'));
axes(axeshandle);

plot([0 freqcount+1],[0 0]+baseline,'k--');
hold on
%plot(p_fit,'g-');
errorbar(p,pe);
axis([0 length(p)+1 min(p-pe*1.5) max(p+pe*1.5)]);
aa=axis;
plot([lidx lidx]./2+0.5,aa(3:4),'g--');
plot([hidx hidx]./2+0.5,aa(3:4),'g--');

if bf>0,
    plot(mm,p(mm),'ro');
end
hold off

stimulusvalues=unique_freq;
stimuluscount=length(stimulusvalues);
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

%axis([0 freqcount+1 aa(3:4)]);
aa=axis;
if bf>0,
    ht=title(sprintf('%s Rep%d BF=%.0f',basename(mfile),size(r,2),bf));
    l=text(0.01*aa(2),0.85*aa(4),...
        sprintf('half-max width: %.2f oct (%d-%d)\n0.37 oct:%.0f-%.0f\n0.5 oct: %.0f-%.0f',...
        log2(bhi/blo),blo,bhi,bf*2^(-0.37/2),bf*2^(0.37/2),bf*2^(-0.25),bf*2^0.25));
    set(l, 'FontSize', 6);
else
    ht=title(sprintf('%s Rep%d BF=nan',...
        basename(mfile),size(r,2)));
    l='';
end
set(ht,'Interpreter','none');
set(l,'Interpreter','none');
set(gcf,'Name',sprintf('%s(%d)',basename(mfile),size(r,2)));

drawnow

return












%%%%%  OLD chord_strf code

ReferencePreStimSilence=max(exptparams.TrialObject.ReferenceHandle.PreStimSilence,0.1);
ReferenceDuration=exptparams.TrialObject.ReferenceHandle.Duration;
ReferencePostStimSilence=max(exptparams.TrialObject.ReferenceHandle.PostStimSilence,0.1);

options.PreStimSilence=ReferencePreStimSilence;
options.PostStimSilence=ReferencePostStimSilence;
options.rasterfs=100;
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

