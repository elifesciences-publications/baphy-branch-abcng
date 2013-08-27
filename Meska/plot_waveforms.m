function plot_waveforms

global SPKRAW UNITMEAN UNITSTD UNITCOUNT XAXIS PCC PCS SPIKESET UPROJ 
global SPKCLASS SPKCOUNT KCOL C0 CELLIDS EXTRAS EVENTTIMES NEWSNR FILEDATA
persistent resplots


classcount=max(SPKCLASS);

NEWSNR=zeros(classcount,1);
st=XAXIS(1):XAXIS(2);

figure
    
    spmatch=find(SPKCLASS==1);
    spnmatch=find(SPKCLASS==2);
    
    testidx=spnmatch(round(linspace(1,length(spnmatch),50)));
    plot(st,SPIKESET(:,testidx),'Color',[0.8 0.8 0.8]);

    hold on
    
    testidx=spmatch(round(linspace(1,length(spmatch),50)));
    plot(st,SPIKESET(:,testidx),'Color',[0 0 0]);
    
    
         plot(st([1 end]),-EXTRAS.sigma.*EXTRAS.sigthreshold.*[1 1],'k--');
    hold off
ht=title(sprintf('%s - ch %d',basename(FILEDATA.evpfile),FILEDATA.channel));
set(ht,'Interpreter','none');

% $$$      isi=diff(EVENTTIMES(spmatch))./EXTRAS.rate*1000;
% $$$     isi=isi(find(isi<30));
% $$$     hist(isi,linspace(0,50,51));
% $$$     if jj==1,
% $$$         title('ISI');
% $$$     end
% $$$     ta=axis;
% $$$     axis([0 30 ta(3:4)]);

