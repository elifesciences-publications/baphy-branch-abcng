function I = getRecInfo(varargin)
% LOAD INFORMATION FOR A GIVEN RECORDING
% Typical Usage is : I = getRecInfo('ani001a01');
% Which ideally should collect most of what you want to know about the
% recording, including the m-File data, Electrode Configuration, IDs, etc.

%% PARSE PARAMETERS
if length(varargin)==1 
  if isstruct(varargin{1})   P=varargin{1}; 
  else P.Identifier = varargin{1};
  end
else P = parsePairs(varargin); end
P = MD_I2S2I(P); Sep = HF_getSep;
OP = MD_dataFormat('Mode','Operator');

checkField(P,'Quick',0); 

%% GET INFORMATION FROM DATABASE
SQL = ['SELECT * FROM gDataRaw WHERE parmfile REGEXP "',P.Identifier,'"'];
R = mysql(SQL);
if isempty(R) error(['No Recordings found for the Identifier ''',P.Identifier,'''']); end

% COPY RELEVANT FIELDS
I.IdentifierFull = R.parmfile(1:end-2); 
I.Stimclass = R.stimclass;
I.Date = R.lastmod;
I.Trials = R.trials;
I.Runclass = R.runclass;
I.Behavior = R.behavior; % not accurate, since distinction between naive and trained
Fields = regexp(I.IdentifierFull,OP.I2S.RE('Runclass'),OP.I2S.Opt{:});
I.Behavior = Fields.Behavior;
I.SiteName = [Fields.Animal,Fields.Penetration,Fields.Depth];

%% FIND MFILE
Path = MD_getDir('Identifier',P.Identifier,'Kind','Base');
I.MFile = [Path,I.IdentifierFull,'.m'];
I.DataPath = MD_getDir('Identifier',P.Identifier,'Kind','Recording');
I.DataRoot = [I.DataPath,I.IdentifierFull];
I.SpikePath = MD_getDir('Identifier',P.Identifier,'DB',1,'Kind','Sorted');
I.SpikeFile = [I.SpikePath,I.IdentifierFull,'.spk.mat'];
I.EVPFile = [I.DataPath,I.IdentifierFull,'.001.1.evp'];
% ADD ID FIELDS
I.ID = R.id;  I.MasterID = R.masterid; I.RunclassID = R.runclassid;

if P.Quick==1 return; end

% CREATE LOCAL PATH FOR RECORDING
[tmp,Paths] = MD_getDir('Identifier',P.Identifier);
if ~exist(Paths.LocalPath,'dir'); mkdirAll(Paths.LocalPath); end

% PREPARE MFILE LOAD
MFileLocal = [Paths.LocalPath,I.IdentifierFull,'.m'];
MFileDB = [Paths.DBPath,I.IdentifierFull,'.m'];
if exist(MFileLocal,'file')
  LOADMFILE = 1;
else
  if exist(MFileDB,'file')
    copyfile(MFileDB,MFileLocal);
    LOADMFILE = 1;
  else
    LOADMFILE = 0;
  end
end

% LOAD MFILE
if LOADMFILE
  I.MFile = MFileLocal;
  LoadMFile(I.MFile);
  I.exptparams = exptparams;
  I.globalparams = globalparams;
  I.exptevents = exptevents;
  I.Stimclass = exptparams.TrialObject.ReferenceClass;

  I.NumberOfChannels = globalparams.NumberOfElectrodes;
  if isfield(exptparams,'TotalRepetitions')
    I.NRepetitions = exptparams.TotalRepetitions;
  else
    I.NRepetitions = 1;
  end
  try I.NTrials = exptparams.TotalTrials; end
  try I.NRefStimuli = length(I.exptparams.TrialObject.ReferenceHandle.Names); end
  try I.RefStimTags = I.exptparams.TrialObject.ReferenceHandle.Names; end
else 
  warning('M-File not found : Paths not set correctly or bad recording');
end

%% DETERMINE RECORDING SYSTEM
if LOADMFILE
  % RECORDING SYSTEM IN PARIS ALWAYS MANTA
  I.Recorder = 'MANTA'; I.EVPVersion = 5;
end

%% LOAD MANTA FILE
if LOADMFILE
  if strcmp(I.Recorder,'MANTA')
    % LOAD FIRST MANTA MAT FILE
    MANTAFileBase = [I.IdentifierFull,'.001.mat'];
    MANTAFile = [I.DataPath,MANTAFileBase];
    
    if ~exist(MANTAFile,'file') % TRY TO EXTRACT MANTA FILE FROM SAVED DATA
      [tmp,Paths] = MD_getDir('Identifier',P.Identifier,'Kind','raw');
      MANTAFileLocal = [Paths.LocalPath,P.Identifier,filesep,MANTAFileBase];
      MANTAFile = MANTAFileLocal;
      if ~exist(MANTAFileLocal,'file')
        TGZFile = [Paths.DBPath,P.Identifier,'.tgz'];
        MANTAFileInternal = [P.Identifier,filesep,MANTAFileBase];
        mkdirAll(MANTAFileLocal);
        Command = ['tar -z --extract --file=',TGZFile,' -C ',Paths.LocalPath,' ',MANTAFileInternal];
        fprintf(['EXTRACTING ',MANTAFileInternal,' FROM ',TGZFile,' TO ',Paths.LocalPath,'\n']);
%         system(Command);
        untar(TGZFile,Paths.LocalPath)
      end
    end
    
    if exist(MANTAFile,'file');
      try
        S = warning('off','all');
        M = load(MANTAFile); I.SR = M.MGSave.DAQ.SR;
        warning(S);
      end
      if ~isfield(I,'SR') I.SR = 25000; end
      if P.Quick==2 return; end
      
      
      % GET ARRAY & SYSTEM SPECS
      [I.ElectrodesByChannel,I.Electrode2Channel ]...
        = MD_getElectrodeGeometry('Identifier',P.Identifier);
      I.NumberOfChannels = length(I.ElectrodesByChannel);
      I.Electrodes = I.ElectrodesByChannel(I.Electrode2Channel);
    else
      I.Electrodes = struct([]);
      warning('MANTA-File not found : Paths not set correctly or bad recording.');
    end
  else
    I.SR = 25000;%I.globalparams.HWparams.fsSpike;
    I.ElectrodesByChannel = M_ArrayInfo('single_clockwise',I.NumberOfChannels);
    for i=1:I.NumberOfChannels I.Electrodes(i).Test = []; end
  end
end

% PREPARE NAMES OF THE SIMPLY TRIGGERED SPIKES
if LOADMFILE
  switch I.Recorder
    case 'MANTA';                TriggerFileBase = [I.IdentifierFull,'.001.1.elec'];
    case {'ALAB','ASNR'};     TriggerFileBase = [I.IdentifierFull,'.001.1.chan'];
  end
  TriggerSuffix = ['.sig4.mat'];
  [tmp,TmpPaths] = MD_getDir('Identifier',P.Identifier,'Kind','tmp');
  TmpPath = TmpPaths.LocalPath;
  for iE=1:I.NumberOfChannels
    I.TriggerFilesByElectrode{iE} = [TmpPath,TriggerFileBase,n2s(iE),TriggerSuffix];
  end
end

%% ASSIGN DEPTH BY CHANNEL (FOR PLEXTRODE USAGE MAINLY)
if LOADMFILE
  tmp = mysql(['SELECT depth FROM gCellMaster WHERE id=',n2s(R.masterid)]);
  if ~isempty(tmp.depth) & ~isempty(I.Electrodes)
    switch I.Recorder
      case 'MANTA';
        cArray = M_ArrayInfo(I.Electrodes(1).Array);
        if ~isempty(R.comments) % USE THE RECORDING COMMENT DEPTH AS THE ESTIMATOR
          Comment = char(R.comments);
        else
          SQL = ['SELECT comments FROM gCellMaster WHERE cellid="',I.SiteName,'"'];
          RCM = mysql(SQL);
          Comment = char(RCM.comments);
        end
        if length(Comment)>=8 && strcmp(Comment(1:8),'Layer IV')
          L4_Electrode = str2num(Comment(22:min([end,23])));
          L4_Depth = 0.500; % Anatomical Depth of Layer IV
          for iE=1:I.NumberOfChannels
            I.Electrodes(iE).DepthBelowSurface = cArray.ElecPos(iE,3)-cArray.ElecPos(L4_Electrode,3) + L4_Depth;
          end
        else
          RecordedDepth = str2num(tmp.depth(1:find(tmp.depth==',')-1))/1000;
          if ~isempty(cArray.Tip) TipDepth = cArray.Tip(3); else TipDepth = 0; end
          for iE=1:I.NumberOfChannels
            I.Electrodes(iE).DepthBelowSurface = RecordedDepth - (TipDepth-cArray.ElecPos(iE,3));
          end
        end
      case 'ALAB';
        RecordedDepth = str2num(tmp.depth)/1000;
        for iE=1:I.NumberOfChannels
          I.Electrodes(iE).DepthBelowSurface = RecordedDepth(iE);
        end
    end
  else
    for iE=1:length(I.Electrodes)
      I.Electrodes(iE).DepthBelowSurface = [];
    end
  end
end

if P.Quick==2 return; end

% LOAD SORTINFO IF AVAILABLE
C  = mysql(['SELECT * FROM sCellFile WHERE rawid=',n2s(R.id)]);
if ~isfield(I,'NumberOfChannels') I.NumberOfChannels = 4; end
I.UnitsByElectrode = cell(I.NumberOfChannels,1);
I.SingleIDsByElectrode = cell(I.NumberOfChannels,1);
for i=1:length(C) % LOOPING OVER UNITS OF ALL ELECTRODES
  I.UnitsByElectrode{C(i).channum}(end+1) = C(i).unit;
  I.SingleIDsByElectrode{C(i).channum}(end+1) = C(i).singleid;
end
I.NumberOfChannels = length(I.UnitsByElectrode);

% ASSIGN THE NUMBER OF SORTED UNITS PER ELECTRODE
I.NUnitsByElectrode = zeros(I.NumberOfChannels,1);
for iE = 1:I.NumberOfChannels
  cPos = find(I.UnitsByElectrode{iE}==min(I.UnitsByElectrode{iE}),1,'last');
  cInd = [ cPos : length( I.UnitsByElectrode{iE} ) ];
  I.UnitsByElectrode{iE} = I.UnitsByElectrode{iE}(cInd);
  I.SingleIDsByElectrode{iE} = I.SingleIDsByElectrode{iE}(cInd);
  I.NUnitsByElectrode(iE) = length(unique(I.UnitsByElectrode{iE}));
end

if exist(I.SpikeFile,'file')  I.SortInfo = load(I.SpikeFile); end