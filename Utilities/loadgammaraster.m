% function [r,tags,trialset,exptevents]=loadgammaraster(mfile,channel,...
%      rasterfs,includeprestim,tag_masks,psthonly,lof,hif,envelope,trialrange)
%
% svd 2011, ripped off loadevpraster
%
function [r,tags,trialset,exptevents]=loadgammaraster(mfile,channel,...
        rasterfs,includeprestim,tag_masks,psthonly,lof,hif,envelope,trialrange)

if ~isempty(findstr(mfile,'sorted')),
   mfile=strrep(mfile,'sorted/','');
   mfile=strrep(mfile,'spk.mat','m')
end

if ~exist('psthonly','var'),
   psthonly=-1;
end
if ~exist('lof','var'),
   lof=100;
end
if ~exist('hif','var'),
   hif=500;
end
if hif==0,
   hif=rasterfs;
end
if ~exist('envelope','var'),
   envelope=1;
end

if envelope,
   tfs=hif.*2;
   
   options.channel=channel;
   options.rasterfs=tfs;
   options.includeprestim=includeprestim;
   options.tag_masks=tag_masks;
   options.lfp=1;
   if exist('trialrange','var'),
      options.trialrange=trialrange;
   end
   
   [r0,tags,trialset,exptevents]=loadevpraster(mfile,options);
   FILTER_ORDER=round(tfs./lof.*2.5).*2;
   NN=tfs./2;
   
   f_hp = firls(FILTER_ORDER,[0 (0.95.*lof)/NN lof/NN 1],[0 0 1 1])';
   
   r=filtfilt(f_hp,1,r0); 
   r=r.*(r>0);
   f_lp = firls(FILTER_ORDER,[0 (0.95.*rasterfs)/NN rasterfs/NN 1],[1 1 0 0]);
   r=filtfilt(f_lp,1,r); 
   
   step=tfs./rasterfs;
   r=r(round((step./2):step:size(r,1)),:,:);
else
   % don't extract envelope, just straight band-pass filter
   tfs=rasterfs;
   
   options.channel=channel;
   options.rasterfs=tfs;
   options.includeprestim=includeprestim;
   options.tag_masks=tag_masks;
   options.lfp=1;
   if exist('trialrange','var'),
      options.trialrange=trialrange;
   end
   
   [r0,tags,trialset,exptevents]=loadevpraster(mfile,options);
   
   if (lof>0 || hif<rasterfs)
      FILTER_ORDER=floor(min(size(r0,1)./4,tfs./lof.*5));
      NN=tfs./2;
      
      f_bp = firls(FILTER_ORDER,[0 0.95.*lof lof hif hif/0.99 NN]./NN,...
                   [0 0 1 1 0 0])';
      r=filtfilt(f_bp,1,r0); 
   else
      r=r0;
   end
   
   if 0 && rasterfs<1000,
      disp('nan-ing out onset response (250 ms)');
      r(1:round(0.25.*rasterfs),:,:)=nan;
   end
end

if psthonly==-1,
   % do nothing?
   
elseif psthonly,
   % time/record all in one long vector, averaged over reps
   r=nanmean(permute(r,[2 1 3]));
   r=r(:);
else
   % time/record X rep
   r=permute(r,[1 3 2]);
   r=reshape(r,size(r,1)*size(r,2),size(r,3));
end
