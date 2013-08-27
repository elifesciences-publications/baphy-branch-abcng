% function results=stim_spectrum(mfile,channel,h,rasterfs[=200]);
% 
% h - handle of axes where plot should be displayed(default, new figure)
%
% returns:
% results.spect = freq X file matrix ... spectrum for each file;
%   .freq = frequency associrated with each entry in results.spect
%   .r= raw lfp data (time X rep X stimulus)
%   .tags = label for each different stimulus in r. ie, same length as size(r,3)
%
function results=stim_spectrum(mfile,channel,h,rasterfs);

if ~exist('h','var') || isempty(h),
    figure;
    h=gca;
    drawnow;
end

if ~exist('channel','var'),
    channel=1;
end
if ~exist('rasterfs','var'),
    rasterfs=200;
end

includeprestim=1;
tag_masks={'SPECIAL-TRIAL'};
[r, tags]=loadevpraster(mfile,channel,rasterfs,4,includeprestim,tag_masks,1);

LoadMFile(mfile);
[eventtime,evtrials,Note,eventtimeoff]=evtimes(exptevents,'STIMULATION,ON');

if length(eventtime)==0,
    error('no microstim events found in this file');
end

stimdur=eventtimeoff(1)-eventtime(1);
ralign=zeros((2+stimdur+2)*rasterfs,length(evtrials));
for tt=1:length(evtrials),
    t0=eventtime(tt)-2;
    s0=round(t0*rasterfs);
    e0=s0+length(ralign)-1;
    ralign(:,tt)=r(s0:e0,evtrials(tt));
end

rpre=ralign(1:round(2*rasterfs),:);
rpost=ralign((end-round(2*rasterfs)+1):end,:);
if 1,
    disp('excluding first 1 sec');
    rpre=rpre(round(rasterfs*1+1):end,:);
    rpost=rpost(round(rasterfs*1+1):end,:);
end

params.Fs=rasterfs;
params.err=[1 0.01];
params.trialave=1;

if size(rpre,1)>200,
    rpre=reshape(rpre,size(rpre,1)./2,2*size(rpre,2));
    rpost=reshape(rpost,size(rpost,1)./2,2*size(rpost,2));
end

[fpre,ll,fpree]=mtspectrumc(rpre,params);
[fpost,ll,fposte]=mtspectrumc(rpost,params);

sfigure(get(h,'Parent'));
set(get(h,'Parent'),'CurrentAxes',h)
%axes(h);
cla

semilogy(ll,[fpre fpost],'LineWidth',2);
hold on
semilogy(ll,[fpree' fposte'],'k-');
hold off
title(sprintf('%s - C%d',basename(mfile),channel),'Interpreter','none');
legend('pre','post');
xlabel('frequency (Hz)');
ylabel('lfp power');

results.f=ll;
results.fpre=fpre;
results.fpost=fpost;

