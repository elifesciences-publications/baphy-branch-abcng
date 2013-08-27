% function results=lfp_cohere(mfiles,options)
%
% mfiles = cell array of parm file names
% options structure can include:  
%    .channels [=[1 2]]
%    .h: figure number where plots should be displayed [=gcf]
%    .tag_masks [={'Reference','TORC'}]
%    .fs[=600]
%    .splitbytarget[=0] special case, divide data based on target ID
%
% returns: not complete yet
%
% created SVD 2007-10-01
%
function results=lfp_cohere(mfiles,options);

if ~iscell(mfiles),
    mfiles={mfiles};
end
mfilecount=length(mfiles);
LoadMFile(mfiles{1});

if ~exist('options','var'),
   options=[];
end
options.h=getparm(options,'h',gcf);
options.channels=getparm(options,'channels',...
                         1:globalparams.NumberOfElectrodes);
options.tag_masks=getparm(options,'tag_masks',{'Reference','TORC'});
options.rasterfs=getparm(options,'rasterfs',400);
options.splitbytarget=getparm(options,'splitbytarget',0);
options.includeincorrect=getparm(options,'includeincorrect',0);
options.includeprestim=getparm(options,'includeprestim',[0.3 0.4]);
options.startwin=getparm(options,'startwin',0);
options.stopwin=getparm(options,'stopwin',0.5);

channels=options.channels;
sfigure(options.h);
drawnow;

fprintf('Analyzing channels %s (fs=%d)\n',...
        num2str(channels),options.rasterfs);



% figure out if we want to split based on target
if options.splitbytarget,
   disp('Splitting data by target id');
   newmfiles={};
   targset={};
   targdsc={};
   tcounter=zeros(size(mfiles));
   for midx=1:mfilecount,
      LoadMFile(mfiles{midx});
      Note=evunique(exptevents,'*TARG*');
      if length(Note)==0,
         Note={'Stim*'};
      end
      tcounter(midx)=length(Note);
      for ii=1:length(Note),
         if strcmpi(Note{ii}(1:4),'Stim')
            newmfiles{length(newmfiles)+1}=mfiles{midx};
            targset{length(targset)+1}=Note{ii};
            tn=strsep(Note{ii},',',1);
            if length(tn)>1,
               targdsc{length(targdsc)+1}=tn{2};
            else
               targdsc{length(targdsc)+1}=tn{1};
            end
         end
      end
   end
   mfiles=newmfiles;
   mfilecount=length(newmfiles);
else
   targset=cell(mfilecount,1);
end


lcol={'b-','r-','k-','g-'};
fns=mfiles;
rout=cell(mfilecount,1);
rprocessed=cell(mfilecount,1);
sprocessed=cell(mfilecount,1);
sout=cell(mfilecount,1);
rspect=[];
rspecterr=[];
shortmfile=cell(mfilecount,1);

tarfreq=zeros(mfilecount,1);

for midx=1:mfilecount,
    shortmfile{midx}=basename(mfiles{midx});
    if midx==1 || ~strcmp(mfiles{midx},mfiles{midx-1}),
       clear exptparams
       LoadMFile(mfiles{midx});
    end
    if isfield(exptparams,'TargetObject') && ...
          isfield(exptparams.TargetObject,'Frequencies'),
       tarfreq(midx)=exptparams.TargetObject.Frequencies(1);
       
    end
    if ~options.splitbytarget,
       [pp,bb,ee]=fileparts(mfiles{midx});
       if tarfreq(midx)>0,
          targdsc{midx}=[bb '-' num2str(tarfreq(midx))];
       else
          targdsc{midx}=bb;
       end
    end
    
    disp('Loading LFP...');
    r=[];
    sp=[];
    for ii=1:length(channels),
       loptions=options;
       loptions.channel=channels(ii);
       loptions.lfp=1;
       if options.splitbytarget,
          [targtime,targtrial] = evtimes(exptevents,targset{midx});
          loptions.trialrange=unique(targtrial);
       end
       [tr, tags]=loadevpraster(mfiles{midx},loptions);
       r=cat(4,r,tr);
       
       % load multi-unit data
       soptions=loptions;
       soptions.lfp=0;
       soptions.sigthreshold=3.5;
       
       %soptions.sorted=1;
       %soptions.unit=1;
       %[pp,bb,ee]=fileparts(mfiles{midx});
       %spkfile=[pp filesep 'sorted' filesep bb '.spk.mat'];
       
       %[ts, tags]=loadspikeraster(spkfile,soptions);
       [ts, tags]=loadevpraster(mfiles{midx},soptions);
       sp=cat(4,sp,ts);
    end
    if isempty(r),
       return
    end
    tic;
    
    if length(options.includeprestim)<2,
       [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PreStim*'],1);
       if length(eventtime)>0,
          PreStimSilence=eventtimeoff(1)-eventtime(1);
          [eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,['PostStim*'],1);
          PostStimSilence=eventtimeoff(1)-eventtime(1);
       else
          PreStimSilence=0.4;
          PostStimSilence=0.8;
       end
    else
       PreStimSilence=options.includeprestim(1);
       PostStimSilence=options.includeprestim(2);
    end
    StimDur=size(r,1)./options.rasterfs-PreStimSilence-PostStimSilence;
    
    starttime=PreStimSilence+options.startwin;
    stoptime=PreStimSilence+options.stopwin;
    ss=round(starttime.*options.rasterfs)+1;
    ee=round(stoptime.*options.rasterfs);
    fprintf('PreStimSilence: %.2f  StimDur: %.2f  PostStimSilence: %.2f\n',...
            PreStimSilence, StimDur, PostStimSilence);
    
    fprintf('restricting spectrum to %.2f - %.2f sec window after stim onset\n',...
        ss/options.rasterfs-PreStimSilence,ee/options.rasterfs-PreStimSilence);
    
    sfigure(options.h);
    if midx==1,
        clf;
    end
    
    tr=r(ss:ee,:,:,:);
    tr=reshape(tr,size(tr,1),size(tr,2)*size(tr,3),size(tr,4));
    keepidx=find(sum(isnan(tr(:,:,1)),1)==0);
    rprocessed{midx}=tr(:,keepidx,:);
    
    ts=sp(ss:ee,:,:,:);
    ts=reshape(ts,size(ts,1),size(ts,2)*size(ts,3),size(ts,4));
    sprocessed{midx}=ts(:,keepidx,:);
    
    fprintf('keeping %d reps for %s\n',size(tr,2),shortmfile{midx});
end

keyboard

cohere_plot(rprocessed,shortmfile,options.rasterfs,sprocessed,channels);

return



siteid=basename(mfiles{1});
results.siteid=siteid(1:7);

results.spect=rspect;
results.specterr=rspecterr;
results.freq=rfreq;
results.rawlfp=rout;
results.tags=tags;
results.fs=options.rasterfs;
results.startwin=starttime;
results.stopwin=stoptime;
results.specgram=sout;
results.sgtime=ttt;
results.sgfreq=tff;

disp('lfp_cohere complete');

