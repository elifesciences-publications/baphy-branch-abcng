function MD_computeShepardTuning(varargin)

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
  StimTags = I.RefStimTags;
  RefHandle = I.exptparams.TrialObject.ReferenceHandle;
  Props = HF_computeShepardProps(RefHandle,StimTags);
  GPROPS.Props = Props; GPROPS.Identifier = P.Identifier; GPROPS.I=I;
else
  Props = GPROPS.Props; I=GPROPS.I;
end
Trials = Events2Trials('Events',I.exptevents,'Stimclass','biasedshepardpair');
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

PreSilence = I.exptparams.TrialObject.ReferenceHandle.PreStimSilence;

for iT = 1:NTrials
  SpontRates(iT) = sum(SpiketimesByTrial{iT}<PreSilence)/PreSilence;
end

AllPitches = [];
for iP=1:length(Props) AllPitches = [AllPitches;Props(iP).Pitches]; end
AllPitches = unique(AllPitches);

Responses = cell(length(AllPitches),1);
ResponsesWindow = cell(length(AllPitches),3);
for iT=1:NTrials % LOOP OVER TRIALS
  cIndex = Trials.Indices(iT);
  cPitches = Props(cIndex).Pitches;
  for iP=1:length(cPitches) % LOOP OVER POSITIONS IN THE BIAS
    cStart = Props(cIndex).ToneStarts(iP);
    cStop = cStart + Props(cIndex).ToneDuration;
    cInd = find(cPitches(iP)==AllPitches);
    cResponse =sum((SpiketimesByTrial{iT} >= cStart).*(SpiketimesByTrial{iT} < cStop))/(cStop-cStart);
    Responses{cInd}(end+1) = cResponse; 
    for iW=1:3
      cStart = Props(cIndex).ToneStarts(iP) + (iW-1)*Props(cIndex).ToneDuration/2;
      cStop = cStart + Props(cIndex).ToneDuration/2;
      cResponse =sum((SpiketimesByTrial{iT} >= cStart).*(SpiketimesByTrial{iT} < cStop))/(cStop-cStart);
      ResponsesWindow{cInd,iW}(end+1) = cResponse;
    end
  end
end
TuningCurve = cellfun(@mean,Responses);
BiasInd = ~isnan(TuningCurve);
AllPitches = AllPitches(BiasInd);
TuningCurve = TuningCurve(BiasInd);

% COMPUTE COARSER TUNING CURVE
PitchesHist = [0:0.25:12];
[Hist,Inds] = histc(AllPitches,PitchesHist);
for i=1:length(PitchesHist)-1 TuningCurveHist(i) = mean(TuningCurve(find(Inds==i))); end

Responses = Responses(BiasInd);
ResponsesWindow = ResponsesWindow(BiasInd,:);
TuningCurveWindow = cellfun(@mean,ResponsesWindow);

ParSmooth = {0.4,0.05};
TuningCurveSmooth = applyCirc(@gaussSmooth,AllPitches,TuningCurve,[],ParSmooth);   
for iT=1:size(TuningCurveWindow,2)
  TuningCurveWindowSmooth(:,iT) = applyCirc(@gaussSmooth,AllPitches,TuningCurveWindow(:,iT),[],ParSmooth);
end

% SHOW SPONTANEOUS RATE
plot(P.Axis,[0,12],repmat(mean(SpontRates),1,2),'Color',[0.75,0.75,0.75],'LineWidth',3);

Strings = {'AV','ON','CONT','OFF','RESP'};
Colors = {[0.5,0.5,0.5],[0.6,0,0],[1,0.3,0.3],[1,0.6,0.6],[0,1,0]};

for iT=1:length(Strings)
  switch Strings{iT}
    case 'AV'; plot(P.Axis,PitchesHist(1:end-1),TuningCurveHist,'-','LineWidth',3,'Color',Colors{iT});
    case 'RESP'; plot(P.Axis,AllPitches,TuningCurveSmooth,'-','LineWidth',2,'Color',Colors{iT});
    otherwise plot(P.Axis,AllPitches,TuningCurveWindowSmooth(:,iT-1),'-','Color',Colors{iT},'LineWidth',2);
  end
  text((iT-1)*0.20+0.05,0.9,Strings{iT},'Color',Colors{iT},'Units','n','FontSize',6,'FontWeight','bold');
end

title(P.Axis,['E',n2s(P.Electrode),' U',n2s(P.Unit)]);
xlabel(P.Axis,'Pitchclass [st]');
ylabel(P.Axis,'FiringRate [Hz]');
xlim(P.Axis,[0,12]);
ylim(P.Axis,[0,max([30,1.5*max(TuningCurveWindowSmooth(:))])]);
set(gcf,'Name',[P.Identifier,' (',n2s(NTrials),')']);