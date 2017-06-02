function TMG_RasterPlot(varargin)

P = parsePairs(varargin);
checkField(P,'MFile');
checkField(P,'Electrode');
checkField(P,'Unit');
checkField(P,'Axis',gca);
checkField(P,'SR',100);
checkField(P,'SpikeSource','Threshold');
checkField(P,'SigmaThreshold',0);
checkField(P,'r',[]);
checkField(P,'LFP',0);
checkField(P,'LFPsf',1000);

P.Identifier = MD_MFile2Identifier(P.MFile);

%% COMPUTE TIMINGS FOR THE STIMULUS & EXTRACT RESPONSE
global GPROPS
if isempty(GPROPS) | ~strcmp(GPROPS.Identifier,P.Identifier)
  % GET GENERAL RECORDING INFO
  I = getRecInfo('Identifier',P.Identifier,'Quick',2);
else
  I=GPROPS.I;
end

PsthDuration = 2.5; StimulusBisDuration = str2num(I.exptparams.TrialObject.TargetHandle.StimulusBisDuration);
PlotGroupedByIndex = 0;
Trials = Events2Trials('Events',I.exptevents,'Stimclass','texturemorphing','Runclass',I.Runclass,...
   'RefSO',I.exptparams.TrialObject.ReferenceHandle,'TargetSO',I.exptparams.TrialObject.TargetHandle,'exptparams',I.exptparams);
NTrials = length(Trials.Indices);
SpiketimesByTrial = cell(NTrials,1);
switch P.SpikeSource
  case 'Threshold';
    CacheFile = cacheevpspikes(I.EVPFile,P.Electrode,P.SigmaThreshold);
    Spikes = load(CacheFile);
    for iT = 1:NTrials
      SpiketimesByTrial{iT} = Spikes.spikebin(find(Spikes.trialid==iT))/I.SR;
    end
  case 'Sorted';
    Spikes = load(I.SpikeFile);
  otherwise error('SpikeSource unknown.'); 
end

PreSilenceRef = I.exptparams.TrialObject.ReferenceHandle.PreStimSilence;
DurationRef = I.exptparams.TrialObject.ReferenceHandle.Duration;
PostSilenceRef = I.exptparams.TrialObject.ReferenceHandle.PostStimSilence;
PreSilenceTar = I.exptparams.TrialObject.TargetHandle.PreStimSilence;
PreTarDuration = PreSilenceRef + DurationRef + PostSilenceRef + PreSilenceTar;
FrozenPatternDuration = I.exptparams.TrialObject.TargetHandle.Par.FrozenPatternDuration;

for iT = 1:NTrials
  SpontRates(iT) = sum(SpiketimesByTrial{iT}<PreTarDuration)/PreTarDuration;
end

AllIndices = unique( cell2mat(Trials.Indices) );
if PlotGroupedByIndex; Responses = cell(length(AllIndices),1); end
TrialCountByIndex = zeros(1,length(AllIndices));

hold(P.Axis,'on');
if ~P.LFP
    for iT=1:NTrials % LOOP OVER TRIALS
      cIndex = cell2mat(Trials.Indices(iT));
      cI = find(cIndex==AllIndices);

      cStop = Trials.ChangeTime{iT}+StimulusBisDuration; % + FrozenPatternDuration;
      cStart = cStop-PsthDuration;
      cResponse = SpiketimesByTrial{iT}( SpiketimesByTrial{iT} >= cStart & SpiketimesByTrial{iT} < cStop )-Trials.ChangeTime{iT};
      if PlotGroupedByIndex
          Responses{cI,TrialCountByIndex(cI)+1} = cResponse;
          TrialCountByIndex(cI) = TrialCountByIndex(cI) +1;
      else
          Responses{iT} = cResponse;
          for iSpike = 1:length(cResponse)
            plot(P.Axis,[cResponse(iSpike) cResponse(iSpike)],[iT iT+.85],'Color',[0,0,0],'LineWidth',1);
          end
      end
    end

    if PlotGroupedByIndex
        for cIndex = AllIndices'
            cI = find(cIndex==AllIndices);
            for iT = 1:TrialCountByIndex(cI)
                for iSpike = 1:length(Responses{cI,iT})
                    yPos = cIndex-0.5+((iT-1)/TrialCountByIndex(cI));
                    plot(P.Axis,[Responses{cI,iT}(iSpike) Responses{cI,iT}(iSpike)],[yPos yPos+1/TrialCountByIndex(cI)],'Color',[0,0,0],'LineWidth',1);
                end
            end
        end
    end
    BinSize = 0.05; BinNb = PsthDuration/BinSize;  % 50ms binning
    [yHist,xHist] = hist(cell2mat(Responses(:)),linspace(-PsthDuration+StimulusBisDuration,StimulusBisDuration,BinNb));
    yHist = yHist/BinSize;
    yHist = yHist/30;
    plot(P.Axis,xHist,yHist,'color',[1 .3 .3],'linewidth',3)
    if FrozenPatternDuration~=0
      plot(P.Axis,repmat(FrozenPatternDuration,1,2),[AllIndices(1)-0.5 AllIndices(end)+0.5],'Color',[0.7,0.7,0.7],'LineWidth',2);
    end
else
    for iT=1:NTrials % LOOP OVER TRIALS
      cIndex = cell2mat(Trials.Indices(iT));
      cI = find(cIndex==AllIndices);

      cStop = Trials.ChangeTime{iT}+StimulusBisDuration; % + FrozenPatternDuration;
      cStart = cStop-PsthDuration;
      cResponse = P.r( round(cStart*P.LFPsf) : min(size(P.r,1),round(cStop*P.LFPsf)) ,iT);
      Responses(iT,1:length(cResponse)) = cResponse;
    end
    plot(P.Axis,linspace(-PsthDuration+StimulusBisDuration,StimulusBisDuration,size(Responses,2)),nanmean(Responses,1),'color',[1 .3 .3],'linewidth',2)
    plot(P.Axis,[-PsthDuration+StimulusBisDuration,StimulusBisDuration],[0 0],'k')
end
axis(P.Axis,'tight');
plot(P.Axis,[0 0],get(P.Axis,'ylim'),'b--','linewidth',PsthDuration)

title(P.Axis,['E',n2s(P.Electrode),' U',n2s(P.Unit), ' Spont: ' num2str(mean(SpontRates(iT))) 'Hz']);
xlabel(P.Axis,'Time (s)');
ylabel(P.Axis,'Index');
set(gcf,'Name',[P.Identifier,' (',n2s(NTrials),')']);