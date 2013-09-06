% function baphy_demo_script_3_classifier

% some coding standards:
% lower-case variables:  ii, evidx -- temporary counter variables
% SentenceCaseVariables:  vectors/matrices used throughout the script
% BLOCK CASE: global constants whose value won't change during script execution

%%
%% DATABASE BOOK-KEEPING
%% 
baphy_set_path

% specify dataset
cellid='por081a-c1';

% some alternatives:
%cellid='por080a-b1';
%cellid='por080a-c2';
%cellid='por080a-d1';
%cellid='por080b-a1';
%cellid='por081b-c2';
%cellid='por089a-c1';
%cellid='por090a-c1';
%cellid='por091a-c1';
%cellid='por096b-c1';
runclass='TSP';

% find sorted data in celldb with matching cellid and runclass
cellfiledata=dbgetscellfile('cellid',cellid,'runclass',runclass);

% alternative, use dbgettspfile(cellid,batch) to find only files that
% belong to this task and meet isolation criteria.
% batch=251; % for the low/high data
% batch=244; % for the left/right data
% cellfiledata=dbgettspfile(cellid,batch);  

%%
%% COMPARE REFERENCE VERSUS TARGET DISCRIMINABILITY FOR EACH EXPERIMENT
%% 

% pick a set of files to analyze.  Limit to 5 for display purposes.
fileset=1:min(5,length(cellfiledata));
filecount=length(fileset);

% create a new figure for all the plots and remember it
CurrentFig=figure;

for f=1:filecount,
   % get information for current file
   fileidx=fileset(f);
   parmfile=[cellfiledata(fileidx).stimpath cellfiledata(fileidx).stimfile];
   spikefile=[cellfiledata(fileidx).path cellfiledata(fileidx).respfile];
   fprintf('Processing file %d, %s:\n',fileidx,parmfile);
   
   LoadMFile(parmfile);
   
   % step 0. Load the data
   
   options=[];
   options.rasterfs=30;  % spike bins per second
   options.unit=cellfiledata(fileidx).unit;
   options.channel=cellfiledata(fileidx).channum;
   
   % new option:  Load data trial-by-trial, don't sort by reference &
   % target events.
   options.tag_masks={'SPECIAL-TRIAL'};
   
   % r_per_trial is now a Time X Trial matrix.  We will use the event log
   % to figure out when stimuli were played 
   [r_per_trial,~,trialset]=loadspikeraster(spikefile,options);
   trialcount=size(r_per_trial,2);
   
   % step 1: figure out when targets happened on every trial
   TarEventList=[];
   TargetTimes=[];
   for evidx=1:length(exptevents),
      if ~isempty(findstr(exptevents(evidx).Note,'Stim ,')) &&...
            ~isempty(findstr(exptevents(evidx).Note,'Target')) &&...
            ismember(exptevents(evidx).Trial,trialset),
         TarEventList=cat(1,TarEventList,evidx);
         TargetTimes=[TargetTimes;exptevents(evidx).StartTime];
      end
   end
   fprintf('Found %d tar events in %d trials.\n',length(TarEventList),trialcount);
   
   % fancy quick Matlab way to concatenate all the matching fields from the
   % struct array into a vector 
   TargetTimes=cat(1,exptevents(TarEventList).StartTime);
   TargetBins=round(TargetTimes.*options.rasterfs);
   
   MinTargetTime=min(TargetTimes);
   MaxTargetTime=max(TargetTimes);
   fprintf('Target onset times range from %.1f to %.1f sec\n',...
      MinTargetTime,MaxTargetTime);
   MinTargetBin=round(MinTargetTime*options.rasterfs);
   MaxTargetBin=round(MaxTargetTime*options.rasterfs);
   TargetDuration=exptparams.TrialObject.TargetHandle.Duration;
   TargetDurationBins=round(TargetDuration.*options.rasterfs);
   ReferencePreStimSilence=exptparams.TrialObject.ReferenceHandle.PreStimSilence;
   ReferencePreBins=round(ReferencePreStimSilence.*options.rasterfs);
   
   % step 2. train classifier by computing probability of response given
   % stimulus identity -- (0)reference, or (1)target
   DecodeWindowLen=0.1;
   DecodeWindowBins=round(DecodeWindowLen.*options.rasterfs);
   
   % start decoding 0.5 sec after reference sound starts
   FirstDecodeTime=ReferencePreStimSilence+0.5;
   FirstDecodeBin=round(FirstDecodeTime*options.rasterfs);
   
   % process the response matrix to indicate the number of spikes that
   % occured during the last DecodeWindowLen period, which happens to be
   % 100ms
   rnonan=r_per_trial;
   rnonan(isnan(rnonan))=0; % remove nans because these mess up convolution
   
   % sumfilter is a quick way of counting spikes in the preceding bins. 
   % if DecodeWindowBins==3 then sumfilter=[1; 1; 1; 0; 0]
   sumfilter=[zeros(DecodeWindowBins-1,1);ones(DecodeWindowBins,1)];
   rnonansmoothed=conv2(rnonan,sumfilter,'same');
   
   % We need to count the number of times each different response rate was
   % observed. Very high rates are rare, so we put a hard max on firing
   % rate--10 spikes per window (approx 100 sp/s)
   rmax=10;
   rnonansmoothed(rnonansmoothed>rmax)=rmax;
   
   % now count the number of times the response had each value during the
   % reference period and the target period
   rcount=zeros(rmax+1,2);
   for trialidx=1:length(TargetTimes),
      for ii=FirstDecodeBin:TargetBins(trialidx),
         rthisbin=rnonansmoothed(ii,trialidx)+1;
         rcount(rthisbin,1)=rcount(rthisbin,1)+1;
      end
      for ii=(TargetBins(trialidx)+1):(TargetBins(trialidx)+TargetDurationBins),
         rthisbin=rnonansmoothed(ii,trialidx)+1;
         rcount(rthisbin,2)=rcount(rthisbin,2)+1;
      end
   end
   
   % P(r|s) is simply counts for each response value divided by the
   % total number of samples in that stimulus condition.
   Prs=zeros(size(rcount));
   for stimidx=1:size(rcount,2),
      Prs(:,stimidx)=rcount(:,stimidx)./sum(rcount(:,stimidx));
   end
   
   % P(s) is the probability at any given time of target. this
   % depends on the period used for decoding.  For example P(s) will be
   % lower if we include the time early than 0.5 sec after reference onset.   
   scount=sum(rcount,1);
   Ps=scount./sum(scount);
   
   % step 3. decoder, given Prs and Ps, what is Psr?
   % Bayes Rule:  P(s|r) = P(r|s) * P(s) / P(r)
   % When decoding, P(r)=1, so we can ignore it.
   
   Psr=Prs.*repmat(Ps,[rmax+1 1]);
   Psr=Psr./repmat(sum(Psr,2),[1 2]);
     
   
   % step 4. construct a big matrix indicating whether the current stimulus is
   % a reference (0) or target (1)
   stim=zeros(size(r_per_trial));
   for trialidx=1:length(TargetTimes),
      stim(TargetBins(trialidx)+(1:TargetDurationBins),trialidx)=1;
      stim((TargetBins(trialidx)+TargetDurationBins+1):end,trialidx)=0.5;
   end
   LastDecodeBin=max(TargetBins)+TargetDurationBins;
   stim=stim(FirstDecodeBin:LastDecodeBin,:);
   
   % P is the probability of target at any given time, same dimensions as
   % stim. A perfect P should match stim exactly.
   P=zeros(size(stim));
   for rr=0:rmax,
      ff=find(rnonansmoothed(FirstDecodeBin:LastDecodeBin,:)==rr);
      P(ff)=Psr(rr+1,2)./sum(Psr(rr+1,:));
   end
   ff=find(stim==0.5);
   P(ff)=0;
   
   figure(CurrentFig);
   subplot(3,filecount,f+0);
   plot(0:rmax,Psr);
   aa=axis;
   axis([0 rmax 0 1]);
   title(basename(parmfile),'Interpreter','none');
   xlabel('response (spikes)');
   ylabel('P(s=1 | r)');
   
   subplot(3,filecount,f+filecount);
   tlabels=(1:size(stim,1))./options.rasterfs+FirstDecodeTime-ReferencePreStimSilence;
   
   % sort 
   [~,sortbylen]=sort(TargetBins);
   imagesc(tlabels,1:length(sortbylen),[stim(:,sortbylen)'],[0 1]);
   if f==1, 
      % reduce clutter by only labeling first plot
      title('Ref(blue) Tar(red)');
      xlabel('Trial time (s)');
      ylabel('Trials (sorted dur)');
   end
   
   subplot(3,filecount,f+filecount*2);
   imagesc(tlabels,1:length(sortbylen),[P(:,sortbylen)'],[0 1]);
   if f==1, 
      % reduce clutter by only labeling first plot
      title('P(tar|response)');
      xlabel('Trial time (s)');
      ylabel('Trials (sorted dur)');
   end
   
   % TO DO: QUANTITATIVE PERFORMANCE METRIC
end


