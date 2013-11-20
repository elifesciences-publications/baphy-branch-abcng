function I =getRecInfo(varargin)

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

%% LOAD MFILE
LOADMFILE = 0;
if exist(I.MFile,'file')
  LOADMFILE = 1;
else
  Pos = strfind(I.MFile,P.Animal);
  global SERVER_PATH;
  ServerMFile = [SERVER_PATH,'daq',I.MFile(Pos(1)-1:end)];
  if exist(ServerMFile,'file')
    I.MFile = ServerMFile  
    LOADMFILE = 1;
  end
end

if LOADMFILE
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
switch I.globalparams.HWSetup
  case {7,8,10,12}; I.Recorder = 'MANTA'; I.EVPVersion = 5;
  case {11}; I.Recorder = 'ASNR'; I.EVPVersion = 4;
  otherwise I.Recorder = 'ALAB'; I.EVPVersion = 4;
end

%% LOAD MANTA FILE
if strcmp(I.Recorder,'MANTA');
  % LOAD FIRST MANTA MAT FILE
  MANTAFile = [I.DataPath,I.IdentifierFull,'.001.mat'];
  if exist(MANTAFile,'file');
    try
      tic
      S = warning('off','all');
      M = load(MANTAFile); I.SR = M.MGSave.DAQ.SR;
      warning(S);
      toc
    end
    if P.Quick==2 return; end

    % GET ARRAY & SYSTEM SPECS
    [I.ElectrodesByChannel,I.Electrode2Channel ]...
      = MD_getElectrodeGeometry('Identifier',P.Identifier);
    I.NumberOfChannels = length(I.ElectrodesByChannel);
    I.Electrodes = I.ElectrodesByChannel(I.Electrode2Channel);
  else
    for i=1:I.NumberOfElectrodes I.Electrodes(i) = []; end
    warning('MANTA-File not found : Paths not set correctly or bad recording.');
  end
else
  I.SR = 25000;%I.globalparams.HWparams.fsSpike;
  I.ElectrodesByChannel = M_ArrayInfo('single_clockwise',I.NumberOfChannels);
  for i=1:I.NumberOfChannels I.Electrodes(i).Test = []; end
end

%% ASSIGN DEPTH BY CHANNEL (FOR PLEXTRODE USAGE MAINLY)
tmp = mysql(['SELECT depth FROM gCellMaster WHERE id=',n2s(R.masterid)]);
if ~isempty(tmp.depth)
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
        TipDepth = cArray.Tip(3);
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

if P.Quick==2 return; end

% LOAD SORTINFO IF AVAILABLE
C  = mysql(['SELECT * FROM sCellFile WHERE rawid=',n2s(R.id)]);
I.NUnitsByElectrode = zeros(I.NumberOfChannels,1);
I.UnitsByElectrode = cell(I.NumberOfChannels,1);
I.SingleIDsByElectrode = cell(I.NumberOfChannels,1);
for i=1:length(C) % LOOPING OVER UNITS OF ALL ELECTRODES
  I.NUnitsByElectrode(C(i).channum) = I.NUnitsByElectrode(C(i).channum)+ 1;
  I.UnitsByElectrode{C(i).channum}(end+1) = C(i).unit;
  I.SingleIDsByElectrode{C(i).channum}(end+1) = C(i).singleid;
end

if exist(I.SpikeFile,'file')  I.SortInfo = load(I.SpikeFile); end