% function [exptevents,exptparams]=multistim_run(globalparams,exptparams,HW);
%
% run the multi-stimulus module in baphy. uses standartad parameter syntax:
%  globalparams - defined by BaphyMainGUI
%  exptparams - defined by dms_init
%  HW - created by InitializeHW
%
% created SVD 2010-04-13
%
function [exptevents,exptparams]=multistim_run(globalparams,exptparams,HW);

% paths should have been set by startup.m
global BAPHYHOME DB_USER

disp([mfilename ': Initializing...']);

if globalparams.HWSetup==0
    disp(['NOTE---RUNNING IN TEST MODE']);
end

stimcount=exptparams.stimcount;

disp('Figuring out multiple parmfiles');
mfiles={globalparams.mfilename};
evpfiles={globalparams.evpfilename};
rawids=globalparams.rawid;

% save first mfile name for converting raw data to evps for stimuli 2..N
globalparams.daqmfilename=globalparams.mfilename;

texptparams=exptparams;
for ii=2:stimcount,
    texptparams.runclass=exptparams.runclass{ii};
    [mfiles{ii},evpfiles{ii},rawids(ii,1)]=...
        dbmfilename(globalparams,texptparams);
end

disp('Setting up sound objects...');
RO=cell(stimcount,1);
maxfs=0;
for ii=1:exptparams.stimcount,
    sii=['Stim',num2str(ii)];
    if isfield(exptparams.(sii),'SamplingRate'),
        maxfs=max(maxfs,exptparams.(sii).SamplingRate);
    end
end
exptparams.fs=maxfs;

maxidxset=zeros(stimcount,1);
for ii=1:exptparams.stimcount,    
    sii=['Stim',num2str(ii)];
    fprintf('%s: Creating %s object...\n',sii,exptparams.(sii).descriptor);
    RO{ii}=eval(exptparams.(sii).descriptor);
    ff=fieldnames(exptparams.(sii));
    for jj=1:length(ff),
        RO{ii}=set(RO{ii},ff{jj},getfield(exptparams.(sii),ff{jj}));
    end
    RO{ii}=set(RO{ii},'SamplingRate',exptparams.fs);
    exptparams.(sii).SamplingRate=exptparams.fs;
    
    %exptparams.TrialObject.(sii)=get(RO{ii});
    maxidxset(ii)=get(RO{ii},'MaxIndex');
end

HW = IOSetTrigger(HW, 'HwDigital');    % AI and AO start synchronously with IOStartAcquisition

if ismember (globalparams.HWSetup,[1 3 5]),
    % ie, full callibrated system
    % use hardware attenuator to achieve least attenuated level.
    hardware_atten=80-exptparams.soundlevel;

    IOSetLoudness(HW,hardware_atten);
else
    % no attenuator, just use software
    hardware_atten=0;
end

% play dummy sound to deal with no-first-play bug. perhaps not necessary?
%[ev,HW]=IOStartSound(HW, zeros(10,1));
%pause(0.05);

% start up JobMonitor
exptevents=cell(stimcount,1);
jh=JobMonitor(globalparams,exptevents{1});

% loop trials indefinitely (until break at end of trial block)
originalmaxreps=exptparams.repcount;
repcount=0;
trialnumber=0;
trialcounters=zeros(stimcount,1);
playedset=ones(sum(maxidxset),1);
exptparams.triallog=[];
while 1,
    %%% basic structure of a trial:
    % 0. figure out if new repetition and, if so, reinitialize
    % 1. figure out which sound to play
    % 2. choose one of those sounds that hasn't been played yet on this rep
    % 
    
    % figure out if new rep, and reinitialize if necessary
    if sum(playedset)==length(playedset),
        repcount=repcount+1;
        fprintf('\n************************\n Starting repetition %d\n************************\n\n',repcount);
        
        % array length=total number of exemplars for all stimuli. so all we
        % need to do to pick the next stimulus is choose one that hasn't
        % been played yet.
        stimidx=[];
        stimsubidx=[];
        for ii=1:stimcount,
            stimidx=cat(1,stimidx,ii.*ones(maxidxset(ii),1));
            stimsubidx=cat(1,stimsubidx,(1:maxidxset(ii))');
        end
        playedset=zeros(sum(maxidxset),1);
    end
    
    trialnumber=trialnumber+1;
    % figure out next stimulus
    ff=find(~playedset);
    nextid=ff(ceil(rand*length(ff)));
    nextstim=stimidx(nextid);
    nextsubstim=stimsubidx(nextid);
    trialcounters(nextstim)=trialcounters(nextstim)+1;
    exptparams.triallog(:,trialnumber)=[nextstim;nextsubstim];
    fprintf('Next: Stim %d idx %d\n',nextstim,nextsubstim);
    
    [w,stimevents]=waveform(RO{nextstim},nextsubstim);
    
    % show current waveform in job monitor
    JobMonitor('JobMonitor_PlotWaveform',jh,[],[],w,exptparams.fs);
    
    %
    % TRIAL STARTS HERE
    %
    
    % load sound, but don't start any acquisition
    aidur=2+length(w)./exptparams.fs;
    IOSetAnalogInDuration(HW, aidur);
    HW=IOLoadSound(HW,w);
    
    % start AI/spike acquisition here
    exptevents{nextstim}=AddEvent(exptevents{nextstim},IOStartAcquisition(HW),trialcounters(nextstim));
    for jj=1:length(stimevents),
        exptevents{nextstim}=AddEvent(exptevents{nextstim},stimevents(jj),trialcounters(nextstim));
        exptevents{nextstim}(end).Note=[exptevents{nextstim}(end).Note ' , Reference'];
    end

    while IOIsPlaying(HW),
        %if exptparams.distobject | IOGetTimeStamp(HW) > exptevents(end).StopTime,
        %if ~QuickError | IOGetTimeStamp(HW)>RO_duration(1)-get(RO,'PostStimSilence'),
        %    IOStopSound(HW);
        %    disp('stopped now');
        %end
        pause(0.01);
    end
    
    exptevents{nextstim}=AddEvent(exptevents{nextstim},IOStopAcquisition(HW),trialcounters(nextstim));
    
    stopnow=get(jh,'UserData');
    JobMonitor('JobMonitor_Refresh',jh,[],[],globalparams,exptevents{nextstim});
    
    playedset(nextid)=1;
    
    % end of repetition, save to more than one mfile??
    if sum(playedset)==length(playedset),
        disp('saving intermediate parameters in case of crash...');
        save_parameters(globalparams,exptparams,exptevents,rawids,mfiles,evpfiles);
    end

    if stopnow || (sum(playedset)==length(playedset) && repcount>=exptparams.repcount),
        disp('---------------------------------------------------------');
        fprintf('Finished %d reps\n',repcount-1+(sum(playedset)==length(playedset)));
        yn=questdlg('Continue running?','Multi-Stim','Yes','No','Yes');
        if strcmp(yn,'No'),
            break
        elseif sum(playedset)==length(playedset) && repcount>=exptparams.repcount,
            % go for a few more reps if we're hit the pre-determined limit.
            exptparams.repcount=exptparams.repcount+originalmaxreps;
        end
    end

end

if exist('jh','var') & ~isempty(jh),
    close(jh);
end

globalparams.ExperimentComplete=1;
save_parameters(globalparams,exptparams,exptevents,rawids,mfiles,evpfiles);

% that's it!
disp([mfilename ': Complete']);



%
%function save_parameters(globalparams,exptparams,exptevents,rawids,mfiles,evpfiles);
%
function save_parameters(globalparams,exptparams,exptevents,rawids,mfiles,evpfiles);

% save appropriate mfiles!
for ii=find(rawids(:)'>0),
    fprintf('Generating m-file: %s...\n',mfiles{ii});
    sii=['Stim',num2str(ii)];
    exptparams.TrialObject=[];
    exptparams.TrialObject.ReferenceHandle=exptparams.(sii);
    exptparams.thisstimidx=ii;
    globalparams.mfilename=mfiles{ii};
    globalparams.evpfilename=evpfiles{ii};
    globalparams.rawid=rawids(ii);
    WriteMFile(globalparams,exptparams,exptevents{ii},1);
    
    disp('saving performance/parameter data to cellDB...');
    
    % code morphed from Nima's PrepareDatabaseData
    Parameters  = [];
    Parameters.Module='Multi-Stimulus';
    Parameters.Stimulus_Total=exptparams.stimcount;
    Parameters.This_Stimulus_Idx=ii;
    Parameters.Trial_OverallDB=exptparams.soundlevel;
    RefHandle = exptparams.TrialObject.ReferenceHandle;
    if ~isempty(RefHandle)
        Parameters.Reference = '______________';
        Parameters.ReferenceClass = RefHandle.descriptor;
        field_names = RefHandle.UserDefinableFields;
        for cnt1 = 1:3:length(field_names)
            Parameters.(['Ref_' field_names{cnt1}]) = getfield(RefHandle, field_names{cnt1});
        end
    end
    field_names = fieldnames(Parameters);
    for cnt1 = 1:length(field_names)
        if ischar(Parameters.(field_names{cnt1}))
            Parameters.(field_names{cnt1}) = strrep(Parameters.(field_names{cnt1}),'<','^<');
            Parameters.(field_names{cnt1}) = strrep(Parameters.(field_names{cnt1}),'>','^>');
        end
    end
    % too long a string for varchar(255). Also not really interesting once
    % the data it pre-processed?
    %Parameters.triallog=exptparams.triallog;
    dbWriteData(globalparams.rawid,Parameters,0,0);
end

