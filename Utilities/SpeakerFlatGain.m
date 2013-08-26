function SpeakerFlatGain (globalparams,attenuation)
% set equlizer to have flat gain at specified attenuation level
%
% SVD 2009-08-18
%
global BAPHYHOME;

paramfname = [BAPHYHOME filesep 'Config' filesep 'HWSetupParams.mat'];
if ~exist(paramfname,'file')
    dlg=warndlg('no hardware settings found!');
    uiwait(dlg);
    return;
else
    load (paramfname);
end


globalparams.Physiology = 'No';
HW = InitializeHW(globalparams);

HW.Eqz = init(HW.Eqz);
zeroequalizer(HW.Eqz);
% also, set the gain of input and output to zero:
adjustinputoutputgain(HW.Eqz,[192 192]);   %192 means 0 db



% constants
maxdB = 110;
mindB = 15;  % this is the minimum you can go, assuming the signal from
% Initialize reference rms voltage
micdB = 74;
micdBscaled = 55; % this is in dB is the target amplitude of the microphone. For less than 55,
VrefmicdBscaled = MicVRef*10^((micdBscaled-micdB)/20);

% Initialize calibration signal
freq = [25.0, 31.5, 40.0, 50.0, 63.0, 80.0, 100.0, 125.0, 160.0,...
    200.0, 250.0, 315.0, 400.0, 500.0, 630.0, 800.0, 1000.0, 1250.0,...
    1600.0, 2000.0, 2500.0, 3150.0, 4000.0, 5000.0, 6300.0, 8000.0,...
    10000.0, 12500.0, 16000.0, 20000.0];
% freq = [    8000 10000.0, 12500.0, 16000.0, 20000.0];
% init signal to tones of above frequencies
voltage      = 10.0;   %This is the peak-to-peak of the output from computer.
signaldur    =0.75;
%%%%%% calibration signal initialized %%%%%%%
% try
% Start the calibration sequence
bandatten = zeros(length(freq),1)+14+attenuation;
% signal = zeros(numsamples,1);
%bandatten(find(bandatten<(80-micdBscaled)))=(80-micdBscaled);  %
%bandatten=bandatten-80+micdBscaled;
%bandatten=max(bandatten)-bandatten;
%bandatten=14+bandatten-max(bandatten);

% Nima add -14 attenuation to the input module of the equalizer, so the
% overal max gain is zero, and the maximum attenuation is -36-14=-50,
% should be enough.
    
loadequalizer(HW.Eqz,bandatten);
adjustinputoutputgain(HW.Eqz,[164 192]); % 152: input at -20, 164: -14dB,  192: output at 0db
    
if ~exist('PumpMlPerSec','var')
    PumpMlPerSec.Pump=0;
end
if ~exist('MicVRef','var')
    MicVRef = 0;
end
if ~exist('PumpLast','var'), PumpLast  = '---';end
if ~exist('MicLast','var'), MicLast  = '---';end

EqualizerCurve = bandatten;
EqzLast = [date ' - ' globalparams.Tester];
save (paramfname,'MicVRef','PumpMlPerSec','EqualizerCurve',...
    'MicLast','PumpLast','EqzLast');

ShutdownHW(HW);
clear HW;
% catch
%     ShutdownHW(HW);
%     clear HW;
%     rethrow(lasterror)
% end

% start of subfunctions:
function [new,newstart,newstop] = binarysearch(rangestart,rangestop,prev,direction,tolerance)
% [new,newstart,newstop] = binarysearch(...
% rangestart,rangestop,prev,direction) returns new value
% within according to the rules of binarysearch
% rangestart,rangestop - decimal values rangestart<rangestop
% prev - decimal value belonging to (rangestart,rangestop)
% direction - 'up','down',1,-1
% default prev = rangestart
% default direction = 'up'

if nargin==2
    tolerance = 0;
    prev = rangestart;
    direction = 'up';
elseif nargin==3
    tolerance = 0;
    direction = 'up';
elseif nargin==4
    tolerance = 0;
end;
if ischar(direction)
    if strncmpi(direction,'u',1)
        new = prev + (rangestop-prev)/2;
        if new+tolerance>rangestop,new=rangestop;end;
        newstart = prev;
        newstop  = rangestop;
    elseif strncmpi(direction,'d',1)
        new = prev - (prev-rangestart)/2;
        if new-tolerance<rangestart,new=rangestart;end;
        newstart = rangestart;
        newstop  = prev;
    else
        new = prev;
        newstart = rangestart;
        newstop  = rangestop;
    end;
else
    if direction>0
        new = prev + (rangestop-prev)/2;
        if new+tolerance>rangestop,new=rangestop;end;
        newstart = prev;
        newstop  = rangestop;
    elseif direction<0
        new = prev - (prev-rangestart)/2;
        if new-tolerance<rangestart,new=rangestart;end;
        newstart = rangestart;
        newstop  = prev;
    else
        new = prev;
        newstart = rangestart;
        newstop  = rangestop;
    end;
end;

% function rmsvalue:
function a = rmsvalue(x)
x = x-mean(x);
y = x.*x;
y = mean(y);
a = y^(0.5);
