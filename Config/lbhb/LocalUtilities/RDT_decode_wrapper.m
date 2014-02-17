    

cellids={'oys027b-c1','oys027c-c1','oys028a-c1','oys033a-a1',...
         'oys033b-b1','oys033c-b1','oys033c-b2','oys034b-a1',...
         'oys027b-c2',...
         'oys027c-c2','oys033a-b1','oys033b-a1','oys030b-a1',...
         'oys031b-a2','oys032a-a1','oys028a-c2',...
         'oys033b-a2'};
close all

dpsum=zeros(4,length(cellids),2);
for ii=1:length(cellids),
    for active=0:1,
        dpsum(:,ii,active+1)=RDT_decoder(cellids{ii},active,1);
    end
end

ff=find(~isnan(dpsum(1,:,1)));
dpsolo=cat(1,squeeze(dpsum(1,ff,:)),squeeze(dpsum(3,ff,:)));
dpolap=cat(1,squeeze(dpsum(2,ff,:)),squeeze(dpsum(4,ff,:)));
figure;
subplot(2,1,1);
plot(dpsolo(:,1),dpsolo(:,2),'.');
hold on
plot([0 1],[0 1],'k--');
axis square equal

subplot(2,1,2);
plot(dpolap(:,1),dpolap(:,2),'.');
hold on
plot([0 1],[0 1],'k--');
axis square equal
