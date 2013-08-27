% function chord_strf_online(mfile,channel,unit,axeshandle,options);
%
% reverse correlation for complex chord stimuli.
%
% SVD 2007-04-12 -- ripped off raster_online & strf_online
%
function [on_mat,off_mat,unique_freq] = boost_online(mfile,channel,unit,axeshandle,options);

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
    options.rasterfs=80;
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
    options.psthfs=100;
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
    options.PostStimSilence=0.0;
end
if ~isfield(options,'filtfmt'),
    options.filtfmt='specgram';
end
if ~isfield(options,'chancount'),
    options.chancount=24;
end

fprintf('%s: Analyzing channel %d (rasterfs %d, spike thresh %.1f std)\n',...
    mfilename,channel,options.rasterfs,options.sigthreshold);
LoadMFile(mfile);

options.channel=channel;
options.unit=unit;
options.PreStimSilence=exptparams.TrialObject.ReferenceHandle.PreStimSilence;
options.PostStimSilence=exptparams.TrialObject.ReferenceHandle.PostStimSilence;

PreBins=round(options.PreStimSilence.*options.rasterfs);
PostBins=round(options.PostStimSilence.*options.rasterfs);

tic;
disp('Loading response...');
[r,tags]=raster_load(mfile,channel,unit,options);
realrepcount=size(r,2);
toc

tic;
disp('Loading stimulus spectrogram...');
[stim,stimparam]=loadstimfrombaphy(mfile,[],[],options.filtfmt,options.rasterfs,options.chancount);
stim=reshape(stim,size(stim,1),size(stim,2)*size(stim,3));
toc
if strcmpi(options.runclass,'SPN') || strcmpi(options.ReferenceClass,'SpNoise'),
    stim =log2(stim+1);
end

%stim=stim(:,PreBins+1:(end-PostBins),:);
r=r(PreBins+1:(end-PostBins),:,:);
stim=stim(:,:)';
r=nanmean(permute(r,[2 1 3]));
r=r(:);

options.chancount=size(stim,2);
%h=blasso(stim,r,0,12,stepsize,tolerance);
h=blasso(stim,r,0,11);

figure(get(axeshandle,'Parent'));
axes(axeshandle);
if options.chancount>3,
    plotastrf(h,2,stimparam.ff,options.rasterfs);
elseif options.chancount>1,
    tt=(0:length(h)-1).*1000/options.rasterfs;
    plot(tt,h);
    hold on
    plot(tt([1 end]),[0 0],'k--');
    hold off
else
    tt=(0:length(h)-1).*1000/options.rasterfs;
    plot(tt,h);
    hold on
    plot(tt([1 end]),[0 0],'k--');
    hold off
end

ht=title(sprintf('%s chan %d rep %d',basename(mfile),channel,realrepcount));
set(ht,'Interpreter','none');
set(gcf,'Name',sprintf('%s(%d)',basename(mfile),realrepcount));

