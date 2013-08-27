
function mean_meska(spiketemp, st, ts, spk, fname, direc, meanfig, plotflag)
for i = 1:length(spk), classvec(i) = ~isempty(spk{i,1}) | ~isempty(spk{i,2}); end
classvec = find(classvec);
numclass = length(classvec);

for abc = 1:numclass,
 if plotflag ==0
     temps = spiketemp(:,find(ismember(st,spk{abc,1})));
 else
    temps = spiketemp(:,find(ismember(st,spk{abc,plotflag}))); 
end
  if ~isempty(temps) %| ~isempty(temps2),
   tem(:,abc) = mean(temps,2);
   temstd(:,abc)= std(temps,0,2);
else
   tem(:,abc) = zeros(length(ts),1);
   temstd(:,abc)= zeros(length(ts),1);
end
end

set(gcf,'Name','JUSTIN - Combined Mean Waveforms ','NumberTitle','off')
eval(['figure(' 'meanfig' ')'])
if plotflag > 0
    subplot(2,1,plotflag)
end
plot(ts,tem)
hold on
ph = plot(ts,tem+temstd,'+')
set(ph,'MarkerSize',2)
%set(ph,'Marker','o')
title([direc,'\_',fname])
grid on 
%legend(num2str((1:numclass)))
clear temps %temps2


