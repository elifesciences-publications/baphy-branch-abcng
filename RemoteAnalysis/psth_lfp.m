% function res = psth_heatmap(mfile,channel,unit,axeshandle,options);
%
% psth heatmap with one row per stimulus
%
%
function res = psth_heatmap(mfile,channel,unit,axeshandle,options);

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
if ~isfield(options,'psthfs'),
    options.psthfs=20;
end
if ~isfield(options,'rasterfs'),
    options.rasterfs=max(1000,options.psthfs);
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
options.includeprestim=1;

disp('Loading response...');
[r,tags]=raster_load(mfile,channel,unit,options);

basestd=nanstd(r(:,:));
mbasestd=nanmedian(basestd);
badidx=find(basestd>mbasestd*1.2);
fprintf('%d/%d reps marked bad for artifacts\n',length(badidx),length(basestd));
r(:,badidx)=nan;

disp('generating psth');
p=squeeze(nanmean(r,2))';
stimcount=length(tags);
freqs=cell(stimcount,1);
for ii=1:stimcount,
    tt=strsep(tags{ii},',',1);
    if length(tt)==1,
        freqs{ii}=tt{1};
    else
        freqs{ii}=tt{2};
    end
end

%mod to have unique color for each LFP line in a new figure(KJD 10.11.2011)
sfigure(get(axeshandle,'Parent'));
axes(axeshandle);
colors=copper(stimcount);

hold on;
poffset=nanstd(p(:));
for i=1:stimcount
  plot((1:size(p,2))./options.rasterfs-options.PreStimSilence,(p(i,:))+poffset.*i,'Color',colors(i,:));
end
aa=axis;
%plot stim onset and offset as black vertical lines
plot([0 0],aa(3:4),'k--');
plot([0 0]+exptparams.TrialObject.ReferenceHandle.Duration,aa(3:4),'k--');
hold off
legend(freqs);
xlabel('time (s)');
ylabel('voltage');
axis tight;

