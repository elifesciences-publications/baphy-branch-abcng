function ISI(spk, npoint,rate, plotflag, isifig)

for i = 1:length(spk), classvec(i) = ~isempty(spk{i,1}) | ~isempty(spk{i,2}); end
classvec = find(classvec);
numclass = length(classvec);

maxint = 50; % ms
binsize = 0.5; %ms
numbins = maxint/binsize;

eval(['figure(' 'isifig' ')'])
set(gcf,'Name',['JUSTIN - ISI'],'NumberTitle','off')
isi = zeros(numbins,numclass); 
for u = 1:numclass,
    if plotflag == 0
        tempi1 = spk{classvec(u),1};
    else
        tempi1 = spk{classvec(u),plotflag};
    end
 tempi1 = tempi1(:);
 bnd = [0;find(diff(ceil(tempi1/npoint)));length(tempi1)];
 isis = []; 
 for abc = 1:length(bnd)-1,
  data = tempi1(bnd(abc)+1:bnd(abc+1));
  isis = [isis; ceil(diff(data)/binsize*1000/rate)];
 end
 
  
 for abc = 1:numbins,
  isi(abc,u) = length(find(isis==abc));
 end
 ftitle=[];
 
 if plotflag ==0
     subplot(numclass,1,classvec(u))
     bar((1:numbins)*binsize,isi(:,u)) 
     if u==numclass, xlabel('Interval (ms)'),end,
     title(['Class ' num2str(classvec(u))],'FontWeight', 'bold')
     axis tight
 elseif plotflag ==1
     subplot(numclass,2,classvec(u)*2-1)
     bar((1:numbins)*binsize,isi(:,u)) 
     if u==numclass, 
         xlabel('Interval (ms)')
     elseif u==1 
         ftitle=['1st file   '];
     end
     title([ftitle,'Class ' num2str(classvec(u))],'FontWeight', 'bold')
     axis tight
 elseif plotflag ==2
     subplot(numclass,2,classvec(u)*2)
     bar((1:numbins)*binsize,isi(:,u)) 
     if u==numclass, xlabel('Interval (ms)'),elseif u==1, ftitle=['2nd file   '];end
     title([ftitle,'Class ' num2str(classvec(u))],'FontWeight', 'bold')
     if u==numclass, xlabel('Interval (ms)'),end;
     axis tight
 end
 

end 

clear tempi1; 

