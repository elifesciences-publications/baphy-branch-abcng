% function dms_plot(exptparams,events,count);
%
% exptparams can be results structure or name of mat file containing results
%
function dms_plot(exptparams,exptevents,count);

global cumres

if ~isstruct(exptparams),
    if strcmp(exptparams(end-1:end),'.m')
        tpwd=pwd;
        [pp,bb]=fileparts(exptparams);
        if ~isempty(pp),
            cd(pp);
        end
        clear exptparams
        eval(bb);
        cd(tpwd);
    else
        load(exptparams);
        exptparams=results;
    end
end

if ~isempty(cumres),
    exptparams.tonetriglick=exptparams.tonetriglick+cumres.tonetriglick;
    exptparams.ttlcount=exptparams.ttlcount+cumres.ttlcount;
    exptparams.volreward=exptparams.volreward+cumres.volreward;
end

tonecount=exptparams.tonecount;

if ~exist('count','var'),
    count=length(exptparams.bstat);
end

bstat=exptparams.bstat{count};
if size(bstat,2)==1,
    bstat=[bstat.*0 bstat bstat.*0];
elseif size(bstat,2)==2,
    bstat=[bstat bstat(:,2).*0];
   
end
berror=exptparams.res(count,2);
lickstart=exptparams.res(count,3);
lickstop=exptparams.res(count,4);
targidx=exptparams.res(count,5);
tstring=exptparams.tstring;
tonetriglick=exptparams.tonetriglick;
ttlcount=exptparams.ttlcount;

tt0=evtimes(exptevents,'TRIALSTART',count);
ttarg=evtimes(exptevents,['STIM,',tstring{targidx},'*'],count)-tt0;
[ttones,cc,tNotes]=evtimes(exptevents,['STIM*'],count);
ttones=ttones-tt0;
tmiss=evtimes(exptevents,'OUTCOME,EARLY',count)-tt0;
if length(tmiss)>0,
    disp('found early');
end

targset=unique(exptparams.targidx0);
targidxmax=min(4,length(targset));
sfigure(1);
clf
subplot(targidxmax+2,1,1);
cla
plot((1:length(bstat))'./exptparams.bfs,bstat(:,1)+2.2);
hold on
plot((1:length(bstat))'./exptparams.bfs,bstat(:,2)+1.1,'g');
plot((1:length(bstat))'./exptparams.bfs,bstat(:,3),'r');

if ~isempty(ttones),
    for ii=1:length(ttones),
        plot([ttones(ii) ttones(ii)],[0 3.2],'g:');
        tn=strsep(tNotes{ii},',',0);
        tn=tn{2};
        if isnumeric(tn),
            tn=num2str(tn);
        end
        text(ttones(ii)+0.01,0.5,tn);
    end
end
if ~isempty(tmiss),
    plot([tmiss(1) tmiss(1)],[0 3.2],'r-');
end
if ~isempty(ttarg),
    plot([ttarg ttarg],[0 3.2],'b--');
    plot([1 1].*lickstart+ttones(1),[0 3.2],'k--');
    plot([1 1].*lickstop+ttones(1),[0 3.2],'k--');
end
hold off
axis([-0.1 max([length(bstat)./exptparams.bfs lickstop+0.1])+1 -0.1 3.3]);
xlabel('time from sound onset (sec)');
ccount=sum(exptparams.res(1:count,2)==0);
title(sprintf('%s - dms0 - perf: %d/%d - h20: %0.1f',...
    exptparams.params.Ferret,ccount,count,exptparams.volreward));
legend('lick','paw');

subplot(targidxmax+2,1,2);
cc=cumsum(exptparams.res(:,2)==0)./(1:length(exptparams.res(:,2)))';
Navg=10;
cc2=conv(double(exptparams.res(:,2)==0),ones(Navg,1)./Navg);
cc2=cc2(1:end-Navg+1);
plot(cc);
hold on
plot(cc2,'g');
hold off
xlabel('trial');
set(gca,'YLim',[0,1]);
legend('cum corr','mvg avg',2);

for jj=1:targidxmax,
    subplot(targidxmax+2,1,jj+2);
    dms_plot_ttr(exptparams,targset(jj));
end

