% function [spkraw,extras]=loadevp(parfile,evpfile,chanNum,sigthresh,fixedsigma);
%
% created SVD 9/13/05 - ripped out of dbmeska, added old file
%                       compatibility
% mod SVD 1/19/07 - added sigthresh option to speed up loading!
% mod SVD 2009-06-01 - added fixed sigma option
%
function [spkraw,extras]=loadevp(parfile,evpfile,chanNum,sigthresh,fixedsigma);

if ~exist('sigthresh','var')       sigthresh=0;   end
if ~exist('fixedsigma','var')    fixedsigma=0; end

extras=[];
[fname,EXPERIMENT_DIR]=basename(parfile);

[pp,bb,ee]=fileparts(evpfile);
bbpref=strsep(bb,'_');
bbpref=bbpref{1};
checkrawevp=[pp filesep 'raw' filesep bb '.001.1' ee];
if exist(checkrawevp,'file')   evpfile=checkrawevp;  end
checktgzevp=[pp filesep 'raw' filesep bbpref '.tgz'];
if exist(checktgzevp,'file'),
  evpfile=checktgzevp;
end

evpv=evpversion(evpfile);
fprintf('evp %s is version %d\n',basename(evpfile),evpv);

exptevents=[]; trialstartidx=[]; StimTagNames={}; refidxmap=[]; spiketimes=[];

%SVD added 9/14/05 - old par/evp file format compatibility
%Mounya modified 10/14/05
switch evpv
  case 1
    %if any(strfind(parfile,'.par'))
    % Old file format
    % read the parameters for old file format
    paramdata = paramsfromfile(parfile);
    stimorder = getfieldvec(paramdata,'random_array');
    stonset = getfieldval(paramdata,'stim_onset');
    stdur = getfieldval(paramdata,'stim_duration');
    datadur = getfieldval(paramdata,'data_dur');
    lfreq = getfieldval(paramdata,'lower_freq')*1000;
    
    
    stimdur = datadur/1000;
    delay = datadur-stonset-stdur;
    if delay<0,
        delay=0;
    end
    af=1;bf=datadur;
    sampfreq = getfieldval(paramdata,'mult_fact')*1000;
    rate = sampfreq;
    sweeps = getfieldval(paramdata,'num_swps');
    records = getfieldval(paramdata,'Records');
    npoint= round(datadur*sampfreq/1000);
    datatotal = round(npoint*sweeps*records);
    units= 1;
    dataget = round(npoint*sweeps);
    numChannels=1; % did we ever get 2-channel data in the old format?
    
    spktimeoffset=stonset/1000*sampfreq;
    
    % mimic new version output
    if ~isempty(findstr(parfile,'tor')),
        % extra junk to make strf work
        inffile = getfieldstr(paramdata,'inf_file');
        
        [wfmTotal,a1s_freqs,a1infodata,speechwfm]=geta1info([EXPERIMENT_DIR inffile]);
        
        stimparam.ba = geta1val(a1infodata,'Base Amplitude');
        stimparam.v = geta1val(a1infodata,'Voltage at 50dB');
        stimparam.fs = geta1val(a1infodata,'Sampling frequency');
        stimparam.rp = geta1val(a1infodata,'Ripple peak');
        stimparam.nc = geta1val(a1infodata,'Number of components');
        stimparam.chs = geta1val(a1infodata,'Components harmonically spaced');
        stimparam.hs = geta1val(a1infodata,'Harmonic spacing');
        stimparam.spd = geta1val(a1infodata,'Spectral Power Decay');
        stimparam.crp = geta1val(a1infodata,'Components random phase');
        stimparam.td = geta1val(a1infodata,'Time duration');
        stimparam.a1am = geta1vec(a1infodata,'Ripple amplitudes');
        stimparam.a1rf = geta1vec(a1infodata,'Ripple frequencies');
        stimparam.a1ph = geta1vec(a1infodata,'Ripple phase shifts');
        stimparam.a1rv = geta1vec(a1infodata,'Angular frequencies');
        stimparam.lfreq = getfieldval(paramdata,'lower_freq')*1000;
        stimparam.hfreq = getfieldval(paramdata,'upper_freq')*1000;
        stimparam.numrecs = getfieldval(paramdata,'Records');
        stimparam.sample_freq=getfieldval(paramdata,'sample_freq');
        if stimparam.lfreq==125,
            TorcFreqRange='l';
        elseif stimparam.lfreq==250,
            TorcFreqRange='h';
        else
            TorcFreqRange='v';
        end
        
        torcList.type = 'tor';
        torcList.tag = tagid;
        torcList.tag = set(torcList.tag,...
            'Frequency',TorcFreqRange,...
            'Index', getfieldval(paramdata,'Records'),...
            'Onset',stonset/1000 ,...
            'Delay',delay/1000 ,...
            'Duration', datadur/1000,...
            'SamplingRate',getfieldval(paramdata,'sample_freq') );
       
        for recidx=1:get(torcList.tag,'Index'),
            torcList.handle(recidx)=tagid;
            
            torcList.handle(recidx) = set(torcList.handle(recidx),...
                'Ripple peak',90 ,...
                'Lower frequency component',stimparam.lfreq,...
                'Upper frequency component',stimparam.hfreq,...
                'Number of components',stimparam.nc(recidx) ,...
                'Components harmonically spaced',stimparam.chs(recidx) ,...
                'Harmonic spacing',stimparam.hs(recidx) ,...
                'Spectral Power Decay',stimparam.spd(recidx),...
                'Components random phase',stimparam.crp(recidx) ,...
                'Ripple amplitudes',stimparam.a1am{recidx},...
                'Ripple frequencies',stimparam.a1rf{recidx},...
                'Ripple phase shifts',stimparam.a1ph{recidx},...
                'Angular frequencies',stimparam.a1rv{recidx},...
                'Filename','TORC_XX_v501.wfm',...
                'Filetype','bin',...
                'Fileformat','float',...
                'Lower frequency component.unit','Hz',...
                'Upper frequency component.unit','Hz',...
                'Harmonic spacing.unit','Hz',...
                'Spectral Power Decay.unit','dB/octave',...
                'Ripple frequencies.unit','cyc/oct',...
                'Ripple phase shifts.unit','deg',...
                'Angular frequencies.unit','Hz');
        end
    else
        torcList.type = 'unknown';
        torcList.tag = tagid;
        torcList.tag = set(torcList.tag,...
            'Frequency','l',...
            'Index', getfieldval(paramdata,'Records'),...
            'Onset',stonset/1000 ,...
            'Delay',delay/1000 ,...
            'Duration', datadur/1000,...
            'SamplingRate',-10000 );
    end
    
    expData = tagid;
    expData = set(expData,...
        'Experiment',getfieldstr(paramdata,'File'),...
        'Version', getfieldval(paramdata,'nsl_fea_version'),...
        'Ferret','unknown',...
        'StartTime',getfieldstr(paramdata,'Date'),...
        'StopTime','unknown',...
        'AcqSamplingFreq',sampfreq ,...
        'StimSamplingFreq', getfieldval(paramdata,'sample_freq'),...
        'SequenceType','unknown',...
        'Repetitions',getfieldval(paramdata,'num_swps') ,...
        'OveralldB',-75 ,...
        'FilterLow',-120 ,...
        'FilterHigh',-4000 ,...
        'electrodes',1 ,...
        'TrialsPlayed',-180 );
    
    playOrder=getfieldvec(paramdata,'random_array');
    
    disp('Reading...')
    clear spkraw % memory
    fid = fopen(evpfile,'rb','b');
    spkraw = fread(fid,'int16');
    fclose(fid);
    
  case 2
    % new file format
    %af = 1+onset*1000;
    %bf = (datadur-delay)*1000;
    
    addpath(EXPERIMENT_DIR);
    
    stmtinit = ([ 'expData = ' fname '(''init'');']);eval(stmtinit);
    stmtlist = ([ 'torcList = ' fname '(''reference'');']);eval(stmtlist);
    stmtplay = ([ 'playorder = ' fname '(''playorder'');']);eval(stmtplay);
    
    torcListtag= torcList.tag;
    t1handle = torcList.handle(1);
    
    %%%%%%%%%
    sweeps = get(expData,'Repetitions');
    records= get(torcListtag,'index');
    stonset = get(torcListtag, 'Onset');
    stdur = get(torcListtag, 'Duration');
    rate = get(expData, 'AcqSamplingFreq');
    try
        hfreq = get(t1handle,'Lower frequency component');
    catch
    end
    delay = get(torcListtag,'Delay');
    
    % Begin changes to open streaming files 04/21/2005 Serin Atiani
    if (strcmpi(lower(torcList.type),'complexaba') | ...
            strcmpi(lower(torcList.type),'streamAB')),
        REGORDER1= 1;
        abastimdur=[];
        astimdur=[];
        tarlength=[];
        for i = 1:length(torcList.handle)
            astimdur(i)=get(torcList.handle(i),'Reference Stimulus Duration');
            tarlength(i)=get(torcList.handle(i),'Target Length')
            abastimdur(i)=astimdur(i)-tarlength(i);
        end
        playOrder= playorder;
        playOrder(2,find(playorder(2,:)>records))= playorder(2,find(playorder(2,:)>records))-records;
        playOrder(1,find(playorder(1,:)==2))=1;
        
        % dist = get(torcListtag, 'DistractorPerSig');
        % sigCount= dist+1;
        % refCount= get(torcListtag, 'RefStimCount');
        % tarCount= get(torcListtag, 'TarCount');
        % tonedur= get(torcListtag, 'ToneDur');
        % gapdur= get(torcListtag, 'GapDur');
        % expdur= sum((((refCount+tarCount).*sigCount).*(tonedur+gapdur))+stonset+delay);
        expdur= sum(abastimdur+stonset);
        npoint= (abastimdur+stonset)*rate;
        datatotal= round(expdur*sweeps*rate);
        dataget= round(expdur*sweeps*rate);
        
    else
        REGORDER1= 0;
        playOrder= playorder;
        ddur = stonset+stdur+delay;
        npoint =round(ddur*rate)
        dataget = round(npoint*sweeps)
        datatotal = round(npoint*sweeps*records)
    end %end changes
    
    disp('Reading...')
    clear spkraw % memory
    
    fid = fopen(evpfile,'r','b');
    
    numChannels = fread(fid,1,'int');
    if str2num(chanNum)<=numChannels,
        fseek(fid,(str2num(chanNum)-1)*4,0);
        doffset = fread(fid, 1, 'long');
        fseek (fid,doffset,-1);
        spkraw = fread(fid,datatotal,'short');
        fclose(fid);
    else
        error(['Channel number entered exceeds the number of channels saved',...
               ' in this file. Data from first file NOT read']);
    end;
    spktimeoffset=0;
    
  case {3 4 5}
    % baphy version!!!! 
    LoadMFile(parfile);
    StimTagNames=exptparams.TrialObject.ReferenceHandle.Names;
    if isfield(exptparams,'TrialObject'),
        if isfield(exptparams.TrialObject,'Torchandle'),
            TorcObject=exptparams.TrialObject.Torchandle;
        else
            TorcObject=exptparams.TrialObject.ReferenceHandle;
        end
    else
        TorcObject=[];
    end
    
    [spikechancount,auxchancount,trialcount,spikefs,auxfs]=...
        evpgetinfo(evpfile);
    
    if exptevents(end).Trial<trialcount,
        disp('mismatch in evp trial count and mfile trial count.');
        disp('likely baphy crashed and lost last partial repetition.');
        trialcount=exptevents(end).Trial;
    end
    
    % define output raster matrix
    trialstartidx=ones(trialcount,1);
    spkraw=[];
    % playOrder is trivially the same as the order of trials in spkraw
    playOrder=[ones(1,trialcount); 1:trialcount];
    
    % figure out the time that each trial started and stopped
    [starttimes,starttrials]=evtimes(exptevents,'TRIALSTART');
    [ontimes,ontrials]=evtimes(exptevents,'STIM,ON');
    [stoptimes,stoptrials]=evtimes(exptevents,'TRIALSTOP');
    [shockstart,shocktrials,shnote,shockstop]=evtimes(exptevents,'BEHAVIOR,SHOCKON');
    [hittime,hittrials]=evtimes(exptevents,'OUTCOME,MATCH');
    if length(hittrials)==0,
        hittrials=1:trialcount;
    else
        hittrials=hittrials(:)';
    end
    
    disp(['need to confirm that starttimes/ontime correction is valid' ...
          ' for all data sets']);
    %keyboard
    
    if sigthresh
       cachefile=cacheevpspikes(evpfile,str2num(chanNum),sigthresh,...
                                0,fixedsigma);
       big_rs=load(cachefile);
       
       spkraw=[];
       for trialidx=1:trialcount,
       
          thistrialidx=find(big_rs.trialid==trialidx);
          spikeevents=big_rs.spikebin(thistrialidx);
          
          shockhappened=find(shocktrials==trialidx);
          if ~isempty(shockhappened),
             fprintf('%d: Removing shock period\n',trialidx);
             goodspikes=...
                 find(spikeevents<shockstart(shockhappened(1))*spikefs | ...
                      spikeevents>shockstop(shockhappened(end))*spikefs);
             spikeevents=spikeevents(goodspikes);
             thistrialidx=thistrialidx(goodspikes);
          end
          
          %hithappened=find(hittrials==trialidx);
          %if ~isempty(hittime),
          %   disp('Removing reward period');
          %   spikeevents=spikeevents(hittime(hithappened(1))*spikefs);
          %end
          
          starttime=starttimes(find(starttrials==trialidx));
          stoptime=min(stoptimes(find(stoptrials==trialidx)));
          expectedspikebins=round((stoptime-starttime)*spikefs);
          if max(spikeevents)>expectedspikebins,
             fprintf('%d: Trimming stray spikes at end of trial\n',trialidx);
             goodspikes=find(spikeevents<=expectedspikebins);
             spikeevents=spikeevents(goodspikes);
             thistrialidx=thistrialidx(goodspikes);
          end
          
          trialstartidx(trialidx+1)=trialstartidx(trialidx)+expectedspikebins;
          
          bb=basename(parfile);
          if (strcmp(bb(1:3),'lim') || strcmp(bb(1:3),'dnb') ||...
                strcmp(bb(1:3),'ama')) && ~isempty(ontimes) && ...
                ontimes(trialidx)>starttimes(trialidx),
             disp('Shifting spike times by ontimes-starttimes');
             spikeevents=spikeevents+round(spikefs.*(ontimes(trialidx)-starttimes(trialidx)));
          end
          
          spkraw=cat(2,spkraw,big_rs.spikematrix(:,thistrialidx));
          spiketimes=[spiketimes;spikeevents+trialstartidx(trialidx)-1];
       end
       npoint=trialstartidx(end)-1;
       dataget = trialstartidx(end)-1;
       datatotal= trialstartidx(end)-1;
    else
    
       big_rs=[];
       for trialidx=1:trialcount,
          starttime=starttimes(find(starttrials==trialidx));
          stoptime=stoptimes(find(stoptrials==trialidx));
          expectedspikebins=round((stoptime-starttime)*spikefs);
          
          if isempty(big_rs) | length(strialidx)<=trialidx,
             [big_rs,strialidx]=evpread(evpfile,str2num(chanNum),[],trialidx:min([trialidx+49 trialcount]));
             strialidx=[zeros(trialidx-1,1); strialidx; length(big_rs)+1];
          end
          
          rs=big_rs(strialidx(trialidx):(strialidx(trialidx+1)-1));
          %rs=evpread(evpfile,str2num(chanNum),[],trialidx);
          if length(rs)<expectedspikebins,
             warning(['trial ' num2str(trialidx) ...
                      ': length(rs)<expectedspikebins! padding tail with zeros.']);
             rs((length(rs)+1):expectedspikebins)=0;
             rs=rs(:);
          else
             % otherwise, trim off any extra junk from end of trial
             rs=rs(1:expectedspikebins);
          end
          
          % remove shock period to avoid bias in sigma calculation
          shockhappened=find(shocktrials==trialidx);
          if ~isempty(shockhappened) & length(rs)>ceil(shockstart(shockhappened(1)).*spikefs),
             disp('Removing shock period');
             rs=rs(1:ceil(shockstart(shockhappened(1))*spikefs));
          end
          
          trialstartidx(trialidx)=length(spkraw)+1;
          if ismember(trialidx,hittrials),
             spkraw=cat(1,spkraw,rs);
          else
             spkraw=cat(1,spkraw,zeros(100,1));
             
          end
          
          drawnow;
       end
       npoint=size(spkraw,1);
       dataget = length(spkraw);
       datatotal= length(spkraw);
    end
    
    rate = spikefs;
    records=1;
    sweeps=1;
    
    if ~isempty(TorcObject) &  ...
        (strcmpi(TorcObject.descriptor,'torc') | ...
        strcmpi(TorcObject.descriptor,'amtorc') | ...
        strcmpi(TorcObject.descriptor,'clickdiscrim')),
        
        %%% TORCS are special, prepare extra variables.  
        % BUT DON'T REORDER!!!! (SVD 2006-07-28)
        tags=evunique(exptevents,['PreStim*']);
        
        fprintf('channel: %s  trials: %d  tags: %d\n',chanNum,trialcount,length(tags));
        
        tgoodidx=zeros(size(tags));
        for ii=1:length(tags),
            b=strsep(tags{ii},',',1);
            if isempty(findstr(b{2},'StimSilence')) & ...
                    isempty(findstr(b{3},'Target')),
                tgoodidx(ii)=1;
            end
        end
        tags={tags{find(tgoodidx)}};
        [eventtime,evtrials,Note]=evtimes(exptevents,['PreStim*']);
        for trialidx=1:trialcount,
            evidxthistrial=find(evtrials==trialidx);
            for evidx=evidxthistrial(:)',
                
                refidx=find(strcmp(tags,Note{evidx}));
                if length(refidx)>0,
                    refidxmap=[refidxmap;
                        refidx trialstartidx(trialidx)+eventtime(evidx)];
                end
            end
        end

        % OLD REORDERING CODE. THIS IS NOW TAKEN CARE OF BY
        % LOADSPIKERASTER.M!!!!
        if 0,
            referencecount=length(tags);
            repcount=exptparams.Repetition;

            % define output raster matrix
            spkraw=nan*zeros(1,1,referencecount);
            playOrder=[];

            % figure out the time that each trial started and stopped
            [starttimes,starttrials]=evtimes(exptevents,'TRIALSTART');
            [stoptimes,stoptrials]=evtimes(exptevents,'TRIALSTOP');
            [eventtime,evtrials,Note]=evtimes(exptevents,['PreStim*']);
            [xx,yy,zz,eventtimeoff]=evtimes(exptevents,['PostStim*']);

            for trialidx=1:trialcount,
                starttime=starttimes(find(starttrials==trialidx));
                stoptime=stoptimes(find(stoptrials==trialidx));
                expectedspikebins=(stoptime-starttime)*spikefs;

                rs=evpread(evpfile,str2num(chanNum),[],trialidx);

                if length(rs)<expectedspikebins,
                    warning(['trial ' num2str(trialidx) ...
                        ': length(rs)<expectedspikebins! padding tail with zeros.']);
                    rs((length(rs)+1):expectedspikebins)=0;
                end

                evidxthistrial=find(evtrials==trialidx);
                for evidx=evidxthistrial,

                    refidx=find(strcmp(tags,Note{evidx}));
                    if ~isempty(refidx),
                        playOrder=[playOrder [1;refidx]];
                        repidx=min(find(isnan(spkraw(1,:,refidx))));
                        if isempty(repidx),
                            %warning('repcount exceeds value specified in exptparams!');
                            repidx=size(spkraw,2)+1;
                        end
                        rlen=(eventtimeoff(evidx)-eventtime(evidx))*spikefs;
                        if size(spkraw,1)<rlen | repidx>size(spkraw,2) | refidx>size(spkraw,3),
                            spkraw((size(spkraw,1)+1):round(rlen),:,:)=nan;
                            spkraw(:,(size(spkraw,2)+1):repidx,:)=nan;
                        end

                        spkraw(1:round((eventtimeoff(evidx)-eventtime(evidx))*spikefs),repidx,refidx)=...
                            rs(round(eventtime(evidx)*spikefs+1):round(eventtimeoff(evidx)*spikefs));
                    end
                end
            end
            
            rate = spikefs;
            npoint=size(spkraw,1);
            sweeps=size(spkraw,2);
            
            records=length(tags);
            dataget = round(npoint*sweeps);
            datatotal= round(datadur*sweeps*spikefs);
        end
        
        % figure out stimulus timing parameters for meska:
        [eventtime,trial,Note,eventtimeoff]=evtimes(exptevents,['PreStim*'],1:10);
        stonset=eventtimeoff(1)-eventtime(1);
        [eventtime,trial,Note,eventtimeoff]=evtimes(exptevents,['Stim*'],1:10);
        stdur=eventtimeoff(1)-eventtime(1);
        [eventtime,trial,Note,eventtimeoff]=evtimes(exptevents,['PostStim*'],1:10);
        delay=eventtimeoff(1)-eventtime(1);
        datadur=stonset+stdur+delay;
        
        % mimic new version output
        torcList.type = exptparams.runclass;
        torcList.tag = tagid;
        
        thandle=TorcObject;
        if strcmpi(TorcObject.descriptor,'clickdiscrim') |...
                strcmpi(TorcObject.descriptor,'amtorc'),
            torcList.tag = set(torcList.tag,...
                'Frequency',thandle.TorcFreqRange(1),...
                'Index', thandle.MaxIndex,...
                'Onset', thandle.PreStimSilence,...
                'Delay', thandle.PostStimSilence ,...
                'Duration', thandle.TorcDuration,...
                'SamplingRate',thandle.SamplingRate);
        else
            torcList.tag = set(torcList.tag,...
                'Frequency',thandle.FrequencyRange(1),...
                'Index', thandle.MaxIndex,...
                'Onset', thandle.PreStimSilence,...
                'Delay', thandle.PostStimSilence ,...
                'Duration', thandle.Duration,...
                'SamplingRate',thandle.SamplingRate);
        end
        
        for recidx=1:thandle.MaxIndex,
            torcList.handle(recidx)=tagid;
            
            torcList.handle(recidx) = set(torcList.handle(recidx),...
                'Ripple peak',90 ,...
                'Lower frequency component',thandle.Params(recidx).LowestFrequency ,...
                'Upper frequency component',thandle.Params(recidx).HighestFrequency ,...
                'Number of components',thandle.Params(recidx).NumberOfComponents ,...
                'Components harmonically spaced',thandle.Params(recidx).HarmonicallySpaced ,...
                'Harmonic spacing',thandle.Params(recidx).HarmonicSpacing ,...
                'Spectral Power Decay',thandle.Params(recidx).SpectralPowerDecay,...
                'Components random phase',thandle.Params(recidx).ComponentRandomPhase ,...
                'Ripple amplitudes',thandle.Params(recidx).RippleAmplitude,...
                'Ripple frequencies',thandle.Params(recidx).Scales,...
                'Ripple phase shifts',thandle.Params(recidx).Phase,...
                'Angular frequencies',thandle.Params(recidx).Rates,...
                'Filename','TORC_XX_v501.wfm',...
                'Filetype','bin',...
                'Fileformat','float',...
                'Lower frequency component.unit','Hz',...
                'Upper frequency component.unit','Hz',...
                'Harmonic spacing.unit','Hz',...
                'Spectral Power Decay.unit','dB/octave',...
                'Ripple frequencies.unit','cyc/oct',...
                'Ripple phase shifts.unit','deg',...
                'Angular frequencies.unit','Hz');
        end
        
    else
        % non-TORCs don't get special TORC structure.  Mimic some of them
        % to make meska happy.
        stonset=0;
        stdur=stoptime-starttime;
        delay=0;
        datadur=stonset+stdur+delay;
        
        % mimic daqpc output
        torcList.type = exptparams.runclass;
        torcList.tag = tagid;
        
        thandle=exptparams.TrialObject.ReferenceHandle;
        if isfield(thandle,'Duration'),
            tdur=thandle.Duration;
        else
            tdur=0;
        end
        torcList.tag = set(torcList.tag,...
            'Frequency','h',...
            'Index', thandle.MaxIndex,...
            'Onset', thandle.PreStimSilence,...
            'Delay', thandle.PostStimSilence ,...
            'Duration', tdur,...
            'SamplingRate',thandle.SamplingRate);
    end       
    
    expData = tagid;
    bb=strsep(basename(parfile),'.');
    bb=bb{1};
    expData = set(expData,...
        'Experiment',bb,...
        'Version', evpv,...
        'Ferret',globalparams.Ferret,...
        'StartTime',globalparams.date,...
        'StopTime','unknown',...
        'AcqSamplingFreq',spikefs ,...
        'StimSamplingFreq', -10000,...
        'SequenceType','unknown',...
        'Repetitions',sweeps ,...
        'OveralldB',-75 ,...
        'FilterLow',-120 ,...
        'FilterHigh',-4000 ,...
        'electrodes',globalparams.NumberOfElectrodes ,...
        'TrialsPlayed',trialcount );
    
    numChannels=globalparams.NumberOfElectrodes;
    
    if ~sigthresh,
       % reshape raw signal matrix for processing by meska
       spkraw=spkraw(:);
       spkraw(find(isnan(spkraw)))=0;
    end
    
    % baphy data: don't need to pad with any zeros
    spktimeoffset=0;
  otherwise
    error('unknown evp version.');
end

if evpv>=3,
  disp('filtering disabled (already done by A-O or evpread(5))');
else
  % Bandpass filtering
  f1 = 310;
  f2 = 8000;
  fprintf('Bandpass filtering raw signal: rate=%d  f1=%.0f  f2=%.0f...\n',rate,f1,f2)
  f1 = f1/rate*2;
  f2 = f2/rate*2;
  [b,a] = ellip(4,.5,20,[f1 f2]);
end

STOP = 0; % Bandstop filtering
if STOP,
    s1 = 930, s2 = 950,
    s1 = s1/rate*2; s2 = s2/rate*2;
    [bs,as] = ellip(4,.5,20,[s1 s2],'stop');
end

sigma = 0;
if fixedsigma,
   sigma=fixedsigma;
elseif evpv>=3 & sigthresh,
   % do nothing. sigmas have already been calculated
   sigma=big_rs.sigma;
   
elseif strcmpi(lower(torcList.type),'complexaba') | ...
        strcmpi(lower(torcList.type),'streamAB')
   if evpv<3,
      spkraw= filtfilt(b,a,spkraw);
   end
   
   sigma= std(spkraw);
elseif length(trialstartidx)>0,
    trialcount=length(trialstartidx);
    for rec=1:trialcount,
        ss=trialstartidx(rec);
        if rec==trialcount,
            ee=length(spkraw);
        else
            ee=trialstartidx(rec+1)-1;
        end
        if evpv<3,
           spkraw(ss:ee) = filtfilt(b,a,spkraw(ss:ee));
        end
        sigma = sigma + std(spkraw(ss:ee));
    end
    sigma = sigma/trialcount;
else
   % does this code ever execute?
   for rec = 1:records,
      if evpv<3,
         spkraw(dataget*(rec-1)+1:dataget*rec) = ...
             filtfilt(b,a,spkraw(dataget*(rec-1)+1:dataget*rec));
      end
        if STOP,
           spkraw(dataget*(rec-1)+1:dataget*rec) = ...
               filtfilt(bs,as,spkraw(dataget*(rec-1)+1:dataget*rec));
        end
        sigma = sigma + std(spkraw(dataget*(rec-1)+1:dataget*rec));
   end
   %sigma = std(spkraw(1:end));
   sigma = sigma/records;
end

% add a bunch of zeros at the begining of old-format files so that
% times match spike times from new files.
if ~sigthresh & spktimeoffset>0,
   fprintf('adding offset zeros: %d\n',spktimeoffset);
   spkraw=reshape(spkraw,npoint,sweeps*records);
   spkraw=cat(1,zeros(spktimeoffset,sweeps*records),spkraw);
   
   npoint= round(datadur*sampfreq/1000)+spktimeoffset;
   datatotal = round(npoint*sweeps*records);
   dataget = round(npoint*sweeps);
   
   spkraw=spkraw(:);
elseif spktimeoffset>0,
   disp('need to deal with offset zeros for sigthresh~=0');
   keyboard
end

% Determine the min and max voltage
extras.sweeps=sweeps;
extras.records=records;
extras.npoint=npoint;
extras.dataget=dataget;
extras.sigma=sigma;
extras.spkmin=min(spkraw);
extras.spkmax=max(spkraw);
extras.playOrder=playOrder;
extras.refidxmap=refidxmap;
extras.expData=expData; 
extras.torcList=torcList;
extras.rate = rate;
extras.stonset = stonset;
extras.stdur = stdur;
extras.numChannels=numChannels;
extras.exptevents=exptevents;
extras.StimTagNames=StimTagNames;
extras.trialstartidx=trialstartidx;
extras.chanNum=chanNum;
extras.tolerance=0.75;
extras.spiketimes=spiketimes;
extras.evpv=evpv;
fprintf('sweeps: %d records: %d datatotal: %d length(spkraw)=%d\n',...
    sweeps,records,datatotal,length(spkraw));

