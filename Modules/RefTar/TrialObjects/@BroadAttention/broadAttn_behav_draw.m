function broadAttn_behav_draw(summary1, summary2, reffreqvec, reflengthvec,timevec,lickcell)

figure(1)
subplot(3,1,1)
bar(summary2','stacked');
set(gca,'XTickLabel',reffreqvec)
legend('False','Hit','Miss')


subplot(3,1,2)
bwidth = 0.1;
groupnum = length(reflengthvec);
for i = 1 : groupnum
bar([i:5:(i+5*(length(reffreqvec) - 1))], summary1(:,i:groupnum:end)','stacked','BarWidth',bwidth);
hold on
end
set(gca,'XTickLabel',reffreqvec)
set(gca,'XTick',[i:5:(i+5*(length(reffreqvec) - 1))])
legend('False','Hit','Miss')
hold off


subplot(3,1,3)
figurewidth = length(reffreqvec) + 1;
for i = 1 : length(timevec)
    line([0,figurewidth],[timevec(i),timevec(i)],'LineStyle','-','Color',[.8 .8 .8]);
    hold on
end
positionvec = 1 : length(reffreqvec);
shapevec = ['o','p','*'];
offsetvec = [-0.2, 0, 0.2];
colorcell{1} = [0 0 1];
colorcell{2} = [1 0 0];
colorcell{3} = [0 1 0];
for i = 1 : length(reffreqvec)
    for j = 1 : length(reflengthvec);
        lickvec = lickcell{(i - 1)*length(reflengthvec) + j};
        if isempty(lickvec)
            contine
        end
        for k = 1 : length(lickvec)
            if lickvec(k) > timevec(j+1)
                colorflag = 1;
            else
                colorflag = 2;
            end
            plot(positionvec(i) + offsetvec(j),lickvec(k),'Marker',shapevec(j),'MarkerSize',6,'MarkerEdgeColor',colorcell{colorflag});
            hold on
        end
    end
end
axis([0 figurewidth 0 timevec(end)+ 2])
set(gca,'XTick',positionvec)
set(gca,'XTickLabel',reffreqvec)
           
