


load e:\topaz\topaz-2005-10-24-dms0-4.mat

ttidx=find(tt>=0.3 & tt<=0.7);
[ss,ii]=sort(params.freqs);
meanlick=squeeze(mean(cumres.tonetriglick(ttidx,ii,:)./cumres.ttlcount(ttidx,ii,:)));
stdlick=zeros(size(meanlick));

for targidx=1:2,
    for jj=1:size(meanlick,1);
        stdlick(jj,targidx)=std([ones(1,round(meanlick(jj,targidx)*100)) ...
            zeros(1,100-round(meanlick(jj,targidx)*100))]);
    end
end
stdlick=stdlick./sqrt(squeeze(cumres.ttlcount(ttidx(1),ii,:)));

figure(1);
clf

errorbar(.7:.155:1.35,meanlick(:,1),stdlick(:,1),'k+');
hold on
errorbar(1.7:.155:2.35,meanlick(:,2),stdlick(:,2),'k+');
ll=bar(meanlick');
hold off
colormap(hot);
legend(ll,'600','1200','2400','4800','9600',-1);
ylabel('fraction of time licking');