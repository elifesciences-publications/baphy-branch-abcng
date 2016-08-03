function [Events, exptparams] = BehaviorControl(o, HW, StimEvents, ...
  globalparams, exptparams, TrialIndex)
% Behavior Object for RewardEyeFixation
% Once trial is initiated (see CanStart), then

% Yves, December 2015, Paris

RewardAmount = get(o,'RewardAmount');
RewardInterval = get(o,'RewardInterval');
RewardIntervalStd = get(o,'RewardIntervalStd');
RewardIntervalLaw = get(o,'RewardIntervalLaw');
AllowedRadius = get(o,'AllowedRadius');
Events = [];
if ~isfield(exptparams,'Water'), exptparams.Water = 0;end
exptparams.WaterUnits = 'milliliter';

CurrentTime = IOGetTimeStamp(HW);
LastReportTiming = CurrentTime;
RewardOccured = 1;
fprintf(['\nRunning Trial... ']);
ev = IOEyeSignal(HW,1);
Events = AddEvent(Events, ev, TrialIndex);
fix_coord_list = [ 540 400 545 450; 540 200 545 250; 1040 400 1045 450; 840 300 845 400; 1540 400 1545 450; 1740 350 1745 400; 1640 700 1645 750; 1700 800 1705 900];

%% DISPLAY FIXATION CROSS

      Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.CircleRectL);
      Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.CircleRectR);
      Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectLin);
      Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectRin);
      Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVL);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHL);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVR);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHR);
      
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVL);
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHL);
% 
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVR);
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHR);


vbl = Screen('Flip', HW.VisionHW.ScreenID);

switch get(o,'Calibration')
  case 1
    %% CALIBRATION
    while CurrentTime < exptparams.LogDuration
      CurrentTime = IOGetTimeStamp(HW);
    end
    
  case 0
    %% BEHAVIOR
    while IOEyeFixate(HW,AllowedRadius) & (CurrentTime < exptparams.LogDuration)
        
        Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
        if randi([0 1]) 
        Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], fix_coord_list(randi([1 8]),:));
        end;
        vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl);
      
       Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.CircleRectL);
       Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.CircleRectR);
       Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectLin);
       Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectRin);
             Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVL);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHL);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVR);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHR);
       
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVL);
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHL);
% 
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVR);
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHR);

        vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl+0.4);
        
        Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
        vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl+0.5);
        
      Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.CircleRectL);
      Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.CircleRectR);
      Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectLin);
      Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectRin); 
            Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVL);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHL);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVR);
Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHR);
%       
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVL);
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHL);
% 
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixVR);
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixHR);
        
        
        
        
        vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl+0.4);
%        noise = repmat(randi(10,1,2)-5,1,2);
%        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixV+noise);
%        Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0], HW.VisionHW.rectFixH+noise);
%        Screen('Flip', HW.VisionHW.ScreenID);   
   
      if RewardOccured

        % Calculate next reward timing
        switch RewardIntervalLaw
          case 'Uniform'
            LawRange = sqrt(12)*RewardIntervalStd; % variance for uniform law
            RewardInterval = max(1,(RewardInterval-LawRange/2) + rand(1,1)*LawRange);
        end
        NextRewardTiming = CurrentTime+RewardInterval;
        RewardOccured = 0;
      end
      if (LastReportTiming+5)<CurrentTime
        fprintf([num2str(CurrentTime) 's ... ']);
        LastReportTiming = CurrentTime;
      end
      
      % Deliver reward
      if NextRewardTiming<CurrentTime
        PumpDuration = RewardAmount/globalparams.PumpMlPerSec.Pump;
        if PumpDuration > 0
          ev = IOControlPump (HW,'start',PumpDuration);
          Events = AddEvent(Events, ev, TrialIndex);
          exptparams.Water = exptparams.Water+RewardAmount;
          %     if strcmpi(get(exptparams.BehaveObject,'RewardSound'),'Click') && PumpDuration
          %       ClickSend (PumpDuration/2);
          %     end
          fprintf(['R @ ',num2str(CurrentTime),'s [interval=' num2str(RewardInterval) 's] ... ']);
          RewardOccured = 1;

        end
      end
      
      CurrentTime = IOGetTimeStamp(HW);
    end
    
    % ferret stopped eye fixating
    ev = IOEyeSignal(HW,0);
    Events = AddEvent(Events, ev, TrialIndex);
    drawnow;
end