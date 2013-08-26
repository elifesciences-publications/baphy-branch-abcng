function SpeakerCalibration (globalparams)
% bandatten = CALIBRATE('COM1','COM2') runs the calibration using objects EQUALIZER
% (serial), ATTENUATOR(gpib), KHFILTER(gpib)
% Calibration algorithm:
%   1. Init Interface objects:  a. equalizer - zeroequalize
%                               b. attenuator- set to MAXDB
%                               c. khfilter
%                               d. AnalogIn - AI default
%                               e. AnalogOut- AO default
%                               f. DigitalOut - Trigger
%   2. Confirm hardware connections. If true then,
%   3. Init calibration signal - tones
%   4. Init reference calibration signal Vreference
%   5. Start calibration. For each signal:
%       5.1 Set KHFilter to match frequency
%       5.2 Send signal through AO
%       5.3 Measure microphone signal through AI
%       5.4 Binary search for best attenuation value such that Vmeasured ~=
%           Vreference
%       5.5 Save attenuation value
%   6. loadequalizer with the calibration curve
%   7. Exit
% Further details will be given with each step

%Nima Mesgarani, May 2006
global BAPHYHOME;
globalparams.Physiology = 'No';
HW = InitializeHW(globalparams);

paramfname = [BAPHYHOME filesep 'Config' filesep 'HWSetupParams.mat'];
if ~exist(paramfname,'file')
    dlg=warndlg('Microphone needs calibration. Can not continue');
    uiwait(dlg);
    return;
else
    load (paramfname);
    if ~exist('MicVRef','var')
        dlg=warndlg('Microphone needs calibration. Can not continue');
        uiwait(dlg);
        return;
    end
end
% Initialize Equalizer
HW.Eqz = init(HW.Eqz);
zeroequalizer(HW.Eqz);
% also, set the gain of input and output to zero:
adjustinputoutputgain(HW.Eqz,[192 192]);   %192 means 0 db

% Initialize Attenuator
maxdB = 110;
mindB = 15;  % this is the minimum you can go, assuming the signal from
attenuate(HW.Atten,maxdB);% Set attenuation to MAXDB
% set(HW.AI.Channel,'Units','milliVolts');
% Initialize reference rms voltage
micdB = 74;
micdBscaled = 55; % this is in dB is the target amplitude of the microphone. For less than 55,
% the signal of the microhone has a very low SNR which
% might messes up the calibration, and for no sound you
% might see enough power in the microphone signal!!
% for higher than this, the lower frequencies might
% become more difficult to reach
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
bandatten = zeros(length(freq),1);
% signal = zeros(numsamples,1);
figure('position',[100 100 1000 800]);
for i = 8:length(freq)
    % Set filter to match frequency
    % the dublicate is for a bug in setfilter command,
    filterinf = setfilter(HW.filter,'Channels','All','Frequency',freq(i));
%     filterinf =
%     setfilter(HW.filter,'Channels','All','Frequency',freq(i));
    actfreq  = filterinf(1,4); % 1st row - freq info, 4th column - 4th Channel
    actfreq=freq(i);
    samplingfreq = 80000;%actfreq*mult_fact;
    HW.params.fsAux = samplingfreq;
    numsamples   = floor(signaldur*samplingfreq);
    pause(0.5)
    signal = voltage/2*sin(2*pi*actfreq/samplingfreq*(1:numsamples)');
    HW = IOSetSamplingRate (HW, [samplingfreq samplingfreq]);
    IOSetAnalogInDuration (HW, signaldur , []);
    %
    tolerance = 1.0;    % tolerance = 1dB = 20log10(V50/Vm)
    rangestart= mindB;
    rangestop = maxdB;
    prev      = rangestart;
    difference= maxdB;
    newatten  = 60; %start with 60dB attenuation!
    disp(['Frequency: ' num2str(freq(i))]);
    while (abs(difference)>tolerance) && (newatten>rangestart+tolerance) && (newatten<rangestop-tolerance),
        % Get attenuation new value and set atenuator
        rangestart
        [newatten,rangestart,rangestop] = binarysearch(rangestart,rangestop,prev,sign(difference));
        prev = floor(newatten);
        %         %%%%%%%%%%%%%%%Begin Test loop%%%%%%%%%%%%%%%%%%%%%%%%%
        %         newatten=0;
        attenuate(HW.Atten,floor(newatten));
        disp(['Attenutation: ' num2str(floor(newatten)) 'dB']);
        IOLoadSound(HW,signal);
        IOStartAcquisition (HW);
        while IOIsPlaying(HW); pause(0.01); end
        IOStopAcquisition (HW);
        [AuxData, SpikeData, AINames] = IOReadAIData(HW);
        % now, extract the lick, spike and microphone data.
        MicChannel  = find(strcmpi(AINames,'Microphone'));
        data        = AuxData(:,MicChannel);
        data=data(floor(samplingfreq*signaldur/3):floor(samplingfreq*signaldur*2/3)); % get only the reliable part of the signal
        data_disp=data;
        Vm = rmsvalue(data);
        difference = 20*log10(Vm/VrefmicdBscaled);

        %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         %%%%%%%%%%%%%%Begin Test loop%%%%%%%%%%%%%%%%%%%%%%%
        %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end; % end of while Vmeasured ~= Vref-54dB
    subplot(6,5,i);plot(data_disp);
    if newatten<mindB*1.1 % failed to equalize
        success='Fail';colcode=[1 0 0];
    else
        success='Pass';colcode=[0 .8 0];
    end
    title(['Freq: ' num2str(freq(i)) 'Hz, Attn: ' num2str(newatten) ', ' success],'fontweight','bold'...
        ,'color',colcode);
    axis ([0 numsamples/3 -VrefmicdBscaled*2.5 VrefmicdBscaled*2.5]);
    set(gca,'xtick',0:10000:20001);
    set(gca,'xticklabel',{0.25, 0.375, 0.5});
    line([0,20000],[VrefmicdBscaled*sqrt(2) VrefmicdBscaled*sqrt(2)],'color',[1 1 0],'linewidth',2.5);
    text(10000,VrefmicdBscaled*sqrt(2)*1.2,'V55','color',[.7 .7 0],'fontweight','bold');
    drawnow;
    bandatten(i) = newatten;
    pause(0.2)
end;
figure('position',[150 200 1000 700]);
subplot(2,1,1),plot(bandatten,'--ro','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',10);
title('Attenuation required for 55dB','fontweight','bold');
axis ([0 31 mindB*.9 max(bandatten)*1.1]);
set(gca,'fontsize',12);
set(gca,'xtick',1:2.0:30);
set(gca,'xticklabel',freq(1:2.0:30));
xlabel('Frequency (Hz)');
ylabel('Attenuation for V55 in dB');
h=line([0 30],[mindB*1.1 mindB*1.1]);set(h,'color',[1 0 0]);
text(13,mindB*1.1+1,'Equalization failed below this line','fontweight','bold','color',[1 0 0]);
line([0 30],[80-micdBscaled 80-micdBscaled],'color',[0 .8 0]);
text(12,80-micdBscaled+1,'For frequencies below this line can not go to 80dB','color',[0 .8 0],'fontweight','bold');
%
bandatten(find(bandatten<(80-micdBscaled)))=(80-micdBscaled);  %
bandatten=bandatten-80+micdBscaled;
bandatten=max(bandatten)-bandatten;
bandatten=14+bandatten-max(bandatten);
% Nima add -14 attenuation to the input module of the equalizer, so the
% overal max gain is zero, and the maximum attenuation is -36-14=-50,
% should be enough.
if sum(abs(diff(abs(bandatten))))>0
    loadequalizer(HW.Eqz,bandatten);
    adjustinputoutputgain(HW.Eqz,[164 192]); % 152: input at -20, 164: -14dB,  192: output at 0db
    subplot(2,1,2),plot(bandatten-14,'--ro','LineWidth',2,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor','g',...
        'MarkerSize',10);
    set(gca,'fontsize',12);
    title('Final equalization curve','fontweight','bold');
    axis ([0 31 min(bandatten-14)*1.1 0]);
    set(gca,'fontsize',12);
    set(gca,'xtick',1:2.0:30);
    set(gca,'xticklabel',freq(1:2.0:30));
    xlabel('Frequency (Hz)');
    ylabel('dB');
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
end

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
