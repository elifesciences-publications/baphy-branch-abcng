function [R,State] = LoadSpikeTimesNSL(varargin)

P = parsePairs(varargin);
checkField(P,'File'); % FILE WITH THE DATA
checkField(P,'Trials'); % TRIAL INFORMATION (FROM EVENTS2TRIALS)
checkField(P,'Electrode',1);
checkField(P,'Unit',1);
checkField(P,'RespType','SUA');
checkField(P,'SR',1000);
checkField(P,'SRRaw',25000);
checkField(P,'SigmaThreshold',4);
checkField(P,'IncludeSilence',1);
checkField(P,'QualityLimitSD',0);
checkField(P,'RawField',0);
checkField(P,'Verbose',0);

% ASSIGN VARIABLES
NTrials = length(P.Trials.DurationsTotal);
NSpikes = 0; R = []; State = 0;

% PROCESS SPECIAL STEPS BY RESPTYPE
switch P.RespType
  case 'SUA'; % SINGLE UNIT ACTIVITY
    D = load(P.File);
    if isempty(D.sortinfo{P.Electrode}) State = 'NotSorted'; return; end
    cData = D.sortinfo{P.Electrode}{1}(P.Unit);
    SpikeTrials = cData.unitSpikes(1,:);
    SpikeBins = cData.unitSpikes(2,:)/P.SRRaw;
    SpikeShape = cData.Template(:,P.Unit);
    if max(abs(SpikeShape))<P.QualityLimitSD; State = 'BelowQuality'; return; end
    R.SpikeShape = SpikeShape;
    
  case 'MUA'; % MULTI UNIT ACTIVITY
    if ~exist(P.File) 
      P.File = cacheevpspikes(P.RawFile,P.Electrode,P.SigmaThreshold,0);
    end
    D = load(P.File);
    SpikeTrials = D.trialid;
    SpikeBins = D.spikebin/P.SRRaw;
    R.SpikeShape = NaN;
end

% BREAK BY TRIAL
for iT=1:NTrials
  cInd = find(SpikeTrials==iT);
  cInd = cInd(SpikeBins(cInd)<=P.Trials.DurationsTotal(iT));
  Times{iT}  = SpikeBins(cInd);
  NSpikes = NSpikes  + length(cInd);
end
if P.Verbose fprintf(['Unit ',n2s(P.Units),' :  Spikes \t',n2s(length(SpikeBins)),' total \t ',n2s(NSpikes),' in bounds ']); end

% CUT SILENCE IF REQUESTED
if ~P.IncludeSilence
  %if P.Verbose fprintf('Cutting Pre- & Poststimulus Silence\n'); end
    for iT = 1:NTrials
      tmp = Times{iT};
      Times{iT} = tmp(logical((tmp>P.Trials.PreSilence(iT)) .* ...
        logical(tmp<(P.Trials.DurationsTotal(iT)-P.Trials.PostSilence(iT)) ) ));
      Times{iT} = Times{iT} - P.Trials.PreSilence(iT); 
      NSpikes = NSpikes - (length(tmp) - length(Times{iT}));
    end
    if P.Verbose fprintf(['\t',n2s(NSpikes),' during stimulus']); end
  P.Trials.DurationsTotal = P.Trials.DurationsTotal-P.Trials.PreSilence - P.Trials.PostSilence;
end
if P.Verbose fprintf('\n'); end
R.Times = Times;

%  CREATE OUTPUT RASTER
NSteps = ceil(P.SR*max(P.Trials.DurationsTotal));
R.Raster = NaN*zeros([NSteps,NTrials],'uint8');
for iT = 1:NTrials
  NSteps = ceil(P.SR*P.Trials.DurationsTotal(iT));
  R.Raster(1:NSteps,iT) = 0;
  SpikeBins = ceil(P.SR*Times{iT});
  for iB=1:length(SpikeBins)
    R.Raster(SpikeBins(iB),iT) = R.Raster(SpikeBins(iB),iT) + 1;
  end
end