function [ev,HW] = IOStopAcquisition (HW);
% function ev = IOStopAcquisition (HW);
%
% This function stops the data acquisition which can mean different things:
%   In test mode, this does not do anything
%   In single electrode setup (Soundproof 1), this means ...
%   In training setup (soundproof 2), this means ...
%   In AlphaOmega setup (soundproof 3), this means stopping the analog
%       input and reseting the trigger signals.
%   In MANTA setup this mean
%
% Nima, November 2005
% 
% SVD update 2012-05-30 : added Nidaqmx support. situation is slightly
% screwy, since we need to leave AI running now in order to read AI data
% and get timestamps. So for now, this only stops AO when driver is NIDAQMX.
%
ev.Note='TRIALSTOP';

if strcmpi(IODriver(HW),'NIDAQMX'),
  if HW.params.HWSetup==0,
    % don't do anything
    
  else
    
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
    %vstop([AITriggerChan AOTriggerChan])=...
    %  HW.DIO(TriggerDIO).InitState([AITriggerChan AOTriggerChan]);
    %disp('IOStopAcquisition: Only stopping AO since AI must be running for data to be read');
    vstop([AOTriggerChan])=HW.DIO(TriggerDIO).InitState([AOTriggerChan]);
    
    % ALPHA OMEGA
    %disp('IOStopAcquisition: ALPHA OMEGA TRIGGERING DISABLED FOR NIDAQ');
    
    % make sure not triggering
    niPutValue(HW.DIO(TriggerDIO),vstop);
    niStop(HW.AO);
  end
  
  % IF COMMUNICATING WITH MANTA
  if strcmp(HW.params.DAQSystem,'MANTA')
    MSG = ['STOP',HW.MANTA.COMterm,HW.MANTA.MSGterm];
    [RESP,HW] = IOSendMessageManta(HW,MSG,'STOP OK','',1);
  end

  ev.StartTime=IOGetTimeStamp(HW);
  ev.StopTime=ev.StartTime;
  
  return;
end

switch HW.params.HWSetup
    case 0  % Test mode: do nothing
        ev.StartTime=IOGetTimeStamp(HW);
        ev.StopTime=[];
        
%     case 11
%         
%         % Stop the sound and acqusition of lick signal from AI
%         A0TriggerType=get(HW.AO,'TriggerType');
%         if strcmp(A0TriggerType,'HwDigital')
%             stop(HW.AO);
%         end
%         stop(HW.AI);
%         
%         for j=1:100,
%             pause(1);
%             ret=AO_StopSave;
%             if ret~=4
%                 disp('Stopped Saving Spikes!!!')
%                 break;
%             end
%         end
%         
%         RetcloseConnection=AO_CloseConnection
%         
%         ev.StartTime=get(HW.AI,'SamplesAcquired')/HW.params.fsAI;
%         ev.StopTime=ev.StartTime;
           
    otherwise
        % mirror-symmetric with IOStartAcquisition triggers
        trigidx1=IOGetIndex(HW.DIO,'TrigAI');
        trigidx2=IOGetIndex(HW.DIO,'TrigAO');
        fileidx=find(strcmp(HW.DIO.Line.LineName,'FileSave'));
        
        % always trigger AI
        % SVD fixed absurd bug where sign was swapped 2010-12-16
        if any(strcmpi(get(HW.AI,'TriggerCondition'),{'NegativeEdge','None'}))
            idxout=1;
        else
            idxout=0;
        end
        
        % only trigger A0 if set to HwDigital trigger
        idxlist=[trigidx1];
        if HW.params.HWSetup~=4,
            A0TriggerType=get(HW.AO,'TriggerType');
            if strcmpi(A0TriggerType,'HwDigital'),
                idxlist=[idxlist trigidx2];
                idxout=[idxout 1];
            end
        else
            A0TriggerType='Manual';
        end
        
        % only trigger FileSave if it exists
        if ~isempty(fileidx),  idxlist=[idxlist fileidx]; idxout=[idxout 0];  end
        
        % actually un-pull the triggers
        putvalue(HW.DIO.Line(idxlist),idxout);
        
        % Stop the sound and acqusition of lick signal from AI
        if strcmp(A0TriggerType,'HwDigital')
            stop(HW.AO);
        end
        stop(HW.AI);
                
        ev.StartTime=get(HW.AI,'SamplesAcquired')/HW.params.fsAI;
        ev.StopTime=ev.StartTime;
end

% IF COMMUNICATING WITH MANTA
if strcmp(HW.params.DAQSystem,'MANTA')
  MSG = ['STOP',HW.MANTA.COMterm,HW.MANTA.MSGterm];
  [RESP,HW] = IOSendMessageManta(HW,MSG,'STOP OK','',1);
end

