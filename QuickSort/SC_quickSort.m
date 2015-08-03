function SC_quickSort(varargin)
baphy_set_path;

% SET VARIABLES
P = parsePairs(varargin);
checkField(P,'Animal');
checkField(P,'Penetration');
checkField(P,'Depth');
checkField(P,'Recording',[]);
checkField(P,'Recordings',[]);
checkField(P,'Electrode');
checkField(P,'Sorter','personne');
checkField(P,'FilterStyle','butter');
checkField(P,'Threshold',4);
checkField(P,'LargeThreshold',100);
checkField(P,'TimeIndex',0);
checkField(P,'SaveSorter',0);
checkField(P,'Shocks',0);

% CHECK IF RECORDINGS WERE SPECIFIED
if isempty(P.Recording)
    if isempty(P.Recordings) error('Parameter : Recording or Recordings has to be assigned!'); end
else P.Recordings = P.Recording; end

% CONNECT TO DATABASE
dbopen;

Sep = HF_getSep; global U;
O = MD_dataFormat('Mode','Operator');

% COMPUTE PATHS AND FILENAMES
P.StimStarts = []; P.StimStops = []; D = 0; idx = [ ]; T = struct('SortInd',[],'Indices',[]);
P.Behaviors='p';

% CREATE QG, WHICH HOLDS THE MAINSTAY OF DATA
global QG; FIG = mod(round(now*1e6),1e9); FID = ['F',n2s(FIG)];
QG.(FID).RawData = [];

% GATHER DATA INFO FOR EACH RECORDING
for iRec = 1:length(P.Recordings)
    P.Recording = P.Recordings(iRec);
    
    % MD_I2S2I constructs recording indentifier
    P = MD_I2S2I(P);
    
    % USE IDENTIFIER TO GATHER RECORDING INFO
    I = getRecInfo('Identifier',P.Identifier);
    
    %IF THIS IS THE FIRST RECORDING, THEN CHECK FOR AND GATHER SORTED CELLS
    if iRec==1
        SortInfo = M_getAllSpikes(P,I);
    end
    
    % LOAD STIMULUS MFILE INFO
    P.StimStart = I.exptparams.TrialObject.ReferenceHandle.PreStimSilence;
    if isfield(I.exptparams.TrialObject.ReferenceHandle,'Duration')
        P.StimStop = P.StimStart + mean(I.exptparams.TrialObject.ReferenceHandle.Duration);
    else
        P.StimStop = P.StimStart + mean([I.exptevents.StopTime]);
    end
    Ttmp = Events2Trials('Events',I.exptevents,'Stimclass',I.Stimclass,'TimeIndex',P.TimeIndex);
    
    % LOOP OVER THESE INDEXES TO CONCATENATE OVER RECORDINGS
    T.SortInd = [T.SortInd,Ttmp.SortInd+length(T.SortInd)];
    T.Indices = [T.Indices,iRec+cell2mat(Ttmp.Indices)/1000];
    
    % LOAD DATA
    Path = MD_getDir('Identifier',P.Identifier,'Kind','recording','EVPVersion',I.EVPVersion);
    switch I.EVPVersion
        case 4;
            IdentifierFull = O.S2I.FH(...
                P.Animal,P.Penetration,P.Depth,P.Recordings(iRec),I.Behavior(1),I.Runclass);
        case 5;
            IdentifierFull = O.S2I.FH(...
                P.Animal,P.Penetration,P.Depth,P.Recordings(iRec),I.Behavior(1),I.Runclass,1,1);
        otherwise error('EVP Version not implemented.');
    end
    BaseName = [Path,IdentifierFull,'.evp'];
            
    % LOAD EVP DATA. Dtmp are the raw data. idxtmp are the trial indexes.
    [Dtmp,idxtmp] = evpread(BaseName,'spikeelecs',P.Electrode,'filterstyle',P.FilterStyle);
    
    %Find Shock Events
    if P.Shocks == 1
        [shockstart,shocktrials,shocknotes,shockstop]=findshockevents(I.exptevents,I.exptparams);
        shocktrials=unique(shocktrials);
        for i = 1:length(shocktrials)
            if shocktrials(i) ~= length(idxtmp)
                Dtmp(idxtmp(shocktrials(i)):idxtmp(shocktrials(i)+1)-1)=0;
            else
                Dtmp(idxtmp(shocktrials(i)):end)==0;
            end
        end
        
        if ~length(shocktrials)
            fprintf('%s: zeroed %d shock trials', I.IdentifierFull, length(shocktrials));
        end
    end

    % LOOP OVER idx and QG.(FID).RawData to concatenate data and indexes
    idx = [idx;idxtmp+D];
    QG.(FID).RawData = [QG.(FID).RawData , Dtmp'];
    P = rmfield(P,'Identifier');
    D = D+length(Dtmp);

end


% SPIKESORT THE SET OF RECORDINGS
quickSort('FIG',FIG,'TrialIndices',idx,'StimStart',P.StimStart,'StimStop',P.StimStop,...
    'PermInd',T.SortInd,'Indices',T.Indices,'Animal',P.Animal,'Penetration',P.Penetration,...
    'Depth',P.Depth,'Recordings',P.Recordings,'Behavior',I.Behavior,...
    'Runclass',I.Runclass,'Electrode',P.Electrode,'Sorter',P.Sorter,'Identifier',I.IdentifierFull,...
    'SortInfo',SortInfo,'Threshold',P.Threshold,'LargeThreshold',P.LargeThreshold,...
    'SaveSorter',P.SaveSorter,'TimeIndex',P.TimeIndex);

function SortInfo = M_getAllSpikes(P,I)

SQL = ['SELECT * FROM gDataRaw WHERE id=',n2s(I.ID),' AND bad=0'];
M = mysql(SQL); mWavesC = cell(1);
fprintf(['Loading Cells from ']);
for i=1:length(M)
    Info{i} = getRecInfo('Identifier',M(i).parmfile(1:end-8),'Quick',1);
    if exist(Info{i}.SpikeFile,'file')
      fprintf([M(i).parmfile(1:end-8),' ']);
      cSortInfo = load(Info{i}.SpikeFile);
      C  = mysql(['SELECT * FROM sCellFile WHERE rawid=',n2s(Info{i}.ID)]);
      % LOAD SORTINFO IF AVAILABLE
      if ~length(C)==0 % 15/03-YB: in case a sorting has been deleted
        Inds = find([C.channum]==P.Electrode);
        cUnits{i} = sort([C(Inds).unit],'ascend');
        for iU = 1:length(cUnits{i})
            if length(mWavesC)<cUnits{i}(iU) mWavesC{cUnits{i}(iU)} = []; end
            mWavesC{cUnits{i}(iU)}(:,end+1) = cSortInfo.sortinfo{P.Electrode}{1}(iU).Template(:,iU);
        end
      end
    end
end
for iS = 1:length(mWavesC)
    mWaves(:,iS) = mean(mWavesC{iS},2);
end
fprintf('\n');
if ~exist('cUnits','var') cUnits = []; mWaves = []; end
SortInfo.mWaves = mWaves;
SortInfo.Units = unique(cell2mat(cUnits));