% funcion [r,params]=load_RDT_by_trial(parmfile,spikefile,options)
%
% Load all the data related to a particular RDT or SNS file (ie,
% repeated embedded noise experiments)
%
% r - binned spike rates [Time x StimSequence x Cell]
% params - a bunch of details about the stimulus sequences and
%          behavior on each trial. of particular interest:
% params.r_raster{sidx,cond} - snipped out rasters for each
%  noise sample (sidx=1..SampleCount) in 5 contexts:
%    cond=1: reference/dual stream
%    cond=2: target/dual stream
%    cond=3: reference/single stream
%    cond=4: target/single stream
%    cond=5: non-target/dual stream
% params.r_trialpos{sidx,cond} - position in noise sequence of each response 
% params.BigSequenceMatrix - list of samples in each trial
%
% created SVD 2013-10-11
%
function [r,params]=load_RDT_by_trial(parmfile,spikefile,options)
    
    if ~exist('options','var'),
        options=struct();
    end
    
    options.lfp=getparm(options,'lfp',0);
    options.rasterfs=getparm(options,'rasterfs',100);
    options.tag_masks=getparm(options,'tag_masks',{'SPECIAL-TRIAL'});
    options.psth=getparm(options,'psth',-1);
    options.meansub=getparm(options,'meansub',0);
    options.resp_shift=getparm(options,'resp_shift',0);
    
    r=[];
    
    % load and process a bunch of parameters
    LoadMFile(parmfile);
    
    params=[];
    params.rasterfs=options.rasterfs;
    if isfield(exptparams.TrialObject,'SamplesPerTrial'),
        params.SamplesPerTrial=exptparams.TrialObject.SamplesPerTrial;
    else
        params.SamplesPerTrial=exptparams.TrialObject.TargetRepCount+...
            max(find(exptparams.TrialObject.ReferenceCountFreq)-1);
    end
    params.PreStimSilence=(exptparams.TrialObject.PreTrialSilence);
    params.PostStimSilence=(exptparams.TrialObject.PostTrialSilence);
    params.SampleDur= ...
        (exptparams.TrialObject.ReferenceHandle.Duration);
    params.SampleCount=exptparams.TrialObject.ReferenceHandle.Count;
    
    TrialCount=exptevents(end).Trial;
    params.TrialCount=TrialCount;
    params.TrialDuration=params.PreStimSilence+params.PostStimSilence+...
        params.SamplesPerTrial*params.SampleDur;
    params.TrialBins=round(params.TrialDuration*options.rasterfs);

    % construct matrices with all the sequences and categories
    Sequences=cell(TrialCount,1);
    params.TargetStartBin=-ones(TrialCount,1);
    for trialidx=1:TrialCount,
        eval('[ev,~,Note]=evtimes(exptevents,''Stim ,*'',trialidx);');
        for ee=1:length(ev),
            tnote=strsep(Note{ee},',',1);
            TypeNote=strtrim(tnote{3});
            tnote=tnote{2};
            v=strsep(tnote,'+');
            Sequences{trialidx}(ee,1:length(v))=cat(2,v{:});
            if strcmpi(TypeNote,'Target'),
                params.TargetStartBin(trialidx)=ee;
            end
        end
    end
    SequenceIdx=exptparams.TrialObject.SequenceIdx;
    if TrialCount<length(SequenceIdx),
        SequenceIdx=SequenceIdx(1:TrialCount);
    end
    
    PreBins=round(params.PreStimSilence.*options.rasterfs);
    PostBins=round(params.PostStimSilence.*options.rasterfs);
    
    params.SampleStartTimes=(0:params.SamplesPerTrial).* ...
                            params.SampleDur+params.PreStimSilence +...
        options.resp_shift;
    params.TargetStartTime=-ones(size(params.TargetStartBin));
    tartrials=find(params.TargetStartBin>0);
    params.TargetStartTime(tartrials)=...
        params.SampleStartTimes(params.TargetStartBin(tartrials));
    params.SampleStarts=round(((0:params.SamplesPerTrial).* ...
        params.SampleDur+params.PreStimSilence+options.resp_shift).*...
                              options.rasterfs)+1;
    
    params.SampleStops=params.SampleStarts+...
        round(params.SampleDur.*options.rasterfs)-1;
    
    %initialize BSM
    params.BigSequenceMatrix=-ones(params.SamplesPerTrial,2,TrialCount);
    params.ThisTarget=zeros(TrialCount,1);
    for ss=1:TrialCount,
         params.BigSequenceMatrix(1:size(Sequences{ss},1),...
                                 1:size(Sequences{ss},2),ss)=Sequences{ss};
         if params.TargetStartBin(ss)>0,
             params.ThisTarget(ss)=...
                 params.BigSequenceMatrix(params.TargetStartBin(ss),1,ss);
         end
    end
    if strcmpi(exptparams.TrialObject.descriptor,'StreamNoise'),
        params.TargetIdx=1:exptparams.TrialObject.TargetCount;
    else
        params.TargetIdx=exptparams.TrialObject.TargetIdx;
    end    
    
    % if behavior, pull out some performance data
    if isfield(exptparams,'Performance'),
        params.FirstLickTime=...
            cat(1,exptparams.Performance(1:TrialCount).FirstLickTime);
        params.Hit=cat(1,exptparams.Performance(1:TrialCount).Hit);
        params.FalseAlarm=~cat(1,exptparams.Performance(1:TrialCount).Hit) ...
            & ~cat(1,exptparams.Performance(1:TrialCount).Miss);
    end
    
    % if spike file is specified, load response for each cell in the site
    if exist('spikefile','var') && ~isempty(spikefile),
        bb=basename(spikefile);
        if ~isfield(options,'channel') | ~isfield(options,'unit'),
            sql=['SELECT channum,unit FROM sCellFile WHERE respfile="',bb,'";'];
            fdata=mysql(sql);
            unitset=[cat(1,fdata.channum).*10+cat(1,fdata.unit)];
            options.channel=floor(unitset(1)/10);
            options.unit=mod(unitset(1),10);
        end
        
        [r,tags,trialset,exptevents,sortextras]=...
            loadsiteraster(spikefile,[],[],options);
        CellCount=size(r,3);
        
        % trim stray bins from end of each trial
        %r=r(1:params.TrialBins,:,:,:).*options.rasterfs;
        r=r.*options.rasterfs;
        
        % for behavior, only loaded correct trials, need to extract
        % that subset from params.
        params.CorrectTrials=trialset;
        
        % compute average response to each stimulus -- ref or tar cond
        binsperstim=round(options.rasterfs.*params.SampleDur);
        pb=params.PreStimSilence.*options.rasterfs;
        if strcmpi(exptparams.TrialObject.descriptor,'StreamNoise'),
            maxsamples=exptparams.TrialObject.SamplesPerTrial;
            tarlen=pb+maxsamples.*binsperstim;
        else
            maxsamples=max(exptparams.TrialObject.TargetRepCount,...
                 params.SamplesPerTrial-exptparams.TrialObject.TargetRepCount);
            tarlen=pb+exptparams.TrialObject.TargetRepCount.*binsperstim;
        end
        r_ref=nan(pb+maxsamples.*binsperstim,length(trialset));
        r_tar=nan(pb+maxsamples.*binsperstim,length(trialset));
        
        for tidx=1:length(trialset),
            trialidx=trialset(tidx);
            if params.TargetStartBin(trialidx)>0,
                tstart=params.SampleStarts(params.TargetStartBin(trialidx));
                r_ref(1:(tstart-1),tidx)=r(1:(tstart-1),tidx);
                
                r_tar(1:tarlen,tidx)=r(tstart-pb-1+(1:tarlen),tidx);
            else
                r_ref(:,tidx)=r(1:size(r_ref,1),tidx);
            end
        end
        
        boundbins=round(options.rasterfs.*0.05);
        r_avg=zeros(binsperstim+boundbins*2,params.SampleCount,5);
        r_count=zeros(params.SampleCount,5);
        r_raster=cell(params.SampleCount,5);
        r_second=cell(params.SampleCount,5);
        r_repSlot=cell(params.SampleCount,5);
        r_trialpos=cell(params.SampleCount,5);
        for sidx=1:params.SampleCount,
            for tidx=1:length(trialset),
                trialidx=trialset(tidx);
                ff=find(params.BigSequenceMatrix(:,1,trialidx)==sidx |...
                    params.BigSequenceMatrix(:,2,trialidx)==sidx);
                for ii=ff(:)',
                    rr=(params.SampleStarts(ii)-boundbins):...
                       (params.SampleStops(ii)+boundbins);
                    repSlot=0;
                    if ii==1 || ...
                          (params.TargetStartBin(trialidx)>0 && ...
                           ii>params.TargetStartBin(trialidx)+3),
                        % skip first sample of each trial and
                        % repeated targets after #3
                        cond=0;
                    elseif params.TargetStartBin(trialidx)>0 && ...
                            ii>params.TargetStartBin(trialidx) && ...
                            params.BigSequenceMatrix(ii,2,trialidx)==sidx && ...
                            params.BigSequenceMatrix(ii,1,trialidx)~=sidx,
                        % background stream during target
                        cond=5;
                    elseif (ii<=params.TargetStartBin(trialidx) ||...
                            params.TargetStartBin(trialidx)<0 ||...
                            params.BigSequenceMatrix(ii,2,trialidx)==sidx) &&...
                           sum(params.BigSequenceMatrix(:,2,trialidx)>0)>0,
                        % reference/dual stream
                        cond=1;
                    elseif sum(params.BigSequenceMatrix(:,2,trialidx)>0)>0
                        % target/dual stream
                        cond=2;
                        if params.TargetStartBin(trialidx)<0,
                            repSlot=ii;
                        else
                            repSlot=ii-params.TargetStartBin(trialidx)+1;
                        end
                    elseif params.TargetStartBin(trialidx)<0 ||...
                           ii<=params.TargetStartBin(trialidx),
                        % reference, single stream
                        cond=3;
                    else
                        % target, single stream
                        cond=4;
                        repSlot=ii-params.TargetStartBin(trialidx)+1;
                    end
                    %if ismember(sidx,params.TargetIdx),
                    %    params.BigSequenceMatrix(:,:,trialidx)
                    %    [sidx cond]
                    %    keyboard
                    %end
                    if cond,
                        r_count(sidx,cond)=r_count(sidx,cond)+1;
                        r_avg(:,sidx,cond)=r_avg(:,sidx,cond)+...
                            gsmooth(r(rr,tidx),options.rasterfs./200);
                        r_raster{sidx,cond}=cat(2,r_raster{sidx,cond},r(rr,tidx));
                        if sidx==params.BigSequenceMatrix(ii,2,trialidx),
                            r_second{sidx,cond}(r_count(sidx,cond),1)=...
                                params.BigSequenceMatrix(ii,1,trialidx);
                        else
                            r_second{sidx,cond}(r_count(sidx,cond),1)=...
                                params.BigSequenceMatrix(ii,2,trialidx);
                        end
                        r_repSlot{sidx,cond}(r_count(sidx,cond),1)=repSlot;
                        r_trialpos{sidx,cond}(r_count(sidx,cond),1)=ii;
                    end
                end
            end
            for cond=1:size(r_avg,3),
                r_avg(:,sidx,cond)=r_avg(:,sidx,cond)./r_count(sidx,cond);
            end
        end
        params.r_avg=r_avg;
        params.r_count=r_count;
        params.r_raster=r_raster;
        params.r_second=r_second;
        params.r_ref=r_ref;
        params.r_tar=r_tar;
        params.r_repSlot=r_repSlot;
        params.r_trialpos=r_trialpos;
     end

 
