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
options.includeprestim=1;

disp('Loading response...');
[r,tags]=raster_load(mfile,channel,unit,options);

disp('generating psth');
p=squeeze(nanmedian(r,2))';
stimcount=length(tags);
freqs=zeros(stimcount,1);
for ii=1:stimcount,
    tt=strsep(tags{ii},',');
    freqs(ii)=tt{2};
end

sfigure(get(axeshandle,'Parent'));
axes(axeshandle);
mm=max(abs(p(:)));
%imagesc((1:size(p,2))./options.rasterfs-options.PreStimSilence,1:stimcount,p,[-mm mm]); 
imagesc((1:size(p,2))./options.rasterfs-options.PreStimSilence,1:stimcount,p); 

%mm makes green = zero by getting max lower and upper abs values
hold on
plot([0 0],[0.5 stimcount+0.5],'k--');
plot([0 0]+exptparams.TrialObject.ReferenceHandle.Duration,[0.5 stimcount+0.5],'k--');
hold off
set(gca,'YTick',1:stimcount,'YTickLabels',freqs);
xlabel('time (s)');
ylabel('frequency');

