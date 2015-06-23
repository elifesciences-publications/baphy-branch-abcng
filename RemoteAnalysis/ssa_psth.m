% function ssa_psth(mfile,options,h);
% 
% h - handle of figure where plot should be displayed(default, new figure)
%
% valid options fields
%    .rasterfs [=1000]
%    .sigthreshold [=4]
%    .datause [='Both'] % ie, all data, targets and references
%
function [ssafrac,ssarespz,r0,adpfrac]=ssa_psth(mfile,options,h)

if ~exist('h','var'),
    h=figure;
    h=gca;
    drawnow;
end
if ~exist('options','var'),
    options=struct();
end
options.channel=getparm(options,'channel',1);
options.unit=getparm(options,'unit',1);
options.rasterfs=getparm(options,'rasterfs',100);
options.includeprestim=1;

channel=options.channel;
unit=options.unit;
fprintf('ssa_psth: Analyzing channel %d\n',channel);
LoadMFile(mfile);

try
    [r,tags]=raster_load(mfile,channel,unit,options);
catch
    disp('error loading data, pausing and reloading');
    pause(1);
    [r,tags]=raster_load(mfile,channel,unit,options);
end

repcount=sum(~isnan(r(:,:)),2);
stopat=max(find(repcount>=max(floor(repcount./5))));
r=r(1:stopat,:,:);

freq=zeros(size(tags));
context=zeros(size(tags));

for ii=1:length(tags),
    s=strsep(tags{ii},',',1);
    s=strsep(s{2},'+');
    freq(ii)=s{1};
    if isnumeric(s{2}),
        context(ii)=s{2};
    else
        context(ii)=0;
    end
end
ufreq=unique(freq);
ucontext=unique(context);
concolors=[0.8 0.8 0.8; 0.8 0.2 0.2; 0.2 0.2 0.8];

prepip=exptparams.TrialObject.ReferenceHandle.PipInterval./2;
% baseline (pre-stimulus) activity
r0=nanmean(nanmean(r(1:round(prepip.*options.rasterfs),:)));

mr=nanmean(r,2).*options.rasterfs;
mr0=nanmean(r(:,:),2);
er0=nanstd(r(:,:),0,2)./sqrt(sum(isnan(r(1,:))));

mrmax=nanmax(mr(:));
ssafrac=zeros(1,length(ufreq));
adpfrac=zeros(1,length(ufreq));
ssarespz=zeros(1,length(ufreq));

tt=(1:size(r,1))./options.rasterfs-prepip;
axes(h);
for uu=1:length(ufreq)
    ff=find(freq==ufreq(uu));
    
    [~,si]=sort(context(ff));
    ff=ff(si);
    label={};
    ctr=0;
    for ii=ff(:)',
        ctx=find(ucontext==context(ii));
        plot(tt,mr(:,ii)+(uu-1)*mrmax,'color',concolors(ctx,:));
        hold on
        ctr=ctr+1;
        label{ctr}=sprintf('%d/%.2f',freq(ii),context(ii));
    end

    rstart=round((prepip+0.01)*options.rasterfs+1);
    rstop=round((prepip+0.12).*options.rasterfs);
    %mr0(1:round((prepip+0.01)*options.rasterfs))=0;
    %rstart=min(find((mr0-r0)./er0>2));
    %rstop=max(find((mr0-r0)./er0>2));
    fprintf('rstart-rstop= %d - %d\n',rstart,rstop);
    
    ron=mean(mr(rstart:rstop,ff(1)));
    rrare=mean(mr(rstart:rstop,ff(2)));
    rcommon=mean(mr(rstart:rstop,ff(3)));
    %ron=mean(mr(rstart:rstop,ff(1)))-r0;
    %rrare=mean(mr(rstart:rstop,ff(2)))-r0;
    %rcommon=mean(mr(rstart:rstop,ff(3)))-r0;
    
    ssafrac(uu)=(rrare-rcommon)./(rrare+rcommon);
    adpfrac(uu)=(ron-rrare)./(ron+rrare);
    sinfo={num2str(ufreq(uu)),sprintf('%.3f',ssafrac(uu))};
    text(0,(uu-1+0.25)*mrmax,sinfo,'HorizontalAlign','Left');
    
    rprev=nanmean(r(1:(rstart-1),:,ff),1);
    rev=nanmean(r(rstart:rstop,:,ff),1);
    rprev=rprev(:);
    rev=rev(:);
    rprev=rprev(~isnan(rprev));
    rev=rev(~isnan(rev));
    ssarespz(uu)=abs(mean(rev)-mean(rprev))./sqrt(var(rev)+var(rprev)).*...
       sqrt(length(rev));
    
end
aa=axis;
pipdur=exptparams.TrialObject.ReferenceHandle.PipDuration;
plot([0 0],aa(3:4),'g--');
plot([0 0]+pipdur,aa(3:4),'g--');
axis tight
legend('onset','rare','common');
legend boxoff


hold off

