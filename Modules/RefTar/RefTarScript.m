function varargout = RefTarScript (globalparams, exptparams, HW)
% This function is the main script for Reference Target module
% The function reads the ReferenceTarget object from config/ReferenceTargetObject
% file and setup the experiment based on the parameters of the object. This object has been
% saved from RefTarGui. This includes:
%   Initializing the trial sequence
%   Looping over the trials
%   Putting out the sound and gathering the data
%   Analysing the lick and shocking the animal
%   Returning the event structure to the main program.
%
% Nima Mesgarani, November 2005
% BE, modified & polished, 2011/7
% SVD, added NIDAQMX support 2012/05

global StopExperiment; StopExperiment = 0; % Corresponds to User button
global exptparams_Copy; exptparams_Copy = exptparams; % some code needs exptparams
global BAPHY_LAB LoudnessAdjusted
global SAVEPUPIL

BehaveObject = exptparams.BehaveObject;

if strcmpi(exptparams.BehaveObjectClass,'MriPassive') && ...
        get(BehaveObject,'DelayAfterScanTTL')==0,
   disp('MriPassive: press a key to synchronize with start of MRI scan ...');
   pause
end

exptevents = []; ContinueExp = 1; exptparams.TotalRepetitions = 0; TrialIndex = 0;
exptparams.StartTime = clock; exptparams.Water = 0;
laststoptime=now;

% ADD DESCRIPTIVE COMMENTS
exptparams.comment = [...
  'Experiment: ',class(exptparams.BehaveObject),' ',...
  'TrialObject: ',class(exptparams.TrialObject),' ',...
  'Reference Class: ',get(exptparams.TrialObject, 'ReferenceClass'),' ',...
  'Target Class: ',get(exptparams.TrialObject, 'TargetClass')];

%% MAIN LOOP
while ContinueExp == 1
  if exist('iRep')==0
    exptparams.TrialObject = ObjUpdate(exptparams.TrialObject);
    TrialIndexLst = 1:(exptparams.TrialBlock*exptparams.Repetition);    % List of trial nb sent to <waveform>; modified during reinsertion
     if (isfield(struct(exptparams.TrialObject),'TrialIndexLst') && isempty(get(exptparams.TrialObject,'TrialIndexLst'))); exptparams.TrialObject = set(exptparams.TrialObject,'TrialIndexLst',TrialIndexLst); end
  elseif isfield(struct(exptparams.TrialObject),'TrialIndexLst')
    TrialIndexLst = get(exptparams.TrialObject,'TrialIndexLst');
    TrialIndexLst = [ TrialIndexLst , max(TrialIndexLst) + (1:(exptparams.TrialBlock*exptparams.Repetition)) ];    % List of trial nb sent to <waveform>; modified during reinsertion
     exptparams.TrialObject = set(exptparams.TrialObject,'TrialIndexLst',TrialIndexLst);
  end  
 
  iRep = 0;
  while iRep < exptparams.Repetition; % REPETITION LOOP
    iRep = iRep+1;
    if ~ContinueExp, break; end
    % AT BEGINNING OF EACH REPETITION, RANDOMIZE SEQUENCE OF INDICES
    % via RandomizeSequence method of the Trial Object with flag = 1 (Repetition Call)
    exptparams = RandomizeSequence(exptparams.TrialObject, exptparams, globalparams, iRep, 1);
    
    iTrial=0;
    while iTrial<get(exptparams.TrialObject,'NumberOfTrials') % TRIAL LOOP
      TrialIndex = TrialIndex + 1; % MAIN TRIAL COUNTER
      iTrial = iTrial+1;  % TRIAL COUNTER WITHIN REPETITION
      exptparams.InRepTrials = iTrial;
      exptparams.TotalTrials = TrialIndex;
      
      %% PREPARE TRIAL
      TrialObject = get(exptparams.TrialObject);
      % 2013/12 YB: VISUAL DISPLAY--Back to grey screen on the second monitor if we are in a psychophysics experiment
      if isfield(TrialObject,'VisualDisplay') && TrialObject.VisualDisplay; 	[VisualDispColor,exptparams] = VisualDisplay(TrialIndex,'GREY',exptparams); end
        
      %Create pump control
      if isfield(TrialObject,'PumpProfile')
          PumpProfile = TrialObject.PumpProfile;
          handles = guihandles(WaterPumpControl(PumpProfile, TrialIndex));
          PumpProfile = str2num(get(handles.edit1,'string'));
          exptparams.TrialObject = set(exptparams.TrialObject,'PumpProfile',PumpProfile);
      end
      
      % Yves; 2013/11: I added an input to 'waveform' methods
      if any(strcmp(fieldnames(exptparams.TrialObject),'TrialIndexLst'))
        [TrialSound, StimEvents, exptparams.TrialObject] = waveform(exptparams.TrialObject, iTrial,TrialIndexLst(TrialIndex));
      else
        [TrialSound, StimEvents, exptparams.TrialObject] = waveform(exptparams.TrialObject, iTrial);
      end
      [HW,globalparams,exptparams] = LF_setSamplingRate(HW,globalparams,exptparams);
      HW = IOSetLoudness(HW, 80-get(exptparams.TrialObject, 'OveralldB'));
      
      % CONSTRUCT FILENAME FOR MANTA RECORDINGS (ONLY USED IN MANTA SETUP)
      HW.Filename = M_setRawFileName(globalparams.mfilename,TrialIndex);

      % GET & SET LOGGING DURATION FOR PRESENT TRIAL
      exptparams.LogDuration = LogDuration(BehaveObject, HW, ...
        StimEvents, globalparams, exptparams, TrialIndex);
      LogSteps = exptparams.LogDuration*HW.params.fsAI;
      IOSetAnalogInDuration(HW,exptparams.LogDuration);
      
      % MATCH SOUND AND ACQUISITION DURATION
      TrialSound(floor(exptparams.LogDuration.*HW.params.fsAO),end) = 0;
      
      exptparams = GUIUpdateStatus (globalparams, exptparams, TrialIndex, iTrial); drawnow;
      
      % CHECK WHETHER TRIAL CAN BE STARTED
      BehaviorEvents = 1; % Just initialize
      while BehaviorEvents
        BehaviorEvents = ... % CHECK PRETRIAL CONDITION
          CanStart(BehaveObject, HW, StimEvents, globalparams, exptparams, TrialIndex);
        if StopExperiment ContinueExp = ContinueOrNot; end; % USER PRESSED STOP
        if ~ContinueExp break; end
      end; if ~ContinueExp, TrialIndex = TrialIndex - 1; break; end
      
      % svd 2012-10-27: moved IOLoadSound after CanStart to allow sounds to
      % be played during CanStart prior to beginning of the aquisition
      % period of the trial. Shouldn't cause any serious changes in timing
      %using the 2nd SOUNDOUT as pumpcontrol by PY @ 9-2/2012
      if strcmpi(BAPHY_LAB,'nsl') && globalparams.HWSetup==3 
        if size(TrialSound,2)==2
          HW = IOLoadSound(HW, TrialSound(:,[2 1]));
        else
          HW = IOLoadSound(HW, TrialSound(:,[1 1]));
        end      
      elseif strcmp( class(BehaveObject) , 'RewardTargetContinuous' )
        
      else
          HW = IOLoadSound(HW, TrialSound);
      end

      % force at least 500 ms pause between trials in SPR2
      if ~niIsDriver(HW) && (HW.params.HWSetup == 3 || HW.params.HWSetup == 11),
        while str2num(datestr(now-laststoptime,'SS.FFF'))<0.1,
          pause(0.05);
          fprintf('.');
        end
      end
      
      %% MAIN ACQUISITION SECTION
      if ~strcmp( class(BehaveObject) , 'RewardTargetContinuous' )  % Acquisition starts within BehaviorControl.m
        [StartEvent,HW] = IOStartAcquisition(HW);
      end
      
      % HAND CONTROL TO LICK MONITOR TO CONTROL REWARD/SHOCK
      [BehaviorEvents, exptparams] = ...
        BehaviorControl(BehaveObject, HW, StimEvents, globalparams, exptparams, TrialIndex);
      
      % STOP ACQUISITION
      [TrialStopEvent,HW] = IOStopAcquisition(HW);
      % IF THERE WAS A PROBLEM ON THE ACQUISITION SIDE, RERUN LAST TRIAL
      if strcmp(HW.params.DAQSystem,'MANTA') &&...
          isfield(HW.MANTA,'RepeatLast') && HW.MANTA.RepeatLast
        TrialIndex = TrialIndex - 1; iTrial = iTrial - 1; HW.MANTA.RepeatLast = 0; continue;
      end
      
      laststoptime=now;
      
      %% COLLECT TRIAL INFORMATION: EVENTS, RESPONSES, MICROPHONE
      exptevents = AddMultiEvent(exptevents,{StartEvent,StimEvents,BehaviorEvents,TrialStopEvent},TrialIndex);
      
      % COLLECT ANALOG CHANNELS
      [Data.Aux, Data.Spike, AINames] = IOReadAIData(HW); RespIndices = [];
      
      for i=1:length(AINames)
        Data.(AINames{i}) = Data.Aux(:,i);
        if strcmpi(AINames{i}(1:min(end,5)),'Touch') RespIndices(end+1) = i; end
        if strcmpi(AINames{i}(1:min(end,4)),'walk') RespIndices(end+1) = i; end
      end
      Data.Responses = Data.Aux(:,RespIndices);
      exptparams.RespSensors = AINames(RespIndices);
      Data.Microphone = [];
      
      % LICK DATA FOR TEST MODE
      if ~HW.params.HWSetup
          t=evtimes(exptevents,'LICK',TrialIndex);
          Data.Responses = zeros(single(LogSteps),1);
          Data.Responses(round(t.*HW.params.fsAux))=1;
          %Data.Responses = double(rand(single(LogSteps),1)<0.005); 
      end
      
      % DISPLAY PERFORMANCE DATA IN RefTarGui
      exptparams = PerformanceAnalysis(BehaveObject, HW, StimEvents, ...
        globalparams, exptparams, TrialIndex, Data.Responses);
      exptparams = GUIUpdateStatus (globalparams, exptparams, TrialIndex, iTrial);
      
      % breaking hardware abstraction rule! Fix this!  SVD 2012-05-31
      % this is to deal with the fact that we have to leave the AI task
      % running in order to read in the AI data.
      if strcmpi(IODriver(HW),'NIDAQMX'),
          %disp('Stopping AI task');
          niStop(HW);
      end
      % IF COMMUNICATING WITH MANTA
      if strcmp(HW.params.DAQSystem,'MANTA')
          MSG = ['STOP',HW.MANTA.COMterm,HW.MANTA.MSGterm];
          [RESP,HW] = IOSendMessageManta(HW,MSG,'STOP OK','',1);
      end
      
      % PLOT BEHAVIOR ANALYSIS
      exptparams = BehaviorDisplay(BehaveObject, HW, StimEvents, globalparams, ...
          exptparams, TrialIndex, Data.Responses, TrialSound);
      
      % SAVE LICK/TOUCH/MICROPHONE DATA TO EVP FILE
      if ~isempty(globalparams.mfilename),
          evpwrite(globalparams.localevpfile,Data.Spike,[Data.Responses Data.Microphone],HW.params.fsSpike,HW.params.fsAux);
      end
      
      % DISPLAY MICROPHONE WAVEFORM
      if strcmpi(exptparams.OnlineWaveform,'Yes') LF_showMic(Data.Microphone,exptparams,HW,TrialSound); end
      
      % CHECK WHETHER TO STOP
      if (~mod(TrialIndex, exptparams.TrialBlock) ...  % end of trialblock
          && ~isempty(strfind(globalparams.Physiology,'No')) ... % but no physiology
          && ~exptparams.ContinuousTraining) ...      % and no continuous training
          || StopExperiment, % stop button pressed
        ContinueExp = ContinueOrNot;
        if ~ContinueExp, break; end
      end
      
      if strcmpi(BAPHY_LAB,'lbhb') && ~mod(TrialIndex,20) && ...
              (globalparams.HWSetup==0 || iTrial<get(exptparams.TrialObject,'NumberOfTrials')) &&...
              ~isempty(globalparams.mfilename),
          fprintf('Saving parmfile for safety.\n');
          WriteMFile(globalparams,exptparams,exptevents,1);
      end
      
      %% RANDOMIZE WITH FLAG 0 (TRIAL CALL)
      % Used in adaptive schemes, where trialset is modified based on animals performance
      % Needs to change NumberOfTrials and Modify the IndexSets
      exptparams = RandomizeSequence(exptparams.TrialObject, exptparams, globalparams, iTrial, 0);
      if any(strcmp(fieldnames(exptparams.TrialObject),'TrialIndexLst')); TrialIndexLst = get(exptparams.TrialObject,'TrialIndexLst'); end
      
    end % END OF TRIAL LOOP
    exptparams.TotalRepetitions = exptparams.TotalRepetitions + 1;
    
    %% FINISH UP REPETITION
    % TELL MANTA TO SAVE ONLINE SPIKETIMES
    if strcmp(HW.params.DAQSystem,'MANTA')
        MSG = ['SETVAR',HW.MANTA.COMterm,...
            'M_saveSpiketimes; ',HW.MANTA.MSGterm];
        IOSendMessageManta(HW,MSG,'SETVAR OK');
    end
    
    % WRITE LOCAL FILE TO TEMP AND WRITE M-FILE
    if ~isempty(globalparams.mfilename) && exist(globalparams.localevpfile,'file')
      if strcmp(HW.params.DAQSystem,'MANTA') || strcmp(globalparams.Physiology,'No'),
        copyfile(globalparams.localevpfile, globalparams.evpfilename);
      else
        % when acquiring data with A-O, save evp to tmp and let flush take
        % care of generating the final evp.
        copyfile(globalparams.localevpfile, globalparams.tempevpfile);
      end
    end
    
    % WRITE MFILE
    if ~isempty(globalparams.mfilename),
      WriteMFile(globalparams,exptparams,exptevents,1);
    else
      disp('TEST MODE. Not saving mfile');
    end
  end % END OF REPETITION LOOP
  
  if HW.params.HWSetup ~= 0 %Checking if using Test mode
    if ~isempty(exptparams.Repetition) && iRep==exptparams.Repetition && ...
            isempty(strfind(globalparams.Physiology,'No')) && ContinueExp
      ContinueExp = ContinueOrNot;  % END OF REPETITION : CHECK IF USE WANTS TO CONTINUE
    end
  else
    if (iRep==exptparams.Repetition) && ContinueExp
      ContinueExp = ContinueOrNot;  % END OF REPETITION : CHECK IF USE WANTS TO CONTINUE
    end
  end
end % CHECK FOR CONTINUING EXPERIMENT
exptparams.StopTime = clock;
% svd commented out line 2014-12-01 because it isn't needed any more?
% if ~isfield(exptparams,'volreward') exptparams.volreward = exptparams.Water; end

%% POSTPROCESSING
switch HW.params.DAQSystem
  case 'MANTA';
    MSG = ['RUNFUN',HW.MANTA.COMterm,'M_startEngine; ',HW.MANTA.MSGterm];
    IOSendMessageManta(HW,MSG,'');
end

% Tell pupil system to stop
if SAVEPUPIL && isfield(HW,'Pupil'),
    MSG = ['STOP',HW.Pupil.COMterm,HW.Pupil.MSGterm];
    [RESP,HW.Pupil] = IOSendMessageTCPIP(HW.Pupil,MSG,'STOP OK','',1);
end

% GET AMOUNT OF WATER GIVEN
if ~isfield(exptparams,'WaterUnits') | strcmp(exptparams.WaterUnits,'seconds')
  exptparams.Water = exptparams.Water .* globalparams.PumpMlPerSec.Pump;
end

% UPDATE DISPLAY WITH WATER AND SOUND
exptparams = BehaviorDisplay(BehaveObject, HW, StimEvents, globalparams, exptparams, TrialIndex, [], TrialSound);

% MAKE SURE PUMP, SHOCK AND LIGHT ARE OFF
try IOControlPump(HW,'stop'); IOControlShock(HW,0,'stop'); IOLightSwitch(HW,0); end

% SEND PARAMETERS & DATA TO DATABASE
LF_writetoDB(globalparams,exptparams)

% WRAP UP DISPLAY & RETURN VALUES
close(exptparams.FigureHandle);
if isfield (exptparams,'FigureHandle'), exptparams = rmfield(exptparams,'FigureHandle');end
if isfield (exptparams,'TempDisp'),     exptparams = rmfield(exptparams,'TempDisp');end
if isfield (exptparams,'wavefig'),      exptparams = rmfield(exptparams,'wavefig');end
varargout{1} = exptevents; varargout{2} = exptparams;

%%
%%======== LOCAL FUNCTIONS =======================================
%%
function ContinueExp = ContinueOrNot
global StopExperiment;
FP = get(0,'DefaultFigurePosition');
MP = get(0,'MonitorPosition');
SS = get(0,'ScreenSize');
set(0,'DefaultFigurePosition',[10,MP(4)/2-SS(2),FP(3:4)]);
UserInput = questdlg('Continue the experiment?');
set(0,'DefaultFigurePosition',FP);
ContinueExp = strcmpi(UserInput, 'Yes') | strcmpi(UserInput,'Cancel');
if ContinueExp==1, StopExperiment = 0; end

function [HW,globalparams,exptparams] = LF_setSamplingRate(HW,globalparams,exptparams)
if strcmpi(exptparams.OnlineWaveform,'Yes')
  HW.params.fsAI = get(exptparams.TrialObject, 'SamplingRate');
  HW.params.fsAux = HW.params.fsAI;
  HW = IOSetSamplingRate(HW, [HW.params.fsAI HW.params.fsAI]);
  globalparams.HWparams = HW.params;
else
  HW = IOSetSamplingRate(HW, get(exptparams.TrialObject, 'SamplingRate'));
end

function LF_showMic(MicData,exptparams,HW,TrialSound)
if ~isempty(MicData)
  if isfield(exptparams,'wavefig') figure(exptparams.wavefig);
  else exptparams.wavefig = figure;
  end
  subplot(2,2,1); plot(TrialSound); axis tight; title('computer waveform')
  subplot(2,2,2); spectrogram(TrialSound,256,[],[],HW.params.fsAO,'yaxis'); title('computer spectrogram');
  subplot(2,2,3); plot(MicData); axis tight; title('microphone waveform');
  subplot(2,2,4); spectrogram(MicData,256,[],[],HW.params.fsAux,'yaxis'); title('microphone spectrogram');
end

function LF_writetoDB(globalparams,exptparams)
global DB_USER
if globalparams.rawid>0 && dbopen,
  [Parameters, Performance] = PrepareDatabaseData ( globalparams, exptparams);
  dbWriteData(globalparams.rawid, Parameters, 0, 0);  % this is parameter and dont keep previous data
  dbWriteData(globalparams.rawid, Performance, 1, 0); % this is performance and dont keep previous data
  if isfield(Performance,'HitRate') && isfield(Performance,'Trials')
    sql=['UPDATE gDataRaw SET corrtrials=',num2str(round(Performance.HitRate*Performance.Trials)),',',...
      ' trials=',num2str(Performance.Trials),' WHERE id=',num2str(globalparams.rawid)];
    mysql(sql);
  elseif isfield(Performance,'Hit') && isfield(Performance,'FalseAlarm')
    sql=['UPDATE gDataRaw SET corrtrials=',num2str(Performance.Hit(1)),',',...
      ' trials=',num2str(Performance.FalseAlarm(2)),' WHERE id=',num2str(globalparams.rawid)];
    mysql(sql);
  end

  % also, if 'water' is a field, make it accumulative:
  if isfield(exptparams, 'Water')
    %%%%%%%%%%%%%% new water:
    sql=['SELECT gAnimal.id as animal_id,gHealth.id,gHealth.water'...
      ' FROM gAnimal LEFT JOIN gHealth ON gHealth.animal_id=gAnimal.id'...
      ' WHERE gAnimal.animal like "',globalparams.Ferret,'"',...
      ' AND date="',datestr(now,29),'" LIMIT 1'];
    hdata=mysql(sql);
    if ~isempty(hdata),
      % gHealth entry already exists, update
      if isempty(hdata.water) hdata.water = 0; end
      swater=sprintf('%.2f',hdata.water+exptparams.Water);
      sql=['UPDATE gHealth set schedule=1,trained=1,water=',...
        swater,' WHERE id=',num2str(hdata.id)];
    else
      % create new gHealth entry
      sql=['SELECT * FROM gAnimal WHERE animal like "',globalparams.Ferret,'"'];
      adata=mysql(sql);
      sql=['INSERT INTO gHealth (animal_id,animal,date,water,trained,schedule,addedby,info) VALUES'...
        '(',num2str(adata.id),',"',globalparams.Ferret,'",',...
        '"',datestr(now,29),'",'...
        num2str(exptparams.Water),',1,1,"',DB_USER,'","dms_run.m")'];
    end
    mysql(sql);
  end
end