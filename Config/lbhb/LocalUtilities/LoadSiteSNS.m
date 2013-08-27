% function [r,s,params]=LoadSiteSNS(cellid)
% 
% r - response raster [Time X Trial X Cell]
% s - stimulus spectrogram [FreqChannel X Time X Trial X Stream]
%     where Stream=1 is first noise samples, Stream=2 is second and
%     Stream=3 is the sum of those samples, ie, the actual stimulus
%     played.
%
% SVD 2013-06-12
%
function [r,s,params]=LoadSiteSNS(cellid,rasterfs)
    
if 0,
    % various options for sites with SNS data
    cellid='por016e-a1';
    cellid='por017c-a1';
    cellid='por020a-a1';
    cellid='por021b-a1';
    cellid='por022a-a1';
    cellid='por023a-a1';
    cellid='por028d-a1';
    cellid='por053a-02-1';
end
if ~exist('cellid','var'),
    cellid='por028d-a1';
end
if ~exist('rasterfs','var'),
    rasterfs=100;
end

cellfiledata=dbgetscellfile('runclass','SNS','cellid',cellid);

parmfile=[cellfiledata(1).stimpath cellfiledata(1).stimfile];
spikefile=[cellfiledata(1).path cellfiledata(1).respfile];

% load the response for each cell in the site
options=[];
options.rasterfs=100;
options.tag_masks={'SPECIAL-TRIAL'};
options.psth=-1;
options.lfp=0;
options.meansub=0;
bb=basename(spikefile);
sql=['SELECT channum,unit FROM sCellFile WHERE respfile="',bb,'";'];
fdata=mysql(sql);
unitset=[cat(1,fdata.channum).*10+cat(1,fdata.unit)];
options.channel=floor(unitset/10);
options.unit=mod(unitset,10);

[r,tags,trialset,exptevents,sortextras]=loadsiteraster(spikefile,[],[],options);

% load the stimulus spectrogram
options.filtfmt='specgram';
s=loadstimbytrial(parmfile,options);

% record a bunch of parameters
LoadMFile(parmfile);

params=[];
params.SamplesPerTrial=exptparams.TrialObject.SamplesPerTrial;
params.PreStimSilence=(exptparams.TrialObject.PreTrialSilence);
params.PostStimSilence=(exptparams.TrialObject.PostTrialSilence);
params.SampleDur=(exptparams.TrialObject.ReferenceHandle.Duration);

params.TrialCount=exptevents(end).Trial;
params.TrialDuration=exptparams.TrialObject.PreTrialSilence+...
    exptparams.TrialObject.PostTrialSilence+...
    exptparams.TrialObject.SamplesPerTrial*...
    exptparams.TrialObject.ReferenceHandle.Duration;
params.TrialBins=round(params.TrialDuration*options.rasterfs);

SequenceIdx=exptparams.TrialObject.SequenceIdx;
if params.TrialCount<length(SequenceIdx),
    SequenceIdx=SequenceIdx(1:params.TrialCount);
end
params.Sequences={exptparams.TrialObject.Sequences{SequenceIdx}};
params.BigCat=exptparams.TrialObject.SequenceCategories(SequenceIdx);

params.CellCount=size(r,3);


% trim stray bins from end of each trial
r=r(1:params.TrialBins,:,:,:);
s=s(:,1:params.TrialBins,:,:);

% trim all-zero trials (for funny crash conditions/cell loss)
zerocheck=nansum(nansum(r,1),3);
nzmax=max(find(zerocheck>0));
if nzmax<params.TrialCount,
    fprintf('All-zero trials at end, truncating from %d to %d trials\n',...
            params.TrialCount,nzmax);
    params.TrialCount=nzmax;
    r=r(:,1:nzmax,:);
end

params.PreBins=round(params.PreStimSilence.*options.rasterfs);
params.PostBins=round(params.PostStimSilence.*options.rasterfs);

params.SampleStarts=round(((0:params.SamplesPerTrial).*params.SampleDur+params.PreStimSilence).*options.rasterfs)+1;
params.SampleStops=params.SampleStarts+round(params.SampleDur.* ...
                                             options.rasterfs)-1;

return

% demo spectrogram reconstruction:

fb=params.SampleStarts(1);
lb=params.SampleStarts(end)-1;
randtrials=find(ismember(params.BigCat,[4 6]));

% stim0 is summed stimulus (both noise streams)
stim0=s(:,fb:lb,randtrials,3);

r0=permute(r(fb:lb,randtrials,:),[1 3 2]);

[teststim,xcperchan]=quick_recon(r0,stim0,[]);



