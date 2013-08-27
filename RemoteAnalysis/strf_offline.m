% function strf = strf_offline(mfile,spikefile,channum,unitnum);
%

% quick & dirty torc reverse correlation
%
function strfest = strf_offline(mfile,spkfile,chanNum,unitNum);

% coarsely sampled stim
[ststims,stimparam]=loadtorc(mfile);

% get spike raster
[r,tags]=loadspikeraster(spkfile,chanNum,unitNum,1000,1,{'torc','ref'},-1);

% compute STRF quick & dirty
stdef = 100; %stimparam.basep;
etdef = stimparam.stonset + stimparam.stdur; 
% keyboard
[strfest,indstrfs,resp]=pastspec(r(round(stimparam.stonset)+1:round(etdef),:,:),...
                                 ststims,stimparam.basep,stdef,stimparam.stdur,...
                                 stimparam.hfreq,stimparam.nrips,1,0);
t=title(sprintf('%s: chan %d unit %d',basename(mfile),chanNum,unitNum),...
        'interpreter','none');

drawnow

