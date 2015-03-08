function D = collectResponse(varargin)

if length(varargin)==1 P = varargin{1}; else P = parsePairs(varargin); end
checkField(P,'Identifier',''); 
if isempty(P.Identifier) error('Recordings must be specified by Identifier!'); end
checkField(P,'RespType','MUA');
checkField(P,'SingleID','');
checkField(P,'Electrodes','all');
checkField(P,'SR',1000);
checkField(P,'IncludeSilence',1);
checkField(P,'Units','all');
checkField(P,'Rasters',0);
checkField(P,'SigmaThreshold',4);
checkField(P,'QualityLimitSD',3);
checkField(P,'Verbose',0);

% COLLECT PROPERTIES OF THE RECORDING
I = getRecInfo(P);

% ASSIGN PARAMETERS
if strcmp(P.Electrodes,'all') P.Electrodes = [1:I.NumberOfChannels]; end
NChannels = length(P.Electrodes);
RefPars = I.exptparams.TrialObject.ReferenceHandle;
PreSteps = round(RefPars.PreStimSilence*P.SR);
PostSteps = round(RefPars.PostStimSilence*P.SR);

 E = MD_getElectrodeGeometry('Identifier',P.Identifier);
 AllElectrodes = [E.Electrode];
 for i=1:length(P.Electrodes) P.Channels(i) = find(P.Electrodes(i)==AllElectrodes); end
 T = Events2Trials('Events',I.exptevents,'Stimclass',I.Stimclass,'Runclass',I.Runclass);
 NRepetitions = ceil(T.NTrials/T.NIndices);
          
% COLLECT RESPONSE
fprintf(['  Loading ',P.RespType, ' :  El. ']);
switch P.RespType
  case {'SUA','MUA'} % SINGLE UNIT ACTIVITY
    k=0;
    
    switch P.RespType
      case 'MUA'
        % ASSIGN PSEUDO-SINGLEIDS FOR THIS CASE, WHICH IDENTIFY THE
        % ANIMAL,RECORDINGDAY & ELECTRODE (VERY LONG INT).
%         Base = int8(I.SiteName(1:3));
%         Base  = num2str(Base);
%         Base=Base(Base~=' ');
%         Base = [Base,I.SiteName(4:6)];
%         Base = 1000*int64(str2num(Base));
        % YB-CB: fix when animal name is longer thqn 3 chqr
        EndAniNameInd = find(~isletter(I.SiteName),1,'first')-1;
        Base = int8(I.SiteName(1:3));
        Base  = num2str(Base);
        Base=Base(Base~=' ');
        Base = [Base,I.SiteName(EndAniNameInd+(1:3))];
        Base = 1000*int64(str2num(Base));
        for iE=1:I.NumberOfChannels
          I.SingleIDsByElectrode{iE} = (Base) + (iE);
        end
    end
    
    for iE=1:length(P.Electrodes) % LOOP OVER ELECTRODES
      cElectrode = P.Electrodes(iE); fprintf('%i ',cElectrode);
      
      switch P.RespType
        case 'SUA'; SpikeFile = I.SpikeFile; RawFile = '';
        case 'MUA'; SpikeFile = I.TriggerFilesByElectrode{cElectrode}; 
          RawFile = [I.DataRoot,'.001.1.evp'];
      end
      
      % SELECT UNITS TO COLLECT
      switch P.RespType
        case 'SUA';
          if ischar(P.Units) & strcmp(P.Units,'all') cUnits = I.UnitsByElectrode{cElectrode};
          else cUnits = unique(P.Units); end
        case 'MUA'; cUnits = 1;
      end
      
      for cUnit=cUnits % LOOP OVER AVAILABLE UNITS
        k=k+1;
        
        % COLLECT SPIKETIMES
        [CD,State]  = LoadSpikeTimesNSL('RespType',P.RespType,'File',SpikeFile,'Trials',T,...
          'IncludeSilence',P.IncludeSilence,'Electrode',cElectrode,'Unit',cUnit,...
          'SR',P.SR,'SRRaw',I.SR,'Verbose',P.Verbose,'QualityLimitSD',P.QualityLimitSD,'RawFile',RawFile);
       
        if State k=k-1; fprintf('skip '); continue; end
        
        % Rasters has dimensions : Time X NRepetitions X NIndices
        Rasters{k} = NaN*zeros(size(CD.Raster,1),NRepetitions,T.NIndices,'uint8');
        Times{k} = cell(NRepetitions,T.NIndices);
        RepCount = zeros(1,T.NIndices);
        for iT = 1:T.NTrials
          if ~isnan(T.Indices{iT})
            if isfield(T,'OutcomesNum') && T.OutcomesNum(iT) <0
              continue; % IF A BROKEN BEHAVIOR TRIAL
            end
            IndPos = find(T.Indices{iT}==T.UIndices); % FOR THE CASE THAT MAXINDEX IS NOT EQUAL TO NUMBER OF INDICES (e.g. in ZTORC, Index 17 is missing)
            RepCount(IndPos) = RepCount(IndPos) + 1;
            Rasters{k}(:,RepCount(IndPos),IndPos) = CD.Raster(:,iT);
            Times{k}(RepCount(IndPos),IndPos) = CD.Times(iT);
          end
        end
        I.Cells(k).SpikeShape = CD.SpikeShape;
        I.Cells(k).Electrode = cElectrode;
        I.Cells(k).Unit = cUnit;
        I.Cells(k).Name = ['El',n2s(cElectrode),' U',n2s(cUnit)];
        cSingleIDs = I.SingleIDsByElectrode{cElectrode};
        I.Cells(k).SingleID = cSingleIDs(find(cUnit==cUnits));
      end
    end
    
    % AFTER COLLECTING ALL CELLS, BUILD STIMULUS BASED ORGANIZATION
    if k>0 % IF CELLS WERE FOUND
      for iS=1:T.NIndices % LOOPS OVER INDICES
        D.RESP{iS} = zeros(size(Rasters{1},1),RepCount(iS),length(Rasters),'uint8');
        D.RESPTimes{iS} = cell(RepCount(iS),length(Rasters));
        for iU=1:length(Rasters) % LOOPS OVER ALL UNITS FROM ALL ELECTRODES
          D.RESP{iS}(:,:,iU) = Rasters{iU}(:,1:RepCount(iS),iS);
          D.RESPTimes{iS}(:,iU) =Times{iU}(1:RepCount(iS),iS);
        end
      end
      if P.Rasters D.Rasters = Rasters; end
      fprintf('\n');
    else 
      D = [];
    end
        
  case 'LFP'; % LOCAL FIELD POTENTIAL
    fprintf('Loading LFP ');
    R = evpread([I.DataRoot,'.001.1.evp'],'lfpchans',P.Channels,'spikechans',[],'SRlfp',P.SR);
    ET = Events2Trials(I.exptevents,I.Stimclass);
    % TRANSITION FROM CHANNEL-BASED TO STIMULUS BASED SEPARATION
    for iS = 1:I.NRefStimuli
      cDuration = ET.Durations(find(ET.Indices==iS,1,'first'));
      StimSteps = round(cDuration*P.SR);
      TotalSteps(iS) = PreSteps + StimSteps + PostSteps;
      D.RESP{iS} = NaN*zeros(TotalSteps(iS),I.NRepetitions,NChannels);
    end
    cReps = zeros(1,I.NRefStimuli); Trialidx = ceil(R.LTrialidx);
    for iT = 1:I.Trials
      iS = ET.Indices(iT); cReps(iS) = cReps(iS) + 1;
      cTotalSteps = min(TotalSteps(iS),size(R.LFP,1)-Trialidx(iT)); % Deals with cutoff trials
      D.RESP{iS}(1:cTotalSteps,cReps(iS),:) ...
        = reshape(R.LFP(Trialidx(iT)+1:Trialidx(iT)+cTotalSteps,:),[cTotalSteps,1,NChannels]);
    end
    endl;
    if P.IncludeSilence error('Needs to be implemented for LFP'); end
         
end

% CUT OUT PRE & POST-SILENCE AFTERWARDS
if ~isempty(D)
  D.NRepetitions = I.NRepetitions;
  D.NChannels = NChannels;
  D.I = I;
  D.T = T;
end
