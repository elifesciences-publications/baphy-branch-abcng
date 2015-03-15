function R = CollectionCenter(varargin)
% TODO
% Add Cochleogram transform

% PARSE INPUTS
P = parsePairs(varargin);
checkField(P,'Runclasses',{'TOR'});
checkField(P,'Animals','');
checkField(P,'Penetrations','all');
checkField(P,'RespType','SUA');
checkField(P,'SRStim',100);
checkField(P,'SREst',100);
checkField(P,'SRResp',100);
checkField(P,'IncludeSilence',1);
checkField(P,'IncludeSilenceConcat',0);
checkField(P,'QualityLimitSD',3);
checkField(P,'FwdLag',[0:0.01:0.25]);
checkField(P,'StimType','stft');
checkField(P,'FreqChannels',30);
checkField(P,'NFFT',4096);
checkField(P,'Scaling','set');
checkField(P,'LevelScaling','logarithmic');
checkField(P,'Pause',0);

% COLLECT CERTAIN UNITS
Recs = D_findRecordings('Animals',P.Animals,'Runclasses',P.Runclasses,...
  'Penetrations',P.Penetrations,'Verbose',1,'ActivePassive',0);

iStim = zeros(size(Recs)); NCells = 0;
for iT=1:length(Recs) % LOOP OVER STIMULUS TYPES
  cRunclass = Recs(iT).RunClass;
   R.STIM{iT} = []; R.RESP{iT} = []; R.KERNELS{iT} = [];
  for iR = 1:length(Recs(iT).Identifiers) % LOOP OVER RECORDINGS
    cIdentifier = Recs(iT).Identifiers{iR};
    PPP(['\n > ',n2s(iR),'. Current Recording :       <  ',cIdentifier,'  >\n']);
    cPars = Recs(iT).P(iR);
    I = getRecInfo(cIdentifier);
    
    % LOAD MFILE
    [cPath,Paths] = MD_getDir('Identifier',cIdentifier,'Kind','base');
    cMFile = [Paths.DBPath,Recs(iT).ParmFiles{iR}];

    if sum(I.NUnitsByElectrode)  & exist(cMFile,'file') % CHECK IF ANY SORTED CELLS      
      LoadMFile(cMFile);
     
      % COLLECT STIMULUS
      % Returns the stimulus as cell over different stimuli, each [ Frequency X Time ]
      if ~strcmpi(exptparams.TrialObject.ReferenceHandle.descriptor,'Torc') continue; end
      FRangeS = exptparams.TrialObject.ReferenceHandle.FrequencyRange;
      FreqBounds(1) = str2num(FRangeS(find(FRangeS==':')+1:find(FRangeS=='-')-1));
      FreqBounds(2) = str2num(FRangeS(find(FRangeS=='-')+1:strfind(FRangeS,' Hz')-1));
      LogStep = log10(FreqBounds(2)/FreqBounds(1))/(2*P.FreqChannels);
      P.FreqBounds = logspace(log10(FreqBounds(1)),log10(FreqBounds(2)),P.FreqChannels+1);
      P.FreqCenters = logspace(log10(FreqBounds(1))+LogStep,log10(FreqBounds(2))-LogStep,P.FreqChannels);
      
      % CHECK IF STIMULUS HAS BEEN PRECOLLECTED
      cPars = exptparams.TrialObject.ReferenceHandle;
      MatchIndex = LF_compareParameters(cPars,R.STIM{iT}); % check in ForwardCenter_BSP
      P.SR = P.SRStim;
      if ~MatchIndex
        iStim(iT) = iStim(iT) + 1;
        P.Identifier = cIdentifier;
        cStim = collectStimulus(P);
        cStim.Pars = cPars;        
        DE = LF_concatenateStim(cStim,P);
        cStim.STIMConcat = DE.STIM;
        cStim = rmfield(cStim,'I');
        R.STIM{iT}{iStim(iT)} = cStim;
        cStimIndex = iStim(iT);
      else
        cStimIndex = MatchIndex;
      end
      cStim = R.STIM{iT}{cStimIndex};
      
      
      % COLLECT RESPONSE
      % Returns the response as cell over different stimuli, each [Time X Rep X Neuron]
      % All cells (may they come from one day or multiple days) have seen identical stimuli
      P.Identifier = cIdentifier;
      P.SR = P.SRResp;
      % SET FREQUENCIES BASES ON STIMULUS (Similar to prescription, for testing)
      cResp = collectResponse(P);
      if ~isempty(cResp)
        % cResp.I.CellNames contains the information on the Cells
        cNCells = length(cResp.I.Cells);
        NCells = NCells + cNCells;
        cResp.NCells = cNCells;
        cResp.StimIndex = cStimIndex;
        cResp = rmfield(cResp,{'NChannels','T'});
        cResp.RESPConcat = LF_concatenateResp(cResp,cStim,P);
        R.RESP{iT}{iR} = cResp;
        CellsAvailable = 1;
      else
        CellsAvailable = 0;
      end
      
      if CellsAvailable
        % COMPUTE CHARACTERISTIC FOR TESTING
        switch cRunclass
          case 'TOR';
            % ESTIMATE STRF
            P.Frequency = cStim.Frequency;
            P.CellNames = {cResp.I.Cells.Name};
            cKernels = LinearEst(cStim.STIMConcat,cResp.RESPConcat,P); % SPIN OFF LinearReconstEst
          otherwise cKernel = [];
        end
        R.KERNELS{iT}{iR} = cKernels;
      end
      
    end % IF CELLS
  end % RECORDINGS 
end % STIMULUS TYPES


% REDUCE TO EXISTING RESPONSES
for iT=1:length(R.RESP)
  cR = 0;
  for iR = 1:length(R.RESP{iT})
    if ~isempty(R.RESP{iT}{iR})
      cR = cR + 1;
      R.RESP{iT}{cR} = R.RESP{iT}{iR};
      R.KERNELS{iT}{cR} = R.KERNELS{iT}{iR};
    end
  end
  R.RESP{iT}        = R.RESP{iT}(1:cR);
  R.KERNELS{iT} = R.KERNELS{iT}(1:cR);
end

N=0;
for i=1:length(R.KERNELS{1})
  if ~isempty(R.KERNELS{1}{i}) 
    N=N+size(R.KERNELS{1}{i}.STRFs,3); 
  end;
end;
R.NCellsTotal = N;

if length(R.STIM) == 1 
  R.RESP = R.RESP{1}; 
  R.KERNELS = R.KERNELS{1};
  R.STIM = R.STIM{1};
end

%% HELPERS %%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONCATENATE STIMULI AND INSERT ZEROS
function DE = LF_concatenateStim(STIMtmp,P)

NStim = length(STIMtmp.STIM);
if ~P.IncludeSilenceConcat
  for iS = 1:NStim
    iStart = STIMtmp.Pars.PreStimSilence*P.SR+1;
    iStop = size(STIMtmp.STIM{iS},2) - STIMtmp.Pars.PostStimSilence*P.SR;
    STIMtmp.STIM{iS} = STIMtmp.STIM{iS}(:,iStart:iStop);
    ConcatLengths(iS) = iStop-iStart+1;
  end
end
PauseSteps = round(P.Pause*P.SRStim);
NSteps = sum(ConcatLengths)  + PauseSteps*NStim;
NFrequencies = length(STIMtmp.Frequency);
DE.STIM = zeros(NFrequencies,NSteps);
for iS=1:NStim
  StimSteps = size(STIMtmp.STIM{iS},2);
  iStart = (iS-1)*(StimSteps + PauseSteps) +1;
  iStop = iStart + size(STIMtmp.STIM{iS},2)-1;
  DE.STIM(:,iStart:iStop) = STIMtmp.STIM{iS};
end
DE.NStim = NStim;
DE.NFrequencies = NFrequencies;
DE.NSteps = NSteps;

% CONCATENATE RESPONSES AND INSERT ZEROS
function RESP = LF_concatenateResp(RESPtmp,STIMtmp,P,T)

NStim = length(STIMtmp.STIM);
if ~P.IncludeSilenceConcat
  for iS = 1:NStim
    iStart = STIMtmp.Pars.PreStimSilence*P.SR+1;
    iStop = size(RESPtmp.RESP{iS},1) - STIMtmp.Pars.PostStimSilence*P.SR;
    RESPtmp.RESP{iS} = RESPtmp.RESP{iS}(iStart:iStop,:,:);
    ConcatLengths(iS) = iStop-iStart+1;
  end
end
PauseSteps = round(P.Pause*P.SRResp);
NSteps = sum(ConcatLengths) + PauseSteps*NStim;
NFrequencies = length(STIMtmp.Frequency);
Sizes = cell2mat(cellfun(@size,RESPtmp.RESP,'UniformOutput',0)');
NRepetitions = min(Sizes(:,2));
RESP = zeros(NSteps,NRepetitions,RESPtmp.NCells);
for iS=1:NStim
  RespSteps = size(RESPtmp.RESP{iS},1);
  iStart = (iS-1)*(RespSteps + PauseSteps) +1;
  iStop = iStart + RespSteps-1;
  RESP(iStart:iStop , : , :)  = RESPtmp.RESP{iS}(:,1:NRepetitions,:);
end

function Index = LF_compareParameters(cPars,STIM)

Index = 0;
for i=1:length(STIM)
  if isequal(cPars,STIM{i}.Pars) Index = i; end
end