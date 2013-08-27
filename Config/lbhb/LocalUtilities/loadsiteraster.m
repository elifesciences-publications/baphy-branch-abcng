function [r,tags,trialset,exptevents,sortextras]=...
    loadsiteraster(spkfile,startbin,stopbin,options)

persistent siteid meanresp

if nargin==2,
   options=startbin;
   startbin=[];
   stopbin=[];
end

channel=getparm(options,'channel',1);
unit=getparm(options,'unit',1);
rasterfs=getparm(options,'rasterfs',1000);
includeprestim=getparm(options,'includeprestim',0);
shuffletrials=getparm(options,'shuffletrials',0);
meansub=getparm(options,'meansub',1);
if ~isfield(options,'tag_masks'),
   tag_masks={};
elseif isnumeric(options.tag_masks),
   psthonly=options.tag_masks;
   tag_masks={};
else
   tag_masks=options.tag_masks;
end
psthonly=getparm(options,'psthonly',-1);
sorter=getparm(options,'sorter','');
includeincorrect=getparm(options,'includeincorrect',0);
mua=getparm(options,'mua',0);
lfpclean=getparm(options,'lfpclean',0);
lfp=getparm(options,'lfp',0);

r=[];
cellcount=length(channel);

for ii=1:cellcount,
   if lfp==0,
      params=[];
      params.channel=channel(ii);
      params.unit=unit(ii);
      params.rasterfs=rasterfs;
      params.psthonly=psthonly;
      params.tag_masks=tag_masks;
      params.includeprestim=includeprestim;
      [tr,tags,trialset,exptevents,sortextras]= ...
          loadspikeraster(spkfile,params);
   else
      parmfile=strrep(spkfile,'sorted/','');
      parmfile=strrep(parmfile,'.spk.mat','');
      %[r,tags,trialset,exptevents]=loadgammaraster(mfile,channel,...
      %          rasterfs,includeprestim,tag_masks,psthonly,lof,hif,envelope,trialrange)
      
      [tr,tags,trialset,exptevents]=loadgammaraster(parmfile,...
         channel(ii),rasterfs,includeprestim,tag_masks,psthonly,80,200,1);
   end
   if size(tr,3)==1,
      r=cat(3,r,tr);
   else
      r=cat(4,r,tr);
   end
end

if meansub,
   disp('subtracting mean response from each channel');
   
   thissiteid=basename(spkfile);
   thissiteid=strsep(thissiteid,'_');
   thissiteid=thissiteid{1}(1:(end-2));
   
   if ~strcmp(thissiteid,siteid) || size(r,3)~=length(meanresp),
      meanresp=squeeze(nanmean(nanmean(r,1),2));
      siteid=thissiteid;
   end
   for ii=1:size(r,3),
      r(:,:,ii)=r(:,:,ii)-meanresp(ii);
   end
end

if shuffletrials,
   disp('shuffling response trials');
   for ii=1:size(r,1),
      for jj=1:size(r,3),
         r(ii,:,jj)=shuffle(r(ii,:,jj));
      end
   end
end

if size(r,4)>1,
   return
end

if psthonly>0,
    r=permute(r,[3 1 2]);
    r=r(:,:);

    if exist('startbin','var'),
        if isempty(startbin) || startbin==0,
            startbin=1;
        end
        if ~exist('stopbin','var') || isempty(stopbin) || stopbin==0,
            stopbin=size(r,2).*size(r,3);
        elseif stopbin>size(r,2).*size(r,3),
            stopbin=size(r,2).*size(r,3);
        end
        r=r(:,startbin:stopbin);
    end
end
