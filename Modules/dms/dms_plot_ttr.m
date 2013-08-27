% function dms_plot_ttr(exptparams,targidx);
%
% plot Tone-Triggered bar Release
%
function dms_plot_ttr(exptparams,targidx);

tstring=exptparams.tstring;
tonetriglick=exptparams.tonetriglick;
ttlcount=exptparams.ttlcount;
tonecount=size(ttlcount,2);

pcol={'r','b','k','g','c','r--','b--','k--','g--','c--','r:','b:','k:','g:','c:'};
ttcount=0;
jj=targidx;
if sum(sum(ttlcount(:,:,jj)))>0,
    flabels={};
    for ii=1:min([tonecount length(pcol)]),
        flabels{ii}=exptparams.tstring{ii};
        
        plot((1:size(tonetriglick,1))./exptparams.bfs,...
            tonetriglick(:,ii,jj)./(ttlcount(:,ii,jj)+(ttlcount(:,ii,jj)==0)),pcol{ii});
        hold on
        
        xp=(size(tonetriglick,1)+1)./exptparams.bfs+0.1+(ii-1)./tonecount.*0.5;
        plot([xp xp],[0.3 1.1],pcol{ii});
        if ii==1 | ii==round(tonecount/3) | ii==round(tonecount*2/3) | ii==tonecount,
            ht=text(xp,0.25,flabels{ii});
            set(ht,'HorizontalAlignment','right','Rotation',90);
        end
    end
    
    % plot target response in bold
    hl=plot((1:size(tonetriglick,1))./exptparams.bfs,...
        tonetriglick(:,jj,jj)./(ttlcount(:,jj,jj)+(ttlcount(:,jj,jj)==0)),pcol{jj});
    set(hl,'LineWidth',2);
    
    hold off
    axis([0 (length(tonetriglick)+1)./exptparams.bfs+0.6 -0.1 1.1]);
    ylabel(['targ=',flabels{jj}]);
    %legend(flabels);
end
xlabel('time after tone (s)');
