function cachefile=cacheevpspikes(evpfile,electrode,sigthreshold,forceregen,fixedsigma,ShockNanDur)
% function cachefile=cacheevpspikes(evpfile,electrode,sigthreshold,forceregen)
%
% load evp and threshold to find candidate spike events.
% then save to cachefile (<evppath>\tmp\<evpbase>.sig<sigthreshold>.mat)
%
% created SVD 2007-01-17
% modified BE 2012-03-28

global USECOMMONREFERENCE VERBOSE
if isempty(VERBOSE) VERBOSE = 0; end 

%% PARSE ARGUMENTS
if ~exist('verbose','var') verbose = 0; end
if ~exist('fixedsigma','var') fixedsigma=0; end
if ~exist('sigthreshold','var') disp('default sigthreshold=4'); sigthreshold=4;end
sigthreshset=sigthreshold;
if ~exist('forceregen','var') forceregen=0; end
if ~exist('ShockNanDur','var') ShockNanDur=.3; end

if fixedsigma  fs=['.f',num2str(fixedsigma)];
else  fs='';
end
if isempty(USECOMMONREFERENCE) || ~USECOMMONREFERENCE,
   commstr='.NOCOM';
else  commstr=''; end
if sigthreshold==0 commstr = ''; end; % MANTA file does not contain this information

%% PARSE FILE NAME AND FIND FILE
[pp,bb,ee]=fileparts(evpfile);
if strcmp(evpfile((end-8):end),'001.1.evp'),
  [pp,bb]=fileparts(evpfile);
  mfilepath=fileparts(fileparts(pp)); % strip off two subdirs
  mfilebase=strrep(bb,'.001.1','.m');
  mfile=fullfile(mfilepath,mfilebase);
  cachebase='.elec';
elseif strcmp(evpfile((end-3):end),'.tgz'),
  [pp,bb]=fileparts(evpfile);
  mfilepath=fileparts(pp); % strip off two subdirs
  dd=dir([mfilepath filesep bb '*m']);
  if ~isempty(dd),
    mfilebase=dd(1).name;
  else
    error('cannot find mfile');
  end
  mfile=fullfile(mfilepath,mfilebase);
  [mfilepath,bb]=fileparts(mfile);
  bb=[bb '.001.1'];
  cachebase='.elec';
else
  mfile=strrep(evpfile,'.evp','.m');
  mfilepath=fileparts(mfile);
  cachebase='.chan';
end

cachefileset=cell(length(sigthreshset),1);
cacheexists=zeros(length(sigthreshset),1);
for ii=1:length(sigthreshset),
  if ~isempty(mfilepath),
    cachefile = [mfilepath filesep 'tmp' filesep bb cachebase num2str(electrode) ...
      '.sig' num2str(sigthreshset(ii)) fs commstr '.mat'];
    cachefile=strrep(cachefile,[filesep 'raw' filesep],filesep);
  else
    cachefile = ['tmp' filesep bb cachebase num2str(electrode) ...
      '.sig' num2str(sigthreshset(ii)) fs commstr '.mat'];
  end
  if exist(cachefile,'file') && forceregen~=1
    if verbose 
      disp(['found cached: ',cachefile]);
    end
    cacheexists(ii)=1;
  end
  cachefileset{ii}=cachefile;
end

if length(sigthreshset)>1   cachefile=cachefileset;  end

if sum(cacheexists)==length(sigthreshset)  return; end

disp([mfilename ': caching ' (evpfile)]);
if sigthreshold==0 
  return;
end

[spikechancount,auxchancount,trialcount,spikefs,auxfs]=evpgetinfo(evpfile);
LoadMFile(mfile);

baphytrialcount=max(cat(1,exptevents.Trial));
if baphytrialcount<trialcount,
   disp('Baphy parm file trial count shorter than evp.  Baphy crash?');
   fprintf('Truncating to %d/%d trials\n',baphytrialcount,trialcount);
   trialcount=baphytrialcount;
end

%% DATA READ IN BLOCKS TO AVOID OUT OF MEMORY PROBLEMS
switch lower(exptparams.runclass)
  case {'mts','rts'}; BlockSize = 30;
  case {'spl'}; BlockSize = 9;
  case {'sht','bst'}; BlockSize = 20;
  otherwise BlockSize = trialcount;
end

% PREPARE TO REMOVE SHOCK EVENTS
[shockstart,shocktrials,shocknotes,shockstop]=...
  findshockevents(exptevents,exptparams);

% PREPARE FOR SPIKESORTING
TrialIDs=cell(1,length(sigthreshset));
SpikeBins=cell(1,length(sigthreshset));
SpikeMatrices= cell(1,length(sigthreshset));

%% ITERATE OVER BLOCKS
NBlocks=ceil(trialcount/BlockSize);     %read raw data in blocks
vsum=0;   Breaking = zeros(size(sigthreshset));

for iBlock=1:NBlocks                 %
  TrialsStart=(iBlock-1)*BlockSize+1;          %
  TrialsStop=min([iBlock*BlockSize trialcount]);%
  R=evpread(evpfile,'spikeelecs',electrode,'trials',[TrialsStart:TrialsStop]);
  cIndices = R.STrialidx; cData = R.Spike; clear R;
  cIndices(end+1) = length(cData) + 1;
  cData=single(cData);
  vsum=vsum+sum(double(cData.^2));
  
  % REMOVE SHOCKEVENTS
  removedshock=0;
  cShockTrialsInd = find((shocktrials>=TrialsStart).*(shocktrials<=TrialsStop));
  for iT =1:length(cShockTrialsInd)
    cShockTrialInd = cShockTrialsInd(iT);
    ShockWindow = (round(((shockstart(cShockTrialInd)-0.05).*spikefs):((shockstop(cShockTrialInd)+ShockNanDur).*spikefs)));
    trialidx=shocktrials(cShockTrialInd) - TrialsStart + 1; % Reposition to current first trial
    fprintf('trial %d: removing shock %.1f-%.1f sec\n',...
      trialidx,shockstart(cShockTrialInd)-0.05,shockstop(cShockTrialInd)+ShockNanDur);
    cData(cIndices(trialidx)-1+ShockWindow)=nan;
    removedshock=1;
  end

  % look for artifacts and remove
  if iBlock==1
     bigartifacts=find(abs(cData)>0.001);
     if fixedsigma,
        fprintf('sigma fixed at %3f\n',fixedsigma);
        sigma=fixedsigma;
     elseif ~isempty(bigartifacts) && length(bigartifacts)<length(cData)./2,
         % don't do this if EVERYTHING is an artifact
         disp('removing artifacts from sigma calc, but not from events.');
        tsig=nanstd(cData);
        ff=find(abs(cData)>tsig*5);
        td=zeros(size(cData));
        td(ff)=1;
        td=conv2(td,ones(500,1),'same');
        tc=cData(find(td==0));
        sigma=nanstd(tc);
      elseif removedshock,
        sigma=nanstd(cData);
        
     else
        mData=mean(cData);
        vData=vsum./(length(cData)-1)-mData.^2;
        sigma=sqrt(vData);
     end
  end
  
  cData(isnan(cData))=0;
  cData = cData - mean(cData);
  
  % PREPARE SPIKE COLLECTION
  SpikeWindow=[-10 39]; SpikeIndices=SpikeWindow(1):SpikeWindow(2);
  
  % LOOP OVER DIFFERENT THRESHOLDS
  for threshidx=1:length(sigthreshset),
    sigthreshold=sigthreshset(threshidx);
    
    % LOOP OVER TRIALS
    for trialidx=1:TrialsStop-TrialsStart+1
      cTrial = TrialsStart + trialidx - 1;
      if trialidx>length(cIndices) || cIndices(trialidx)>length(cData),
          break;
      end
      cTrialData=cData(cIndices(trialidx):(cIndices(trialidx+1)-1));
      
      % DETECT SPIKES
      if sigthreshold>1000,
          % FIND BINS WITH SPIKES basd on fixed threshold
          tspikebin=[double(cTrialData>sigthreshold)];
          tspikebin=[0;diff(tspikebin)>0];
          tspikebin=find(tspikebin);
          cNSpikes = length(tspikebin);
          figure(1);
          plot(cTrialData);
          hold on
          plot([1 length(cTrialData)],[1 1].*sigthreshold,'k--');
          hold off
          title(num2str(trialidx));
          drawnow;
     elseif isempty(bigartifacts)
         if sigthreshold>0,
            tspikebin=[0;diff(-cTrialData>(sigthreshold*sigma))>0];
         else
            tspikebin=[0;diff(cTrialData>abs(sigthreshold*sigma))>0];
         end
         
         % FIND BINS WITH SPIKES
         tspikebin=find(tspikebin); cNSpikes = length(tspikebin);
      else
         spikesize=-cTrialData./(sigthreshold*sigma);
         tspikebin=[0;diff(spikesize>1)>0];
            
         % FIND BINS WITH SPIKES
         tspikebin=find(tspikebin); 
         
         ff=find(spikesize(tspikebin)>7);
         if ~isempty(ff),
             ffextra=[];
             for ii=1:length(ff),
                 ffextra=union(ffextra,find(abs(tspikebin- ...
                                                tspikebin(ff(ii)))<500));
             end
             delidx=union(ff,ffextra);
             keepidx=setdiff(1:length(tspikebin),delidx);
             
             if 0
                 figure(3);
                 plot(cTrialData);
                 hold on;
                 plot(tspikebin(keepidx),...
                      spikesize(tspikebin(keepidx))./20000,'ko');
                 plot(tspikebin(delidx),...
                      spikesize(tspikebin(delidx))./20000,'rx');
                 hold off
                 title(num2str(trialidx));
                 drawnow
                 %keyboard;
             end
             
             tspikebin=tspikebin(keepidx);
         end
         
         %if ~isempty(tspikebin),
         %   tspikebin=tspikebin(spikesize(tspikebin)<7);
         %end
         
         cNSpikes = length(tspikebin);
         if cNSpikes>0,
             cNSpikes
         end
      end
      
      %if VERBOSE fprintf(['Trial : ',n2s(cTrial),' [ ',num2str(length(tspikebin)),' triggers found ]\n']); end
      % CHECK FOR EXCEEDINGLY HIGH SPIKE RATE (>1000HZ) AND BREAK TO AVOID MEMORY PROBLEMS
      if cNSpikes/(length(cTrialData)/spikefs) > 1000 
        fprintf('SpikeRate exceeds 1000Hz. Stopping Spike collection.\n'); 
        Breaking(threshidx) = 1; break; 
      end
      
      % REMOVE EVENTS TOO CLOSE TO BEGINNING AND END OF VECTOR
      tspikebin=tspikebin(find(tspikebin>-SpikeWindow(1)));
      tspikebin=tspikebin(find(tspikebin<=length(cTrialData)-SpikeWindow(2)));
      
      % COLLECT SPIKE WAVEFORMS
      cSpikes=zeros(length(SpikeIndices),length(tspikebin));
      for jj=1:length(tspikebin)    cSpikes(:,jj)=cTrialData(tspikebin(jj)+SpikeIndices);    end
      
      % COLLECT TRIAL INFORMATION
      TrialIDs{threshidx} = [TrialIDs{threshidx} ; ones(length(tspikebin),1).*cTrial];
      SpikeBins{threshidx} = [SpikeBins{threshidx} ; tspikebin];
      SpikeMatrices{threshidx} = [ SpikeMatrices{threshidx} , cSpikes ];
      
    end % END TRIALS
  end % END THRESHOLDS
  clear cData;
end % END BLOCKS
%% SAVE THE SPIKE TIMES
for threshidx=1:length(sigthreshset)
  if Breaking(threshidx)  cachefile=[]; continue;  end
  
  sigthreshold = sigthreshset(threshidx);
  trialid = TrialIDs{threshidx};
  spikebin = SpikeBins{threshidx};
  spikematrix = SpikeMatrices{threshidx};
  
  fprintf('found %d events for electrode %d, sigthresh %.1f -> %s\n',...
    length(trialid),electrode,sigthreshold,basename(cachefileset{threshidx}));
  
  if ~exist([mfilepath filesep 'tmp'],'dir')   mkdir(mfilepath,'tmp');   end
  
  channel = electrode; % To preserve old naming convention
  save(cachefileset{threshidx},'trialid','spikebin','spikematrix',...
    'sigthreshold','sigma','channel');
end

