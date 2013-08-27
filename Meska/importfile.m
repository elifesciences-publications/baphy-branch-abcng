% function [Ws, Wt, Ss, St, st, spiketemp, spk, xaxis]= 
%     importfile(filename, path,ts, spkraw,num,chanNum, abaflag, extras);
%
% Ws, Wt, Ss, St - all returned empty
% st - vector of spike times
% spiketemp - corresponding segments of the raw signal
% spk - spike times for each different unit
% 
% modified SVD 2005-10-16 - added comments
%
function [Ws, Wt, Ss, St, st, spiketemp, spk, xaxis]=...
    importfile(filename, path,ts, spkraw,num,chanNum, abaflag, extras);

s = load(fullfile(path,filename));
spk = cell(num,1);
%spk = cell(s.Ncl,1);
if exist('extras','var') & isfield(extras,'refidxmap'),
   refidxmap=extras.refidxmap;
else
   refidxmap=[];
end
if exist('extras','var') & isfield(extras,'trialstartidx'),
   trialstartidxold=extras.trialstartidx;
else
   trialstartidxold=[];
end

if length(s.sortinfo)<16
   for u = 1:s.sortinfo{1}(1).Ncl,
      spk{u} = ((s.sortinfo{1}(u).unitSpikes(1,:)-1)*s.npoint + ...
                s.sortinfo{1}(u).unitSpikes(2,:))';
   end
   
elseif isfield(s,'baphy_fmt') & s.baphy_fmt,
   
   % otherwise newer format???
   trialstartidx=s.trialstartidx;
   
   if length(trialstartidx)>0 & sum(abs(trialstartidxold-trialstartidx))>0,
      warning('trialstartidx mismatch in imported file!!! using new one.');
      trialstartidx=trialstartidxold;
   end
   
   for u = 1:s.sortinfo{chanNum}{1}(1).Ncl,
      spk{u}=[];
      for trialidx=1:length(trialstartidx);
            tspikes=find(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)==trialidx);
            spk{u}=[spk{u}; ...
                    s.sortinfo{chanNum}{1}(u).unitSpikes(2,tspikes)'+...
                    trialstartidx(trialidx)-1];
      end
   end
elseif ~abaflag
   for u = 1:s.sortinfo{chanNum}{1}(1).Ncl,
      spk{u} = ((s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)-1)*s.npoint + ...
                s.sortinfo{chanNum}{1}(u).unitSpikes(2,:))';
      
      % un-Reorder the damn spike times!
      newspk=zeros(size(spk{u}));
      if length(refidxmap)>0,
         maxrefidx=max(refidxmap(:,1));
         repcount=sum(refidxmap(:,1)==1);
         oldstartidx=1;
         oldstepsize=s.npoint;
         for refidx=1:maxrefidx,
            ff=find(refidxmap(:,1)==refidx);
            for repidx=1:repcount,
               tspkidx=find(spk{u}>=oldstartidx & ...
                            spk{u}<oldstartidx+oldstepsize);
               oldtimes=spk{u}(tspkidx);
               newtimes=oldtimes-oldstartidx+refidxmap(ff(repidx),2);
               newspk(tspkidx)=newtimes;
               oldstartidx=oldstartidx+oldstepsize;
            end
         end
         spk{u}=sort(newspk);
      end
   end
else
    % calculate spike times from ABA files
    for x= 1:length(s.npoint)
        trialdur(x)= sum(s.npoint(1:x)*s.nsweep);
    end
    for u = 1:s.sortinfo{chanNum}{1}(1).Ncl,
        %spk{u}= (trialdur(max(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep)-1,1)).*min(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep)-1,1) +(((mod(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:),s.nsweep)+~mod(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:),s.nsweep)-1)*s.nsweep).*s.npoint(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep)))+s.sortinfo{chanNum}{1}(u).unitSpikes(2,:))'
        spk{u} = (trialdur(max(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep),2)-1).*min((ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep)-1),1) + ((mod(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:),s.nsweep)+(~mod(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:),s.nsweep)*s.nsweep)-1).*s.npoint(ceil(s.sortinfo{chanNum}{1}(u).unitSpikes(1,:)/s.nsweep))) + s.sortinfo{chanNum}{1}(u).unitSpikes(2,:))';
        %
        %length of cummulative sum of prior stimulus sweeps + (number of trials with in that sweep * duration of stimulus) + spike time with in that trial
        %
    end
end

% added SVD 2005-10-22 : recover xaxis used for sorting this file
xaxis=s.sortinfo{chanNum}{1}(1).xaxis;
if isempty(ts),
   ts=xaxis(1):xaxis(2);
end

Ws = []; Wt = []; Ss = []; St = [];
st = unique(cat(1,spk{:}));
spiketemp = spkraw(round(min(max((ts'*ones(1,length(st)))+...
                                 (ones(length(ts),1)*st'),1),length(spkraw))));


