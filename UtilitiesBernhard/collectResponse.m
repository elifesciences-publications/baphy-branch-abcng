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
 
% COLLECT RESPONSE
switch P.RespType
  case 'SUA'; % SINGLE UNIT ACTIVITY
    fprintf('Loading SUA ');
    TagMasks = {'SPECIAL-TRIAL'};
    k=0; SingleIDs = [];
    I.SpikeShapes = cell(size(E));
    
    for iE=1:length(P.Electrodes)
      cElectrode = P.Electrodes(iE);
      I.SpikeShapes{cElectrode} = cell(size(I.UnitsByElectrode{cElectrode}));
      
      if ischar(P.Units) & strcmp(P.Units,'all')
        cUnits = unique(I.UnitsByElectrode{cElectrode});
      else cUnits = unique(P.Units); 
      end
      cSingleIDs = I.SingleIDsByElectrode{cElectrode};
      
      for cUnit=cUnits
        k=k+1;
        SingleIDs = [SingleIDs,cSingleIDs(find(cUnit==cUnits))];
        options.channel = cElectrode;
        options.unit = cUnit;
        options.rasterfs = P.SR;
        options.includeprestim = P.IncludeSilence;
        options.tag_masks = TagMasks;
        options.includeincorrect =1;
        options.spikeshape = 1;
        I.CellNames{k} = ['El',n2s(cElectrode),' U',n2s(cUnit)];
        [cRaster, tmp , tmp , tmp , SortExtras]  = loadspikeraster(I.SpikeFile,options);
        Rasters{k} = NaN*zeros(size(cRaster,1),ceil(size(cRaster,2)/T.NIndices),T.NIndices,'uint8');
        RepCount = zeros(1,T.NIndices);
        for iT = 1:size(cRaster,2)
          if ~isnan(T.Indices(iT))
            if isfield(T,'OutcomesNum') && T.OutcomesNum(iT) <0
              continue; % IF A BROKEN BEHAVIOR TRIAL
            end
            RepCount(T.Indices(iT)) = RepCount(T.Indices(iT)) + 1 ;
            Rasters{k}(:,RepCount(T.Indices(iT)),T.Indices(iT)) = cRaster(:,iT);
          end
        end
        try
          I.SpikeShapes{cElectrode}{cUnit} = SortExtras.SpikeShape;
        end
        I.Cells(k).Electrode = cElectrode;
        I.Cells(k).Unit = cUnit;
      end
    end
    I.SingleIDs = SingleIDs;
    
    % TRANSITION FROM CHANNEL-BASED TO STIMULUS BASED SEPARATION
    for iS=1:T.NIndices
      D.RESP{iS} = zeros(size(Rasters{1},1),RepCount(iS),length(Rasters),'uint8');
      for iU=1:length(Rasters) % LOOPS OVER ALL UNITS FROM ALL ELECTRODES
        D.RESP{iS}(:,:,iU) = Rasters{iU}(:,1:RepCount(iS),iS);
      end
    end
    % D.StimTags = cStimTags;
    if P.Rasters D.Rasters = Rasters; end
    endl;
    
  case 'MUA'; % MULTI UNIT ACTIVITY
    fprintf('Loading MUA ');
    warning('WRITE NEW RASTER LOADER BEFORE USING THIS FUNCTION AGAIN');
%     options = struct('datause','Reference Only','tag_masks',{'Ref'},'unit',1,...
%       'rasterfs',P.SR,'verbose',0,'includeincorrect',1);
    options = struct('rasterfs',P.SR,'sigthreshold',P.SigmaThreshold,'lfp',0,'usefirstcycle',0,'scalesnr',0,'includeprestim',P.IncludeSilence,'tag_masks',{{'TORC'}});
    for i=1:length(P.Electrodes)
      % [Rasters{i},cStimTags,cStimsVsTrials,cExptEvents] ...
      %         = raster_load(I.MFile,P.Electrodes(i),[],options);
      options.channel = P.Electrodes(i);
      [Rasters{i},cStimTags]=loadevpraster(I.MFile,options);
      I.CellNames{i} = ['El',n2s(P.Electrodes(i)),' U1'];
      I.SingleIDs(i) = NaN;
    end
    
    % UNSCRAMBLE INDICES
    Indices = Tags2Indices(cStimTags,I.Stimclass);
    [Indices,SortInd] = sort(Indices,'ascend');
    cStimTags = cStimTags(SortInd);
    
    % TRANSITION FROM CHANNEL-BASED TO STIMULUS BASED SEPARATION
    for j=1:T.NIndices
      D.RESP{j} = zeros(size(Rasters{i},1),size(Rasters{i},2),length(P.Electrodes));
      for i=1:length(P.Electrodes)
        D.RESP{j}(:,:,i) = Rasters{i}(:,:,SortInd(j));
      end
    end
    D.StimTags = cStimTags;
    if P.Rasters D.Rasters = Rasters; end
    fprintf('\n');
    
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
     
  case 'HighGamma' % HIGH FREQUENCY GAMMA BAND
    
end

if ~strcmp(P.RespType,'MUA')
  if ~P.IncludeSilence
    for iS=1:T.NIndices D.RESP{iS} = D.RESP{iS}(PreSteps+1:end-PostSteps,:,:); end
    if isfield(D,'Rasters')
      for iC=1:length(D.Rasters) D.Rasters{iC} = D.Rasters{iC}(PreSteps+1:end-PostSteps,:,:); end
    end
  end
else
  warning('Not removing Pre/Postsilence, due to screwy raster code in mua path.');
end

D.NRepetitions = I.NRepetitions;
D.NChannels = NChannels;
D.I = I;
D.T = T;
