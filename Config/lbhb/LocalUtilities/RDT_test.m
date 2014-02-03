
cellids={'oys022b-a1','oys022b-b1','oys022b-b2','oys022b-c1',...
         'oys022c-a1','oys022c-c1',...
         'oys023a-a1','oys023a-b1',...
         'oys024c-a1','oys024c-a2',...
         'oys025b-a1','oys025b-b1'};
mdrsum=[];
mfr1=[];
mfr2=[];
mft1=[];
mft2=[];
for cc=1:length(cellids),
    cellid=cellids{cc};
    [a0,a,b,c,d]=RDT_sim(cellid);
    mdrsum=cat(1,mdrsum,a0);
    mfr1=cat(1,mfr1,a);
    mfr2=cat(1,mfr2,b);
    mft1=cat(1,mft1,c);
    mft2=cat(1,mft2,d);
end

figure;
plot([-0.02 .12],[-0.02 .12],'k--');
hold on
plot(mdrsum(:,5),mdrsum(:,4),'.','Color',[0.8 0.8 0.8]);
plot(mdrsum(:,2),mdrsum(:,1),'k.');
hold off
axis tight square
