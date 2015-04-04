function MultiFileRT(parmfile,regen);

if ~exist('regen','var'),
    regen=0;
end

for ii=1:length(parmfile),
    if regen
        exptparams=replicate_behavior_analysis(parmfile{ii});
        exptparams.TrialObject=get(exptparams.TrialObject);
    else
        LoadMFile(parmfile{ii});
    end
    tcount=length(exptparams.Performance)-1;
    if ii==1,
        Performance=exptparams.Performance(1:tcount);
        FirstRefLick=exptparams.FirstLick.Ref(1:tcount);
        FirstCatchLick=exptparams.FirstLick.Catch(1:tcount);
    else
        Performance=cat(2,Performance,exptparams.Performance(1:tcount));
        FirstRefLick=cat(2,FirstRefLick,exptparams.FirstLick.Ref(1:tcount));
        FirstCatchLick=cat(2,FirstCatchLick,exptparams.FirstLick.Catch(1:tcount));
    end
    
end

TarResponseWinStart=cat(1,Performance.TarResponseWinStart);
CatResponseWinStart=cat(1,Performance.CatResponseWinStart);

uWarningTrial=cat(1,Performance.uWarningTrial);
uReactionTime=cat(1,Performance.uReactionTime);
if sum(~isnan(FirstCatchLick)),
    cReactionTime=FirstCatchLick(:);
    catch_trial_count=sum(~isnan(cat(1,Performance.FirstCatchTime)));
    LateCatTime=nanmax(uReactionTime,[],2);
    LateCatTime=LateCatTime+TarResponseWinStart-CatResponseWinStart
    cReactionTime=nanmin([cReactionTime LateCatTime],[],1);
elseif isfield(Performance,'cReactionTime'),
    cReactionTime=cat(1,Performance.cReactionTime);
    
    LateCatTime=nanmax(uReactionTime,[],2);
    LateCatTime=LateCatTime+TarResponseWinStart-CatResponseWinStart
    cReactionTime=nanmin([cReactionTime LateCatTime],[],1);
    
    catch_trial_count=sum(~isnan(cat(1,Performance.FirstCatchTime)));

    
else
    cReactionTime=uReactionTime.*nan;
    catch_trial_count=0;
end
BinSize = 0.04;
MaxBinTime=nanmax([uReactionTime(:);cReactionTime(:)])+BinSize;
MaxBinTime=1.1+BinSize;

TarWinStart=exptparams.UniqueTarResponseWinStart(:);

rReactionTime=[];

for ii=1:length(FirstRefLick);
    dd=FirstRefLick(ii)-TarWinStart(TarWinStart<Performance(ii).TarResponseWinStart);
    dd=dd(isnan(dd) | dd>0);
    
    rReactionTime=cat(1,rReactionTime,dd);
end

figure;
subplot(2,2,1);
TarCount=size(uWarningTrial,2);

colormtx=[0 0 0;
   255 191 117;
   0 0 255;
   237 41 36;
   204 102 153]./255;

%colormtx=colormtx(round(linspace(1,64,TarCount+2)),:);
CumHist=[];
sLegend=cell(TarCount,1);
for ii=1:TarCount,
    ff=find(uWarningTrial(:,ii));
    h1=cumsum(hist(uReactionTime(ff,ii),0:BinSize:MaxBinTime)');
    CumHist=[CumHist h1./length(ff)];
    stairs(0:BinSize:MaxBinTime,CumHist(:,ii),'color',colormtx(ii,:),'linewidth',1);
    hold on
    sLegend{ii}=sprintf('%d dB',exptparams.TrialObject.RelativeTarRefdB(ii));
end

ff=find(~isnan(cReactionTime));
if ~isempty(ff),
    h1=cumsum(hist(cReactionTime(ff),0:BinSize:MaxBinTime)');
    CumHist=[CumHist h1./catch_trial_count];
    stairs(0:BinSize:MaxBinTime,CumHist(:,end),'color',colormtx(end-1,:),'linewidth',1);
    sLegend{end+1}=sprintf('Catch');
end

LateHitTime=nanmax(uReactionTime,[],2);
LateHitTime=LateHitTime+0.5;
LateHitTime(LateHitTime>MaxBinTime)=nan;

%ff=find(~isnan(rReactionTime));
%h1=cumsum(hist(rReactionTime(ff),0:BinSize:MaxBinTime)');
%CumHist=[CumHist h1./length(rReactionTime)];
%stairs(0:BinSize:MaxBinTime,CumHist(:,end),'color',colormtx(end,:),'linewidth',1);

AllRT=[rReactionTime; LateHitTime; nan*ones(length(Performance),1)];
ff=find(~isnan(AllRT));
h1=cumsum(hist(AllRT(ff),0:BinSize:MaxBinTime)');
AllRTHist=[h1./length(AllRT)];
stairs(0:BinSize:MaxBinTime,AllRTHist,'color',colormtx(end,:),'linewidth',1);
CumHist=[CumHist AllRTHist];

sLegend{end+1}=sprintf('FA');

hold off

legend(sLegend,'Location','NorthWest');
xlabel('time (s)');
ylabel('cum. prob. of response');
title(basename(parmfile{1}),'Interpreter','None');
axis tight square

subplot(2,2,2);
CumHist=cat(1,zeros(1,size(CumHist,2)),CumHist,ones(1,size(CumHist,2)));

plot([0 1],[0 1],'k--','linewidth',0.5);
hold on
for ii=1:size(CumHist,2)-1,
   plot(CumHist(:,end),CumHist(:,ii),'color',colormtx(ii,:),'linewidth',1);
end
hold off
xlabel('p(FA)');
ylabel('p(Hit)');
axis tight square



