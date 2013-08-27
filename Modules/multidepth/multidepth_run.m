% function [exptevents,exptparams]=dms_run(globalparams,exptparams,HW);
%
% run the dms module in baphy. uses standartad parameter syntax:
%  globalparams - defined by BaphyMainGUI
%  exptparams - defined by dms_init
%  HW - created by InitializeHW
%
% currently only supports pure tones. tone parameters specified in
% dms_init, and tones generated in this program before running the task
%
% created SVD 2005-11
% modified SVD 2005-11-25 - added intermittent reward
%
function [exptevents,exptparams]=dms_run(globalparams,exptparams,HW);

% paths should have been set by startup.m
global BAPHYHOME DB_USER

disp([mfilename ': initializing...']);

if globalparams.HWSetup==0
    disp(['NOTE---RUNNING IN TEST MODE']);
end

disp('Setting up reference sound object...');
RO=eval(exptparams.ReferenceObject.descriptor);
ff=fieldnames(exptparams.ReferenceObject);
for ii=1:length(ff),
    RO=set(RO,ff{ii},getfield(exptparams.ReferenceObject,ff{ii}));
end
RO=set(RO,'SamplingRate',exptparams.fs);
exptparams.TrialObject.ReferenceHandle=get(RO);
distobjectindexset=[];
dindex=0;

disp('Setting up target sound object...');
TO=eval(exptparams.TargetObject.descriptor);
ff=fieldnames(exptparams.TargetObject);
for ii=1:length(ff),
    TO=set(TO,ff{ii},getfield(exptparams.TargetObject,ff{ii}));
end
TO=set(TO,'SamplingRate',exptparams.fs);
exptparams.TrialObject.TargetHandle=get(TO);
targidx=get(TO,'MaxIndex');
usingtargetidx=get(TO,'MaxIndex');

% backwards compatibility for tone-trigged lick display stuff...
if get(RO,'MaxIndex')<=29,
    CompressedRefTTL=0;
    tonecount=get(TO,'MaxIndex')+get(RO,'MaxIndex');
    tstring={get(TO,'Names'),get(RO,'Names')};
    tstring={tstring{1}{:},tstring{2}{:}};
else
    CompressedRefTTL=1;
    tonecount=get(TO,'MaxIndex')+1;
    tstring={get(TO,'Names'),{'REF'}};
    tstring={tstring{1}{:},tstring{2}{:}};
end
exptparams.tonecount=tonecount;
exptparams.tstring=tstring;
exptparams.ttlcount=tonecount;
exptparams.targidx0=(1:get(TO,'MaxIndex'));
rampHz=30;

% white noise burst for half of timeout period on incorrect trials
t=(1/exptparams.fs:1/exptparams.fs:exptparams.timeout/2)';
punishsound=exptparams.voltage.*randn(size(t)).*10.^(-exptparams.punishvol./20);
punishsound(punishsound>10)=10;  % make sure it doesn't saturate
punishsound(punishsound<-10)=-10;

% onset/offset ramp
ramp = hanning(round(.01 * exptparams.fs*2));
ramp = ramp(1:floor(length(ramp)/2));
punishsound(1:length(ramp)) = punishsound(1:length(ramp)) .* ramp;
punishsound(end-length(ramp)+1:end) = punishsound(end-length(ramp)+1:end) .* flipud(ramp);

% initialize counters
exptparams.params=globalparams;  % for compatibility with plot routine
exptparams.res=[];       % matrix to record basic performance
exptparams.bstat={};     % record digital input behavior
exptparams.bfs=50;       % dio fs (in the mfile; bigger=bloated mfile)
exptparams.lastreward=0;
exptparams.repcount=-1;
bstep=1./exptparams.bfs;
exptevents=[];
evcount=0;
ttlsec=1.0;
tonetriglick=zeros(exptparams.bfs*ttlsec,tonecount,get(TO,'MaxIndex'));
ttlcount=zeros(exptparams.bfs*ttlsec,tonecount,get(TO,'MaxIndex'));
exptparams.volreward=0;

tic;
count=0;
type=[];
prestat=[];

% prepare random response times for passive ("simu-lick") experiments
switch exptparams.simulate_touch,
    case 'No',
        exptparams.simulick=0;
    case 'Yes',
        exptparams.simulick=1;
    case 'Yes-Always correct',
        exptparams.simulick=2;
    otherwise
        exptparams.simulick=0;
end
if exptparams.simulick,
    rand('state',0);
    exptparams.simulick_outcomes = ...
        exptparams.nolick+exptparams.startwin+exptparams.respwin./2+...
        exptparams.nolickstd+randn(1000,1).*(exptparams.respwin/2);
end

% make sure all hardware is initialized and in correct starting state
SAVEPRESOUND=1;  % toggle save spikes/licks during prestimsilence
HW = IOSetSamplingRate(HW,exptparams.fs);
if SAVEPRESOUND,
    HW = IOSetTrigger(HW, 'Immediate');    % AO started with IOStartSound command
else
    HW = IOSetTrigger(HW, 'HwDigital');    % AI and AO start synchronously with IOStartAcquisition
end
IOControlPump(HW,0);  % turn off the pump
if exptparams.use_light,
    IOLightSwitch(HW,0);  % turn off the light
end

if ismember (globalparams.HWSetup,[1 3 5]),
    % ie, full callibrated system
    % use hardware attenuator to achieve least attenuated level. Remaining
    % attenuation will be performed digitally before output to AO
    if exptparams.dist_atten_final<exptparams.targ_atten,
        hardware_atten=exptparams.dist_atten_final;
    else
        hardware_atten=exptparams.targ_atten;
    end
else
    % no attenuator, just use software
    hardware_atten=0;
end

% doesn't do anything for hwsetup in [0 2 4]
IOSetLoudness(HW,hardware_atten);

% play dummy sound to deal with no-first-play bug. perhaps not necessary?
[ev,HW]=IOStartSound(HW, zeros(10,1));
pause(0.05);

% start up JobMonitor
jh=JobMonitor(globalparams,exptevents);
berror=0;
QuickError=0;

% loop trials indefinitely (until break at end of trial block)
while 1,
    %%% basic structure of a trial:
    % figure out trial stimulus
    % contruct stimulus (ref/tar) vector
    % figure out valid lick period
    % wait for no lick (0.5 sec?)
    % start playing sound
    % at first lick, stop sound
    % if lick at valid time, administer reward
    % if lick at invalid time, play punishment sound and timeout
    % pause for isi
    
    %
    % high level trial control
    %
    
    % increment trial counter
    count=count+1;
    fprintf('\n** trial %d (%d) start **\n',count,exptparams.setcount);
    
    % check if we've entered a new block. if so, figure out new target
    if exptparams.blocksize==0 & ~berror,
        % random targets on each trial
        targidx=ceil(rand*get(TO,'MaxIndex'));
    elseif mod(count,exptparams.blocksize)==1,
        % block is done, cycle to next target in list
        targidx=targidx+1;
        if targidx > get(TO,'MaxIndex'),
            targidx=1;
        end
    end
    
    % figure out if this is a cue trial ...
    % ... either because it's a new block ...
    if mod(count,exptparams.blocksize)==1 | exptparams.blocksize==0,
        disp('new block');
        if exptparams.blocksize==0,
            cuestartidx=1;
        else
            cuestartidx=count;
        end
        cuestouse=exptparams.cuecount;
        td=get(TO);
        if isfield(td,'Duration'),
            temptargetduration=get(TO,'Duration');
            TO=set(TO,'Duration',0.1);
        
            %% cuetone currently set to silence. This is old cuetone, only
            %% used for "reminder" cues after incorrect trials
            cuetone=waveform(TO,targidx);
            TO=set(TO,'Duration',temptargetduration);
        else
            cuetone=waveform(TO,targidx);
        end
        dist_scale=0; %10.^(-exptparams.cue_atten./20);
        cuetone=cuetone.*dist_scale;

    end
    if count>1,
        corrtrialssinceblock=sum(exptparams.res(cuestartidx:end,2)==0);
    else
        corrtrialssinceblock=0;
    end
    
    % ... or because animal has missed previous wrongtrialsforrecue trials
    wrongtrialsforrecue=9;
    if corrtrialssinceblock<cuestouse,
        fprintf('cue trial (%d/%d)... ',corrtrialssinceblock,cuestartidx);
        cuetrial=1;
    elseif size(exptparams.res,1)>wrongtrialsforrecue & ...
            sum(exptparams.res(end-wrongtrialsforrecue+1:end,2)==0)==0 & ...
            exptparams.blocksize>0,
        % ie, zero instances of berror=0 in the last wrongtrialsforrecue trials
        fprintf('missed %d trials in a row. reminder trial\n',wrongtrialsforrecue);
        cuetrial=1;
    else
        cuetrial=0;
    end
    
    %
    % figure out target time
    %
    disp(['target: ' tstring{targidx}]);
    
    % keep licktime same from previous trial if early release
    if count>5,
        last_three_early_count=sum(exptparams.res(end-2:end,2)==1);
    else
        last_three_early_count=0;
    end
    if exptparams.nolickstd>0 & (count==1 | berror~=1 | last_three_early_count==5), 
        nolicktime=0;
        % random time to target (ie, nolicktime) is combination of 
        % 75% uniform, 25% exponential... gives slight bias to shorter trials.
        nolicktime=exptparams.nolick+rand.*exptparams.nolickstd.*(0.75) + ...
            random('exp',exptparams.nolickstd.*(0.25));
        if nolicktime<0.01,
            % require at least 0.01 sec no lick
            nolicktime=0.01;
        end
        if exptparams.simulick,
            if nolicktime>4,
                nolicktime=4;
            end
        elseif nolicktime>5,
            % max length is 5 seconds
            nolicktime=5;
        end
    elseif ~exist('nolicktime','var'),
        nolicktime=0;
        % do nothing
    end
    fprintf('time to target=%.2f sec\n',nolicktime);
    
    %
    % generate the stimulus vector.
    %
    
    % reduce distractor attenuation gradually over the first XX trials.
    % hopefully this number can be small in the long run
    XX=10;
    if corrtrialssinceblock>XX | cuestartidx>1,
        dist_atten=exptparams.dist_atten_final;
    else
        dist_atten=exptparams.dist_atten+(corrtrialssinceblock-1).*...
            (exptparams.dist_atten_final-exptparams.dist_atten)./XX;
    end
    fprintf('Distractor attenuation: %.1f dB\n',dist_atten);
    
    % bonus response window times. if not used, just set to zero
    rwstart1=0;
    rwstop1=0;
    nobonusyet=1;

    % figure out number of refs before target
    td=get(TO);
    if isfield(td,'Duration'),
        targdur=td.Duration;
    else
        ttarg=waveform(TO,1);
        targdur=(length(ttarg)-get(TO,'PreStimSilence')-get(TO,'PostStimSilence'))./...
            td.SamplingRate;
    end
    
    TO_duration=targdur+td.PreStimSilence+td.PostStimSilence;
    if exptparams.targ_rep_count>1,
        TO_duration=repmat(TO_duration,exptparams.targ_rep_count,1);
    end
    posttargettime=max(0,(exptparams.startwin+exptparams.respwin)-sum(TO_duration));
    
    % figure out length of each reference
    RO_silence=get(RO,'PreStimSilence')+get(RO,'PostStimSilence');
    if exptparams.refstd==0 & exptparams.refmean>0,
        fixed_RO_len=1;
        if get(RO,'Duration')~=exptparams.refmean,
            RO=set(RO,'Duration',exptparams.refmean);
        end
        RO_duration=get(RO,'Duration')+RO_silence;
        pretonecount=ceil(nolicktime./RO_duration);
        nolicktime=pretonecount.*RO_duration;
        RO_duration=repmat(RO_duration,pretonecount,1);
        posttonecount=ceil(posttargettime./RO_duration(1));
        posttargettime=posttonecount.*RO_duration(1);
        RO_duration_after=repmat(RO_duration(1),posttonecount,1);

    else
        fixed_RO_len=0;

        RO_durtotal=0;
        RO_duration=[];
        while RO_durtotal<nolicktime,
            nextdur=exptparams.refmean + rand.*exptparams.refstd.*(3./5) + ...
                random('exp',exptparams.refstd.*(2./5));
            if strcmp(get(RO,'descriptor'),'Torc'),
                % make torcs a multiple of 250ms long
                nextdur=round(nextdur.*4)./4;
            end
            RO_duration=[RO_duration; RO_silence+nextdur];
            RO_durtotal=sum(RO_duration);
        end
        RO_duration(end)=RO_duration(end)-RO_durtotal+nolicktime;
        if length(RO_duration)>1 & RO_duration(end)-RO_silence<0.2,
            RO_duration(end-1)=RO_duration(end-1)+RO_duration(end);
            RO_duration=RO_duration(1:(end-1));
        end
        % avoid negative length references
        if RO_duration(1)<RO_silence,
            RO_duration(1)=RO_silence+0.1;
        end

        pretonecount=length(RO_duration);

        RO_durtotal=0;
        RO_duration_after=[];
        if posttargettime>0,
            while RO_durtotal<posttargettime,
                RO_duration_after=[RO_duration_after; RO_silence+exptparams.refmean+...
                    rand.*exptparams.refstd.*(3./5) + random('exp',exptparams.refstd.*(2./5))];
                RO_durtotal=sum(RO_duration_after);
            end
            RO_duration_after(end)=RO_duration_after(end)-RO_durtotal+nolicktime;
            if length(RO_duration_after)>1 & RO_duration_after(end)-RO_silence<0.2,
                RO_duration_after(end-1)=RO_duration_after(end-1)+RO_duration_after(end);
                RO_duration_after=RO_duration_after(1:(end-1));
            end
            if RO_duration_after(end)<RO_silence,
                RO_duration_after=RO_duration_after(1:(end-1));
            end
            posttonecount=length(RO_duration_after);
        end
    end
    all_duration=[RO_duration;TO_duration;RO_duration_after];
    totalstimcount=length(all_duration);

    % set response window
    rwstart=sum(RO_duration) + exptparams.startwin;
    rwstop=sum(RO_duration) + exptparams.startwin + exptparams.respwin;

    % generate stimulus waveform
    thisstim=[];  % stimulus waveform vector
    soundevents=[];  % events associated with stimulus
    targetdonetime=0;
    distindex_thistrial=[];
    for ii=1:totalstimcount,
        % jitter each tone by random db integer amount, uniformly
        % distributed from 0 to (jitter_db-1):
        jitter_int=floor(rand.*exptparams.jitter_db);
        if rand<exptparams.no_atten_frac & ii<=pretonecount,
            % catch...  distractor at hi sound level.  not using
            % this either?  hopefully can use jitter to achieve
            % overlap
            rstr=['REF-' num2str(jitter_int)];
        else
            rstr=['REF-' num2str(dist_atten+jitter_int)];
        end
        
        % subtract off hardware attenuation from ref/targ
        % scaling factors
        dist_scale=10.^(-(dist_atten-hardware_atten+jitter_int)./20);
        targ_scale=10.^(-(exptparams.targ_atten-hardware_atten+jitter_int)./20);
        
        ev=[];
        if (cuetrial & (ii<pretonecount+1 | ii>pretonecount+exptparams.targ_rep_count)) ||...
                (ii>pretonecount+exptparams.targ_rep_count & ~exptparams.ref_after_target)
            % cue trial, add silence during resp window after target
            thisstim=[thisstim;zeros(round(all_duration(ii)*HW.params.fsAO),1)];
            distidx=0;
        else
            if (ii>=pretonecount+1 & ii<=pretonecount+exptparams.targ_rep_count),
                % this is the target
                
                % mark with "R-" prefix if repeated tone
                if ii>pretonecount+1,
                    ee='R';
                else
                    ee='';
                end
                rstr=[ee 'TARG-' num2str(exptparams.targ_atten+jitter_int)];
                
                distidx=0;
                [thistone,ev]=waveform(TO,targidx);
                thistone=thistone.*targ_scale;
                
                if exptparams.overlay_reftar,
                    % overlay a random reference on target
                    if ~fixed_RO_len,
                        RO=set(RO,'Duration',targdur);
                    end
                    [thistone2,ev2]=waveform(RO,ceil(rand*get(RO,'MaxIndex')));
                    thistone(1:length(thistone2))=thistone(1:length(thistone2))+...
                        thistone2.*dist_scale;
                    ev=cat(1,ev(:),ev2(:));
                end

                % actually append the tone to the stimulus vector
                thisstim=[thisstim; thistone];

            else
                % pick a reference. for single distractor runs
                % only pick a new tone for the first tone. and only do
                % that if previous trial was correct
                if (ii==1 & berror~=1) || ~exptparams.single_dist,
                    if length(distobjectindexset)==0,
                        distobjectindexset=1:get(RO,'MaxIndex');
                        exptparams.repcount=exptparams.repcount+1;
                    end
                    
                    tdistobjectindexset=setdiff(distobjectindexset,distindex_thistrial);
                    if isempty(tdistobjectindexset),
                        tdistobjectindexset=1:get(RO,'MaxIndex');
                    end
                    distindex=tdistobjectindexset(ceil(rand.*length(tdistobjectindexset)));
                    fprintf('distractor object index: %d (remaining this rep: %d)\n',...
                        distindex, length(tdistobjectindexset)-1);
                    distindex_thistrial=[distindex_thistrial;distindex];
                end
                
                rstr=['REF-' num2str(dist_atten+jitter_int)];
                
                % generate the reference waveform of appropriate length
                if ~fixed_RO_len,
                    RO=set(RO,'Duration',round((all_duration(ii)-RO_silence).*100)./100);
                end
                [thistone,ev]=waveform(RO,distindex);
                
                if sum(isnan(thistone))>0
                    keyboard
                end
                
                % append the current reference to the stimulus vector
                thisstim=[thisstim; thistone.*dist_scale];
            end
            
            for jj=1:length(ev),
                soundevents=AddEvent(soundevents,[ev(jj).Note, ' , ',rstr],count,...
                    sum(all_duration(1:(ii-1)))+ev(jj).StartTime,...
                    sum(all_duration(1:(ii-1)))+ev(jj).StopTime);
            end

            if (ii==pretonecount+1),
                targetdonetime=soundevents(end).StopTime;
            end
        end
    end
    % finished generating sound waveform
    
    triallen=length(thisstim)./exptparams.fs;
    fprintf('valid response range: %.2f - %.2f sec; totlen=%.2f\n',...
        rwstart,rwstop,triallen);
    
    % show current waveform in job monitor
    JobMonitor('JobMonitor_PlotWaveform',jh,[],[],thisstim,exptparams.fs);
    
    %
    % pre-trial: figure out no lick time required to start
    %
    disp('waiting for no lick');
    if globalparams.HWSetup==0,  % ie, testmode
        disp('need to start lick in zero state');
    end
    
    % set variables for recording behavior and trial state
    berror=[];  % outcome undefined
    trialover=0;
    stopnow=0;
    
    % wait through Isi for nolick
    if QuickError,
        nlt=0;
    elseif cuetrial & nolicktime>0,
        %nolicktime=nolicktime.*0.75;
        nlt=nolicktime;
    else
        % 50% random nolick time to prevent cheating with timing cues
        nlt=exptparams.nolicksilence.*0.5 + ...
            random('exp',exptparams.nolicksilence.*0.5);
    end
    
    %
    % TRIAL STARTS HERE
    %
    
    if SAVEPRESOUND,
        % allow for longer AI to include prestimsilence wait period, which
        % can be up to 10 seconds
        aidur=10+length(thisstim)./exptparams.fs;
        IOSetAnalogInDuration(HW, aidur);
        HW=IOLoadSound(HW,thisstim);
        
        % start AI/spike acquisition here
        exptevents=AddEvent(exptevents,IOStartAcquisition(HW),count);
    else
        % load sound, but don't start any acquisition
        aidur=2+length(thisstim)./exptparams.fs;
        IOSetAnalogInDuration(HW, aidur);
        HW=IOLoadSound(HW,thisstim);
    end
    
    % (no lick) for isi before trial starts
    QuickError=0;  % reset, since already used this information to skip silent wait period
    touch=1;
    tic;
    lasttouch=toc;
    tstart=lasttouch;
    
    if nlt>0,
       % silence during no-lick
       fprintf('silent hold time=%.2f\n',nlt);
       first_hold=1;
       
       % loop til touch goes to zero for nlt seconds
       while touch & ~trialover,
            currenttime=toc;
            
            % require bar down AND no licks for time nlt:
            if exptparams.use_lick & IOLickRead(HW) & ~(exptparams.simulick==1),
                lasttouch=currenttime;
            elseif ~exptparams.use_lick & IOPawRead(HW) & ~(exptparams.simulick==1), % | IOLickRead(HW),
                lasttouch=currenttime;
            end
            
            touch=(currenttime-lasttouch<nlt);
            
            drawnow;
            stopnow=get(jh,'UserData');
            
            if stopnow,
                % user cancelled
                disp('* cancel');
                berror=3;
                terror=toc;
                trialover=1;
            end
            
            if currenttime-tstart>9.5,
                % impatience error
                disp(' * TIMEOUT');
                berror=3;
                terror=9.5;
                trialover=1;
            end

            if first_hold & currenttime-lasttouch>0.05,
                % play cue sound on each trial???
                %[ev,HW]=IOStartSound(HW, cuetone);
                first_hold=0;
            end
        end
    end
    
    %
    % start AI and recording
    %
    
    if SAVEPRESOUND,
        % start AO here
        exptevents=AddEvent(exptevents,IOStartSound(HW),count);
        tstart=exptevents(end).StartTime;
    else
        % start AI/spike acquisition here
        exptevents=AddEvent(exptevents,IOStartAcquisition(HW),count);
        tstart=0;
    end
    
    % time in trial when AO start event occurs now this is always the same
    % as when AI starts, ie, 0
    prewardstarted=0;
    timesincestart=0;
    
    if ~trialover,
        fprintf('playing sound (tstart=%.2f)...\n',tstart);
        
        if ~exptparams.use_lick & exptparams.startrwdur>0,
            % reward for pressing bar -- early training.
            if exptparams.use_light,
                IOLightSwitch(HW,1,exptparams.startrwdur);
            end
            IOControlPump(HW,'Start',exptparams.startrwdur);
            prewardstarted=1;
        end
        
        while timesincestart<triallen & ~trialover,
            
            if exptparams.use_lick & exptparams.startrwdur>0 & ...
                    (timesincestart>rwstart+(rwstop-rwstart)./2 & ...
                    timesincestart<=rwstop) & ...
                    ~prewardstarted,
                % reward for waiting long enough before licking -- early training.
                IOControlPump(HW,'Start',exptparams.startrwdur);
                prewardstarted=1;
            end
            
            if exptparams.simulick,
                if exptparams.simulick==2 & timesincestart>rwstart,
                    % ie, always correct
                    touch=1;
                elseif exptparams.simulick==1 & ...
                        timesincestart>exptparams.simulick_outcomes(count),
                    % ie, sometimes correct, randomly
                    touch=1;
                else
                    touch=0;
                end
            elseif exptparams.use_lick,
                touch=IOLickRead(HW);
            else
                touch=IOPawRead(HW);
            end
            
            if touch,
                touchtime=IOGetTimeStamp(HW);
            end
            
            if touch && touchtime-tstart<=rwstart && strcmpi(globalparams.Ferret,'bom') ...
                    && ~strcmpi(globalparams.Physiology,'No'),
                % early lick, skip for bom during physiology
                touch=0;
            end
            
            if touch,
                
                trialover=1;
                % trial is over, but don't stop sound yet; may want to let
                % it run for a bit longer
                
                if prewardstarted,
                    % reward for pressing bar -- early training.
                    disp('turning off pre-ward');
                    if exptparams.use_light,
                        IOLightSwitch(HW,0);
                    end
                    IOControlPump(HW,'Stop');
                end
                
                if (touchtime-tstart>rwstart & touchtime-tstart<=rwstop) | ...
                   (touchtime-tstart>rwstart1 & touchtime-tstart<=rwstop1),
                    berror=0;
                    disp(' * HIT!');
                    
                    % jitter reward time to decorrelate from response time
                    if exptparams.rwjitter>0,
                        rwdelay=rand.*exptparams.rwjitter;
                        fprintf('(pausing %.2f sec)\n',rwdelay);
                        pause(rwdelay);
                    end
                    
                    exptevents=AddEvent(exptevents,'OUTCOME,MATCH',count,IOGetTimeStamp(HW));
                    
                    % turn on light
                    if exptparams.use_light,
                        IOLightSwitch(HW,1);
                    end
                    
                    % decide if actually giving a reward based on rwfrac
                    if cuetrial, 
                        rlen=exptparams.rwdur/2;
                    else
                        rlen=exptparams.rwdur;
                    end
                    if rand<=exptparams.rwfrac,
                        % turn on the pump for exptparams.rwdur sec
                        IOControlPump(HW,'Start',rlen);
                        exptparams.volreward=exptparams.volreward+exptparams.volpersec*rlen;
                    end
                    
                    % play target tone(s) out to end if it hasn't finished
                    % yet... to help reinforce?
                    while IOGetTimeStamp(HW)-touchtime<rlen,
                        pause(0.01);
                        if IOIsPlaying(HW) && ...
                                IOGetTimeStamp(HW)-tstart>targetdonetime,
                            IOStopSound(HW);
                        end
                    end
                    
                    % turn off light
                    if exptparams.use_light,
                        IOLightSwitch(HW,0);
                    end
                    IOStopSound(HW);
                   
                elseif touchtime-tstart<=rwstart,
                    % special case: very early lick, don't timeout. instead
                    % end trial and start next trial ASAP
                    if touchtime-tstart<0.5 & touchtime-tstart<RO_duration(1)-get(RO,'PostStimSilence'),
                        QuickError=1;
                        disp(' * QUICK FALSE ALARM');
                    else
                        disp(' * FALSE ALARM');
                    end
                    terror=touchtime;
                    berror=1;
                    
                else % touchtime>rwstop
                    terror=touchtime;
                end
            end
            
            timesincestart=IOGetTimeStamp(HW)-tstart;
        end
    end
    
    % log sound exptevents that actually played
    for ii=1:length(soundevents),
        if soundevents(ii).StartTime<timesincestart,
            exptevents=AddEvent(exptevents,soundevents(ii).Note,count,...
                soundevents(ii).StartTime+tstart,soundevents(ii).StopTime+tstart);
        end
    end
    
    if isempty(berror),
        % if never licked, play punishment sound and timeout
        berror=2;
        terror=IOGetTimeStamp(HW);
        fprintf('trial over(triallen=%.2f timesincestart=%.2f)...\n',triallen,timesincestart);
        disp(' * MISS');
    end
    
    while IOIsPlaying(HW),
        %if exptparams.distobject | IOGetTimeStamp(HW) > exptevents(end).StopTime,
        if ~QuickError | IOGetTimeStamp(HW)>RO_duration(1)-get(RO,'PostStimSilence'),
            IOStopSound(HW);
            disp('stopped now');
        end
        pause(0.01);
    end
    
    if berror,
        if ~stopnow & ~QuickError,
            if berror~=2 | exptparams.jitter_db<30,
                [tev,HW]=IOStartSound(HW,[punishsound;cuetone;cuetone]);
                fprintf('timeout: %.1f sec\n',exptparams.timeout);
            end
            
            pause(exptparams.timeout);
        end
        
        if berror==3,
            exptevents=AddEvent(exptevents,'OUTCOME,IMP',count,terror);
        elseif berror==2,
            exptevents=AddEvent(exptevents,'OUTCOME,MISS',count,terror);
        elseif QuickError,
            exptevents=AddEvent(exptevents,'OUTCOME,VEARLY',count,terror);
        else
            exptevents=AddEvent(exptevents,'OUTCOME,EARLY',count,terror);
        end
    else
        fprintf('ITI=%.2f\n',exptparams.isi);
        pause(exptparams.isi);
        
        % mark distractor as having played on a correct trial
        distobjectindexset=setdiff(distobjectindexset,distindex_thistrial);
    end
    
    exptevents=AddEvent(exptevents,IOStopAcquisition(HW),count);
    
    % read real licks, if running real licks or simulick always correct
    if ~(exptparams.simulick==1),
        [AuxData,SpikeData,names]=IOReadAIData(HW);
        LickChannel     = find(strcmpi(names,'touch'));
        LickData        = AuxData(:,LickChannel);
        PawChannel     =  find(strcmpi(names,'paw'));
        if size(AuxData,2)>=PawChannel,
            PawData        = AuxData(:,PawChannel);
        else
            PawData=[];
        end
    else
        AIsamples=round(exptevents(end).StartTime.*HW.params.fsAI);
        LickData=zeros(AIsamples,1);
        LickData(round(exptparams.simulick_outcomes(count).*HW.params.fsAI)+(0:200))=1;
        PawData=zeros(AIsamples,1);
        PawData(round(exptparams.simulick_outcomes(count).*HW.params.fsAI)+(0:200))=1;
    end
    if isfield(globalparams,'rawid') & globalparams.rawid>0
        evpwrite(globalparams.tempevpfile,[],[LickData(:) PawData(:)],HW.params.fsAI,...
            HW.params.fsAI);
    end
    
    % save lick data at coarser sampling rate
    if length(LickData)>0,
        bstat=round(resample([LickData(:) PawData(:)],exptparams.bfs,HW.params.fsAI));
    else
        warning('lickdata is missing!!!');
        bstat=zeros(1000,2);
    end
    
    if 1 | ~stopnow,
        tlick=(0:(length(bstat)-1))./exptparams.bfs;
        if exptparams.use_lick
            lick=[bstat(:,1); nan*zeros(exptparams.bfs*ttlsec+100,1)];
        else
            lick=[bstat(:,2); nan*zeros(exptparams.bfs*ttlsec+100,1)];
        end
        tt0=evtimes(exptevents,'TRIALSTART',count);
        if berror==0,
            % trim licks after correct response to avoid bias?
            ttcorrect=evtimes(exptevents,'OUTCOME,MATCH',count);
            %[size(lick) size(tlick)]
            if exptparams.simulick~=2,
                cutoffidx=min(find(tlick>ttcorrect-tt0+.2));  % keep 200 ms after lick
                if ~isempty(cutoffidx),
                    lick(cutoffidx:end)=nan;
                end
            end
        end
        
        for ii=1:tonecount,
            if CompressedRefTTL & ii==tonecount,
                [tt,ttt,nn]=evtimes(exptevents,['STIM , *'],count);
                bkeep=zeros(size(tt));
                for jj=1:length(tt),
                    if findstr(nn{jj},', REF'),
                        bkeep(jj)=1;
                    end
                end
                tt=tt(find(bkeep));
                ttt=ttt(find(bkeep));
                nn=nn(find(bkeep));
            else
                [tt,ttt,nn]=evtimes(exptevents,['STIM , ',tstring{ii},' *'],count);
            end
            tt=tt-tt0;
            %fprintf('%s: %d',tstring{ii},length(tt));
            for jj=1:length(tt),
                if ~cuetrial & isempty(strfind(nn{jj},'RTARG')),
                    sbin=min(find(tlick>tt(jj)));
                    if isempty(sbin),
                        %[ii max(tlick) tt(jj)]
                    else
                        minnan=min([(find(isnan(lick(sbin:sbin+exptparams.bfs*ttlsec-1)))-1)' exptparams.bfs*ttlsec]);
                        tonetriglick(1:minnan,ii,targidx)=tonetriglick(1:minnan,ii,targidx)+ ...
                            lick(sbin:sbin+minnan-1);
                        ttlcount(1:minnan,ii,targidx)=ttlcount(1:minnan,ii,targidx)+1;
                    end
                end
            end
        end
        exptparams.tonetriglick=tonetriglick;
        exptparams.ttlcount=ttlcount;
        
        % accumulate behavioral data and stats
        exptparams.res=[exptparams.res; nolicktime berror rwstart rwstop targidx];
        exptparams.tt{count}=(1:length(bstat))'./exptparams.bfs;
        exptparams.bstat{count}=bstat;
        ccount=sum(exptparams.res(:,2)==0);
        
        exptparams.results_command=['dms_plot_ext ',globalparams.mfilename];
        % plot some results
        dms_plot(exptparams,exptevents);
        drawnow
        
    elseif berror==3
        count=count-1;
    end
    
    % text results
    if count>1,
        fprintf('Performance: correct,early,miss,olick / total: %d,%d,%d,%d / %d\n',...
            hist(exptparams.res(:,2),0:3),length(exptparams.res));
        fprintf('** End trial %d **\n\n', count);
    end
    % make sure sound really stopped
    IOStopSound(HW);

    % stop if animal is on a bad streak
    streaklen=200;
    if count>=streaklen & sum(exptparams.res(end-streaklen+1:end,2)==0)==0,
        fprintf('missed last %d trials. stopping.\n',streaklen);
        stopnow=1;
    end
    
    if ~stopnow,
        stopnow=get(jh,'UserData');
    end
    
    JobMonitor('JobMonitor_Refresh',jh,[],[],globalparams,exptevents);
    
    if (stopnow | mod(count,10)==0) & isfield(globalparams,'rawid') & globalparams.rawid>0,
        % save results to db every 10 trials to make sure it gets saved in
        % event of crash.
        sql=['UPDATE gDataRaw SET',...
            ' corrtrials=',num2str(ccount),',',...
            ' trials=',num2str(count),...
            ' WHERE id=',num2str(globalparams.rawid)];
        mysql(sql);
        
        % update water record
        % if gHealth.id not known, figure it out.
        %if ~exist('hdata','var') | length(hdata)==0 | isempty(hdata.id),
            sql=['SELECT gAnimal.id as animal_id,gHealth.id,gHealth.water'...
                 ' FROM gAnimal LEFT JOIN gHealth ON gHealth.animal_id=gAnimal.id'...
                 ' AND date="',datestr(now,29),'"'...
                 ' WHERE gAnimal.animal like "',globalparams.Ferret,'"'];
            hdata=mysql(sql);
        %end
        if length(hdata)>0 & ~isempty(hdata.id),
            swater=sprintf('%.2f',hdata.water+exptparams.volreward-...
                exptparams.lastreward);
            
            sql=['UPDATE gHealth set trained=1,water=',swater,' WHERE id=',num2str(hdata.id)];
            mysql(sql);
        else
            sql=['INSERT INTO gHealth (animal_id,animal,date,water,trained,addedby,info) VALUES'...
                '(',num2str(hdata.animal_id),',"',globalparams.Ferret,'",',...
                '"',datestr(now,29),'",'...
                num2str(exptparams.volreward),',1,"',DB_USER,'","dms_run.m")'];
            mysql(sql);
        end
        exptparams.lastreward=exptparams.volreward;
        
        % save mfile to avoid crash problems and to allow on-line STRFs
        if (stopnow | mod(count,20)==0),
            fprintf('Saving intermediate m-file: %s...\n',globalparams.mfilename);
            WriteMFile(globalparams,exptparams,exptevents,1);
        end
    end
    
    if stopnow | mod(count,exptparams.N)==0,
        disp('---------------------------------------------------------');
        fprintf('%d / %d trials correct.\n',ccount,count);
        fprintf('Total reward: %d (corr) x %0.2f (sec/corr) x %.2f (ml/sec) x %.1f rwfrac = %.2f ml\n',...
            ccount,exptparams.rwdur,exptparams.volpersec,exptparams.rwfrac,exptparams.volreward);
        fprintf('Total reward today: %.2f\n',exptparams.totalreward+exptparams.volreward);
        yn=questdlg('Continue running DMS?','DMS','Yes','No','Yes');
        if strcmp(yn,'No'),
            break
        end
    end
end

% clear bstat to save mfile write time
exptparams.bstat={};

if exist('jh','var') & ~isempty(jh),
    close(jh);
end

if isfield(globalparams,'rawid') & globalparams.rawid>0,
    disp('saving performance/parameter data to cellDB...');
    
    % code morphed from Nima's PrepareDatabaseData
    Parameters  = [];
    Performance = [];
    RefHandle = exptparams.TrialObject.ReferenceHandle;
    if ~isempty(RefHandle)
        Parameters.Reference = '______________';
        Parameters.ReferenceClass = RefHandle.descriptor;
        field_names = RefHandle.UserDefinableFields;
        for cnt1 = 1:3:length(field_names)
            Parameters.(['Ref_' field_names{cnt1}]) = getfield(RefHandle, field_names{cnt1});
        end
    end
    TarHandle = exptparams.TrialObject.TargetHandle;
    if ~isempty(TarHandle)
        Parameters.Target = '______________';
        Parameters.TargetClass = TarHandle.descriptor;
        field_names = TarHandle.UserDefinableFields;
        for cnt1 = 1:3:length(field_names)
            Parameters.(['Tar_' field_names{cnt1}]) = getfield(TarHandle, field_names{cnt1});
        end
    end
    field_names = fieldnames(Parameters);
    for cnt1 = 1:length(field_names)
        if ischar(Parameters.(field_names{cnt1}))
            Parameters.(field_names{cnt1}) = strrep(Parameters.(field_names{cnt1}),'<','^<');
            Parameters.(field_names{cnt1}) = strrep(Parameters.(field_names{cnt1}),'>','^>');
        end
    end
    
    Parameters.NoLickSilence=exptparams.nolicksilence;
    Parameters.Ref_Len_Mean=exptparams.refmean;
    Parameters.Ref_Len_Std=exptparams.refstd;
    Parameters.Trial_Len_Mean=exptparams.nolick;
    Parameters.Trial_Len_Std=exptparams.nolickstd;
    Parameters.Ref_Atten_Start=exptparams.dist_atten;
    Parameters.Ref_Atten_Final=exptparams.dist_atten_final;
    Parameters.Repeat_Single_Ref=exptparams.single_dist;
    Parameters.Ref_After_Tar=exptparams.ref_after_target;
    Parameters.Tar_Rep_Count=exptparams.targ_rep_count;
    Parameters.Block_Size=exptparams.blocksize;
    Parameters.RespWin_Start=exptparams.startwin;
    Parameters.RespWin_Len=exptparams.respwin;
    Parameters.PREward_Duration=exptparams.startrwdur;
    Parameters.Reward_Duration=exptparams.rwdur;
    Parameters.Punish_Atten=exptparams.punishvol;
    Parameters.Punish_Timeout=exptparams.timeout;
    Parameters.ITI=exptparams.isi;
    Parameters.Cue_Trial_Count=exptparams.cuecount;
    Parameters.Use_Lick=exptparams.use_lick;
    Parameters.Use_Light=exptparams.use_light;
    Parameters.Avg_Trial_Len=mean(exptparams.res(:,1));
    Parameters.HWSetup=globalparams.HWSetup;
    Parameters.Tar_Atten=exptparams.targ_atten;
    Parameters.Overlay_Ref_Tar=exptparams.overlay_reftar;
    Parameters.Use_Catch=exptparams.use_catch;
    
    Parameters.jitter_db=exptparams.jitter_db;
    Parameters.rwfrac=exptparams.rwfrac;
    Parameters.tonecount=exptparams.tonecount;
    %Parameters.targidx0=exptparams.targidx0;
    % nolickstd/2 for uniform distribution
    % nolickstd for gamma
    %Parameters.freqs=exptparams.freqs;
    %Parameters.freqe=exptparams.freqe;
    %Parameters.toneamp=exptparams.toneamp;
    %Parameters.modfreq=exptparams.modfreq;
    dbWriteData(globalparams.rawid,Parameters,0,0);
    
    tperf=[];
    tperf.Ref_Rep_Count=exptparams.repcount;
    tperf.Ref_Valid_Time=sum(exptparams.res((exptparams.res(:,2)==0),1));
    tperf.trials=count;
    ccount=sum(exptparams.res(:,2)==0);
    tperf.hit=ccount;
    tperf.early=sum(exptparams.res(:,2)==1);
    tperf.miss=sum(exptparams.res(:,2)==2);
    tperf.snooze=sum(exptparams.res(:,2)==3);
    tperf.water=exptparams.volreward;
    dbWriteData(globalparams.rawid,tperf,1,0);

end

% function next_idx=pick_next_distractor(distractor_count);
%
% pseudo-random distractor picker that forces relatively even sampling
% across all distractors (max different number of samples=2)
%
function next_idx=pick_next_distractor(distractor_count,picksetcount);

global idx_set

if ~exist('picksetcount','var'),
    picksetcount=2;
end

if length(idx_set)<=distractor_count.*(picksetcount-1),
    idx_set=[idx_set shuffle(1:distractor_count)];
end

next_idx=idx_set(1);
idx_set=idx_set(2:end);

