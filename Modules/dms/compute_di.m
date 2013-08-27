% function [di,hits,fas,tsteps]=compute_di(stimtime,resptime,stimtype,stop_respwin,stepcount)
%
% stimtime: vector of time that each stimulus occurred
% resptime: vector of same size with response time on the trial
%           with that stimulus
% stimtype: 0=reference, 1=target
% stop_respwin: maximum allowed RT
% stepcount: number of bins from 0 to step_respwin
%
% created SVD 2008-07-16 based PBY's ideas.
%
function [di,hits,fas,tsteps]=compute_di(stimtime,resptime,stimtype,stop_respwin,stepcount)

if ~exist('stepcount','var'),
   stepcount=50;
end


tsteps=[linspace(0,stop_respwin,stepcount-1) inf];
hits=zeros(stepcount,1);
fas=zeros(stepcount,1);
for tt=1:stepcount,
   hits(tt)=sum(stimtype==1 & resptime-stimtime<=tsteps(tt));
   fas(tt)=sum(stimtype==0 & resptime-stimtime<=tsteps(tt));
end

% total number of targets presented, ie, one for each hit and miss trial
targcount=sum(stimtype==1);
% total number of references = total stim minus targcount
refcount=sum(stimtype==0);

hits=hits./(targcount+(targcount==0));
fas=fas./(refcount+(refcount==0));
hits(end)=1;
fas(end)=1;

w=([0;diff(fas)]+[diff(fas);0])./2;
di=sum(w.*hits);
w2=([0;diff(hits)]+[diff(hits);0])./2;
di2=1-sum(w2.*fas);

di=(di+di2)./2;
