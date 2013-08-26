

% a few hard coded parameters
params.dur=0.1;
params.gapdur=0.1;
params.freqs=[1200 2400];
params.freqe=[1200 2400];
params.toneamp=[1 1];
params.voltage=6.0;      % volume scaling
params.volpersec=0.251;  % measured using pumpcal.m
params.presec=1.0;       % record presec worth of data before trial start
params.fs=16000;                % sound sampling frequency

% generate stimuli
tstring={'A','B','C','D','E','F','G','H','I','J','K','L'};
tonecount=length(params.freqs);
if length(params.toneamp)<tonecount,
    toneamp=repmat(params.toneamp(1),size(params.freqs));
else
    toneamp=params.toneamp;
end
t=(1./params.fs:1/params.fs:params.dur)';
tones=zeros(length(t),tonecount);
for ii=1:length(params.freqs),
    if length(params.freqe)<ii | params.freqe(ii)==params.freqs(ii),
        tones(:,ii)=toneamp(ii).*params.voltage*sin(2*pi*params.freqs(ii).*t);
    else
        tones(:,ii)=toneamp(ii).*params.voltage*chirp(t,params.freqs(ii),params.dur,params.freqe(ii));
    end
    fprintf('%s: %.1f %.1f\n',tstring{ii},mean(tones(:,ii)),std(tones(:,ii)));
end

% set up figure for observation and key inputs
fh=1;
figure(fh);
clf
callstr = ['set(gcbf,''Userdata'',double(get(gcbf,''Currentcharacter''))) ; uiresume '] ;
set(fh,'keypressfcn',callstr); %set(fh,'windowstyle','modal'); 

% Initialize Analog output for Sound output
DAQ.AO = analogoutput('nidaq',1);
hwAnOut = addchannel(DAQ.AO,0:1);                 % Add channels for each speaker
set(DAQ.AO,'TriggerType','HwDigital');
set(DAQ.AO,'TransferMode','DualDMA');
set(DAQ.AO,'SampleRate',params.fs);

% Initialize Digital IO
DAQ.DIO     = digitalio('nidaq',1);
hwDIOut = addline(DAQ.DIO,0:1,'Out'); % Shock Light and Shock Switch   
hwDiIn  = addline(DAQ.DIO,2,'In'); 
hwTrOut = addline(DAQ.DIO,3:4,'Out'); % Trigger for AI and AO
hwDiIn2 = addLine(DAQ.DIO,7,'In'); % touch input
hwDiIn2 = addLine(DAQ.DIO,6,'In');
hwDiOut = addLine(DAQ.DIO,5,'Out'); % Water Pump

if 1
    % Initialize Analog Input
    fstouch = 1000;
    fsspike = 20000;
    %mode = 'Behavior&Physiology';
    mode = 'Behavior';
    switch mode
        case 'Behavior'
            fsAI = fstouch;
            aichannel = 0
            ainames = {'Touch'}
        case 'Passive'
            fsAI = fsspike;
            aichannel = 1;
            ainames = {'Spike'};
        case 'Behavior&Physiology'
            fsAI = fsspike;
            aichannel = 0:1;
            ainames = {'Touch','Spike'};
    end
    DAQ.AI      = analoginput('nidaq',1)       % Create object DAQ.AI - NI Daq(2)
    hwAnIn  = addchannel(DAQ.AI,aichannel,ainames);     % Add the h/w line
    % Line 1 is for touch input
    % Line 2 is for spike data
    set(DAQ.AI,'InputType','NonReferencedSingleEnded');      % Single ended input
    set(DAQ.AI,'DriveAISenseToGround','On');    % Do not use DAQ.AI sense to ground
    set(DAQ.AI,'SampleRate',fsAI);           % Sample rate
    set(hwAnIn,'InputRange',[-10 10]);      % Output from Amplifiers
    set(hwAnIn,'SensorRange',[-10 10]);     % for evp data set to 
    set(hwAnIn,'UnitsRange',[-10 10]);      % [-10 10]Volts
    %set(DAQ.AI,'TriggerType','HwDigital');         % Trigger type=Manual
    set(DAQ.AI,'TriggerType','Immediate');       
    set(DAQ.AI,'LoggingMode','Memory');
    set(DAQ.AI,'SamplesPerTrigger',fsAI*10);
end


iopump(DAQ,0); % turn off the pump
iolight(DAQ,0);  % turn off the light
iosoundstart(DAQ,zeros(100,1),params.fs);   % play dummy sound to deal with no-first-play issue
pause(0.01);
iosoundstop(DAQ);

prestat=[];
prestart=clock;
bfs=50;  % behavior sampling frequency
bstep=1./bfs;

% start AI
start(DAQ.AI);

t={};
for ii=1:10,
    iosoundstart(DAQ,tones(:,1),params.fs);
    prestat=wait_get_bstat(DAQ,prestat,bstep,prestart,params.dur+params.gapdur);
    iosoundstop(DAQ);
    %t{ii}=getdata(DAQ.AI);
end

% start AI
stop(DAQ.AI);

spikecount   = get(DAQ.AI,'SamplesAcquired')    % Determine how many samples were acquired

if ~(spikecount)         % If # of samples acquired=0, 
    display('Data not recorded');   % skip saving data.
    return;
end;
datatouch = getdata(DAQ.AI,spikecount);
flushdata(DAQ.AI,'all');
datatouch = (datatouch>4); % threshold analog signal


%iocleanup(DAQ);

figure(1);
clf
subplot(2,1,1);
plot((1:length(prestat))'./bfs,prestat(:,1)+2.2);
hold on
plot((1:length(prestat))'./bfs,prestat(:,2)+1.1,'g');
plot((1:length(prestat))'./bfs,prestat(:,3),'r');
hold off
axis([0 length(prestat)./bfs -0.1 3.3]);
xlabel('time from sound onset (sec)');
legend('light','lick','pump');

subplot(2,1,2);
plot(datatouch);

return

    
    % initialize counters
    summ.res=[];    % record basic performance
    summ.bstat=[];  % record detailed behavior
    summ.bfs=50;  % behavior sampling frequency
    bstep=1./summ.bfs;
    summ.events=[];
    evcount=0;
    ttlsec=1;
    tonetriglick=zeros(summ.bfs*ttlsec,tonecount,2);
    ttlcount=zeros(tonecount,2);
    
    count=0;
    type=[];
    prestat=[];
    prestart=clock;
    
    % start first block with target 1
    targidx=params.targidx0;
    
    % send a little reward to wake up at begining of each block?
    %rewardsend(DAQ,2.0);
    
    taskstarttime=clock;
    
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
        
        % figure out delay between tones
        %thistype=params.gapdur+randn*params.gapstd;
        %if thistype<0.1,
        %    thistype=0.1;  % force at least 0.1 sec
        %end
        %type=[type thistype];
        
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
        if mod(count,params.blocksize)>0 & mod(count,params.blocksize)<4,
            cuetrial=1;
            fprintf('cue trial... ');
        else
            cuetrial=0;
        end
        
        %distidx=targidx+1;
        %if distidx > tonecount,
        %   distidx=1;
        %end
        
        stimpattern=0;
        
        %%
        %% construct tone vector
        %%
        cuestim=[];
        cuetime=0;
        switch stimpattern,
            case 0,
                disp(['target: ' tstring{targidx}]);
                thisstim=[cuestim;  tones(:,targidx)];
                targtime=cuetime;
            case 1,
                disp(['trial fmt: ' tstring{targidx} tstring{distidx} tstring{targidx}]);
                thisstim=[cuestim; tones(:,distidx); gap; tones(:,targidx)];
                targtime=cuetime+params.dur+thistype;
            case 2,
                disp(['trial fmt: ' tstring{targidx} tstring{targidx} tstring{distidx}]);
                thisstim=[cuestim; tones(:,targidx); gap; tones(:,distidx)];
                targtime=cuetime+params.dur;
        end
        
        % figure out valid lick period. 
        % negative lickstarts are offset after trial starts 
        % positive lickstarts are offset after target appears
        if params.startwin<0,
            lickstart=-params.startwin;
            lickstop=length(thisstim)./fs+params.respwin;
        else
            lickstart=targtime+params.startwin;
            lickstop=lickstart+params.respwin;
        end
        triallen=max([lickstop length(thisstim)./fs]);
        fprintf('valid lick range: %.2f - %.2f sec; totlen=%.2f\n',...
            lickstart,lickstop,triallen);
        
        % pre-trial: wait til animal hasn't licked for params.nolick sec
        fprintf('waiting for no lick ');
        if params.TESTMODE,
            %disp('reseting lick to 0');
            iolick(DAQ,0);
        end
        
        % require at least 0.05 sec no lick
        nolicktime=0;
        while nolicktime<0.05 | nolicktime>2,
            %nolicktime=params.nolick+randn*params.nolickstd;
            nolicktime=params.nolick+random('exp',params.nolickstd);
        end
        fprintf('nolicktime=%.2f sec\n',nolicktime);
        
        % set variables for recording behavior
        set(fh,'Userdata',[]);    % clear keyboard buffer
        stopnow=0;
        berror=[];  % outcome undefined
        bstat=[];    % matrix to record behavioral data
        trialover=0;
        
        evcount=evcount+1;
        summ.events(evcount).trial=count;
        summ.events(evcount).time=etime(clock,taskstarttime);
        summ.events(evcount).note='TRIALSTART';
        
        touch=1;
        if cuetrial,
            nlt=nolicktime;
        else
            nlt=0.2;
        end
        while touch,
            % silence during no-lick
            prestat=wait_get_bstat(DAQ,prestat,bstep,prestart,0.01);
            
            prelen=size(prestat,1);
            if prelen>=round(summ.bfs*nlt),
                touch=sum(prestat((prelen-round(summ.bfs*nlt-1)):prelen,2))>0;
            end
            
            if prelen/summ.bfs>15,
                touch=0;
                disp(' * too much pre-licking');
                berror=3;  % impatience error
                trialover=1;
            end
        end
        if ~cuetrial,
            % minimum nolick time has passed. now start playing tones
            touch=1;
            nlt=nolicktime-0.2;
            while touch,
                % pick a non-target tone
                toneidx=ceil(rand*(tonecount-1));
                if toneidx>=targidx,
                    toneidx=toneidx+1;
                end
                fprintf('%s',tstring{toneidx});
                tt=iosoundstart(DAQ,tones(:,toneidx),fs);
                evcount=evcount+1;
                summ.events(evcount).trial=count;
                summ.events(evcount).time=etime(tt,taskstarttime);
                summ.events(evcount).note=tstring{toneidx};
                prestat=wait_get_bstat(DAQ,prestat,bstep,prestart,params.dur+params.gapdur);
                iosoundstop(DAQ);
                
                prelen=size(prestat,1);
                if prelen>=round(summ.bfs*nlt),
                    touch=sum(prestat((prelen-round(summ.bfs*nlt-1)):prelen,2))>0;
                end
                
                if prelen/summ.bfs>15,
                    touch=0;
                    disp(' * too much pre-licking');
                    berror=3;  % impatience error
                    trialover=1;
                end
            end
        end
        
        if ~trialover,
            % start playing sound
            %disp('debug: starting sound');
            fprintf('*%s*',tstring{targidx});
            tt=iosoundstart(DAQ,thisstim,fs);
            evcount=evcount+1;
            summ.events(evcount).trial=count;
            summ.events(evcount).time=etime(tt,taskstarttime);
            summ.events(evcount).note=tstring{targidx}; %['*' tstring{targidx} '*'];
        end
        
        %disp('debug: starting waitloop');
        timesincestart=0;
        tstart=clock;
        lastdstart=0;
        touch=0;
        while timesincestart<triallen & ~trialover,
            
            bstat=wait_get_bstat(DAQ,bstat,bstep,tstart,0.03);
            timesincestart=etime(clock,tstart);
            
            if size(bstat,1)>0,
                touch=sum(bstat(:,2))>0;
            end
            %if params.format==3 & timesincestart>targtime+params.dur & ...
            %        timesincestart>lastdstart+params.distdur+params.gapdur,
             if ~cuetrial & timesincestart>targtime+params.dur & ...
                    timesincestart>lastdstart+params.dur+params.gapdur,
                iosoundstop(DAQ);
                toneidx=ceil(rand*(tonecount-1));
                if toneidx>=targidx,
                    toneidx=toneidx+1;
                end
                fprintf('%s',tstring{toneidx});
                tt=iosoundstart(DAQ,tones(:,toneidx),fs);
                evcount=evcount+1;
                summ.events(evcount).trial=count;
                summ.events(evcount).time=etime(tt,taskstarttime);
                summ.events(evcount).note=tstring{toneidx};
                lastdstart=timesincestart;
            end
            
            if touch,
                trialover=1;
                
                licktime=min(find(bstat(:,2))).*bstep;
                if licktime>lickstart & licktime<=lickstop,
                    berror=0;
                    disp(' * correct!');
                    evcount=evcount+1;
                    summ.events(evcount).trial=count;
                    summ.events(evcount).time=etime(clock,taskstarttime);
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
            tt=iosoundstart(DAQ,punishsound,fs);
            evcount=evcount+1;
            summ.events(evcount).trial=count;
            summ.events(evcount).time=etime(tt,taskstarttime);
            if berror==2,
                summ.events(evcount).note='MISS';
            else
                summ.events(evcount).note='EARLY';
            end
            
            fprintf('timeout: %.1f sec\n',params.timeout);
            bstat=wait_get_bstat(DAQ,bstat,bstep,tstart,params.timeout);
            iosoundstop(DAQ);              % make sure sound is stopped
        end
        
        tlick=(-length(prestat):(length(bstat)-1))./summ.bfs;
        lick=[prestat(:,2); bstat(:,2); zeros(summ.bfs*ttlsec,1)];
        targtime=evtimes(summ.events,tstring{targidx},count);
        for ii=1:tonecount,
            tt=evtimes(summ.events,tstring{ii},count)-targtime;
            for jj=1:length(tt),
                sbin=min(find(tlick>tt(jj)));
                tonetriglick(:,ii,targidx)=tonetriglick(:,ii,targidx)+lick(sbin:sbin+summ.bfs*ttlsec-1);
            end
            ttlcount(ii,targidx)=ttlcount(ii,targidx)+length(tt);
        end
        summ.tonetriglick=tonetriglick;
        summ.ttlcount=ttlcount;
        
        % accumulate behavioral data and stats
        presamp=params.presec*summ.bfs;
        prelen=size(prestat,1);
        if prelen < presamp,
            prestat=[ones(presamp-prelen,size(prestat,2)); prestat];
        else
            prestat=prestat((end-presamp+1):end,:);
        end
        
        summ.res=[summ.res; nolicktime berror lickstart lickstop stimpattern];
        summ.tt=(1:length(bstat))'./summ.bfs-params.presec;
        if count==1,
            summ.bstat=bstat;
        elseif size(bstat,1)>size(summ.bstat,1),
            summ.bstat(size(summ.bstat,1)+1:size(bstat,1),:,:)=nan;
            summ.bstat(:,:,count)=bstat;
        else
            summ.bstat(:,:,count)=nan;
            summ.bstat(1:size(bstat,1),:,count)=bstat;
        end
        summ.tt=(1:size(summ.bstat,1))'./summ.bfs-params.presec;
        
        % plot some results
        %figure(1);
        subplot(tonecount+2,1,1);
        cla
        bstat=[prestat;bstat];
        plot((1:length(bstat))'./summ.bfs-params.presec,bstat(:,1)+2.2);
        hold on
        plot((1:length(bstat))'./summ.bfs-params.presec,bstat(:,2)+1.1,'g');
        plot((1:length(bstat))'./summ.bfs-params.presec,bstat(:,3),'r');
        plot([lickstart lickstart],[0 3.2],'k--');
        plot([lickstop lickstop],[0 3.2],'k--');
        hold off
        axis([-params.presec-0.1 max([length(bstat)./summ.bfs lickstop+0.1]) -0.1 3.3]);
        xlabel('time from sound onset (sec)');
        title(sprintf('trial %d - error=%d',count,berror));
        legend('light','lick','pump');
        
        subplot(tonecount+2,1,2);
        cc=cumsum(summ.res(:,2)==0)./(1:length(summ.res(:,2)))';
        Navg=10;
        cc2=conv((summ.res(:,2)==0),ones(Navg,1)./Navg);
        cc2=cc2(1:end-Navg+1);
        
        plot(cc);
        hold on
        plot(cc2,'g');
        hold off
        xlabel('trial');
        legend('cum corr','mvg avg',2);
        drawnow
        
        pcol={'b','r'};
        for ii=1:tonecount,
            subplot(tonecount+2,1,ii+2);
            for jj=1:2,
                if ttlcount(ii,jj)>0,
                    plot((1:length(tonetriglick))./summ.bfs,tonetriglick(:,ii,jj)./ttlcount(ii,jj),pcol{jj});
                    hold on
                end
            end
            hold off
            axis([0 (length(tonetriglick)+1)./summ.bfs -0.1 1.1]);
            ylabel(tstring{ii});
            if ii==1,
                %title('tone-triggered lickfrac');
            end
            if ii<tonecount,
                set(gca,'XTickLabel',[]);
            end
        end
        xlabel('time after tone (s)');
        
        % text results
        fprintf('Performance: correct,early,miss,olick / total: %d,%d,%d,%d / %d\n',...
                hist(summ.res(:,2),0:3),length(summ.res));
        fprintf('** End trial %d **\n\n', count);
        
        
        % stop if animal is on a bad streak
        if length(cc2)>=Navg & cc2(end)==0,
            fprintf('missed last %d trials. stopping.\n',Navg);
            stopnow=1;
        end
        
        if ~stopnow & mod(count,params.N)~=0,
            % pause for isi before next trial
            fprintf('isi=%.1f\n',params.isi);
            prestart=clock;
            prestat=[];
            prestat=wait_get_bstat(DAQ,prestat,bstep,prestart,params.isi);
        else
            disp('-----------------------------');
            ccount=sum(summ.res(:,2)==0);
            summ.volreward=ccount*params.volpersec*params.rwdur;
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
            prestat=[];
            prestart=clock;
        end
    end
    
    iocleanup(DAQ);
    error(['error: ',lasterr]);
end

iocleanup(DAQ);
