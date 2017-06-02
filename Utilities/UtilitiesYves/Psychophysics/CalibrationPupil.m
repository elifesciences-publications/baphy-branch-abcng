function [Events] = CalibrationPupil()
% The following lines are for calibration of the eye-tracker (to get the position of the fixation cros per subject and be able to compute the egrees of eye-movement) this shoud nEventser be committe to baphy within the passive % JL 07/05/17

% initialise psychtoolbox
% AssertOpenGL
% Screen('Preference', 'SkipSyncTests', 1);
window = 10;
windowRect = [0,0,1280,1024];
% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray = white/2;

% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

% Properties if the dot
dotSizePix = 30;
dotColor = [255 255 255];

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
xR = (xCenter*2)-dotSizePix/2;
yU = dotSizePix/2;
xL = dotSizePix/2;
yD = (yCenter*2)-dotSizePix/2;


% All coordinates for center and all four corners in order of presentation
xvalues = [xCenter xL xCenter xR xCenter xR xCenter xL xCenter];
yvalues = [yCenter yU yCenter yU yCenter yD yCenter yD yCenter];
DotPosition = {'Center','CornerUL','Center','CornerUR','Center','CornerBR','Center','CornerBL','Center'};
% Start the clock 
tic;

%instruction 1
Screen('TextSize', window, 40);
Screen('TextFont', window, 'Arial');
DrawFormattedText(window, 'Follow the dot', 'center', 'center', white);
Screen('Flip', window);
pause(1)
Events=[]; 
% do it twice
for j = 1:2;
  for i = 1:length(xvalues)
    
    dotXpos = xvalues(i);
    dotYpos = yvalues(i);
    % Draw dot
    Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
    
    % Flip to the screen
    Screen('Flip', window);
    Events = AddEventsent(Events,['StartDot',' ',DotPosition{i}],[],toc);
    pause(2);
    
    Screen('Flip', window); % Screen gray again
    
  end
end

%instruction 2
Screen('TextSize', window, 40);
Screen('TextFont', window, 'Arial');
DrawFormattedText(window, 'Look at the red dot', 'center', 'center', white);
Screen('Flip', window);
pause(2)

dotColor = [255 0 0];

Screen('FillRect',window,gray,windowRect);
Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
Screen('Flip', window);
Events = AddEventsent(Events,['GreyBackground'],[],toc);
pause(3);

% Get maximal and min pupil size
Screen('FillRect',window,black,windowRect);
Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
Screen('Flip', window);
Events = AddEventsent(Events,['BlackBackground'],[],toc);
pause(2);

Screen('FillRect',window,gray,windowRect);
Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
Screen('Flip', window);
Events = AddEventsent(Events,['GreyBackground'],[],toc);
pause(3);

Screen('FillRect',window,white,windowRect);
Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
Events = AddEventsent(Events,['WhiteBackground'],[],toc);
Screen('Flip', window);

pause(2);

Screen('FillRect',window,gray,windowRect);
Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
Screen('Flip', window);
 Events = AddEventsent(Events,['GreyBackground'],[],toc);
pause(3);
end