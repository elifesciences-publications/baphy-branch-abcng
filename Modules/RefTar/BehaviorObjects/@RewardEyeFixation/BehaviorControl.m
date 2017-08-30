function [Events, exptparams] = BehaviorControl(o, HW, StimEvents, ...
  globalparams, exptparams, TrialIndex)
% Behavior Object for RewardEyeFixation
% Once trial is initiated (see CanStart), then

% Yves, December 2015, Paris
global data    
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

      s = daq.createSession('ni');
      s.DurationInSeconds = 90;
      s.Rate = 120;
      ch = addAnalogInputChannel(s,'Dev2','ai0','Voltage');
      ch = addAnalogInputChannel(s,'Dev2','ai1','Voltage');  
      lh = addlistener(s,'DataAvailable',@storeData); 
      s.NotifyWhenDataAvailableExceeds = 1;
      startBackground(s);
addpath('C:/Users/LargeBooth/Desktop/AnnaScripts/');
switch o.StimType
       
    case 'approxRFbar'
         order_ind = 1;
         order(order_ind) = 1;
                 screens = Screen('Screens');
        screenNumber2 = max(screens);
        [winPtr2, winRect2] = Screen('OpenWindow', screenNumber2, 0, [0 0 480 270]);
        HW.VisionHW.ScreenID2 = winPtr2;
        HW.VisionHW.ScreenRect2 = winRect2;
         stim_dur    = 30000;  % stimulus duration (ms)
         waitframes = 1;% Show new image at each waitframes'th monitor refresh
         fix_rad     = 50;  % radius of the bar image (pix)
         escape = KbName('ESC');
         space = KbName('space');
        [winCenter2(1), winCenter2(2)] = RectCenter(HW.VisionHW.ScreenRect2);
        fps = Screen('FrameRate',HW.VisionHW.ScreenID2);      % frames per second
        ifi = Screen('GetFlipInterval', HW.VisionHW.ScreenID2);
        if fps == 0,
           fps = 1/ifi;
        end
        nframes = round(stim_dur/1000*fps/waitframes);  % number of animation frames in loop

        SetMouse(winCenter2(1), winCenter2(2));

        white = WhiteIndex(HW.VisionHW.ScreenID2);
        black = BlackIndex(HW.VisionHW.ScreenID2);
        HideCursor;	% Hide the mouse cursor

        % Do initial flip...
        vbl=Screen('Flip', winPtr2);

        fix_cord0 = [winCenter2-fix_rad, winCenter2+fix_rad];

        Priority(MaxPriority(winPtr2));
        imageMatrix = zeros(2000,2000);
        imageMatrix(:, 900:1200)=254;
        texture2=Screen('MakeTexture', winPtr2, imageMatrix);
        texture=Screen('MakeTexture', HW.VisionHW.ScreenID, imageMatrix);
        scale = 1;
        angleGrating = 0;
        colorModulation = [255 255 255];
        
    case 'SFTuning' 
         load (HW.VisionHW.stimfile, 'parametersTuning','orderTuning', 'order_ind');
         parametersTuning = parametersTuning(parametersTuning(2) == 1);
         order = orderTuning;
         waitframes = 1;
         fps = Screen('FrameRate',HW.VisionHW.ScreenID);      % frames per second
         ifi = Screen('GetFlipInterval', HW.VisionHW.ScreenID);
         if fps == 0,
           fps = 1/ifi;
         end
   %      timesTuning = cell(length(fix_sf_list),length(fix_orient_list), length(fix_Speed_list));
   case 'OrientationTuning'
         load (HW.VisionHW.stimfile, 'parametersTuning','orderTuning', 'order_ind');
         parametersTuning = parametersTuning(parametersTuning(1) == 1);
         order = orderTuning;
         waitframes = 1;
         fps = Screen('FrameRate',HW.VisionHW.ScreenID);      % frames per second
         ifi = Screen('GetFlipInterval', HW.VisionHW.ScreenID);
         if fps == 0,
           fps = 1/ifi;
         end
        
    case 'Flicker'
         freqFlicker = 2; %Hz
         order_ind = 1;
         order(order_ind) = 1;
         waitframes = 1;
         fps = Screen('FrameRate',HW.VisionHW.ScreenID);      % frames per second
         ifi = Screen('GetFlipInterval', HW.VisionHW.ScreenID);
         if fps == 0,
           fps = 1/ifi;
         end
                       
    case 'Training'
         order_ind = 1;
         order(order_ind) = 1;
         fix_coord_list = [ 540 400 545 450; 540 200 545 250; 1040 400 1045 450; 840 300 845 400; 1540 400 1545 450; 1740 350 1745 400; 1640 700 1645 750; 1700 800 1705 900];
          
    case 'MseqMono'
        
         imageRect = [960   120    1920     1080];         
         load (HW.VisionHW.stimfile, 'Mseqorder', 'order_ind');
         order = Mseqorder;
         waitframes = 1;
         fps = Screen('FrameRate',HW.VisionHW.ScreenID);      % frames per second
         ifi = Screen('GetFlipInterval', HW.VisionHW.ScreenID);
         if fps == 0,
           fps = 1/ifi;
         end
                
    case 'HartleyMono'
        
        imageRect = [664.67905      309.39094      1920      1080];
        load (HW.VisionHW.stimfile, 'Hartleyorder', 'order_ind');
        order = Hartleyorder;
        waitframes = 1;
        fps = Screen('FrameRate',HW.VisionHW.ScreenID);      % frames per second
        ifi = Screen('GetFlipInterval', HW.VisionHW.ScreenID);
        if fps == 0,
          fps = 1/ifi;
        end

end      
      
switch get(o,'Calibration')
  case 1
    %% CALIBRATION
    while CurrentTime < exptparams.LogDuration
      CurrentTime = IOGetTimeStamp(HW);
    end
    
  case 0
    %% BEHAVIOR
    
   Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
   Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrL);
   vbl = Screen('Flip', HW.VisionHW.ScreenID);          
    
    while IOEyeFixate(HW,AllowedRadius) && (CurrentTime < exptparams.LogDuration) 
        if isempty(order(order_ind))
            fprintf('Sequence of stimulations finished');
            break;
        end;    
           
switch o.StimType
    case 'approxRFbar'
        
        SetMouse(winCenter2(1), winCenter2(2), winPtr2);        
        for ii = 1:nframes,

            % Break out of animation loop if any key on keyboard or any button on mouse is pressed:
            [mx, my, buttons] = GetMouse(screenNumber2);

            mousePos = [mx, my] - winCenter2;
            if buttons(1)
                scale = scale*1.1;
            end;    
            if buttons(3)
                scale = scale/1.1;
            end; 

            if buttons(2)
                angleGrating = angleGrating+2;
            end;

            fix_cord0 = [winCenter2-scale*fix_rad, winCenter2+scale*fix_rad];
            fix_cord2 = fix_cord0 + repmat(mousePos, 1, 2);
            x1 = asin(data(1)/10*512/HW.VisionHW.DotPitchTracker/3.5)*HW.VisionHW.Pix2Deg;
            y1 = asin(data(2)/10*512/HW.VisionHW.DotPitchTracker/3.5)*HW.VisionHW.Pix2Deg;
            fix_cord = fix_cord2*4+[x1,y1,x1,y1];  

            [keyIsDown, timeSecs, KeyCode] = KbCheck(-1);
            if  KeyCode(escape)
                disp(['Square: ', num2str(fix_cord)]);
                disp(['Angle: ', num2str(angleGrating)]);
                disp(['Width: ', num2str(300*scale)]);
                pause(0.5);
                break;
            end;   
            
            Screen('DrawTexture', winPtr2, texture2, [], fix_cord2, angleGrating, [], [], colorModulation);
            Screen('DrawTexture', HW.VisionHW.ScreenID, texture, [], fix_cord, angleGrating, [], [], colorModulation);

            vbl = Screen('Flip', winPtr2, vbl + (waitframes-0.5)*ifi);
            vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + (waitframes-0.5)*ifi);
        end

        % Clean up everything and leave
        Screen('FillRect', winPtr2, black);
        Screen('FillRect', HW.VisionHW.ScreenID, black);
        Screen('Flip', winPtr2);
        Screen('Flip', HW.VisionHW.ScreenID);        
        
    case 'approxRFlfp'
        
  for time_ind=1:24
      if IOEyeFixate(HW,AllowedRadius)   
       time0 = IOGetTimeStamp(HW);
       while IOGetTimeStamp(HW)-time0<0.0167
       end; 
      end; 
  end;
  vbl = Screen('Flip', HW.VisionHW.ScreenID);
  sf = fix_sf_list(randi(length(fix_sf_list),1));
  orien = fix_orient_list(randi(length(fix_orient_list),1));
  phaSp = fix_phaseSpeed_list(randi(length(fix_phaseSpeed_list),1));
  for time_ind=1:48
        if IOEyeFixate(HW,AllowedRadius)
        time0 = IOGetTimeStamp(HW);
        while IOGetTimeStamp(HW)-time0<0.0167            
        grating = TwoDramp(sf,orien, phaSp*time_ind);

        Screen('PutImage', HW.VisionHW.ScreenID, grating.*256, [0 0 1920 1080]);
    
        vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + (waitframes-0.5)*ifi);
        end; 
       end;
  end; 
  
    case 'OrientationTuning'
        
  sf = HW.VisionHW.parametersTuning(order(order_ind),1);
  orien = HW.VisionHW.parametersTuning(order(order_ind),2);
  Sp = HW.VisionHW.parametersTuning(order(order_ind),3);
  Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrL);
  vbl = Screen('Flip', HW.VisionHW.ScreenID);
        if IOEyeFixate(HW,AllowedRadius)
         time0 = IOGetTimeStamp(HW);
         for time_ind=1:10
             Screen('PutImage', HW.VisionHW.ScreenID,  HW.VisionHW.grating{time_ind, sf, orien, Sp}.*256, [0 0 1920 1080]);
             Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrL);
             vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + 2.5*ifi); %% it gives precisely half a second of each stimulation
         end;
         time1 = IOGetTimeStamp(HW);
         Events = AddEvent(Events, 'StimulusShown', TrialIndex, time0, time1); 
         Events(end).Rove = order(order_ind);
         order_ind=order_ind+1;
        else 
         Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
         Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
         Screen('Flip', HW.VisionHW.ScreenID);               
       end; 
       
    case 'SFTuning'
        
  sf = HW.VisionHW.parametersTuning(order(order_ind),1);
  orien = HW.VisionHW.parametersTuning(order(order_ind),2);
  Sp = HW.VisionHW.parametersTuning(order(order_ind),3);      
  Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrL);
  vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl+(60-0.5)*ifi);
        if IOEyeFixate(HW,AllowedRadius)
         time0 = IOGetTimeStamp(HW);
         for time_ind=1:10
             Screen('PutImage', HW.VisionHW.ScreenID, HW.VisionHW.grating{time_ind, sf, orien, Sp}.*256, [0 0 1920 1080]);
             Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrL);
             vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + 0.5*ifi);
         end;
         vbltime=IOGetTimeStamp(HW);
         Events = AddEvent(Events, 'StimulusShown', TrialIndex, vbltime, vbltime+0.5); 
         Events(end).Rove = order(order_ind);
         order_ind=order_ind+1;
        else 
         Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
         Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
         Screen('Flip', HW.VisionHW.ScreenID);               
       end;     
    
    case 'Flicker'
        
           Screen('FillRect', HW.VisionHW.ScreenID,[0 0 0],[]);
           vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl+(90-0.5)*ifi);
        for time_ind=1:100 
            if IOEyeFixate(HW,AllowedRadius) 
                Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255],[HW.VisionHW.ScreenSize(1)/2 0 HW.VisionHW.ScreenSize(1) HW.VisionHW.ScreenSize(2)]); 
                Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrL);
                vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + (8-0.5)*ifi); %grey screen for 60 frames
                vbltime = IOGetTimeStamp(HW);
                Events = AddEvent(Events, 'StimulusShown', TrialIndex, vbltime, vbltime+0.1336); 
                Events(end).Rove = 'Flicker';  
                Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0],[HW.VisionHW.ScreenSize(1)/2 0 HW.VisionHW.ScreenSize(1) HW.VisionHW.ScreenSize(2)]);
                Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrL);
                vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + (8-0.5)*ifi);  %flicker frequency 2Hz
            else 
                Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
                Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
                Screen('Flip', HW.VisionHW.ScreenID); 
           
            end
        end;  
       
    case 'Training'
        Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
        Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrL);
        Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrR);
        fc = fix_coord_list(randi([3 6]),:);
        posCurrent = fc;
        
  for time_ind=1:6
      if IOEyeFixate(HW,AllowedRadius)   
       time0 = IOGetTimeStamp(HW);
       while IOGetTimeStamp(HW)-time0<0.0167
       end; 
      end; 
  end;
  time1(1:24)=0;   
  for time_ind=1:24
        if IOEyeFixate(HW,AllowedRadius)
        time0 = IOGetTimeStamp(HW);
        while IOGetTimeStamp(HW)-time0<=0.0167            
            x1 = asin(data(1)/10*512/HW.VisionHW.DotPitchTracker/3.5)*HW.VisionHW.Pix2Deg;
            y1 = asin(data(2)/10*512/HW.VisionHW.DotPitchTracker/3.5)*HW.VisionHW.Pix2Deg;
            posCurrent = fc +[x1,y1,x1,y1];      
%            display(data);           
%            d = niReadAIData(HW.AI(2));            
%            display(IOGetTimeStamp(HW)-time0); 
            Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], posCurrent);
            Screen('Flip', HW.VisionHW.ScreenID);
            time1(time_ind) = IOGetTimeStamp(HW);
        end; 
       end;
  end; 
  time0 = IOGetTimeStamp(HW);
  Events = AddEvent(Events, 'StimulusShown', TrialIndex, time1(1), time0);

       Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.CircleRectL);
       Screen('FillOval', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.CircleRectR);
       Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectLin);
       Screen('FillOval', HW.VisionHW.ScreenID, 180, HW.VisionHW.CircleRectRin);
       Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixVL);
       Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixHL);
       Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixVR);
       Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixHR);
       Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrL);
       Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrR);
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixV);
%         Screen('FillRect', HW.VisionHW.ScreenID, [255 0 0 0.1], HW.VisionHW.rectFixH); 
         Screen('Flip', HW.VisionHW.ScreenID);        
%         Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
        Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrL);
        Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrR);
%    for time_ind=1:30     
%        if IOEyeFixate(HW,AllowedRadius) 
%         time0 = IOGetTimeStamp(HW);
%         while IOGetTimeStamp(HW)-time0<0.0167
%         end; 
%        end; 
%    end;  
%        Screen('Flip', HW.VisionHW.ScreenID);
        
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
      Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrL);
      Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrR);

   for time_ind=1:24
      if IOEyeFixate(HW,AllowedRadius)   
       time0 = IOGetTimeStamp(HW);
       while IOGetTimeStamp(HW)-time0<0.0167
       end; 
      end; 
   end;      
        Screen('Flip', HW.VisionHW.ScreenID);
        
    case 'MseqMono' 
                
   vbltime=[]; 
   image(1:HW.VisionHW.NumPix, 1:HW.VisionHW.NumPix) = HW.VisionHW.Mseq(:,:, order(order_ind));
   image = image.*256;
   Screen('PutImage', HW.VisionHW.ScreenID, image, imageRect);
   if IOEyeFixate(HW,AllowedRadius)
                Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrL);
%                 Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrR);
                vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + (waitframes-0.5)*ifi);
                vbltime(1) = IOGetTimeStamp(HW);   
                Events = AddEvent(Events, 'StimulusShown', TrialIndex, vbltime(1), vbltime(1)+0.0167); 
                Events(end).Rove = Mseqorder(order_ind); 
                order_ind = order_ind+1; 
                image(1:HW.VisionHW.NumPix, 1:HW.VisionHW.NumPix) = HW.VisionHW.Mseq(:,:,order(order_ind));
                image = image.*256;
                Screen('PutImage', HW.VisionHW.ScreenID, image, imageRect);
                if IOEyeFixate(HW,AllowedRadius)
                   Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrL);
%                    Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrR);
                   vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + (waitframes-0.5)*ifi);
                   vbltime(2) = IOGetTimeStamp(HW);
                   Events = AddEvent(Events, 'StimulusShown', TrialIndex, vbltime(2), vbltime(2)+0.0167); 
                   Events(end).Rove = Mseqorder(order_ind); 
                   order_ind = order_ind+1;
                else
                     Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
                     Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
                     Screen('Flip', HW.VisionHW.ScreenID);   
                end;
   else Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
        Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
        Screen('Flip', HW.VisionHW.ScreenID);            
   end; 
   
    case 'HartleyMono'
        
   vbltime=[];  
   image(1:HW.VisionHW.SizeHar, 1:HW.VisionHW.SizeHar) = HW.VisionHW.Hartley(order(order_ind),:,:);
   image = image.*256;
   Screen('PutImage', HW.VisionHW.ScreenID, image, imageRect);  
   if IOEyeFixate(HW,AllowedRadius)
                Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrL);
      %         Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrR);
                vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + (waitframes-0.5)*ifi);
                vbltime(1) = IOGetTimeStamp(HW);
                Events = AddEvent(Events, 'StimulusShown', TrialIndex, vbltime(1), vbltime(1)+0.033); 
                Events(end).Rove = Hartleyorder(order_ind); 
                order_ind = order_ind+1; 
                image(1:HW.VisionHW.NumPix, 1:HW.VisionHW.NumPix) = HW.VisionHW.Hartley(order(order_ind),:,:);
                image = image.*256;
                Screen('PutImage', HW.VisionHW.ScreenID, image, imageRect);
                if IOEyeFixate(HW,AllowedRadius)
                   Screen('FillRect', HW.VisionHW.ScreenID, [255 255 255], HW.VisionHW.rectRefrL);
         %         Screen('FillRect', HW.VisionHW.ScreenID, [0 0 0], HW.VisionHW.rectRefrR);
                   vbl = Screen('Flip', HW.VisionHW.ScreenID, vbl + (waitframes-0.5)*ifi);
                   vbltime(2) = IOGetTimeStamp(HW);
                   Events = AddEvent(Events, 'StimulusShown', TrialIndex, vbltime(2), vbltime(2)+0.033); 
                   Events(end).Rove = Hartleyorder(order_ind); 
                   order_ind = order_ind+1;
                else
                     Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
                     Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
                     Screen('Flip', HW.VisionHW.ScreenID);   
                end;
   else Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
        Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
        Screen('Flip', HW.VisionHW.ScreenID);            
   end;               
       
end 

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
    Screen('FillRect', HW.VisionHW.ScreenID, 180,[]);
    Screen('FillRect', HW.VisionHW.ScreenID, [125 125 125], HW.VisionHW.rectRefrL);
    Screen('Flip', HW.VisionHW.ScreenID); 
    switch o.StimType
    
    case 'MseqMono'
     save(HW.VisionHW.stimfile, 'Mseqorder', 'order_ind');
    case 'HartleyMono'
     save(HW.VisionHW.stimfile, 'Hartleyorder', 'order_ind'); 
    case 'SFtuning'
     save(HW.VisionHW.stimfile, 'parametersTuning', 'orderTuning','order_ind');    
    case 'OrientationTuning'
     save(HW.VisionHW.stimfile, 'parametersTuning', 'orderTuning','order_ind');    
    end    
    
end
stop(s);
switch o.StimType
    case 'approxRFbar'
    Priority(0);
    ShowCursor;
    Screen('Close', HW.VisionHW.ScreenID2);
end    
end



