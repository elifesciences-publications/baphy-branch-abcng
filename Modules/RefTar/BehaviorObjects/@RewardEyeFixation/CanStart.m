function [StopExperiment, HW] = CanStart (o, HW, StimEvents, globalparams, exptparams, TrialIndex)
% CanStart for ReferenceEyeFixation
% We wait until the animal fixates for at least NoResponseTime


% 15/08-YB
% if TrialIndex==1
%     PumpDuration = 2*get(o,'PumpDuration');
%     tic;  %added by pby
%     ev = IOControlPump (HW,'start',PumpDuration);
%     pause(PumpDuration);
%     if strcmpi(get(o,'TurnOnLight'),'BehaveOrPassive')
%         [ll,ev] = IOLightSwitch (HW, 1);
%     end
%     pause(1);
% end
AllowedRadius = exptparams.BehaveObject.AllowedRadius;

%% OLD SECTION FOR CHECKING AI ONLINE
% %% START ACQUISITION OF ONLINE EYE TRACKING
% % From IOStartAcquisition.m
% % Configure Triggers
% aiidx=find(strcmp({HW.Didx.Name},'TrigOnlineAI'));
% TriggerDIO=HW.Didx(aiidx).Task; % WARNING : THIS ASSUMES EVERYTHING IS ON ONE TASK
% 
% AITriggerChan=[HW.Didx(aiidx).Line];
% v=niGetValue(HW.DIO(TriggerDIO));
% vstop=v;
% % only triggering AI
% vstop([AITriggerChan])=HW.DIO(TriggerDIO).InitState([AITriggerChan]);
% v([AITriggerChan])=1-vstop([AITriggerChan]);
% 
% AInum=find(~cell2mat(cellfun(@isempty,strfind({HW.AI.Names},'Online'),'UniformOutput',0)));
% niStop(HW.AI(AInum));
% 
% % Taken from niStart.m
% global NI_SHOW_ERR_WARN
% 
% if NI_SHOW_ERR_WARN,
%   disp('Starting NIDAQMX tasks');
% end
% 
% S = DAQmxStartTask(HW.DIO(TriggerDIO).Ptr);
% if S NI_MSG(S); end
% 
% if ~isempty(HW.DIO(TriggerDIO).InitState),
%   %     make sure DO channels are set to appropriate initial state before
%   %     starting Analog channels
%   SamplesWritten = libpointer('int32Ptr',false);
%   WriteArray = libpointer('uint8PtrPtr',HW.DIO(TriggerDIO).InitState);  % POINTER to array
%   S = DAQmxWriteDigitalLines(HW.DIO(TriggerDIO).Ptr,1,1,10,NI_decode('DAQmx_Val_GroupByScanNumber'),WriteArray,SamplesWritten,[]);
%   if S NI_MSG(S); end
%   if get(SamplesWritten,'value')<1,
%     disp('warning: 1 sample not written during DO init!');
%   end
% end
% 
% S = DAQmxStartTask(HW.AI(AInum).Ptr);
% if S NI_MSG(S); end
% 
% % make sure not triggering
% niPutValue(HW.DIO(TriggerDIO),vstop);
% 
% % now actually trigger
% niPutValue(HW.DIO(TriggerDIO),v);

%% WAIT FOR LONG ENOUGH FIXATION FOR INITIATING TRIALS
disp(['Waiting for initial fixation during ' num2str(get(o,'NoResponseTime')) 's']);

%% DISPLAY

        Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrL);
 %      Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrR);
       
switch o.StimType
    
        case 'approxRFbar'
      Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrL);      
      Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], []);
  
       
    case 'Training'
%% DISPLAY FIXATION CROSS

      Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.CircleRectL);
      Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.CircleRectR);
      Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectLin);
      Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectRin);
      Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixVL);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixHL);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixVR);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixHR);      
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixV);
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixH);

    case 'MseqMono'
%% DISPLAY FIXATION CROSS

%       Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.CircleRectL);
%       Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.CircleRectR);
%       Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectLin);
%       Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectRin);
%       Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixVL);
% Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixHL);
% Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixVR);
% Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixHR);      
        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixV);
        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixH);
        Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);


     case 'HartleyMono'
             Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixV);
        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixH);
        Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
     
    case 'Flicker'
        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixV);
        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixH);
        Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
        
    case 'SFtuning'    
        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixV);
        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixH);
        Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
        
    case 'OrientationTuning'
        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixV);
        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixH);
        Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
        
     
end
Screen('Flip', HW.VisionHW.ScreenID);

global StopExperiment;
LastTime = clock;
while etime(clock,LastTime)<get(o,'NoResponseTime') && ~StopExperiment && ~get(o,'Calibration')
    if ~IOEyeFixate(HW,AllowedRadius)
        % if she does not fixate, reset the timer
        LastTime = clock;
    end
    drawnow;
end