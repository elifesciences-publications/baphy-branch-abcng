function [eventtime,evtrials,Note,eventtimeoff,tags]= ...
        loadeventfinder(exptevents,tag_masks,includeprestim,runclass,evpfile);
    
% figure out the tag for each different stimulus
repcounter=1;
if ~isempty(tag_masks) && length(tag_masks{1})>=12 && ...
        strcmp(tag_masks{1}(1:12),'SPECIAL-LICK'),
    disp('SPECIAL TAGS: Loading lick data...');
    
    [~,AuxChannelCount,trialcount,~,auxfs]=evpgetinfo(evpfile);
    if ~AuxChannelCount, % MANTA evp?
        altevp=strrep(evpfile,'/raw/','/');
        altevp=strrep(altevp,'.tgz','');
        altevp=strtrim(ls([altevp '*evp*']));
        altevp=strsep(altevp,char(10),1);
        altevp=strtrim(altevp{1});
        if ~isempty(altevp),
            evpfile=altevp;
            [~,AuxChannelCount,trialcount,~,auxfs]=evpgetinfo(evpfile);
       end
    end
    
    [~,~,lickdata,atrialidx]=evpread(evpfile,[],1);
    atrialidx=cat(1,atrialidx,length(lickdata)+1);
    
    licktotalcount=length(find(diff(lickdata)));
    if licktotalcount>500,
        disp('only using 500 licks');
    end
    
    %  [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['Stim*']);
    eventtime=[];
    evtrials=[];
    eventtimeoff=[];
    for trialidx=1:trialcount,
        lrange=atrialidx(trialidx):(atrialidx(trialidx+1)-1);
        licktime=find(diff(lickdata(lrange)))./auxfs;
        
        % remove licks too close to start of trial
        licktime=licktime(licktime>0.4);
        
        % only use last lick from each trial if requested
        if strcmp(tag_masks{1},'SPECIAL-LICK-LAST') && ~isempty(licktime),
            licktime=licktime(end);
        elseif strcmp(tag_masks{1},'SPECIAL-LICK-FIRST') && ~isempty(licktime),
            licktime=licktime(1);
        elseif length(licktime)>1 && licktotalcount>500,
            keepidx=round(linspace(1,length(licktime),...
                round(500./licktotalcount.*length(licktime))));
            licktime=licktime(keepidx);
        end
        eventtime=cat(1,eventtime,licktime-0.4);
        eventtimeoff=cat(1,eventtimeoff,licktime+0.4);
        evtrials=cat(1,evtrials,ones(size(licktime)).*trialidx);
    end
    if strcmp(tag_masks{1},'SPECIAL-LICK-LAST') && ~isempty(licktime),
        tags={'LASTLICK,LASTLICK'};
    else
        tags={'LICK,LICK'};
    end
    repcounter=length(eventtime);
    Note=cell(length(eventtime),1);
    for ii=1:length(eventtime),
        Note{ii}=tags{1};
    end
elseif ~isempty(tag_masks) && strcmp(tag_masks{1},'SPECIAL-TRIAL'),
    disp('SPECIAL TAGS: Loading trial by trial...');
    
    [eventtime,~,Note]=evtimes(exptevents,['TRIALSTART']);
    [eventtimeoff,evtrials]=evtimes(exptevents,['TRIALSTOP']);
    tags={Note{1}};
    repcounter=length(eventtime);
elseif ~isempty(tag_masks) && length(tag_masks{1})>=16 && strcmp(tag_masks{1}(1:16),'SPECIAL-COLLAPSE'),
    disp('SPECIAL TAGS: Collapsing over references and/or targets...');
    % find all events that match masks
    tm=strsep(tag_masks{1},'-',1);
    split_incorrect=0;
    
    if ~strcmpi(runclass,'SWC')
        switch tm{3},
            case 'REFERENCE',
                tags={'Reference,Reference'};
                if any(cell2mat( cellfun( @strfind,{exptevents.Note},repmat({'Light'},1,length({exptevents.Note})),'UniformOutput',false) ))
                    tags={'Reference,Light','Reference,NoLight'};
                end
            case 'TARGET',
                tags={'Target,Target'};
            case 'ORDER',
                tags={'Ref1,Ref1','RefN,RefN','Target,Target'};
            case 'SPLIT',
                tags={'Reference,Reference','Hit,Hit','Miss,Miss'};
                split_incorrect=1;
            otherwise
                tags={'Reference,Reference','Target,Target'};
        end
    else
        ShockTar = exptparams.TrialObject.ShockTar;
        if ShockTar<3
        tags={'Reference,Reference','Target,Target','Distractor,Distractor'};
        else
        tags={'Reference,Reference','Target,Target'};
        end            
    end
    
    
    % figure out when each event to be rastered started and stopped
    if sum(includeprestim)>0 & length(includeprestim)>1,
        [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['Stim*']);
        eventtime=eventtime-includeprestim(1);  % ie, minus PreStimSilence
        eventtimeoff=eventtimeoff+includeprestim(2);  % ie, plus PostStimSilence
    
        % check for discrim arrangement, ie, if every other post-stim
        % silence is zero
        [xx2,gg,hh,yy2]=evtimes(exptevents,['PostStim*']);
        dd=yy2-xx2;
        if ~isempty(findstr(hh{1},'TORC')) &&...
                (sum(dd(1:2:end)>0)==0 & sum(dd(2:2:end)==0)==0)
           eventtime=eventtime(1:2:end);
           evtrials=evtrials(1:2:end);
           eventtimeoff=eventtimeoff(2:2:end);
           Note={Note{1:2:end}};
        end
    elseif includeprestim,
        [eventtime,evtrials,Note,preoff]=evtimes(exptevents,['PreStim*']);
        [xx,yy,zz,eventtimeoff]=evtimes(exptevents,['PostStim*']);
        if isempty(eventtimeoff),
            eventtimeoff=eventtime+0.5;
        end
        if preoff(1)-eventtime(1)==0,
            disp('fixing fake prestim from 0 to 0.1');
            eventtime=eventtime-0.1;
        end
        if length(eventtimeoff)<length(eventtime),
            [xx,yy,zz,eventtimeoff]=evtimes(exptevents,['Stim*']);
        end
        
        % check for discrim arrangement, ie, if every other post-stim
        % silence is zero (special check for CLK tasks with gap by
        % simply asking if there are two targets per trial)
        tarstim=zeros(size(eventtime));
        for ii=1:length(Note),
            if ~isempty(findstr(Note{ii},'Target')),
                tarstim(ii)=1;
            end
        end
        [btar,~,jjtar]=unique(evtrials(find(tarstim)));
        dd=eventtimeoff-xx;
        if ~isempty(btar) && ( length(jjtar)==length(btar).*2 ||... 
                (sum(dd(1:2:end)>0)==0 & sum(dd(2:2:end)==0)==0) )
            % ie, two targets per trial or funny case of 0 gap
            % between pairs of stimuli
            eventtime=eventtime(1:2:end);
            evtrials=evtrials(1:2:end);
            eventtimeoff=eventtimeoff(2:2:end);
            Note={Note{1:2:end}};
        end
    else
        [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['Stim*']);
    end
    repcounter=0;
    
    keepidx=find(~strcmp(Note,'STIM,ON'));
    eventtime=eventtime(keepidx);
    evtrials=evtrials(keepidx);
    Note={Note{keepidx}};
    eventtimeoff=eventtimeoff(keepidx);
    
    
    if strcmpi(runclass,'SWC')
        TarOrDis=[];
        for cnt1 = 1:length(exptevents)
            if strcmpi(exptevents(cnt1).Note,'TRIALSTART') == 0 && ...
                    strcmpi(exptevents(cnt1).Note,'TRIALSTOP') == 0
                [Type, StimName, StimRefOrTar] = ParseStimEvent (exptevents(cnt1));
                if strcmpi(Type,'Stim');
                    if strcmpi(StimRefOrTar,'Target')
                        if ShockTar < 3
                            if exptevents(cnt1).Rove{1} == ShockTar
                                TarOrDis = [TarOrDis; 1];
                            else
                                TarOrDis = [TarOrDis; 0];
                            end
                        else
                            TarOrDis = [TarOrDis; 1];
                        end
                    elseif strcmpi(StimRefOrTar,'Reference')
                        TarOrDis = [TarOrDis; nan];
                    end
                end
            end
        end
    end
    
    
    
    for ii=1:length(eventtime),        
        if strfind(upper(Note{ii}),'TARG'),
            if split_incorrect,
                [shockstart]=evtimes(exptevents,'BEHAVIOR,SHOCKON',evtrials(ii));
                if length(shockstart)>0,
                    Note{ii}='Miss,Miss';
                else
                    Note{ii}='Hit,Hit';
                end
            else
                if ~strcmpi(runclass,'SWC')
                    Note{ii}='Target,Target';
                else                    
                    if TarOrDis(ii) == 1
                     Note{ii}='Target,Target';
                    else
                     Note{ii}='Distractor,Distractor';
                    end
                end
            end
        end
        if strfind(upper(Note{ii}),'REF'),
            if strcmpi(tm{3},'ORDER'),
                if ii==1 || evtrials(ii)>evtrials(ii-1),
                    Note{ii}='Ref1,Ref1';
                else
                    Note{ii}='RefN,RefN';
                    repcounter=repcounter+1;
                end
            else
                if ~isempty(findstr(Note{ii},'NoLight'))
                    Note{ii}='Reference,NoLight';
                elseif ~isempty(findstr(Note{ii},'Light'))
                    Note{ii}='Reference,Light';
                else
                    Note{ii}='Reference,Reference';
                end
                repcounter=repcounter+1;
            end
        end
    end
    
    % remove duplicate events (for overlaid stim, eg VTL)
    keepidx=find([1;(diff(eventtime)~=0 | diff(evtrials)~=0)]);
    eventtime=eventtime(keepidx);
    eventtimeoff=eventtimeoff(keepidx);
    evtrials=evtrials(keepidx);
    Note={Note{keepidx}}';
else
    % find all events that match masks
    if sum(includeprestim)==1 && length(includeprestim)==1,
        tags=evunique(exptevents,['PreStim*']);
    else
        tags=evunique(exptevents,['Stim*']);
    end
    
    tgoodidx=zeros(size(tags));
    for ii=1:length(tags),
        b=strsep(tags{ii},',',1);
        if isempty(findstr(b{2},'StimSilence')),
            tgoodidx(ii)=1;
        end
    end
    tags={tags{find(tgoodidx)}};
    
    for jj=1:length(tag_masks),
        ttfind=(strfind(upper(tags),upper(tag_masks{jj})));
        tt2=[];
        for ii=1:length(ttfind),
            if ~isempty(ttfind{ii}),
                tt2=[tt2 ii];
            end
        end
        tags={tags{tt2}};
    end
    
    % figure out when each event to be rastered started and stopped
    if sum(includeprestim)>0 && length(includeprestim)>1,
        [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['Stim*']);
        eventtime=eventtime-includeprestim(1);  % ie, minus PreStimSilence
        eventtimeoff=eventtimeoff+includeprestim(2);  % ie, plus PostStimSilence
    elseif includeprestim,
        [eventtime,evtrials,Note,~,evonidx]=evtimes(exptevents,['PreStim*']);
        [~,~,~,eventtimeoff,offidx]=evtimes(exptevents,['PostStim*']);
        if isempty(eventtimeoff),
            eventtimeoff=eventtime+0.5;
        end
        if length(eventtime)~=length(eventtimeoff),
            disp('fixing eventtime length');
            eventtime=zeros(size(eventtimeoff));
            evtrials=zeros(size(eventtimeoff));
            Note={};
            for ii=1:length(eventtimeoff),
                %onidx=offidx(ii)-2;
                onidx=evonidx(find(evonidx<offidx(ii), 1, 'last' ));
                eventtime(ii)=exptevents(onidx).StartTime;
                Note{ii}=exptevents(onidx).Note;
                evtrials(ii)=exptevents(onidx).Trial;
            end
        end
        if length(eventtimeoff)<length(eventtime),
            [~,~,~,eventtimeoff]=evtimes(exptevents,['Stim*']);
        end
    else
        [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['Stim*']);
    end
    
    % special case --remove reference period with overlapping targets
    if ~isempty(tag_masks) && strcmpi(tag_masks{1},'Reference'),
        [ttime,ttrial,tnote]=evtimes(exptevents,['Stim*']);
        validevents=ones(size(eventtime));
        for ee=1:length(ttime),
            if ~isempty(findstr(tnote{ee},', Target')),
                ff=find(eventtimeoff>ttime(ee) & evtrials==ttrial(ee));
                for gg=ff(:)',
                    if gg==ee || eventtime(gg)>ttime(ee),
                        validevents(gg)=0;
                    elseif eventtimeoff(gg)>ttime(ee),
                        eventtimeoff(gg)=ttime(ee);
                    end
                end
            end
        end
        eventtime=eventtime(find(validevents));
        evtrials=evtrials(find(validevents));
        Note={Note{find(validevents)}}';
        eventtimeoff=eventtimeoff(find(validevents));
        if sum(1-validevents)>0
            fprintf('removed %d/%d invalid target overlap events\n',...
                    sum(1-validevents),length(validevents));
        end
    end

end
