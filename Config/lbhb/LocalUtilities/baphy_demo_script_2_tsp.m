% function baphy_demo_script_2_tsp

%%
%% DATABASE BOOK-KEEPING
%% 
baphy_set_path

% specify dataset
cellid='por077a-c1';

% some alternatives: 
% cellid='por069b-b2';
% cellid='por070a-b1';
% cellid='por072a-c2';
% cellid='por075b-d1';
% cellid='por076b-a1';
 cellid='por077a-a1';
% cellid='por077a-c1';
% cellid='por077a-d1';
runclass='TSP';

% find sorted data in celldb with matching cellid and runclass
cellfiledata=dbgetscellfile('cellid',cellid,'runclass',runclass);

% print out some interesting information about each file
fprintf('Files for cell %s runclass %s:\n',cellid,runclass);
for fileidx=1:length(cellfiledata),
    
    %cellfiledata is an array of structures.  cellfiledata(fileidx)
    %is the structure for the current file.  access fields of
    %cellfiledata with syntact cellfiledata(fileidx).<fieldname>
    parmfile=[cellfiledata(fileidx).stimpath cellfiledata(fileidx).stimfile];
    spikefile=[cellfiledata(fileidx).path cellfiledata(fileidx).respfile];
    
    fprintf('%2d. parmfile:  %s\n',fileidx,parmfile);
    fprintf('    spikefile: %s\n',spikefile);
    fprintf('    RawID: %d  Channel: %d  Unit: %d\n',...
            cellfiledata(fileidx).rawid,cellfiledata(fileidx).channum,...
            cellfiledata(fileidx).unit);
end


%%
%% READING INFORMATION ABOUT AN EXPERIMENT
%% 

% now focus on one file and look at more details
fileidx=1;
parmfile=[cellfiledata(fileidx).stimpath cellfiledata(fileidx).stimfile];
spikefile=[cellfiledata(fileidx).path cellfiledata(fileidx).respfile];
fprintf('Focusing on file %d, %s:\n',fileidx,parmfile);

LoadMFile(parmfile);

fprintf('High level info (experimenter, ferret): %s, %s\n',...
        globalparams.Tester, globalparams.Ferret);
fprintf('Some experimental parameters (referenceobject,targetobject): %s, %s\n',...
        exptparams.TrialObject.ReferenceClass,...
        exptparams.TrialObject.TargetClass);

fprintf('And some events in trials #1 and #2:\n');
eventtrials=cat(2,exptevents.Trial);
thistrialevents=find(eventtrials==1 | eventtrials==2);
for tt=thistrialevents,
    fprintf('Event: %d Trial: %d Note: %s (Start-Stop): %.2f-%.2f\n',...
            tt,exptevents(tt).Trial,exptevents(tt).Note,...
            exptevents(tt).StartTime,exptevents(tt).StopTime);
end

ReferencePreStimSilence=exptparams.TrialObject.ReferenceHandle.PreStimSilence;
ReferenceDuration=1.5;  % this avoids including the target period
% exclude target period, which follows immediately after reference
ReferencePostStimSilence=0;  

TargetPreStimSilence=exptparams.TrialObject.TargetHandle.PreStimSilence;
TargetDuration=exptparams.TrialObject.TargetHandle.Duration;
TargetPostStimSilence=exptparams.TrialObject.TargetHandle.PostStimSilence;

% create a single figure with multiple plots
figure
subplothandles=[0 0];
% loop through a couple files
fileset=[5 6 7];
for jj=1:length(fileset),
   fileidx=fileset(jj);
   parmfile=[cellfiledata(fileidx).stimpath cellfiledata(fileidx).stimfile];
   spikefile=[cellfiledata(fileidx).path cellfiledata(fileidx).respfile];
   options=[];
   options.rasterfs=30;  % spike bins per second
   options.unit=cellfiledata(fileidx).unit;
   options.channel=cellfiledata(fileidx).channum;
   options.includeprestim=[ReferencePreStimSilence ReferencePostStimSilence];
   
   % only load reference data
   options.tag_masks={'Reference'};
   [r_ref,tags_ref]=loadspikeraster(spikefile,options);
   % r_ref is a 3-dim matrix : time X repetition X stimulus(tag). not
   % all stimuli are presented the same number of times, so values of
   % r_ref are NaN if not presented during experiment.
   
   % snip of reference responses after 2 seconds
   r_ref=r_ref(1:round((ReferencePreStimSilence+ReferenceDuration).*options.rasterfs),:,:);
   
   fprintf('%d references (repcount):\n',length(tags_ref));
   for ii=1:length(tags_ref),
      fprintf('%s (%d reps)\n',tags_ref{ii},sum(~isnan(r_ref(1,:,ii))));
   end
   
   % only load reference data
   options.tag_masks={'Target'};
   options.includeprestim=[TargetPreStimSilence TargetPostStimSilence];
   [r_tar,tags_tar]=loadspikeraster(spikefile,options);
   
   fprintf('%d targets: (repcount)\n',length(tags_tar));
   for ii=1:length(tags_tar),
      fprintf('%s (%d reps)\n',tags_tar{ii},sum(~isnan(r_tar(1,:,ii))));
   end
   
   % compute mean responses, averaged over all references or targets:
   % "nanmean" doesn't count matrix entries with the value "NaN", which is
   % good. The duration of the reference sound varies between trials (because
   % the target can occur at different times), and NaNs represent samples that
   % do not exist.
   r_ref_mean=nanmean(nanmean(r_ref,2),3).*options.rasterfs;
   r_tar_mean=nanmean(nanmean(r_tar,2),3).*options.rasterfs;
   r_ref_sem=nanstd(r_ref(:,:),0,2)./sqrt(sum(~isnan(r_ref(:,:)),2)).*options.rasterfs;
   r_tar_sem=nanstd(r_tar(:,:),0,2)./sqrt(sum(~isnan(r_tar(:,:)),2)).*options.rasterfs;
   
   subplothandles(jj)=subplot(1,3,jj);
   timeaxis=(1:length(r_ref_mean))'./options.rasterfs- ...
      ReferencePreStimSilence;
   tartimeaxis=(1:length(r_tar_mean))'./options.rasterfs+timeaxis(end)+1./options.rasterfs;
   plot(timeaxis,r_ref_mean,'b');
   hold on
   plot(tartimeaxis,r_tar_mean,'r');
   errorshade(timeaxis,r_ref_mean,r_ref_sem,[0 0 1],[0.7 0.7 1]);
   errorshade(tartimeaxis,r_tar_mean,r_tar_sem,[1 0 0],[1 0.7 0.7]);
   hold off
   legend('reference','target');
   xlabel('time after onset (sec)');
   ylabel('mean spike rate (spikes/sec)');
   title(sprintf('cell %s file %s',cellid,basename(parmfile)),'Interpreter','none');
end

% some fancy graphics stuff:
get(subplothandles(1))
ymax1=get(subplothandles(1),'YLim');
ymax2=get(subplothandles(2),'YLim');
ymax3=get(subplothandles(3),'YLim');
ymax=max(max(ymax1(2),ymax2(2)),ymax3(2));
set(subplothandles(1),'YLim',[0 ymax]);
set(subplothandles(2),'YLim',[0 ymax]);
set(subplothandles(3),'YLim',[0 ymax]);


%%  HOMEWORK

% 1a. plot a raster for responses to the different targets
% 1b. plot a raster for response to the single reference with the
% most repeats (hint: stimidx=1)

% ANSWER 1a.
ff=1;
fileidx=fileset(ff);
parmfile=[cellfiledata(fileidx).stimpath cellfiledata(fileidx).stimfile];
spikefile=[cellfiledata(fileidx).path cellfiledata(fileidx).respfile];
options=[];
options.rasterfs=1000;  % spike bins per second
options.unit=cellfiledata(fileidx).unit;
options.channel=cellfiledata(fileidx).channum;
options.includeprestim=[ReferencePreStimSilence ReferencePostStimSilence];

% only load reference data
options.tag_masks={'Target'};
options.includeprestim=[TargetPreStimSilence TargetPostStimSilence];
[r_tar,tags_tar]=loadspikeraster(spikefile,options);
   
r_tar_all=r_tar(:,:);
%remove nan trials
goodtrials=find(~isnan(r_tar_all(1,:)));
r_tar_goodtrials=r_tar_all(:,goodtrials);

[spiketime,spiketrial] = find(r_tar_goodtrials);  % returns coordinates of all non-zero
                                          % values in r_single
spiketime=spiketime./options.rasterfs-TargetPreStimSilence;

figure;
plot(spiketime,spiketrial,'k.');
axis([-TargetPreStimSilence TargetDuration+TargetPostStimSilence...
      0.5 size(r_tar_goodtrials,2)+0.5]);
hold on;
aa=axis;
plot([0 0],[0.5 size(r_tar_goodtrials,2)+0.5],'g--');
plot([0 0]+TargetDuration,[0.5 size(r_tar_goodtrials,2)+0.5],'g--');
hold off
xlabel('Time after stimulus onset (sec)');
title(sprintf('Raster Cell %s File %s Target',...
              cellid,basename(parmfile)),'Interpreter','none');

% even more challenging part: label y axis accurately
stimuluscount=length(tags_tar);  % same as size(r_ref,3)
repcount=size(r_tar,2);
set(gca,'YTickLabel',[]);
hold on;
stimulusvalues=zeros(stimuluscount,1);
reps_per_stim=squeeze(sum(~isnan(r_tar(1,:,:)),2));
yaxisvalue=0;
for stimidx=1:stimuluscount,
   plot([-TargetPreStimSilence TargetDuration+TargetPostStimSilence],...
      [yaxisvalue yaxisvalue],'b--');
   
   % record the stimulus values
   ys=strsep(tags_tar{stimidx},',',0);   
   stimulusvalues(stimidx)=ys{2};
   previousyaxisvalue=yaxisvalue;
   yaxisvalue=yaxisvalue+reps_per_stim(stimidx);
   text(-TargetPreStimSilence,mean([previousyaxisvalue yaxisvalue]),num2str(ys{2}),'HorizontalAlignment','right');
   
end
hold off

% SOLUTION 1b.
options.tag_masks={'Reference'};
[r_ref,tags_ref]=loadspikeraster(spikefile,options);
% r_ref is a 3-dim matrix : time X repetition X stimulus(tag). not
% all stimuli are presented the same number of times, so values of
% r_ref are NaN if not presented during experiment.
   
% snip of reference responses after 2 seconds
r_ref=r_ref(1:round(2.0.*options.rasterfs),:,:);

% find stimulus that was repeated most times, not necessarily stimidx==1!
reps_per_stim=squeeze(sum(~isnan(r_ref(1,:,:)),2));
stimidx=find(reps_per_stim==max(reps_per_stim),1);

plot_this_ref=r_ref(:,:,stimidx);

[spiketime,spiketrial] = find(plot_this_ref);  % returns coordinates of all non-zero
                                          % values in r_single
spiketime=spiketime./options.rasterfs-ReferencePreStimSilence;

figure;
plot(spiketime,spiketrial,'k.');
axis([-ReferencePreStimSilence ReferenceDuration+ReferencePostStimSilence...
      0.5 size(plot_this_ref,2)+0.5]);
hold on;
aa=axis;
plot([0 0],[0.5 size(plot_this_ref,2)+0.5],'g--');
plot([0 0]+ReferenceDuration,[0.5 size(plot_this_ref,2)+0.5],'g--');
hold off
xlabel('Time after reference onset (sec)');
title(sprintf('Raster Cell %s File %s Reference #%d',...
              cellid,basename(parmfile),stimidx),'Interpreter','none');

% 2. compute PSTHs and standard error for the data in #1 (individual
% targets and most common reference) and plot with the errorshade command

% load target data with 30 Hz sampling
ff=1;
fileidx=fileset(ff);
parmfile=[cellfiledata(fileidx).stimpath cellfiledata(fileidx).stimfile];
spikefile=[cellfiledata(fileidx).path cellfiledata(fileidx).respfile];
options=[];
options.rasterfs=30;  % spike bins per second
options.unit=cellfiledata(fileidx).unit;
options.channel=cellfiledata(fileidx).channum;
options.tag_masks={'Target'};
options.includeprestim=[TargetPreStimSilence TargetPostStimSilence];
[r_tar,tags_tar]=loadspikeraster(spikefile,options);

% traditional "C" way to count number of different targets presented
tar_count=size(r_tar,3);
separate_tar_count=zeros(tar_count,1);
for ii=1:tar_count, % loop through each stimulus
   for jj=1:size(r_tar,2), % loop through each rep
      if isfinite(r_tar(1,jj,ii)),
         separate_tar_count(ii)=separate_tar_count(ii)+1;
      end
   end
end

% Matlab way:
separate_tar_count=squeeze(sum(~isnan(r_tar(1,:,:)),2));

% compute average for each target
r_tar_mean=squeeze(nanmean(r_tar,2)) .* options.rasterfs;

% comput SEM, C way
r_tar_sem=zeros(size(r_tar,1),tar_count);
for jj=1:tar_count,
   % how many reps for this target?
   count_for_this_tar=separate_tar_count(jj);
   for ii=1:size(r_tar,1),
      r_tar_sem(ii,jj)=std(r_tar(ii,1:count_for_this_tar,jj))./sqrt(count_for_this_tar);
   end
end
r_tar_sem=r_tar_sem.*options.rasterfs;

% matlab way
r_tar_sem=squeeze(nanstd(r_tar,0,2))./sqrt(repmat(separate_tar_count',[size(r_tar,1) 1])) .* options.rasterfs;

linecolorset={[1 0 0],[0.6 0.1 0.1],[0.3 0.2 0.2]};
bgcolorset={[1 0.8 0.8],[1 0.8 0.8],[1 0.8 0.8]};

figure;
tar_time=(1:size(r_tar_mean,1))'./options.rasterfs-TargetPreStimSilence;
for tar_idx=1:tar_count,
   errorshade(tar_time,r_tar_mean(:,tar_idx),r_tar_sem(:,tar_idx),...
      linecolorset{tar_idx},bgcolorset{tar_idx});
   hold on
end
hold off

% can repeat basically same thing for references


% 3. compute PSTH plots for each TSP file for this cell and plot each one
% with the same scaling (hint; use the "axis" command)

% compare response to reference #1 across behavior sets
filecount=length(fileset);
for ff=1:filecount;
   fileidx=fileset(ff);
   parmfile=[cellfiledata(fileidx).stimpath cellfiledata(fileidx).stimfile];
   spikefile=[cellfiledata(fileidx).path cellfiledata(fileidx).respfile];
   options=[];
   options.rasterfs=30;  % spike bins per second
   options.unit=cellfiledata(fileidx).unit;
   options.channel=cellfiledata(fileidx).channum;
   options.includeprestim=[ReferencePreStimSilence ReferencePostStimSilence];
   options.tag_masks={'Reference'};
   [r_ref,tags_ref]=loadspikeraster(spikefile,options);
   % snip off reference responses after 2 seconds
   r_ref=r_ref(1:round(2.*options.rasterfs),:,:);
   
   % find stimulus that was repeated most times, not necessarily stimidx==1!
   reps_per_stim=squeeze(sum(~isnan(r_ref(1,:,:)),2));
   stimidx=find(reps_per_stim==max(reps_per_stim),1);
   
   if ff==1,
      % first time through loop, define reference mean and sem matrices
      ref_len=size(r_ref,1);
      r_ref_mean=zeros(ref_len,filecount);
      r_ref_sem=zeros(ref_len,filecount);
   end
   
   % follow the way of matlab to find the answer
   ref_common=r_ref(:,:,stimidx);
   ref_common_count=sum(~isnan(ref_common(1,:)));
   r_ref_mean(:,ff)=squeeze(nanmean(ref_common,2)) .* options.rasterfs;
   r_ref_sem(:,ff)=squeeze(nanstd(ref_common,0,2))./sqrt(ref_common_count) .* options.rasterfs;

end

% might want difference colors for reference
linecolorset={[0 1 0],[1 0 0],[0 0 1]};
bgcolorset={[0.8 1 0.8],[1 0.8 0.8],[0.8 0.8 1]};

figure;
ref_time=(1:size(r_ref_mean,1))'./options.rasterfs-ReferencePreStimSilence;
for ff=1:filecount,
   errorshade(ref_time,r_ref_mean(:,ff),r_ref_sem(:,ff),...
      linecolorset{ff},bgcolorset{ff});
   hold on
end
hold off


% 4a. summary plot:  average spontaneous firing before reference
% onset as a function of data files.  hit use "bar" to generate a bar plot
% 4b. average reference/target-evoked firing 0-0.5 sec after onset
% as a function of data file
% 4c. how about 0-1.0 sec after stimulus onset




