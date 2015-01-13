function TMG_RasterPlot(varargin)

P = parsePairs(varargin);
checkField(P,'MFile');
checkField(P,'Electrode');
checkField(P,'Unit');
checkField(P,'Axis',gca);
checkField(P,'SR',100);
checkField(P,'SpikeSource','Threshold');
checkField(P,'SigmaThreshold',0);

P.Identifier = MD_MFile2Identifier(P.MFile);

%% COMPUTE TIMINGS FOR THE STIMULUS & EXTRACT RESPONSE
global GPROPS
if isempty(GPROPS) | ~strcmp(GPROPS.Identifier,P.Identifier)
  % GET GENERAL RECORDING INFO
  I = getRecInfo('Identifier',P.Identifier,'Quick',2);
else
  I=GPROPS.I;
end

 Trials = Events2Trials('Events',I.exptevents,'Stimclass','texturemorphing','Runclass',I.Runclass,...
   'RefSO',I.exptparams.TrialObject.ReferenceHandle,'TargetSO',I.exptparams.TrialObject.TargetHandle);
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
Responses = cell(length(AllIndices),1);
TrialCountByIndex = zeros(1,length(AllIndices));
for iT=1:NTrials % LOOP OVER TRIALS
  cIndex = cell2mat(Trials.Indices(iT));
  cI = find(cIndex==AllIndices);
  
  cStart = Trials.Times{iT}(1) + PreTarDuration;
  cStop = Trials.Times{iT}(2); % + FrozenPatternDuration;
  cResponse = SpiketimesByTrial{iT}( SpiketimesByTrial{iT} >= cStart & SpiketimesByTrial{iT} < cStop );
  Responses{cI,TrialCountByIndex(cI)+1} = cResponse;
  TrialCountByIndex(cI) = TrialCountByIndex(cI) +1;
end

hold(P.Axis,'on');
for cIndex = AllIndices'
  cI = find(cIndex==AllIndices);
  for iT = 1:TrialCountByIndex(cI)
    for iSpike = 1:length(Responses{cI,iT})
      yPos = cIndex-0.5+((iT-1)/TrialCountByIndex(cI))
      plot(P.Axis,[Responses{cI,iT}(iSpike) Responses{cI,iT}(iSpike)],[yPos yPos+1/TrialCountByIndex(cI)],'Color',[0,0,0],'LineWidth',1);
    end
  end
end
if FrozenPatternDuration~=0
  plot(P.Axis,repmat(FrozenPatternDuration,1,2),[AllIndices(1)-0.5 AllIndices(end)+0.5],'Color',[0.7,0.7,0.7],'LineWidth',2);
end


title(P.Axis,['E',n2s(P.Electrode),' U',n2s(P.Unit), ' Spont: ' num2str(mean(SpontRates(iT))) 'Hz']);
xlabel(P.Axis,'Time (s)');
ylabel(P.Axis,'Index');
ylim(P.Axis,[AllIndices(1)-0.5 AllIndices(end)+0.5]);
set(gcf,'Name',[P.Identifier,' (',n2s(NTrials),')']);