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
    else
        Performance=cat(2,Performance,exptparams.Performance(1:tcount));
        FirstRefLick=cat(2,FirstRefLick,exptparams.FirstLick.Ref(1:tcount));
    end
    
end


uWarningTrial=cat(1,Performance.uWarningTrial);
uReactionTime=cat(1,Performance.uReactionTime);
if isfield(Performance,'cReactionTime'),
    cReactionTime=cat(1,Performance.cReactionTime);
    catch_trial_count=sum(~isnan(cat(1,Performance.FirstCatchTime)));
else
    cReactionTime=uReactionTime.*nan;
    catch_trial_count=0;
end
BinSize = 0.04;
MaxBinTime=nanmax([uReactionTime(:);cReactionTime(:)])+BinSize;

TarWinStart=exptparams.UniqueTarResponseWinStart(:);
rReactionTime=[];

for ii=1:length(FirstRefLick);
    dd=FirstRefLick(ii)-TarWinStart(TarWinStart<Performance(ii).TarResponseWinStart);
    dd=dd(isnan(dd) | dd>0);
    rReactionTime=cat(1,rReactionTime,dd);
end


figure;

TarCount=size(uWarningTrial,2);
colormtx=jet;
colormtx=colormtx(round(linspace(1,64,TarCount+2)),:);
CumHist=[];
sLegend=cell(TarCount,1);
for ii=1:TarCount,
    ff=find(uWarningTrial(:,ii));
    h1=cumsum(hist(uReactionTime(ff,ii),0:BinSize:MaxBinTime)');
    CumHist=[CumHist h1./length(ff)];
    stairs(0:BinSize:MaxBinTime,CumHist(:,ii),'color',colormtx(ii,:),'linewidth',2);
    hold on
    sLegend{ii}=sprintf('%d dB',exptparams.TrialObject.RelativeTarRefdB(ii));
end

ff=find(~isnan(cReactionTime));
if ~isempty(ff),
    h1=cumsum(hist(cReactionTime(ff),0:BinSize:MaxBinTime)');
    CumHist=[CumHist h1./catch_trial_count];
    stairs(0:BinSize:MaxBinTime,CumHist(:,end),'color',colormtx(end-1,:),'linewidth',2);
    sLegend{end+1}=sprintf('Catch');
end

ff=find(~isnan(rReactionTime));
h1=cumsum(hist(rReactionTime(ff),0:BinSize:MaxBinTime)');
CumHist=[CumHist h1./length(rReactionTime)];
stairs(0:BinSize:MaxBinTime,CumHist(:,end),'color',colormtx(end,:),'linewidth',2);
sLegend{end+1}=sprintf('FA');


hold off
legend(sLegend,'Location','SouthEast');
xlabel('time (s)');
ylabel('cum. prob. of response');
title(basename(parmfile{1}),'Interpreter','None');

