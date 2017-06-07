function [] = dot_calibration(angle, duration, rep)

%%Dots for eyetracker calibration 
%Creates random order of several dots in the center and at an angle *angle*, shows each for *duration* time *rep* times and and stores everything in a file

[seed, whichGen] = ClockRandSeed;		  % Seed random number generator
AssertOpenGL;                                            % OpenGL PTB
KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 1);   % skip sync tests

%% *************** constants *******************
screenNumber = 0;				% use main screen
viewingDistance = 600;			% viewing distance in mm
resolDesired = [1920, 1080];	% desired resolution 

dotPitch = 0.3125*2;		    % pixel size in mm (for 1920*1080))
pixDepth = 32;                  % number of bits per pixel
nbBlankings = 1;				% number of blankings per frame
deg2pix = pi/180 * viewingDistance / dotPitch;			% conversion between degrees and pixels

escapeKey = KbName('ESCAPE');
spaceKey = KbName('space');

%%Change these parametes

eccentr_degrees = 1.5; %size of a dot in degrees of visual angle
colorSpl = [255 0 0];

viewingDistPix = viewingDistance / dotPitch;
stimSize = eccentr_degrees*deg2pix;           % pixels
texrect = [0 0 2*ceil(stimSize) 2*ceil(stimSize)];

%BLOCK THAT CORRECTS MONITOR GAMMA
% % monitor gamma calibration 
% gamma = 2.16;
% calib_lst = linspace(0.0, 1.0, 256);
% calib_lst = calib_lst .^ (1/gamma);
% calibratedClut = calib_lst' * [ 1 1 1 ];

%% Main part

fileDir = 'Data/';                     % directory for data
%subjectName = 'test' ;               % default subject name
% % get subject's name
prompt = {'Enter subject name:'};
Name =  inputdlg(prompt);
subjectName = Name{1};
fileName = sprintf('%s%sCalibration.data', fileDir, subjectName);

% open a window
maxScreen = max(Screen('Screens'));

[winPtr, winRect] = Screen('OpenWindow', maxScreen, 0, [], 32, 2);
[winCtr(1), winCtr(2)] = RectCenter(winRect);
%Screen('LoadNormalizedGammaTable', winPtr,calibratedClut);
black = BlackIndex(winPtr);
white = WhiteIndex(winPtr);
gray=white/2;
inc=white-gray;
% enable alpha blending with proper blend-function for drawing of smoothed points
Screen('BlendFunction', winPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;

%% refresh rate
ifi = Screen('GetFlipInterval', winPtr);
frameDuration = nbBlankings * ifi;
waitBlanking = (nbBlankings - 0.5) * ifi;
refreshRate = 1 / ifi;

%% open data file
fp = fopen(fileName, 'a');
currentTime = clock;
ye = currentTime(1); mo = currentTime(2); da = currentTime(3);
ho = currentTime(4); mi = currentTime(5); se = currentTime(6);
fprintf(fp, '\n*** Dots calibration ***\n');
fprintf(fp, 'Date and Time:\t%2d/%2d/%4d\t%2d:%2d:%2.0f\n', da, mo, ye, ho, mi, se);
fprintf(fp, 'Target size in deg: %d\n', eccentr_degrees);
fprintf(fp, 'seed = %.0f (generator=''%s'')\n', seed, whichGen);
fprintf(fp, '******************************************************\n');
fprintf(fp, 'X\t Y\t  Time\t  Duration\t    Wait\n' );
  
%% check the maximum priority level
priorityLevel = MaxPriority(winPtr);

Screen('FillRect', winPtr, gray, winRect);
Screen('DrawText', winPtr, 'Press any key', 10, 10, 255);
Screen('Flip', winPtr, waitBlanking, 1);
while KbCheck; end;
[secs, keyCode] = KbWait;
tim0 = GetSecs;
nspl = 5;
x(1) = winCtr(1);
y(1) =  winCtr(2);
x(2) = winCtr(1);
y(2) = winCtr(2) + angle*deg2pix;
x(3) = winCtr(1);
y(3) = winCtr(2) -angle*deg2pix;
x(4) = winCtr(1)-angle*deg2pix;
y(4) = winCtr(2);
x(5) = winCtr(1)+angle*deg2pix;
y(5) = winCtr(2);
order = 1:1:nspl;

for re = 1:rep                             
                                   order1 = Shuffle (order);
                                   for i=1:nspl
                                    j = order1(i);  
                                    Screen('FillRect', winPtr, gray, winRect); 
                                    vbl = Screen('Flip', winPtr, 0,1);
                                    multi = 1;
                                    sign = 1;
                                    tim_st = GetSecs;
                                    fprintf(fp, '%d    %d   %3.3f  %d  %d\n', x(j), y(j), tim_st, duration); 
                                    RectNew = CenterRectOnPoint (texrect, x(j), y(j));
                                    Screen('FillOval', winPtr, [255], RectNew); 
                                    Screen('Flip', winPtr);  
                                    WaitSecs(duration);
                                    
                                  end; 
 
end;
WaitSecs(0.5);
fclose(fp);					       % close data file
Priority(0);                        % reset priority
ShowCursor;						% redisplay the cursor
Screen('CloseAll');				% close the window


