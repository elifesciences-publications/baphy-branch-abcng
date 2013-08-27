function [ev,HW] = IOStartAcquisition(HW)
% function ev = IOStartAcquisition (HW);
%
% This function starts the data acquisition which can mean different things:
%   In test mode, this plays the audioplayer object created in IOLoadSound
%   In single electrode setup (Soundproof 1), this means starting the
%       acquisition of spike data and lick (Analog Input) and sending the
%       triger (digital output) for starting the sound (analog output)
%   In training setup (soundproof 2), this means starting the acqusition of
%       lick (Analog Input) and sendind the trigger (digital output) for
%       starting the sound (analog output)
%   In AlphaOmega setup (soundproof 3), this means starting the acquisition
%       of lick and spike in control computer (Analog Input) and sending
%       the triggers (digital output) for starting the sound (analog
%       output) and alphaomega computer.
%  In MANTA setup, this means sending the new filename to MANTA.
%
% Nima, November 2005
% 
% SVD update 2012-05-30 : added Nidaqmx support

% SVD add for NIDAQ driver (2005-05-30):
ev.Note='TRIALSTART';
ev.StartTime=0;
ev.StopTime=0;

HW.params.StartClock=clock;

%% IF COMMUNICATING WITH MANTA, GET SYSTEM READY
if isfield(HW, 'MANTA') HW = IOReadyManta(HW); end

switch IODriver(HW)
  
  case 'NIDAQMX';
    switch HW.params.HWSetup
      case 0;      tic;
        if strcmpi(HW.params.AOTriggerType,'HwDigital'),
            play(HW.AO);  % AO is an audio player object, which gives control on the sound.
        end
        
      otherwise
        % Configure Triggers
        aiidx=find(strcmp({HW.Didx.Name},'TrigAI'));
        aoidx=find(strcmp({HW.Didx.Name},'TrigAO'));
        TriggerDIO=HW.Didx(aiidx).Task; % WARNING : THIS ASSUMES EVERYTHING IS ON ONE TASK
        
        % IF A BILATERAL TRIGGER IS USED ADD THOSE TRIGGERS
        aiidxInv=find(strcmp({HW.Didx.Name},'TrigAIInv'));
        aoidxInv=find(strcmp({HW.Didx.Name},'TrigAOInv'));
        if ~isempty(aiidxInv) aiidx = [aiidx,aiidxInv]; end
        if ~isempty(aoidxInv) aoidx = [aoidx,aoidxInv]; end
        
        AITriggerChan=[HW.Didx(aiidx).Line];
        AOTriggerChan=[HW.Didx(aoidx).Line];
        v=niGetValue(HW.DIO(TriggerDIO));
        vstop=v;
        if HW.params.syncAIAO,
            % triggering both AI and AO
            vstop([AITriggerChan AOTriggerChan])=...
                HW.DIO(TriggerDIO).InitState([AITriggerChan AOTriggerChan]);
            v([AITriggerChan AOTriggerChan])=...
                1-vstop([AITriggerChan AOTriggerChan]);
        else
            % only triggering AI
            vstop([AITriggerChan])=HW.DIO(TriggerDIO).InitState([AITriggerChan]);
            v([AITriggerChan])=1-vstop([AITriggerChan]);
        end
        
        % ALPHA OMEGA
        %disp('IOStartAcquisition: ALPHA OMEGA TRIGGERING DISABLED FOR NIDAQ');
        if 0
            TrigIndexFile=find(strcmp(HW.DIO.Line.LineName,'FileSave'));
            % only trigger FileSave if it exists. A-O expects 0 -> 1 transition to start
            if ~isempty(TrigIndexFile)
                TrigIndices(end+1) = TrigIndexFile; TrigVals=[TrigVals TrigValFile];
            end
        end
        
        niStop(HW.AI);
        
        HW=niStart(HW);
        % make sure not triggering
        niPutValue(HW.DIO(TriggerDIO),vstop);
        
        % now actually trigger
        niPutValue(HW.DIO(TriggerDIO),v);
    end

  case 'DAQTOOLBOX';
    
    switch HW.params.HWSetup
      case 0 % Test mode
        if strcmpi(HW.params.AOTriggerType,'HwDigital'),
          play(HW.AO);  % AO is an audio player object, which gives control on the sound.
        end
        tic;
        
      otherwise
        %% WAIT UNTIL INPUT AND OUTPUT BECOME AVAILABLE (if daq is still running)
        if isrunning(HW.AO) || isrunning(HW.AI),
          warning('IOStartAcquisition: Device is not ready');end
        while isrunning(HW.AO) || isrunning(HW.AI); pause(0.01); end
        
        %% ANALOG INPUT
        TrigIndexAI=IOGetIndex(HW.DIO,'TrigAI');
        TrigValAI = IOGetTriggerValue(HW.AI,'TRIGGER');
        TrigIndices = TrigIndexAI; TrigVals = TrigValAI;
        set(HW.AI,'BufferingMode','Auto');
        
        %% ALPHA OMEGA
        TrigIndexFile=find(strcmp(HW.DIO.Line.LineName,'FileSave'));
        % only trigger FileSave if it exists. A-O expects 0 -> 1 transition to start
        if ~isempty(TrigIndexFile)
          TrigIndices(end+1) = TrigIndexFile; TrigVals=[TrigVals TrigValFile];
        end
        
        %% ANALOG OUTPUT
        if strcmpi(get(HW.AO,'TriggerType'),'HwDigital') % TRIGGER ONLY FOR DAQ BASED SOUND OUT
          stop([HW.AO HW.AI]);
          TrigIndexAO=IOGetIndex(HW.DIO,'TrigAO');
          TrigValAO = IOGetTriggerValue(HW.AO,'TRIGGER');
          TrigIndices(end+1) = TrigIndexAO;
          TrigVals(end+1) = TrigValAO;
          start([HW.AO HW.AI]);
        else
          start([HW.AI]);
        end
        
        %% RESET ALL LINES
        putvalue(HW.DIO.Line(TrigIndices),1-TrigVals);
        
        %% TRIGGER ALL LINES
        putvalue(HW.DIO.Line(TrigIndices),TrigVals);
        % [TV,TS] = datenum2time(now); fprintf([' >> TRIGGER sent (',TS{1},')\n']);
    end
    
  otherwise 
    error('NI Driver not implemented. (Contact BE when you get this error.)')
    
end
