function quickSaveResults(R,varargin)
% Tasks: 
% - Adapt format to spk.mat format and save mat file in ./sorted/
% - Save information in sCellFile
% - Save linking information in gSingleRaw ? 

% SET VARIABLES
P = parsePairs(varargin); global U;
checkField(P,'Animal');
checkField(P,'Penetration');
checkField(P,'Depth');
checkField(P,'Recording');
checkField(P,'Behavior');
checkField(P,'Runclass');
checkField(P,'Electrode');
checkField(P,'Sorter')
checkField(P,'SortParameters');
if ~isfield(P,'SaveSorter') P.SaveSorter=0; end
    
dbopen; % MAKE SURE DB IS ACCESSIBLE

% COMPUTE PATHS AND FILENAMES
P = MD_I2S2I(P);
I = getRecInfo('Identifier',P.Identifier);
Path = MD_getDir('Identifier',P.Identifier,'DB',1);

%LOAD STIMULUS MFILE
P.StimStart = I.exptparams.TrialObject.ReferenceHandle.PreStimSilence;
P.StimStop = P.StimStart + I.exptparams.TrialObject.ReferenceHandle.Duration;
Path = MD_getDir('Identifier',P.Identifier,'Kind','Sorted','DB',1);

% CONVERT RESULTS TO OLD FORMAT FOR DB ACCESS
MFile = I.MFile; % OK
SpikeFile = [Path,I.IdentifierFull,'.spk.mat']; % OK
EventTimes = sort(cell2mat(R.STs),'ascend'); % OK
SpikeSet = R.SortedWaves'; % OK
spksav1 = R.STs; % OK
sorter = P.Sorter; % OK
PSORTER = 1; % OK
sflag = 1; % OK, but Unclear
comments = 'Sorted with quickSort / SC_quickSort'; % OK
expData = tagid; % OK
expData = set(expData,'AcqSamplingFreq',I.SR); % OK
expData = set(expData,'Repetitions',I.NRepetitions); % OK

extras = struct('exptevents',I.exptevents,... % OK
  'npoint',diff(R.TrialIndices(end-1:end)),... % OK
  'chanNum',num2str(P.Electrode),... % OK
  'numChannels',I.NumberOfChannels,... %OK
  'StimTagNames',{I.RefStimTags},... % via Events2Trials
  'trialstartidx',R.TrialIndices(1:end-1),... % OK
  'tolerance',0,... % Not set here
  'expData',expData,...
  'sweeps',I.NRepetitions); % OK
ABAFlag = 0;

% savespikes(source,destin,st,             spiketemp,spk,        sorter,sflag, comments,extras,abaflag,xaxis,sortparameter);
P.SortParameters.SaveSorter = P.SaveSorter;
savespikes(MFile,SpikeFile,EventTimes,SpikeSet,spksav1,sorter,sflag,comments,extras,ABAFlag,[],P.SortParameters);

ONEFILE=1; % OK
fname=I.MFile; % OK
spk=spksav1; % OK
O = MD_dataFormat('Mode','Operator');
siteid = O.S2I.FH(P.Animal,P.Penetration,P.Depth); % Important to be able to link cells together
chanNum=P.Electrode; % OK
source = MFile(1:end-2); % SOURCE OF DATA = ORIGINAL M-FILE ON LOCAL MACHINE (but for some reason without .M)
destin = SpikeFile(1:end-8); % DESTINATION OF SPIKESORTED DATA = .SPK.MAT FILE ON SERVER 
destin2=destin; source2=source;
chanNum = num2str(P.Electrode);
isopct = 100*ones(size(R.STs));
matchcell2file;