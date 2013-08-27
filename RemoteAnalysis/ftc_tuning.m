% function [bf,lat,rm,freq,r]=ftc_tuning(parmfile,channum,unit,plotaxes);
%
% tuning analysis for sorted FTC data
%
function [bf,lat,rm,freq,r]=ftc_tuning(parmfile,channum,unit,plotaxes);

if ~exist('plotaxes','var'),
   plotaxes=[];
end
options=[];
options.rasterfs=1000;
options.includeprestim=1;
options.tag_masks={'Reference'};
options.channel=channum;
options.unit=unit;
fprintf('loading FTC raster for %s\n',...
        basename(parmfile));
if unit==0,
   [r,tags,trialset,exptevents]=loadevpraster(parmfile,options);
else
   [r,tags,trialset,exptevents]=loadspikeraster(parmfile,options);
end

% figure out pre- and post- windows
tpre=evtimes(exptevents,'PreStimSilence ,*');
tstart=evtimes(exptevents,'Stim ,*');
tpost=evtimes(exptevents,'PostStimSilence ,*');
startbin=round(tstart(1).*options.rasterfs);
stopbin=min(startbin+80,round(tpost(1).*options.rasterfs));
finalbin=size(r,1);

if size(r,2)>1,
   r=r(:,1,:);
   %ff=find(~isnan(r(1,2,:)));
   %r=cat(3,r(:,1,:),r(:,2,ff));
   %tags={tags{:} tags{ff}};
end
r=r(:,:);

unsortedtags=zeros(length(tags),1);
for cnt1=1:length(tags),
   temptags = strrep(strsep(tags{cnt1},',',1),' ','');
   unsortedtags(cnt1) = str2num(temptags{2});
end

[sortedtags, index] = sort(unsortedtags); % sort the numeric tags
tags={tags{index}};
r=r(:,index);


mb=mean(mean(r(1:(startbin-1),:)));
m=squeeze(mean(r(startbin:(stopbin-1),:)));
lt=log2(sortedtags);
rlt=linspace(min(lt),max(lt),length(lt).*2)';
rm=interp1(lt,m,rlt);
if length(rm)>80,
   rm=gsmooth(rm,10,0);
else
   rm=gsmooth(rm,5,0);
end
freq=2.^rlt;

maxf=min(find(rm==max(rm)));
bf=round(2.^rlt(maxf));
if rm(maxf)-mb>2.*std(rm),
   fprintf('FTC peak at %.0f Hz\n',bf);
else
   fprintf('TC peak at %.0f Hz not significant\n',2.^rlt(maxf));
   bf=0;
end

maxrange=(-10:10)+round(maxf./2);
if min(maxrange)<1,
   maxrange=maxrange-min(maxrange)+1;
elseif max(maxrange)>size(r,2),
   maxrange=maxrange-max(maxrange)+size(r,2);
end

rpeak=r(startbin:(stopbin-1),maxrange);
rpeak=gsmooth(rpeak,[5,0.01]);
mpeak=mean(rpeak,2);
epeak=std(rpeak,0,2)./sqrt(length(maxrange));

sigmod=find(mpeak-mb>epeak.*2);
if length(sigmod)>2,
   latbin=sigmod(3);
   lat=round(latbin.*1000./options.rasterfs);
   fprintf('onset latency %d ms\n',lat);
else
   latbin=0;
   lat=0;
   fprintf('no significant onset latency\n');
end

if isempty(plotaxes),
   sfigure(2);
   clf
   subplot(1,2,1);
else
   axes(plotaxes(1));
   cla;
end
plot(rm);
hold on
plot([1 length(rm)],[mb mb],'k--');
plot([maxf maxf],[0 max(rm)],'r--');
hold off
axis tight
title(sprintf('%s - BF %d Hz',basename(parmfile),bf),...
      'Interpreter','none');
xt=get(gca,'XTick');
set(gca,'XTick',xt,'XTickLabel',round(2.^rlt(xt)));


if isempty(plotaxes),
   subplot(1,2,2);
else
   axes(plotaxes(2));
   cla;
end

errorbar(mpeak,epeak);
hold on
plot([1 length(mpeak)],[mb mb],'k--');
plot([latbin latbin],[0 max(mpeak)+max(epeak)],'r--');
hold off
axis tight
title(sprintf('Lat %d ms',lat));
