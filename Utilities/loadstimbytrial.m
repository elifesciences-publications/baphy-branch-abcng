% function [stim,stimparam]=loadstimbytrial(parmfile,options);
%
% inputs: 
%  parmfile - a baphy m-file
%  options - struct with optional fields:
%   filtfmt - currently can be 'wav' or 'specgram' or 'wav2aud' or
%              'audspectrogram' or 'envelope' (collapsed over frequency)
%   fsout - output sampling rate
%   chancount - output number of channels
%   forceregen - regenerate cached stimulus file from raw waveform
%
% returns:
%  stim - spectrogram or otherwise formatted Reference stimulus in
%         baphy parameter file, all stimuli are sorted according to
%         their index and concatenated into one large freq X time
%         matrix.
%  stimparam - currently empty except for filtfmt=='specgram', when
%              it contains a vector of the frequency corresponding
%              to each channel in the stimulus spectrogram.
%
% created SVD 2013-03-27
%
function [stim,stimparam]=loadstimbytrial(parmfile,options);

% check function parms and set defaults
if ~exist('options','var'),
    options=[];
    disp('no options specified, using defaults');
end
filtfmt=getparm(options,'filtfmt','none');
fsout=getparm(options,'fsout',100);
if strcmpi(filtfmt,'envelope'),
    chancount=getparm(options,'chancount',0);
else
    chancount=getparm(options,'chancount',30);
end
forceregen=getparm(options,'forceregen',0);
%includeprestim=getparm(options,'includeprestim',1);
truncatetargets=getparm(options,'truncatetargets',1);

if strcmp(filtfmt,'wav') || strcmp(filtfmt,'none'),
   % force chancount to default for wav format (ie, actual number
   % of channels)
   chancount=0;
end

% check for cached file
%if exist('~/data/tstim/','dir')
%    ppdir=['~/data/tstim/'];
%else
if exist('/auto/data/tmp/tstim/','dir')
    ppdir=['/auto/data/tmp/tstim/'];
else
    ppdir=tempdir;
end
preprocfile=sprintf('%sloadstimbytrial_%s_ff%s_fs%d_cc%d_trunc%d.mat',...
             ppdir,basename(parmfile),filtfmt,fsout,...
             chancount,truncatetargets);

if ~forceregen && exist(preprocfile,'file')
   fprintf('Loading saved stimulus from %s\n',basename(preprocfile));
   % load pregenerated stim
   load(preprocfile);
   return
end

% preprocessed file doesn't exist or forced regeneration --
% generate stimulus env/spectrogram
fh=[];
fprintf('Cache file %s does not exist. Regenerating...\n',...
        basename(preprocfile));

LoadMFile(parmfile);

fprintf('Creating Trial Object %s\n',exptparams.TrialObjectClass);
TrialObject=feval(exptparams.TrialObjectClass);
fields=get(TrialObject,'UserDefinableFields');
for cnt1 = 1:3:length(fields),
    try % since objects are changing,
        TrialObject = set(TrialObject,fields{cnt1},exptparams.TrialObject.(fields{cnt1}));
    catch
        disp(['property ' fields{cnt1} ' not found, using default']);
    end
end

fprintf('Creating Reference Object %s\n',exptparams.TrialObject.ReferenceClass);
RefObject=feval(exptparams.TrialObject.ReferenceClass);
fields=get(RefObject,'UserDefinableFields');
for cnt1 = 1:3:length(fields),
    try % since objects are changing,
        RefObject = set(RefObject,fields{cnt1},exptparams.TrialObject.ReferenceHandle.(fields{cnt1}));
    catch
        if strcmp(fields{cnt1},'UseBPNoise'),
            % special case, for old data use non-default value
            disp('Setting UseBPNoise=0 for backwards compatability');
            RefObject = set(RefObject,fields{cnt1},0);
        else
            disp(['property ' fields{cnt1} ' not found, using default']);
        end
    end
end
if ~strcmpi(exptparams.TrialObject.TargetClass,'None'),
    fprintf('Creating Target Object %s\n',exptparams.TrialObject.TargetClass);
    TarObject=feval(exptparams.TrialObject.TargetClass);
    fields=get(TarObject,'UserDefinableFields');
    for cnt1 = 1:3:length(fields),
        try % since objects are changing,
            TarObject = set(TarObject,fields{cnt1},exptparams.TrialObject.TargetHandle.(fields{cnt1}));
        catch
            if strcmp(fields{cnt1},'UseBPNoise'),
                % special case, for old data use non-default value
                disp('Setting UseBPNoise=0 for backwards compatability');
                TarObject = set(TarObject,fields{cnt1},0);
            else
                disp(['property ' fields{cnt1} ' not found, using default']);
            end
        end
    end
else
    TarObject=[];
end
TrialObject = set(TrialObject, 'TargetHandle', TarObject);
TrialObject = set(TrialObject, 'ReferenceHandle', RefObject);

NonUserDefFields=setdiff(fieldnames(exptparams.TrialObject),...
                         {'ReferenceClass','ReferenceHandle',...
                    'TargetClass','TargetHandle',...
                    'descriptor','RunClass','UserDefinableFields'});
for ii=1:length(NonUserDefFields),
    if isfield(TrialObject,NonUserDefFields{ii}),
        TrialObject=set(TrialObject,NonUserDefFields{ii},...
                        exptparams.TrialObject.(NonUserDefFields{ii}));
    end
end
dstr='';

RefObject=get(TrialObject,'ReferenceHandle');
TarObject=get(TrialObject,'TargetHandle');
TrialFs=get(TrialObject,'SamplingRate');
if isfield(exptparams.TrialObject,'OveralldB'),
    OveralldB=exptparams.TrialObject.OveralldB;
    dstr=[dstr '-' num2str(OveralldB) 'dB'];
    scalelevel=10.^(-(80-OveralldB)./20);
else
    OveralldB=0;
    scalelevel=1;
end
if isfield(exptparams.TrialObject,'RelativeTarRefdB'),
    RelativeTarRefdB=exptparams.TrialObject.RelativeTarRefdB;
    tarscalelevel=10.^(RelativeTarRefdB./20);
else
    RelativeTarRefdB=0;
    tarscalelevel=1;
end
TrialCount=globalparams.rawfilecount;

%
% generate the stimulus signal for each trial
%
if strcmpi(exptparams.TrialObjectClass,'StreamNoise') || ...
        strcmpi(exptparams.TrialObjectClass,'RepDetect'),
    maxstreams=3;
    if strcmpi(exptparams.TrialObject.descriptor,'StreamNoise'),
        SamplesPerTrial=exptparams.TrialObject.SamplesPerTrial;
    else
        SamplesPerTrial=exptparams.TrialObject.TargetRepCount+...
            max(find(exptparams.TrialObject.ReferenceCountFreq)-1);
    end
    BigStimMatrix=-ones(SamplesPerTrial,2,TrialCount);
    if strcmpi(filtfmt,''),
        [qstim,tstimparam]...
            =loadstimfrombaphy(parmfile,[],[],'specgramv',fsout,chancount);
    elseif strcmpi(filtfmt,'qlspecgram'),
        [qstim,tstimparam]...
            =loadstimfrombaphy(parmfile,[],[],'specgram',fsout,chancount);
    end
    
else
    maxstreams=1;
    BigStimMatrix=[];
end
MaxTrialLen=round(max(evtimes(exptevents,'TRIALSTOP').*fsout));
for trialidx=1:TrialCount,
    ThisTrialLength=evtimes(exptevents,'TRIALSTOP',trialidx);
    fprintf('Trial %d (len %.2f)\n',trialidx,ThisTrialLength);
    if strcmpi(filtfmt,'qspecgram') || strcmpi(filtfmt,'qlspecgram'),
        ThisTrialBins=round(ThisTrialLength.*fsout);
        w=zeros(ThisTrialBins,chancount);
    elseif strcmpi(filtfmt,'envelope'),
        ThisTrialBins=round(ThisTrialLength.*fsout);
        w=zeros(ThisTrialBins,maxstreams);
        smfilt=ones(round(TrialFs/fsout),1)./round(TrialFs/fsout);
    else
        ThisTrialBins=round(ThisTrialLength.*TrialFs);
        w=zeros(ThisTrialBins,maxstreams);
    end
    
    [t1,~,~,toff1]=evtimes(exptevents,'PreStim*',trialidx);
    [t2,~,Note,toff2]=evtimes(exptevents,'Stim *',trialidx);
    [t3,~,~,toff3]=evtimes(exptevents,'PostStim*',trialidx);
    
    % go through each event
    for evidx=1:length(t2),
        
        NoteParts=strsep(Note{evidx},',',1);
        if ~isempty(findstr(NoteParts{3},'Target')) &&...
                ~isempty(TarObject),
            o=TarObject;
            istar=1;
        else
            o=RefObject;
            istar=0;
        end
        if length(t1)==length(t2),
            o=set(o,'PreStimSilence',toff1(evidx)-t1(evidx));
            o=set(o,'Duration',toff2(evidx)-t2(evidx));
            o=set(o,'PostStimSilence',toff3(evidx)-t3(evidx));
        end
        
        n=get(o,'Names');
        ff=find(strcmp(strtrim(NoteParts{2}),n),1);
        
        if (strcmpi(filtfmt,'qspecgram') || strcmpi(filtfmt,'qlspecgram')) && ...
                (strcmpi(exptparams.TrialObjectClass,'StreamNoise') ||...
                 strcmpi(exptparams.TrialObjectClass,'RepDetect')),
            % special treatment for stream noise
            stimidxs=strsep(NoteParts{2},'+',1);
            tw=[];
            for sidx=1:length(stimidxs),
                ff=find(strcmp(strtrim(stimidxs{sidx}),n),1);
                tw=cat(3,tw,qstim(:,:,ff)');
                BigStimMatrix(evidx,sidx,trialidx)=ff;
            end
            tw=mean(tw,3);
            startbin=round(t2(evidx).*fsout);
            
            if isfield(exptparams.TrialObject,'PreTargetAttenuatedB'),
                if strcmpi(strtrim(NoteParts{3}),'Reference'),
                    PreTargetScaleBy=10^(-exptparams.TrialObject.PreTargetAttenuatedB/20);
                    tw=tw.*PreTargetScaleBy;
                end
            end
            
            w(startbin+(1:size(tw,1)),:)=tw;
            
        elseif strcmpi(exptparams.TrialObjectClass,'StreamNoise') ||...
                strcmpi(exptparams.TrialObjectClass,'RepDetect'),
            
            % special treatment for stream noise
            stimidxs=strsep(NoteParts{2},'+',1);
            tw=[];
            for sidx=1:length(stimidxs),
                ff=find(strcmp(strtrim(stimidxs{sidx}),n),1);
                tw=cat(2,tw,waveform(o,ff));
                BigStimMatrix(evidx,sidx,trialidx)=ff;
            end
            if size(tw,2)>maxstreams,
                 w(:,maxstreams+1:size(tw,2))=0;
                 maxstreams=size(tw,2);
            elseif size(tw,2)<maxstreams,
                 tw(:,size(tw,2)+1:maxstreams)=0;
            end
            tw(:,end)=sum(tw(:,1:(end-1)),2);
            startbin=round(t2(evidx).*TrialFs);
            
            if isfield(exptparams.TrialObject,'PreTargetAttenuatedB'),
                if strcmpi(strtrim(NoteParts{3}),'Reference'),
                    PreTargetScaleBy=10^(-exptparams.TrialObject.PreTargetAttenuatedB/20);
                    tw=tw.*PreTargetScaleBy;
                end
            end
            
            w(startbin+(1:size(tw,1)),1:size(tw,2))=tw;
            
        elseif istar && truncatetargets
            
            % truncate waveform at time that target sound starts
            TarBin=round(t2(evidx).*fsout);
            if size(w,1)>TarBin,
                w=w(1:round(t2(evidx).*fsout),:);
            end
        elseif strcmpi(filtfmt,'envelope') && ismethod(o,'env'),
            
            % special envelope 
            fprintf(' %s (%.2f-%.2f)\n',n{ff},t2(evidx),toff2(evidx));
            w2=env(o,ff).*scalelevel;
            w3=conv2(w2,smfilt,'same');
            tstim=w3(round((TrialFs/fsout./2):(TrialFs/fsout):length(w3)),:);
            startbin=round(t1(evidx).*fsout+1);
            stopbin=round(toff3(evidx).*fsout);
            if stopbin>ThisTrialBins,
                stopbin=ThisTrialBins;
                tstim=tstim(1:(stopbin-startbin+1),:);
            end
            if size(tstim,2)>size(w,2),
                w(:,size(tstim,2))=0;
            end
            if istar,
                for jj=1:size(tstim,2),
                    tstim=tstim*tarscalelevel(min(length(tarscalelevel),jj));
                end
            end
            w(startbin:stopbin,1:size(tstim,2))=...
                w(startbin:stopbin,1:size(tstim,2))+tstim;
        else
            error(['env method required / or unsupported filtfmt/' ...
                   'TrialObject combo']);
        end
        
    end
    if isfield(exptparams.TrialObject,'OnsetRampSec') &&...
       exptparams.TrialObject.OnsetRampSec>0,
        % add a ramp
        PreBins=round(t2(1).*TrialFs);
        OnsetRampBins=round(exptparams.TrialObject.OnsetRampSec.*TrialFs);
        OnsetRamp=linspace(0,1,OnsetRampBins)';
        w(PreBins+(1:OnsetRampBins),:)=...
            w(PreBins+(1:OnsetRampBins),:).*repmat(OnsetRamp,[1 size(w,2)]);
    end
    
    if strcmpi(filtfmt,'none') || strcmpi(filtfmt,'wav') ||...
            strcmpi(filtfmt,'envelope') || strcmpi(filtfmt,'qspecgram') || strcmpi(filtfmt,'qlspecgram'),
        if ~strcmpi(filtfmt,'envelope') && ~strcmpi(filtfmt,'qspecgram') && ~strcmpi(filtfmt,'qlspecgram'),
            % envelope has already been downsampled
            tstim=[];
            for ww=1:size(w,2),
                tstim=cat(2,tstim,resample(w(:,ww),fsout,...
                    exptparams.TrialObject.SamplingRate));
            end
            w=tstim;
        end
        if trialidx==1,
            stim=zeros(size(w,2),MaxTrialLen,TrialCount).*nan;
        end
        stim(:,1:size(w,1),trialidx)=w';
    else
        if isempty(fh),
            fh=figure;
        else
            sfigure(fh);
        end
        if trialidx==1
            stim=zeros(chancount,MaxTrialLen,TrialCount,maxstreams).*nan;
        end
        
        for sidx=1:size(w,2),
            mm=max(find(abs(w(:,sidx))>0));
            if ~isempty(mm),
                fprintf('%d samples: ',mm);
                [tstim,tstimparam]=...
                    wav2spectral(w(1:mm,sidx),filtfmt,TrialFs,fsout,chancount);
            else
                fprintf('empty stream\n');
                tstim(:)=0;
            end
            stim(:,1:size(tstim,1),trialidx,sidx)=tstim';
        end
        imagesc(cat(1,stim(:,:,trialidx,1),stim(:,:,trialidx,2),...
                    stim(:,:,trialidx,3)));
        axis xy;
        drawnow
    end
end

%
% determine some useful meta-information about the stimulus
%
stimparam=[];
ro=exptparams.TrialObject.ReferenceHandle;
if strcmpi(filtfmt,'envelope'),
    stimparam.tags=ro.Names;
    
    if isfield(ro,'LowFreq'),
        bandcount=size(stim,1);
        bandnames=cell(bandcount,1);
        FilterParms=cell(bandcount,1);
        for bb=1:bandcount,
            f1 = ro.LowFreq(bb)/ro.SamplingRate*2;
            f2 = ro.HighFreq(bb)/ro.SamplingRate*2;
            [b,a] = ellip(4,.5,20,[f1 f2]);
            FilterParams{bb} = [b;a];
            bandnames{bb}=sprintf('%d-%d',round(ro.LowFreq(bb)),...
                                  round(ro.HighFreq(bb)));
        end
        stimparam.ff=bandnames;
    end
elseif strcmpi(filtfmt,'none') || strcmpi(filtfmt,'wav'),
    stimparam.tags=ro.Names;
    
else
    stimparam=tstimparam;
    stimparam.tags=ro.Names;
end
stimparam.BigStimMatrix=BigStimMatrix;

% truncate time bins that are always nan at the end of the stim vectors
sn=max(sum(~isnan(stim(1,:,:,1))));
stim=stim(:,1:sn,:,:);

%
% save cache file for quick reloading
%
fprintf('saving cached stimulus to %s\n',basename(preprocfile));
save(preprocfile,'stim','stimparam');

