function [exptparams] = VisualDisplayEyeTracking(TrialIndex,TrialPerformance,exptparams)
window = 10;
windowRect = [0,0,1280,1024];
if TrialIndex >= 1  % Already Initialized
  
  
  % elseif TrialIndex==1   % Initialize
  
  
  % Get the screen numbers
  screens = Screen('Screens');
  
  % Draw to the external screen if avaliable
  screenNumber = max(screens);
  
  % Define black and white
  white = WhiteIndex(screenNumber);
  black = BlackIndex(screenNumber);
  gray = white/2;
  
  % Get the size of the on screen window
  [screenXpixels, screenYpixels] = Screen('WindowSize', window);
  
  % Query the frame duration
  ifi = Screen('GetFlipInterval', window);
  
  % Set up alpha-blending for smooth (anti-aliased) lines
  Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
  
  % Setup the text type for the window
  Screen('TextFont', window, 'Ariel');
  Screen('TextSize', window, 36);
  
  % Get the centre coordinate of the window
  [xCenter, yCenter] = RectCenter(windowRect);
  
  % Here we set the size of the arms of our fixation cross
  fixCrossDimPix = 20;
  
  % Now we set the coordinates (these are all relative to zero we will let
  % the drawing routine center the cross in the center of our monitor for us)
  xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
  yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
  allCoords = [xCoords; yCoords];
  
  % Set the line width for our fixation cross
  lineWidthPix = 4;
  
  % Draw the fixation cross in white, set it to the center of our screen and
  % set good quality antialiasing
  Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
  
  % Flip to the screen
  Screen('Flip', window);
  
end

% if  isfield(exptparams,'Performance') && ~strcmp(TrialPerformance,'GREY')
%   TrialPerformance = exptparams.Performance(TrialIndex).Outcome;
if strcmp(TrialPerformance,'SNOOZE') || strcmp(TrialPerformance,'EARLY')
  % draw cross for FA and Miss
  
  [xCenter, yCenter] = RectCenter(windowRect);
  
  % Here we set the size of the arms of our fixation cross
  fixCrossDimPix = 20;
  
  % Now we set the coordinates (these are all relative to zero we will let
  % the drawing routine center the cross in the center of our monitor for us)
  xCoords = [-fixCrossDimPix fixCrossDimPix fixCrossDimPix -fixCrossDimPix];
  yCoords = [-fixCrossDimPix fixCrossDimPix -fixCrossDimPix fixCrossDimPix];
  allCoords = [xCoords; yCoords];
  
  % Set the line width for our fixation cross
  lineWidthPix = 4;
  
  % Draw the fixation cross in white, set it to the center of our screen and
  % set good quality antialiasing
  Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
  
  % Flip to the screen
  Screen('Flip', window);
  pause(1.5) % diplay the outcome for 1.5s
  % then display the fixation cross again for 0.5s
  
  % Here we set the size of the arms of our fixation cross
  fixCrossDimPix = 20;
  
  % Now we set the coordinates (these are all relative to zero we will let
  % the drawing routine center the cross in the center of our monitor for us)
  xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
  yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
  allCoords = [xCoords; yCoords];
  
  % Set the line width for our fixation cross
  lineWidthPix = 4;
  
  % Draw the fixation cross in white, set it to the center of our screen and
  % set good quality antialiasing
  Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
  
  % Flip to the screen
  Screen('Flip', window);
  pause(0.5) % diplay the outcome for 1.5s
  
elseif strcmp(TrialPerformance,'HIT')
  % draw v for Hits
  
  [xCenter, yCenter] = RectCenter(windowRect);
  
  % Here we set the size of the arms of our fixation cross
  fixCrossDimPix = 20;
  
  % Now we set the coordinates (these are all relative to zero we will let
  % the drawing routine center the cross in the center of our monitor for us)
  xCoords = [-fixCrossDimPix*2 0 fixCrossDimPix*2 0];
  yCoords = [-fixCrossDimPix/1000 fixCrossDimPix -fixCrossDimPix*2 fixCrossDimPix];
  allCoords = [xCoords; yCoords];
  
  % Set the line width for our fixation cross
  lineWidthPix = 4;
  
  % Draw the fixation cross in white, set it to the center of our screen and
  % set good quality antialiasing
  Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
  
  % Flip to the screen
  Screen('Flip', window);
  pause(1.5) % diplay the outcome for 1.5s
  
  % then display the fixation cross again for 0.5s
  
  % Here we set the size of the arms of our fixation cross
  fixCrossDimPix = 20;
  
  % Now we set the coordinates (these are all relative to zero we will let
  % the drawing routine center the cross in the center of our monitor for us)
  xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
  yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
  allCoords = [xCoords; yCoords];
  
  % Set the line width for our fixation cross
  lineWidthPix = 4;
  
  % Draw the fixation cross in white, set it to the center of our screen and
  % set good quality antialiasing
  Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
  
  % Flip to the screen
  Screen('Flip', window);
  pause(0.5) % diplay the outcome for 1.5s
  
end

% end