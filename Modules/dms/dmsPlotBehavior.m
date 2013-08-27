% function dmsPlotBehavior(summ,count);
%
% summ can be results structure or name of mat file containing results
%
function dmsPlotBehavior(summ,count);

global cumres

if ~isstruct(summ),
    load(summ);
    summ=results;
end

if ~isempty(cumres),
    summ.tonetriglick=summ.tonetriglick+cumres.tonetriglick;
    summ.ttlcount=summ.ttlcount+cumres.ttlcount;
    summ.volreward=summ.volreward+cumres.volreward;
end
        
tonecount=length(summ.params.freqs);

if ~exist('count','var'),
    count=length(summ.bstat);
end

bstat=summ.bstat{count};
berror=summ.res(count,2);
lickstart=summ.res(count,3);
lickstop=summ.res(count,4);
targidx=summ.res(count,5);
tstring=summ.tstring;
tonetriglick=summ.tonetriglick;
ttlcount=summ.ttlcount;

tt0=evtimes(summ.events,'TRIALSTART',count);
ttarg=evtimes(summ.events,tstring{targidx},count)-tt0;

targidxmax=size(ttlcount,3);
clf
subplot(targidxmax+2,1,1);
cla
plot((1:length(bstat))'./summ.bfs,bstat(:,1)+2.2);
hold on
plot((1:length(bstat))'./summ.bfs,bstat(:,2)+1.1,'g');
plot((1:length(bstat))'./summ.bfs,bstat(:,3),'r');

if ~isempty(ttarg),
    plot([ttarg ttarg],[0 3.2],'b:');
    plot([1 1].*lickstart+ttarg,[0 3.2],'k:');
    plot([1 1].*lickstop+ttarg,[0 3.2],'k:');
end
hold off
axis([-0.1 max([length(bstat)./summ.bfs lickstop+0.1])+1 -0.1 3.3]);
xlabel('time from sound onset (sec)');
ccount=sum(summ.res(1:count,2)==0);
title(sprintf('%s - dms0 - perf: %d/%d - h20: %0.1f',...
    summ.params.animal,ccount,count,summ.volreward));
legend('light','lick','pump');

subplot(targidxmax+2,1,2);
cc=cumsum(summ.res(:,2)==0)./(1:length(summ.res(:,2)))';
Navg=10;
cc2=conv((summ.res(:,2)==0),ones(Navg,1)./Navg);
cc2=cc2(1:end-Navg+1);
plot(cc);
hold on
plot(cc2,'g');
hold off
xlabel('trial');
legend('cum corr','mvg avg',2);
drawnow

pcol={'r','b','k--','g--','c--','k:','g:','c:'};
for jj=1:targidxmax,
    subplot(targidxmax+2,1,jj+2);
    for ii=1:tonecount,
        plot((1:length(tonetriglick))./summ.bfs,...
            tonetriglick(:,ii,jj)./(ttlcount(:,ii,jj)+(ttlcount(:,ii,jj)==0)),pcol{ii});
        hold on
    end
    hold off
    axis([0 (length(tonetriglick)+1)./summ.bfs -0.1 1.1]);
    ylabel(['targ=',tstring{jj}]);
    %if ii<tonecount,
    %    set(gca,'XTickLabel',[]);
    %end
end
xlabel('time after tone (s)');
