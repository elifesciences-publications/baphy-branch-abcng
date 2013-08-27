% function [exptevents,exptparams]=dms_run(globalparams,exptparams,HW);
%
% run the dms module in baphy. uses standartad parameter syntax:
%  globalparams - defined by BaphyMainGUI
%  exptparams - defined by dms_init
%  HW - created by InitializeHW
%
% created SVD 2005-11
% modified SVD 2005-11-25 - added intermittent reward
%
function [exptevents,exptparams]=dnms_run(globalparams,exptparams,HW)

% paths should have been set by startup.m
global BAPHYHOME DB_USER

disp([mfilename ': initializing...']);

if globalparams.HWSetup==0
    disp('NOTE---RUNNING IN TEST MODE');
end

% prepare random response times for passive ("simu-lick") experiments
switch exptparams.Alternate_RefTar,
    case 'None',
        exptparams.alterreftar=0;
    case 'Ch1',
        exptparams.alterreftar=1;
    case 'Ch2',
        exptparams.simulick=2;
    case 'Both',
        exptparams.simulick=3;
end

disp('Setting up reference sound objects...');
RO1=eval(exptparams.ReferenceObject1.descriptor);
ff=fieldnames(exptparams.ReferenceObject1);
for ii=1:length(ff),
    RO1=set(RO1,ff{ii},getfield(exptparams.ReferenceObject1,ff{ii}));
end
RO1=set(RO1,'SamplingRate',exptparams.fs);
%?
exptparams.TrialObject.ReferenceHandle1=get(RO1);
distobjectindexset1=[];
dindex1=0;

RO2=eval(exptparams.ReferenceObject2.descriptor);
ff=fieldnames(exptparams.ReferenceObject2);
for ii=1:length(ff),
    RO2=set(RO2,ff{ii},getfield(exptparams.ReferenceObject2,ff{ii}));
end
RO2=set(RO2,'SamplingRate',exptparams.fs);
%?
exptparams.TrialObject.ReferenceHandle2=get(RO2);
distobjectindexset2=[];
dindex2=0;

disp('Setting up target sound object...');
TO1=eval(exptparams.TargetObject1.descriptor);
ff=fieldnames(exptparams.TargetObject1);
for ii=1:length(ff),
    TO1=set(TO1,ff{ii},getfield(exptparams.TargetObject1,ff{ii}));
end
TO1=set(TO1,'SamplingRate',exptparams.fs);
exptparams.TrialObject.TargetHandle1=get(TO1);
targidx1=get(TO1,'MaxIndex');
usingtargetidx1=get(TO1,'MaxIndex');

%? backwards compatibility for tone-trigged lick display stuff...
if get(RO1,'MaxIndex')<=29,
    CompressedRefTTL1=0;
    tonecount1=get(TO1,'MaxIndex')+get(RO1,'MaxIndex');
    tstring1={get(TO1,'Names'),get(RO1,'Names')};
    tstring1={tstring1{1}{:},tstring1{2}{:}};
else
    CompressedRefTTL1=1;
    tonecoun1t=get(TO,'MaxIndex')+1;
    tstring1={get(TO,'Names'),{'REF'}};
    tstring1={tstring1{1}{:},tstring1{2}{:}};
end

if get(RO2,'MaxIndex')<=29,
    CompressedRefTTL2=0;
    tonecount2=get(TO2,'MaxIndex')+get(RO2,'MaxIndex');
    tstring2={get(TO2,'Names'),get(RO2,'Names')};
    tstring2={tstring2{1}{:},tstring2{2}{:}};
else
    CompressedRefTTL2=1;
    tonecount2=get(TO2,'MaxIndex')+1;
    tstring2={get(TO2,'Names'),{'REF'}};
    tstring2={tstring2{1}{:},tstring2{2}{:}};
end

exptparams.tonecount1=tonecount1;
exptparams.tonecount2=tonecount2;
exptparams.tstring1=tstring1;
exptparams.tstring2=tstring2;
exptparams.ttlcount1=tonecount1;
exptparams.ttlcount2=tonecount2;
exptparams.targidx01=(1:get(TO1,'MaxIndex'));
exptparams.targidx02=(1:get(TO2,'MaxIndex'));
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

% outcome of previous trial
% 0 - correct
% 1 - false alarm
% 2 - miss
% 3 - timeout (too much licking before trial)
berror=0;

QuickError=0;
LastQuickError=0;

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
    if any(globalparams.HWSetup==[7,8])
      HW.Filename = M_setRawFileName(globalparams.mfilename,count);
    end
    
    % check if we've entered a new block. if so, figure out new target sound and
    % target channel indices
    if exptparams.blocksize==0 && (~berror || (berror==2 && exptparams.cycle_miss)),
        % random target on each correct trial (and miss if cycle_miss==1)
        targidx(1)=ceil(rand*get(TO1,'MaxIndex'));
        targidx(2)=ceil(rand*get(TO2,'MaxIndex'));
        targchidx = (rand>.5)+1;
    elseif mod(count,exptparams.blocksize)==1,
        % block is done, cycle to next target in list
        targidx(1)=targidx(1)+1;
        if targidx(1) > get(TO1,'MaxIndex'),
            targidx(1)=1;
        end
        targidx(2)=targidx(2)+1;
        if targidx(2) > get(TO2,'MaxIndex'),
            targidx(2)=1;
        end       
    end
    if exptparams.blocksize==0,
        startidx=1;
    elseif mod(count,exptparams.blocksize)==1
        startidx=count;
    end
    if count>1,
        corrtrialssinceblock=sum(exptparams.res(startidx:end,2)==0);
    else
        corrtrialssinceblock=0;
    end
    % figure out target time
    %
    disp(['ch1 target: ' tstring1{targidx(1)}]);
    disp(['ch2 target: ' tstring2{targidx(2)}]);
    % keep licktime same from previous trial if early release

    if count==1 || berror~=1
        pretonecount(1) = (rand>.5)+1;
        pretonecount(2) = (rand>.5)+1;
    else
        % prev trial was false alarm, nolicktime kept at same value
    end
    fprintf('time to target=%.2f sec\n',nolicktime);
    
    %
    % generate the stimulus vector.
    %
    
    % reduce distractor attenuation gradually over the first XX trials.
    % hopefully this number can be small in the long run
    XX=10;
    dist_atten=exptparams.dist_atten+(corrtrialssinceblock-1).*...
        (exptparams.dist_atten_final-exptparams.dist_atten)./XX;
    fprintf('Distractor attenuation: %.1f dB\n',dist_atten);
    
    % bonus response window times. if not used, just set to zero
    rwstart1=0;
    rwstop1=0;
    nobonusyet=1;

    % figure out number of refs before target
    td=get(TO1);
    if isfield(td,'Duration'),
        targdur(1)=td.Duration;
    else
        ttarg=waveform(TO1,1);
        %?
        targdur(1)=(length(ttarg)-get(TO1,'PreStimSilence')-get(TO1,'PostStimSilence'))./...
            td.SamplingRate;
    end
    
    TO_duration1=targdur1+td.PreStimSilence+td.PostStimSilence;
    if exptparams.targ_rep_count>1,
        TO_duration1=repmat(TO_duration1,exptparams.targ_rep_count,1);
    end
    posttargettime(1)=max(0,(exptparams.startwin+exptparams.respwin)-sum(TO_duration1));
    
    td=get(TO2);
    if isfield(td,'Duration'),
        targdur(2)=td.Duration;
    else
        ttarg=waveform(TO2,1);
        %?
        targdur(2)=(length(ttarg)-get(TO2,'PreStimSilence')-get(TO2,'PostStimSilence'))./...
            td.SamplingRate;
    end
    
    TO_duration2=targdur2+td.PreStimSilence+td.PostStimSilence;
    if exptparams.targ_rep_count>1,
        TO_duration2=repmat(TO_duration2,exptparams.targ_rep_count,1);
    end
    posttargettime(2)=max(0,(exptparams.startwin+exptparams.respwin)-sum(TO_duration2));
    
    % figure out length of each reference
    RO_silence(1)=get(RO1,'PreStimSilence')+get(RO1,'PostStimSilence');
    RO_silence(2)=get(RO2,'PreStimSilence')+get(RO2,'PostStimSilence');
    if exptparams.refstd==0 && exptparams.refmean>0,
        fixed_RO_len=1;
        if get(RO1,'Duration')~=exptparams.refmean,
            RO=set(RO1,'Duration',exptparams.refmean);
        end
        RO_duration1=get(RO1,'Duration')+RO_silence1;
        nolicktime(1)=pretonecount(1).*RO_duration1;
        RO_duration1=repmat(RO_duration1,pretonecount(1),1);
        posttonecount(1)=ceil(posttargettime(1)./RO_duration1(1));
        posttargettime(1)=posttonecount1.*RO_duration1(1);
        RO_duration_after1=repmat(RO_duration1(1),posttonecount(1),1);
        
        if get(RO2,'Duration')~=exptparams.refmean,
            RO=set(RO2,'Duration',exptparams.refmean);
        end
        RO_duration2=get(RO2,'Duration')+RO_silence(2);
        nolicktime(2)=pretonecount(2).*RO_duration2;
        RO_duration2=repmat(RO_duration2,pretonecount(2),1);
        posttonecount(2)=ceil(posttargettime(2)./RO_duration2(1));
        posttargettime(2)=posttonecount(2).*RO_duration2(1);
        RO_duration_after2=repmat(RO_duration2(1),posttonecount(2),1);   
        
        nolicktime = nolicktime(targchidx);       
    end
    all_duration1=[RO_duration1;TO_duration1;RO_duration_after1];
    totalstimcount(1)=length(all_duration1);

    all_duration2=[RO_duration2;TO_duration2;RO_duration_after2];
    totalstimcount(2)=length(all_duration2);
    
    [xzwy,shorteridx] = min(totalstimcount);
    posttonecount(shorteridx) = max(totalstimcount)-(pretonecount(shorteridx)+targ_rep_count);
    if shorteridx~=targchidx
        if shorteridx==1; RO_duration_after1 = repmat(RO_duration_after1(1),posttonecount(1),1);
        else RO_duration_after2 = repmat(RO_duration_after2(1),posttonecount(2),1);
        end
    end
    totalstimcount = totalstimcount(targchidx);
  
    % set response windows
    rwstart(1)=sum(RO_duration1) + exptparams.startwin;
    rwstop(1)=sum(RO_duration1) + exptparams.startwin + exptparams.respwin;
    rwstart(2)=sum(RO_duration2) + exptparams.startwin;
    rwstop(2)=sum(RO_duration2) + exptparams.startwin + exptparams.respwin;
    rwstart = rwstart(targchidx);
    rwstop = rwstop(targchidx);
   

    % generate stimulus waveform
    thisstim=[];  % stimulus waveform vector
    soundevents1=[];  % events associated with stimulus in channel 1
    soundevents2=[];  % events associated with stimulus in channel 2
    targetdonetime=0;
    distindex_thistrial1=[];
    distindex_thistrial2=[];
    
    for ii=1:totalstimcount,
        % jitter each tone by random db integer amount, uniformly
        % distributed from 0 to (jitter_db-1):
        jitter_int=floor(rand.*exptparams.jitter_db);
        if rand<exptparams.no_atten_frac && ii<=pretonecount(1),
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
        if (ii>pretonecount(1)+exptparams.targ_rep_count && ~exptparams.ref_after_target)
            thistone(1,:) = zeros(round(all_duration1(ii)*HW.params.fsAO),1);
            distidx=0;
        else
            if (ii>=pretonecount(1)+1 && ii<=pretonecount(1)+exptparams.targ_rep_count),
                % this is the target
                
                % mark with "R-" prefix if repeated tone
                if ii>pretonecount(1)+1,
                    ee='R';
                else
                    ee='';
                end
                rstr=[ee 'TARG-' num2str(exptparams.targ_atten+jitter_int)];
                
                distidx=0;
                [thistone(:,1),ev]=waveform(TO1,targidx(1));
                thistone(:,1)=thistone(:,1).*targ_scale;
            else
                % pick a reference. for single distractor runs
                % only pick a new tone for the first tone. and only do
                % that if previous trial was correct
                if (ii==1 && berror~=1) || ~exptparams.single_dist,
                    if isempty(distobjectindexset1),
                        distobjectindexset1=1:get(RO1,'MaxIndex');
                        exptparams.repcount=exptparams.repcount+1;
                    end
                    
                    tdistobjectindexset=setdiff(distobjectindexset1,distindex_thistrial1);
                    if isempty(tdistobjectindexset),
                        tdistobjectindexset=1:get(RO1,'MaxIndex');
                    end
                    distindex=tdistobjectindexset(ceil(rand.*length(tdistobjectindexset)));
                    fprintf('ch 1 distractor object index: %d (remaining this rep: %d)\n',...
                        distindex, length(tdistobjectindexset)-1);
                    distindex_thistrial1=[distindex_thistrial1;distindex];
                end
                
                rstr=['REF-' num2str(dist_atten+jitter_int)];
                
                % generate the reference waveform of appropriate length
                if ~fixed_RO_len,
                    RO1=set(RO1,'Duration',round((all_duration1(ii)-RO_silence(1)).*100)./100);
                end
                [thistone,ev]=waveform(RO1,distindex);
                if sum(isnan(thistone))>0
                    keyboard
                end
                
                % adjust sound level
                thistone(:,1)=thistone(:,1).*dist_scale;               
            end
            
            for jj=1:length(ev),
                soundevents1=AddEvent(soundevents1,[ev(jj).Note, ' , ',rstr],count,...
                    sum(all_duration1(1:(ii-1)))+ev(jj).StartTime,...
                    sum(all_duration1(1:(ii-1)))+ev(jj).StopTime);
            end

            if (ii==pretonecount(1)+1),
                targetdonetime(1)=soundevents1(end).StopTime;
            end
        end
        ev=[];
        if (ii>pretonecount(2)+exptparams.targ_rep_count && ~exptparams.ref_after_target)
            thistone(2,:) = zeros(round(all_duration2(ii)*HW.params.fsAO),1);
            distidx=0;
        else
            if (ii>=pretonecount(2)+1 && ii<=pretonecount(2)+exptparams.targ_rep_count),
                % this is the target
                
                % mark with "R-" prefix if repeated tone
                if ii>pretonecount(2)+1,
                    ee='R';
                else
                    ee='';
                end
                rstr=[ee 'TARG-' num2str(exptparams.targ_atten+jitter_int)];
                
                distidx=0;
                [thistone(:,2),ev]=waveform(TO2,targidx(2));
                thistone(:,2)=thistone(:,2).*targ_scale;
            else
                % pick a reference. for single distractor runs
                % only pick a new tone for the first tone. and only do
                % that if previous trial was correct
                if (ii==1 && berror~=1) || ~exptparams.single_dist,
                    if isempty(distobjectindexset2),
                        distobjectindexset2=1:get(RO2,'MaxIndex');
                        exptparams.repcount=exptparams.repcount+1;
                    end
                    
                    tdistobjectindexset=setdiff(distobjectindexset2,distindex_thistrial2);
                    if isempty(tdistobjectindexset),
                        tdistobjectindexset=1:get(RO2,'MaxIndex');
                    end
                    distindex=tdistobjectindexset(ceil(rand.*length(tdistobjectindexset)));
                    fprintf('ch2 distractor object index: %d (remaining this rep: %d)\n',...
                        distindex, length(tdistobjectindexset)-1);
                    distindex_thistrial2=[distindex_thistrial2;distindex];
                end
                
                rstr=['REF-' num2str(dist_atten+jitter_int)];
                
                % generate the reference waveform of appropriate length
                if ~fixed_RO_len,
                    RO2=set(RO2,'Duration',round((all_duration2(ii)-RO_silence(2)).*100)./100);
                end
                [thistone(:,2),ev]=waveform(RO2,distindex);
                if sum(isnan(thistone))>0
                    keyboard
                end
                
                % adjust sound level
                thistone(:,2)=thistone(:,2).*dist_scale;               
            end            
            for jj=1:length(ev),
                soundevents2=AddEvent(soundevents2,[ev(jj).Note, ' , ',rstr],count,...
                    sum(all_duration2(1:(ii-1)))+ev(jj).StartTime,...
                    sum(all_duration2(1:(ii-1)))+ev(jj).StopTime);
            end

            if (ii==pretonecount(2)+1),
                targetdonetime(2)=soundevents2(end).StopTime;
            end
        end 
        % append the current reference to the stimulus vector
        if size(thisstim,2)==1,
            thisstim(:,2)=0;
        end
        thisstim=[thisstim; thistone];
    end
    % finished generating sound waveform
    % get
    
    triallen=size(thisstim,1)./exptparams.fs;
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
        LastQuickError=1;
        nlt=0;
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
       while touch && ~trialover,
            currenttime=toc;
            
            % require bar down AND no licks for time nlt:
            if exptparams.use_lick && IOLickRead(HW),
                lasttouch=currenttime;
            elseif ~exptparams.use_lick && IOPawRead(HW) && ~(exptparams.simulick==1), % | IOLickRead(HW),
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

            if first_hold && currenttime-lasttouch>0.05,
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
    prewardjuststarted=0;

    if ~trialover,
        fprintf('playing sound (tstart=%.2f)...\n',tstart);
        
        if ~exptparams.use_lick && exptparams.startrwdur>0,
            % reward for pressing bar -- early training.
            if exptparams.use_light,
                IOLightSwitch(HW,1,exptparams.startrwdur);
            end
            disp('starting pre-reward');
            IOControlPump(HW,'Start',exptparams.startrwdur);
            prewardstarted=1;
        end
        
        while timesincestart<triallen && ~trialover,
            
            % start preward 1/4 of way through response window
            % (moved back from 1/2 SVD 2009_03_10)
            if exptparams.use_lick && exptparams.startrwdur>0 && ...
                    (timesincestart>rwstart+(rwstop-rwstart)/4 && ...
                    timesincestart<=rwstop) && ...
                    ~prewardstarted,
                % reward for waiting long enough before licking -- early training.
                disp('starting pre-reward');
                IOControlPump(HW,'Start',exptparams.startrwdur);
                %prepumpev=IOControlPump(HW,'Start',0);
                prewardstarted=1;
                prewardjuststarted=1;
                pause(exptparams.startrwdur);
            end
            if 0 &&prewardstarted && timesincestart>prepumpev.StartTime+exptparams.startrwdur,
              IOControlPump(HW,'Stop',0);
            end
            if exptparams.use_lick,
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
                
                if (touchtime-tstart>rwstart && touchtime-tstart<=rwstop) || ...
                   (touchtime-tstart>rwstart1 && touchtime-tstart<=rwstop1),
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
                    if touchtime-tstart<0.5 && touchtime-tstart<RO_duration(1)-get(RO,'PostStimSilence') &&...
                          ~LastQuickError,  
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
    LastQuickError=0;
    
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
        if ~QuickError || IOGetTimeStamp(HW)>RO_duration(1)-get(RO,'PostStimSilence'),
            IOStopSound(HW);
            disp('stopped now');
        end
        pause(0.01);
    end
    
    if targchidx==1; tmpO = TO1; else tmpO = TO2; end
    td=get(tmpO);
    if isfield(td,'Duration'),
        tmpO=set(tmpO,'Duration',0.1);
        cuetone=waveform(tmpO,targidx);
    else
        cuetone=waveform(tmpO,targidx);
    end
    dist_scale=0; %10.^(-exptparams.cue_atten./20);
    cuetone=cuetone.*dist_scale;
    
    if berror,
        if ~stopnow && ~QuickError,
            if berror~=2 || exptparams.jitter_db<30,
                [tev,HW]=IOStartSound(HW,[punishsound;cuetone(:,1);cuetone(:,1)]);
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
        distobjectindexset1=setdiff(distobjectindexset1,distindex_thistrial1);
        distobjectindexset2=setdiff(distobjectindexset2,distindex_thistrial2);
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
    if isfield(globalparams,'rawid') && globalparams.rawid>0
        evpwrite(globalparams.tempevpfile,[],[LickData(:) PawData(:)],HW.params.fsAI,...
            HW.params.fsAI);
    end
    
    % save lick data at coarser sampling rate
    if ~isempty(LickData),
        bstat=round(resample([LickData(:) PawData(:)],exptparams.bfs,HW.params.fsAI));
    else
        warning('lickdata is missing!!!');
        bstat=zeros(1000,2);
    end
    
    if 1 || ~stopnow,
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
        
        exptparams.results_command=['dms_di ',globalparams.mfilename];
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
            if isempty(swater),
                swater=sprintf('%.2f',exptparams.volreward);
            end
            if isempty(swater),
                swater='0';
            end
            sql=['UPDATE gHealth set schedule=1,trained=1,water=',...
                 swater,' WHERE id=',num2str(hdata.id)];
            mysql(sql);
        else
            sql=['INSERT INTO gHealth (animal_id,animal,date,',...
                 'water,trained,schedule,addedby,info) VALUES (',...
                 num2str(hdata.animal_id),',"',globalparams.Ferret,'",',...
                 '"',datestr(now,29),'",' num2str(exptparams.volreward),...
                 ',1,1,"',DB_USER,'","dms_run.m")'];
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

