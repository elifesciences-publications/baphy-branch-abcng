function results=dms0(animal);
% function results=dms0(animal)
% 
% pre training procedure for dms.  loads parameter set from 
% dmsparams.<animal>.mat (or dmsparams.mat if animal is not specified)
%
% created SVD 2005-09-01 (approx)
% modified SVD 2005-10-04 -- added chirps to target/distractor sets
% modified SVD 2005-10-08 -- log events using timestamps from DAQ card
%
global BAPHYHOME
if ~exist('animal','var'),
    pfile=[BAPHYHOME filesep 'Config' filesep 'dmsparams.mat'];
else
    pfile=[BAPHYHOME filesep 'Config' filesep 'dmsparams.' animal '.mat'];
end

if exist(pfile,'file'),
    disp(['Loading saved parameters from ' pfile '...']);
    load(pfile);
else
    params=[];
end

global cumres;
cumres=[];

totalreward=0;

while 1,
    
    params=mainmenu(params);
    if params.action=='u',
        
        % generate save file name, making sure not to overwrite existing files
        setcount=0;
        outfile='';
        while isempty(outfile) | exist(outfile,'file'),
            setcount=setcount+1;
            outfile=[params.outpath params.animal filesep params.animal '-' ...
                    datestr(now,'yyyy-mm-dd') '-' mfilename '-' num2str(setcount) '.mat'];
        end
        params.setcount=setcount;
        params.totalreward=totalreward;
        
        results=sub_start(params);
        
        if isempty(cumres),
            cumres=results;
        elseif ~isempty(results),
            cumres.params=results.params;
            cumres.tonetriglick=cumres.tonetriglick+results.tonetriglick;
            cumres.ttlcount=cumres.ttlcount+results.ttlcount;
            cumres.volreward=totalreward;
        end
        if strcmp(params.outpath,'x') | strcmp(params.outpath,'X'),
            disp('***************');
            disp(' skipping save ');
            disp('***************');
        else
            fprintf('saving to %s\n',outfile);
            if ~exist([params.outpath params.animal])
                mkdir([params.outpath params.animal]);
            end
            save(outfile,'results','cumres','params');
        end
        
        % keep track of total water earned
        if isfield(results,'volreward'),
            totalreward=totalreward+results.volreward;
            fprintf('\nCumulative reward: %.2f ml\n\n',totalreward);
        end
        params.totalreward=totalreward;
    else
        break
    end
end 

xx=input('save current params (y/[n])? ','s');
if strcmp(xx,'y'),
    save(pfile,'params');
end
fprintf('\nFinal cumulative reward: %.2f ml\n\n',totalreward);
disp('goodbye!');

%=============================================================
function params=mainmenu(params)

ii=0;
ii=ii+1; maintext{ii}=sprintf('%2d   Ferret Name:  ',ii); parmname{ii}='animal'; parmdef{ii}='test'; 
ii=ii+1; maintext{ii}=sprintf('%2d   Save path ("X"=no save):  ',ii); parmname{ii}='outpath'; parmdef{ii}=['e:' filesep]; 
ii=ii+1; maintext{ii}=sprintf('%2d   Test mode:  ',ii); parmname{ii}='TESTMODE'; parmdef{ii}=0;
ii=ii+1; maintext{ii}=sprintf('%2d   Tone start (Hz):  ',ii);  parmname{ii}='freqs'; parmdef{ii}=[1200   600  2400  4800  9600];
ii=ii+1; maintext{ii}=sprintf('%2d   Tone dest (Hz):  ',ii);  parmname{ii}='freqe'; parmdef{ii}=[1200   600  2400  4800  9600];
ii=ii+1; maintext{ii}=sprintf('%2d   Tone sound level:  ',ii); parmname{ii}='toneamp'; parmdef{ii}=[1.0 0.2 0.2 0.2 0.2 0.2];
ii=ii+1; maintext{ii}=sprintf('%2d   Tone duration (sec):  ',ii); parmname{ii}='dur'; parmdef{ii}=0.2;
ii=ii+1; maintext{ii}=sprintf('%2d   Gap duration (sec):  ',ii); parmname{ii}='gapdur'; parmdef{ii}=0.5;
%ii=ii+1; maintext{ii}=sprintf('%2d   Gap std (sec):  ',ii); parmname{ii}='gapstd'; parmdef{ii}=0.25;
%ii=ii+1; maintext{ii}=sprintf('%2d   Task format (1=AA/BB, 2=ABA/AA/BAB/BB, 3=constant distr):  ',ii); parmname{ii}='format'; parmdef{ii}=1;
%ii=ii+1; maintext{ii}=sprintf('%2d   Fraction distractor trials:  ',ii); parmname{ii}='distfrac'; parmdef{ii}=[0.0];
%ii=ii+1; maintext{ii}=sprintf('%2d   Distractor duration:  ',ii); parmname{ii}='distdur'; parmdef{ii}=0.1;
ii=ii+1; maintext{ii}=sprintf('%2d   First target:  ',ii); parmname{ii}='targidx0'; parmdef{ii}=1;
ii=ii+1; maintext{ii}=sprintf('%2d   Trials between target switch:  ',ii); parmname{ii}='blocksize'; parmdef{ii}=10;
%ii=ii+1; maintext{ii}=sprintf('%2d   Play cue:  ',ii); parmname{ii}='cueon'; parmdef{ii}=1;
ii=ii+1; maintext{ii}=sprintf('%2d   No-lick mean (sec):  ',ii); parmname{ii}='nolick'; parmdef{ii}=0.5;
ii=ii+1; maintext{ii}=sprintf('%2d   No-lick std (sec):  ',ii); parmname{ii}='nolickstd'; parmdef{ii}=0.15;
ii=ii+1; maintext{ii}=sprintf('%2d   Response win start (sec):  ',ii); parmname{ii}='startwin'; parmdef{ii}=0.2;
ii=ii+1; maintext{ii}=sprintf('%2d   Response win duration (sec):  ',ii); parmname{ii}='respwin'; parmdef{ii}=1.0;
ii=ii+1; maintext{ii}=sprintf('%2d   Reward duration (sec):  ',ii); parmname{ii}='rwdur'; parmdef{ii}=0.75;
ii=ii+1; maintext{ii}=sprintf('%2d   Punish sound level:  ',ii); parmname{ii}='punishvol'; parmdef{ii}=0.5;
ii=ii+1; maintext{ii}=sprintf('%2d   Punish timeout (sec):  ',ii); parmname{ii}='timeout'; parmdef{ii}=5.0;
ii=ii+1; maintext{ii}=sprintf('%2d   Inter-trial interval (sec):  ',ii); parmname{ii}='isi'; parmdef{ii}=1.0;
ii=ii+1; maintext{ii}=sprintf('%2d   Trials in each set:  ',ii); parmname{ii}='N'; parmdef{ii}=10;
ii=ii+1; maintext{ii}=sprintf(' u   Start pretraining'); parmname{ii}='action'; parmdef{ii}='u';
ii=ii+1; maintext{ii}=sprintf(' x   Quit'); parmname{ii}='action'; parmdef{ii}='x';

ncmdcount=ii-2; % number of numeric commands

for ii=1:length(parmname),
    if ~isfield(params,parmname{ii}),
        params=setfield(params,parmname{ii},parmdef{ii});
    end
end

params.action='';
while isempty(params.action),
    disp([mfilename ' Settings=================================='])
    for ii=1:length(maintext),
        dd=getfield(params,parmname{ii});
        if isnumeric(dd),
            dd=num2str(dd);
        end
        disp([maintext{ii} dd]);
    end
    disp('  ');
    xx=input(sprintf('Your Choice (1-%d,x,u):',ncmdcount),'s');
    disp('==============================================');
    nn=str2num(xx);
    if ismember(nn,1:ncmdcount),
        if isnumeric(parmdef{nn}),
            ss=sprintf('%s [%s]: ',parmname{nn},num2str(parmdef{nn}));
            tt=input(ss,'s');
            if isempty(tt)
                tt=parmdef{nn};
            else
                tt=str2num(tt);
            end
        else
            ss=sprintf('%s [%s]: ',parmname{nn},parmdef{nn});
            tt=input(ss,'s');
            if isempty(tt),
                tt=parmdef{nn};
            end
        end
        params=setfield(params,parmname{nn},tt);
        
    elseif strcmp(xx,'u'),
        params.action='u';
    elseif strcmp(xx,'x'),
        params.action='x';
    else
        disp('-------invalid selection! try again'); 
    end
end

%=============================================================
function summ=sub_start(params);

summ=[];
if params.TESTMODE
    disp('NOTE : RUNNING IN TEST MODE');
end
if strcmp(input('Ready!! Do you really want to start ([y]/n)? ','s'),'n')
    return;
end

% save parameters
summ.params=params;

% a few hard coded parameters
params.voltage=6.0;      % volume scaling
params.volpersec=0.251;  % measured using pumpcal.m
params.presec=1.0;       % record presec worth of data before trial start
fs=16000;                % sound sampling frequency
params.fs=fs;

% generate stimuli
tstring={'A','B','C','D','E','F','G','H','I','J','K','L'};
summ.tstring=tstring;
tonecount=length(params.freqs);
if length(params.toneamp)<tonecount,
    toneamp=repmat(params.toneamp(1),size(params.freqs));
else
    toneamp=params.toneamp;
end
t=(1./fs:1/fs:params.dur)';
tones=zeros(length(t),tonecount);
for ii=1:length(params.freqs),
    if length(params.freqe)<ii | params.freqe(ii)==params.freqs(ii),
        tones(:,ii)=toneamp(ii).*params.voltage*sin(2*pi*params.freqs(ii).*t);
    else
        tones(:,ii)=toneamp(ii).*params.voltage*chirp(t,params.freqs(ii),params.dur,params.freqe(ii));
    end
    fprintf('%s: %.1f %.1f\n',tstring{ii},mean(tones(:,ii)),std(tones(:,ii)));
end

% play 200 Hz sound for 1 sec on incorrect trials
t=(1/fs:1/fs:1)';
punishsound=params.punishvol.*params.voltage.*sin(2*pi*200.*t);

% set up figure for observation and key inputs
fh=1;
figure(fh);
clf
callstr = ['set(gcbf,''Userdata'',double(get(gcbf,''Currentcharacter''))) ; uiresume '] ;
set(fh,'keypressfcn',callstr); %set(fh,'windowstyle','modal'); 

global LICKSIGN
LICKSIGN=1;

%try,
    % DAQ activity in try segment so it can be disabled in the event of an
    % error or break
    
    DAQ=ioinitialize(params);
    DAQ.params.HWSetup=2
    DAQ.params.fsAI=1000;

    % initialize counters
    summ.res=[];    % record basic performance
    summ.bstat={};  % record detailed behavior
    summ.bfs=50;  % behavior sampling frequency
    bstep=1./summ.bfs;
    summ.events=[];
    evcount=0;
    ttlsec=1.0;
    tonetriglick=zeros(summ.bfs*ttlsec,tonecount,2);
    ttlcount=zeros(summ.bfs*ttlsec,tonecount,2);
    
    count=0;
    type=[];
    prestat=[];
    
    % start first block with target 1
    targidx=params.targidx0;
    
    % send a little reward to wake up at begining of each block?
    %rewardsend(DAQ,2.0);
    iopump(DAQ,0); % turn off the pump
    iolight(DAQ,0);  % turn off the light
    taskstarttime=iosoundstart(DAQ,zeros(100,1));   % play dummy sound to deal with no-first-play issue
    pause(0.01);
    iosoundstop(DAQ);

    % loop trials indefinitely (until break at end of trial block)
    while 1,
        %%% basic structure of a trial:
        % figure out trial stimulus
        % contruct tone vector
        % figure out valid lick period
        % wait for no lick (0.5 sec?)
        % start playing sound
        % monitor licks
        % at first lick, stop sound
        % if lick at valid time, administer reward
        % if lick at invalid time, play punishment sound and timeout
        % pause for isi
        
        %%% useful functions:
        % start sound           - iosoundstart
        % stop sound            - iosoundstop
        % get lick status       - iolick
        % reward switch on/off  - iopump
        % light switch on/off   - iolight
        % close DAQ connection  - iocleanup
        % shock switch on/off
        
        % increment trial counter
        count=count+1;
        fprintf('\n** trial %d (%d) start **\n',count,params.setcount);
        
        % choose target and distractor
        if params.blocksize==0,
            % random targets one each trial
            targidx=ceil(rand*tonecount);
        elseif mod(count,params.blocksize)==1 & count>1,
            % block is done, switch target
            % for now target can only be tone A or B
            if targidx==1,
                targidx=2;
            else
                targidx=1;
            end
            %targidx=targidx+1;
            %if targidx > tonecount,
            %    targidx=1;
            %end
        end
        trialssinceblock=mod(count-1,params.blocksize);
        if count==1,
            corrtrialssinceblock=0;
        else
            corrtrialssinceblock=sum(summ.res(end-trialssinceblock+1:end,2)==0);
        end
        if corrtrialssinceblock<3,
            %  mod(count,params.blocksize)>0 & mod(count,params.blocksize)<4,
            cuetrial=1;
            fprintf('cue trial... ');
        else
            cuetrial=0;
        end
        
        %%
        %% construct tone vector
        %%
        disp(['target: ' tstring{targidx}]);
        thisstim=tones(:,targidx);
        
        lickstart=params.startwin;
        lickstop=lickstart+params.respwin;
        triallen=max([lickstop length(thisstim)./fs]);
        fprintf('valid lick range: %.2f - %.2f sec; totlen=%.2f\n',...
                lickstart,lickstop,triallen);
        
        % pre-trial: wait til animal hasn't licked for params.nolick sec
        fprintf('waiting for no lick ');
        if params.TESTMODE,
            iolick(DAQ,0);
        end
        
        % require at least 0.05 sec no lick
        
        if params.nolickstd>0 & (count==1 | berror==0), % keep licktime same from previous trial
            nolicktime=0;
            while nolicktime<0.05 | nolicktime>2,
                %nolicktime=params.nolick+randn*params.nolickstd;
                nolicktime=params.nolick+random('exp',params.nolickstd);
            end
        elseif ~exist('nolicktime','var'),
            nolicktime=0;
            % do nothing
        end
        fprintf('nolicktime=%.2f sec\n',nolicktime);
        
        % set variables for recording behavior
        set(fh,'Userdata',[]);    % clear keyboard buffer
        stopnow=0;
        berror=[];  % outcome undefined
        trialover=0;
       
        %
        % TRIAL STARTS HERE
        % this is presumably the time to start recording spikes in a
        % physiology expt
        %
        % start AI
        if params.TESTMODE,
            daqstarttime=clock;
        else
            start(DAQ.AI);  % don't need to trigger
            t=get(DAQ.AI,'EventLog');
            daqstarttime=t(end).Data.AbsTime;
        end
        
        daqstartsec=etime(daqstarttime,taskstarttime);
        evcount=evcount+1;
        summ.events(evcount).trial=count;
        summ.events(evcount).starttime=daqstartsec;
        summ.events(evcount).note='TRIALSTART';
        
        % wait through Isi for nolick
        touch=1;
        if cuetrial & nolicktime>0,
            nlt=nolicktime;
        else
            nlt=params.isi;
        end
        
        % (no lick) for isi before trial starts
        fprintf('ITI=%.1f\n',nlt);
        tstart=clock;
        bstat=[];    % matrix to record behavioral data
        if nlt>0,
            while touch,
                % silence during no-lick
                bstat=wait_get_bstat(DAQ,bstat,bstep,tstart,0.01);
                
                prelen=size(bstat,1);
                if prelen>=round(summ.bfs*nlt),
                    touch=sum(bstat((prelen-round(summ.bfs*nlt-1)):prelen,2))>0;
                end
                
                if prelen/summ.bfs>15,
                    touch=0;
                    disp(' * too much pre-licking');
                    berror=3;  % impatience error
                    trialover=1;
                end
            end
        end
        
        % this shouldn't change the appearance of anything as far as the
        % ferrets can tell, except tones will get interrupted. if it freaks
        % them out, switch this to "if 1,"
        if 0,
            % old format. play tones until nolick time passes
            if ~cuetrial & ~trialover,
                % minimum nolick isi time has passed. now start playing tones
                touch=1;
                nlt=nolicktime-params.isi;
                while touch,
                    % pick a non-target tone
                    toneidx=ceil(rand*(tonecount-1));
                    if toneidx>=targidx,
                        toneidx=toneidx+1;
                    end
                    fprintf('%s',tstring{toneidx});
                    tt=iosoundstart(DAQ,tones(:,toneidx));
                    evcount=evcount+1;
                    summ.events(evcount).trial=count;
                    summ.events(evcount).starttime=etime(tt,taskstarttime);
                    summ.events(evcount).note=tstring{toneidx};
                    bstat=wait_get_bstat(DAQ,bstat,bstep,tstart,params.dur+params.gapdur);
                    iosoundstop(DAQ);
                    
                    prelen=size(bstat,1);
                    if prelen>=round(summ.bfs*nlt),
                        touch=sum(bstat((prelen-round(summ.bfs*nlt-1)):prelen,2))>0;
                    end
                    
                    if prelen/summ.bfs>15,
                        touch=0;
                        disp(' * too much pre-licking');
                        berror=3;  % impatience error
                        trialover=1;
                    end
                end
            end
        elseif nolicktime>0,
            % new format: stop trial on no-lick violation. don't punish though?
            if ~cuetrial & ~trialover,
                % minimum nolick isi time has passed. now start playing tones
                touch=1;
                nlt=nolicktime-params.isi;
                diststarttime=clock;
                
                while etime(clock,diststarttime)<nlt & ~trialover,
                    % pick a non-target tone
                    toneidx=ceil(rand*(tonecount-1));
                    if toneidx>=targidx,
                        toneidx=toneidx+1;
                    end
                    fprintf('%s',tstring{toneidx});
                    tt=iosoundstart(DAQ,tones(:,toneidx));
                    evcount=evcount+1;
                    summ.events(evcount).trial=count;
                    summ.events(evcount).starttime=etime(tt,taskstarttime);
                    summ.events(evcount).note=tstring{toneidx};
                    
                    tt=clock;
                    touch=0;
                    while etime(clock,tt)<params.dur+params.gapdur,
                        bstat=wait_get_bstat(DAQ,bstat,bstep,tstart,0.03);
                        if bstat(end,2)>0,
                            touch=1;
                        end
                    end
                    iosoundstop(DAQ);
                    
                    if touch>0,
                        disp(' * early lick');
                        berror=1;  % early lick
                        trialover=1;
                    end
                end
            end
        end
        
        if ~trialover,
            % start playing sound
            fprintf('*%s*',tstring{targidx});
            tt=iosoundstart(DAQ,thisstim);
            evcount=evcount+1;
            summ.events(evcount).trial=count;
            summ.events(evcount).starttime=etime(tt,taskstarttime);
            summ.events(evcount).note=tstring{targidx};
        end
        
        timesincestart=0;
        targstart=clock;
        lastdstart=0;
        touch=0;
        b0=length(bstat)+1;
        while timesincestart<triallen & ~trialover,
            
            bstat=wait_get_bstat(DAQ,bstat,bstep,tstart,0.03);
            timesincestart=etime(clock,targstart);
            
            if size(bstat,1)>0,
                touch=sum(bstat(b0+1:end,2))>0;
            end
            if ~cuetrial & timesincestart>params.dur & ...
                    timesincestart>lastdstart+params.dur+params.gapdur,
                iosoundstop(DAQ);
                toneidx=ceil(rand*(tonecount-1));
                if toneidx>=targidx,
                    toneidx=toneidx+1;
                end
                fprintf('%s',tstring{toneidx});
                tt=iosoundstart(DAQ,tones(:,toneidx));
                evcount=evcount+1;
                summ.events(evcount).trial=count;
                summ.events(evcount).starttime=etime(tt,taskstarttime);
                summ.events(evcount).note=tstring{toneidx};
                lastdstart=timesincestart;
            end
            
            if touch,
                trialover=1;
                
                licktime=min(find(bstat(b0+1:end,2))).*bstep;
                if licktime>lickstart & licktime<=lickstop,
                    berror=0;
                    disp(' * correct!');
                    tt=iotimestamp(DAQ);
                    evcount=evcount+1;
                    summ.events(evcount).trial=count;
                    summ.events(evcount).starttime=etime(tt,taskstarttime);
                    summ.events(evcount).note='MATCH';
                    
                    % turn on light
                    iolight(DAQ,1);
                    
                    % turn on the pump for params.rwdur sec
                    iopump(DAQ,1);
                    bstat=wait_get_bstat(DAQ,bstat,bstep,tstart,params.rwdur);
                    iopump(DAQ,0);
                    
                    % turn off light
                    iolight(DAQ,0);

                    % wait til reward over to stop sound??
                    iosoundstop(DAQ);
                    
                elseif licktime<=lickstart,
                    iosoundstop(DAQ);                 % stop interfaces
                    berror=1;
                    disp(' * early lick');
                else % licktime>lickstop
                    iosoundstop(DAQ);                 % stop interfaces
                end
            end
            
            ch = get(fh,'Userdata') ;
            if ~isempty(ch),
                set(fh,'Userdata',[]);
                disp(['key: ',ch]);
                
                switch ch,
                        
                case 'l',
                    if params.TESTMODE,
                        iolick(DAQ,1-iolick(DAQ));
                    end
                case 'q',
                    stopnow=1;
                end
                
            end
        end
        
        %iolight(DAQ,0);    % turn off the light
        iosoundstop(DAQ);  % make sure sound is stopped
        
        if isempty(berror),
            % if never licked, play punishment sound and timeout
            berror=2;
            disp(' * missed');
        end
        
        if berror,
            if berror==2,
                tt=iosoundstart(DAQ,punishsound);
                fprintf('timeout: %.1f sec\n',1.0);
                bstat=wait_get_bstat(DAQ,bstat,bstep,tstart,1.0);
                iosoundstop(DAQ);              % make sure sound is stopped
            else
                fprintf('no timeout\n');
                fprintf('timeout: %.1f sec\n',params.timeout);
                bstat=wait_get_bstat(DAQ,bstat,bstep,tstart,params.timeout);
                tt=iotimestamp(DAQ);
            end
            
            evcount=evcount+1;
            summ.events(evcount).trial=count;
            summ.events(evcount).starttime=etime(tt,taskstarttime);
            if berror==3,
                summ.events(evcount).note='IMP';
            elseif berror==2,
                summ.events(evcount).note='MISS';
            else
                summ.events(evcount).note='EARLY';
            end
        end
        
        if ~params.TESTMODE,
            stop(DAQ.AI);
            if 0,
                spikecount   = get(DAQ.AI,'SamplesAcquired')    % Determine how many samples were acquired
                datatouch = getdata(DAQ.AI,spikecount);
                flushdata(DAQ.AI,'all');
                if LICKSIGN<0,
                    datatouch=5-datatouch;
                end
                datatouchclean = (datatouch>4); % threshold analog signal
                figure(2);
                plot(datatouch./5);
                hold on
                plot(datatouchclean,'r');
                hold off
                figure(1);
            end
        end
        
        tlick=(0:(length(bstat)-1))./summ.bfs;
        lick=[bstat(:,2); nan*zeros(summ.bfs*ttlsec+100,1)];
        tt0=evtimes(summ.events,'TRIALSTART',count);
        if berror==0,
            % trim licks after correct response to avoid bias?
            ttcorrect=evtimes(summ.events,'MATCH',count);
            cutoffidx=min(find(tlick>ttcorrect-tt0+.2));  % keep 200 ms after lick
            [size(lick) size(tlick)]
            if ~isempty(cutoffidx),
                lick(cutoffidx:end)=nan;
            end
        end
        
        for ii=1:tonecount,
            tt=evtimes(summ.events,tstring{ii},count)-tt0;
            fprintf('%s: %d',tstring{ii},length(tt));
            for jj=1:length(tt),
                sbin=min(find(tlick>tt(jj)));
                if isempty(sbin),
                    %[ii max(tlick) tt(jj)]
                else
                    minnan=min([find(isnan(lick(sbin:sbin+summ.bfs*ttlsec-1)))' summ.bfs*ttlsec]);
                    tonetriglick(1:minnan-1,ii,targidx)=tonetriglick(1:minnan-1,ii,targidx)+ ...
                        lick(sbin:sbin+minnan-2);
                    ttlcount(1:minnan-1,ii,targidx)=ttlcount(1:minnan-1,ii,targidx)+1;
                end
            end
        end
        summ.tonetriglick=tonetriglick;
        summ.ttlcount=ttlcount;
        
        % accumulate behavioral data and stats
        summ.res=[summ.res; nolicktime berror lickstart lickstop targidx];
        summ.tt{count}=(1:length(bstat))'./summ.bfs;
        summ.bstat{count}=bstat;
        
        % plot some results
        %figure(1);
        ccount=sum(summ.res(:,2)==0);
        summ.volreward=ccount*params.volpersec*params.rwdur;
        dmsPlotBehavior(summ);
        
        % text results
        fprintf('Performance: correct,early,miss,olick / total: %d,%d,%d,%d / %d\n',...
                hist(summ.res(:,2),0:3),length(summ.res));
        fprintf('** End trial %d **\n\n', count);
        
        % stop if animal is on a bad streak
        streaklen=20;
        if count>=streaklen & sum(summ.res(end-streaklen+1:end,2)==0)==0,
            fprintf('missed last %d trials. stopping.\n',streaklen);
            stopnow=1;
        end
        
        if ~stopnow & mod(count,params.N)~=0,
            
            % isi moved to front of loop
            
        else
            disp('-----------------------------');
            fprintf('%d / %d trials correct.\n',ccount,count);
            fprintf('Total reward: %d (corr) x %0.2f (sec/corr) x %.2f (ml/sec) = %.2f ml\n',...
                    ccount,params.rwdur,params.volpersec,summ.volreward);
            fprintf('Total reward today: %.2f\n',params.totalreward+summ.volreward);
            if strcmp(input('do you wish to continue?, ([y]/n): ','s'),'n'),
                break
            end
            if params.TESTMODE,
                figure(fh);
                drawnow;
            end
        end
    end
    
%catch,
%    iocleanup(DAQ);
%    error(['error: ',lasterr]);
%end

iocleanup(DAQ);
