% function baphy_demo_script

%%
%% DATABASE BOOK-KEEPING
%% 
baphy_set_path
close all

% specify dataset
cellid='por077a-d2';
runclass='BNB';

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
fileidx=length(cellfiledata);  % looking at last entry in list
parmfile=[cellfiledata(fileidx).stimpath cellfiledata(fileidx).stimfile];
spikefile=[cellfiledata(fileidx).path cellfiledata(fileidx).respfile];
fprintf('Focusing on file %d, %s:\n',fileidx,parmfile);

% if not connected to the database, just get copies of these files:
%spikefile='/auto/data/daq/Portabello/por077/sorted/por077a15_p_BNB.spk.mat';
%parmfile='/auto/data/daq/Portabello/por077/por077a15_p_BNB.m';

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
ReferenceDuration=exptparams.TrialObject.ReferenceHandle.Duration;
ReferencePostStimSilence=exptparams.TrialObject.ReferenceHandle.PostStimSilence;


%% Load data

parmfile=[cellfiledata(fileidx).stimpath cellfiledata(fileidx).stimfile];
spikefile=[cellfiledata(fileidx).path cellfiledata(fileidx).respfile];
options=[];
options.rasterfs=1000;  % spike bins per second
options.unit=cellfiledata(fileidx).unit;
options.channel=cellfiledata(fileidx).channum;
options.includeprestim=[ReferencePreStimSilence ReferencePostStimSilence];

% only load reference data -- for BNB, there is no target, so this
% is everything.
options.tag_masks={'Reference'};
[r_ref,tags_ref]=loadspikeraster(spikefile,options);

% r_ref is a 3-dim matrix : time X repetition X stimulus(tag). not
% all stimuli are presented the same number of times, so values of
% r_ref are NaN if not presented during experiment.

fprintf('%d references (repcount):\n',length(tags_ref));
for ii=1:length(tags_ref),
    fprintf('%s (%d reps)\n',tags_ref{ii},sum(~isnan(r_ref(1,:,ii))));
end

% compute mean responses, averaged over all repetitions of all stimuli:
r_ref_mean=nanmean(nanmean(r_ref,2),3).*options.rasterfs;

figure;
timeaxis=(1:length(r_ref_mean))./options.rasterfs- ...
         ReferencePreStimSilence;
plot(timeaxis,r_ref_mean);
hold on;
aa=axis;
plot([0 0],[aa(3) aa(4)],'g--');
plot([0 0]+ReferenceDuration,[aa(3) aa(4)],'g--');
hold off
xlabel('Time after stimulus onset (sec)');
ylabel('Mean spike rate (spikes/sec)');
title(sprintf('Cell: %s File: %s Avg PSTH %d Hz',...
              cellid,basename(parmfile),options.rasterfs),...
      'Interpreter','none');

% try loading with bigger time bins:
options100=options;  % replicate options structure from above
options100.rasterfs=100;  % change spike bins per second
[r_ref_100]=loadspikeraster(spikefile,options100);
r_ref_mean_100=nanmean(nanmean(r_ref_100,2),3).*options100.rasterfs;

figure;
timeaxis100=(1:length(r_ref_mean_100))./options100.rasterfs- ...
         ReferencePreStimSilence;
plot(timeaxis100,r_ref_mean_100);
hold on;
aa=axis;
plot([0 0],[aa(3) aa(4)],'g--');
plot([0 0]+ReferenceDuration,[aa(3) aa(4)],'g--');
hold off
xlabel('Time after stimulus onset (sec)');
ylabel('Mean spike rate (spikes/sec)');
title(sprintf('Cell: %s File: %s Avg PSTH %d Hz',...
              cellid,basename(parmfile),options100.rasterfs),...
      'Interpreter','none');


% pick one stimulus and plot a raster
stimid=17;
r_single=r_ref(:,:,stimid);
[spiketime,spiketrial] = find(r_single);  % returns coordinates of all non-zero
                             % values in r_single
spiketime=spiketime./options.rasterfs-ReferencePreStimSilence;

figure;
plot(spiketime,spiketrial,'k.');
axis([-ReferencePreStimSilence ReferenceDuration+ReferencePostStimSilence...
      0.5 size(r_single,2)+0.5]);
hold on;
aa=axis;
plot([0 0],[0.5 size(r_single,2)+0.5],'g--');
plot([0 0]+ReferenceDuration,[0.5 size(r_single,2)+0.5],'g--');
hold off
xlabel('Time after stimulus onset (sec)');
ylabel('Trial');
title(sprintf('Raster Cell %s File %s Tag %s',...
              cellid,basename(parmfile),tags_ref{stimid}),'Interpreter','none');



%%  HOMEWORK

% 1. plot a raster for all the stimuli, sorted by the different noise
% bands
% (hint: use the "reshape" command on r_ref)

% SOLUTION: Same code as above but subbing "r_ref_collapsed" for "r_single"
r_ref_collapsed=reshape(r_ref,400,200);
% get row and column of each non-zero value in r_ref_collapsed
[spiketime,spiketrial] = find(r_ref_collapsed);

% convert from row index to seconds
spiketime=spiketime./options.rasterfs-ReferencePreStimSilence;

figure;

plot(spiketime,spiketrial,'k.');
axis([-ReferencePreStimSilence ReferenceDuration+ReferencePostStimSilence...
      0.5 size(r_ref_collapsed,2)+0.5]);
hold on;
aa=axis;
plot([0 0],[0.5 size(r_ref_collapsed,2)+0.5],'g--');
plot([0 0]+ReferenceDuration,[0.5 size(r_ref_collapsed,2)+0.5],'g--');
hold off

xlabel('Time after stimulus onset (sec)');
title(sprintf('Raster Cell %s File %s All stimuli',...
              cellid,basename(parmfile)),'Interpreter','none');

% challenging part: label y axis accurately
stimuluscount=length(tags_ref);  % same as size(r_ref,3)
repcount=size(r_ref,2);
set(gca,'YTickLabel',[]);
hold on;
stimulusvalues=zeros(stimuluscount,1);
for stimidx=1:stimuluscount,
   yaxisvalue=stimidx*repcount+0.5;
   plot([-ReferencePreStimSilence ReferenceDuration+ReferencePostStimSilence],...
      [yaxisvalue yaxisvalue],'b--');
   
   ys=strsep(tags_ref{stimidx},',',0);
   text(-ReferencePreStimSilence,yaxisvalue-repcount/2,num2str(ys{2}),'HorizontalAlignment','right');
   
   % record the stimulus values
   stimulusvalues(stimidx)=ys{2};
end
hold off
 
% 2. figure out mean firing rate averaged across each noise band:
%    a. before stimulus onset
%    b. 0-50 ms after stimulus onset
%    c. 50-100 ms after stimulus onset
%    d. 0-50 ms after stimulus offset
% this will result in four 20x1 vectors
% (hint: "help mean")

% 3. compute standard error across trials for each of these means this
% will also result in four 20 x 1 vectors of numbers 
% (hint: standard error = standard deviation across repetitions
% divided by the sqrt of the number of repetitions)
% (hint: number of repetitions is 10)

% find the time bins for the pre-stimulus epoch
spontbins=1:round(ReferencePreStimSilence*options.rasterfs);

% calculate mean rate over time (dimension 1) and repetitions (dimension
% 2).  squeeze() to reshape result to a stimuluscount X 1 vector
meanspontaneous=squeeze(mean(mean(r_ref(spontbins,:,:),1),2))*options.rasterfs;

% calculate SEM by averaging over time and computing standard error over
% repetitions.
semspontaneous=squeeze(std(mean(r_ref(spontbins,:,:),1),0,2))*options.rasterfs./sqrt(stimuluscount);

% repeat for onset period
onsetbins=round(ReferencePreStimSilence*options.rasterfs+1):...
   round((ReferencePreStimSilence+0.05)*options.rasterfs);
meanonset=squeeze(mean(mean(r_ref(onsetbins,:,:),1),2))*options.rasterfs;
semonset=squeeze(std(mean(r_ref(onsetbins,:,:),1),0,2))*options.rasterfs./sqrt(stimuluscount);

% repeat for sustained period
sustbins=round((ReferencePreStimSilence+0.05)*options.rasterfs+1):...
   round((ReferencePreStimSilence+0.1)*options.rasterfs);
meansustained=squeeze(mean(mean(r_ref(sustbins,:,:),1),2))*options.rasterfs;
semsustained=squeeze(std(mean(r_ref(sustbins,:,:),1),0,2))*options.rasterfs./sqrt(stimuluscount);

% repeat for offset period
offsetbins=round((ReferencePreStimSilence+ReferenceDuration)*options.rasterfs+1):...
   round((ReferencePreStimSilence+ReferenceDuration+0.05)*options.rasterfs);
meanoffset=squeeze(mean(mean(r_ref(offsetbins,:,:),1),2))*options.rasterfs;
semoffset=squeeze(std(mean(r_ref(offsetbins,:,:),1),0,2))*options.rasterfs./sqrt(stimuluscount);


% 4. plot these four tuning curves with standard errors to compare
% onset, sustained and offset responses to baseline firing rate. label
% your and number your axes accurately! what is the best frequency
% reported by each of these tuning curves?
% (hint: "help errorbar")

figure; % create new figure
errorbar(repmat((1:stimuluscount)',[1 4]),...
   [meanspontaneous meanonset meansustained meanoffset],...
   [semspontaneous semonset semsustained semoffset])
hold on
plot([1 stimuluscount],[0 0]+mean(meanspontaneous),'b--');
hold off
fprintf('current figure # is %d\n',gcf);
fprintf('current axis # is %.8f\n',gca);
set(gca,'XLim',[0 stimuluscount+1]);  % make x axis look nice
stimulusKHz=round(stimulusvalues./100)./10;
stimlabelidx=1:2:stimuluscount;
set(gca,'XTick',stimlabelidx,'XTickLabel',stimulusKHz(stimlabelidx));

legend('Spont','Onset','Sust','Offset');
ylabel('Spike rate (spikes/sec)');
xlabel('Stimulus frequency (KHz)');
title(sprintf('cellid %s BNB tuning',cellid));

% 5. repeat for different cells:  por077a-a1, por077a-b1, por077a-c1 

% SOLUTION: replace line 10 with 
%  cellid='por077a-a1';
% or whatever other cellid you want and re-run this script


