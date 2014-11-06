function MicrophoneCalbration (globalparams)
% This function calibrate the microphone using the test tone. The test tone
% is played at 74db

global BAPHYHOME;
globalparams.Physiology = 'No';
HW = InitializeHW(globalparams);
% set(HW.AI.Channel,'units','milivolts');
% init signal to tones of above frequencies
paramfname = [BAPHYHOME filesep 'Config' filesep 'HWSetupParams.mat'];
TestToneFreq = 1000;
TestToneDur  = 1;
%filterinf = setfilter(HW.filter,'Channels','All','Frequency',TestToneFreq);
%filterinf = setfilter(HW.filter,'Channels','All','Frequency',TestToneFreq);
samplingfreq = 20000;%actfreq*mult_fact;
HW.params.fsAux = samplingfreq; 
HW = IOSetSamplingRate (HW, [samplingfreq samplingfreq]);
IOSetAnalogInDuration (HW, TestToneDur , []);
flag = 0;
while ~flag
    IOLoadSound(HW,zeros(1,samplingfreq*TestToneDur));
    start = questdlg('Are you ready to start the calibration?');
    if strcmpi(start,'yes')
        IOStartAcquisition (HW);
        while IOIsPlaying(HW);end
        IOStopAcquisition (HW);
        [AuxData, SpikeData, AINames] = IOReadAIData(HW);
        % now, extract the lick, spike and microphone data.
        MicChannel  = find(strcmpi(AINames,'Microphone'));
        data        = AuxData(:,MicChannel);
        data=data(floor(samplingfreq*TestToneDur/3):floor(samplingfreq*TestToneDur*2/3)); % get only the reliable part of the signal
        f=figure(100);hold off;
        subplot(2,1,1);
        plot(data);
        title(['RMS value : ' num2str(rmsvalue(data))]);
        subplot(2,1,2);
        plot(abs(fft(data)));
        isok = questdlg('Does the waveform (figure 100) looks OK?');
        if strcmpi(isok,'yes')
            if exist(paramfname,'file')
                load (paramfname);
            end
            MicVRef = rmsvalue(data);
            MicVRef = round(MicVRef*1000)/1000;
            MicLast = [date ' - ' globalparams.Tester];
            if ~exist('PumpMlPerSec','var')
                PumpMlPerSec.Pump=NaN;
            end
            if ~exist('EqualizerCurve','var')
                EqualizerCurve = zeros(1,30);
            end
            if ~exist('PumpLast','var'), PumpLast  = '---';end
            if ~exist('EqzLast','var'), EqzLast  = '---';end

            save (paramfname,'MicVRef','PumpMlPerSec','EqualizerCurve',...
                'MicLast','PumpLast','EqzLast');

            flag = 1;
        elseif strcmpi(isok,'cancel')
            flag = 1;
            break;
        end
    else
        flag = 1;
        break;
    end
end
ShutdownHW(HW);
if exist('f','var')
    close(f);
end
% function rmsvalue:
function a = rmsvalue(x)
x = x-mean(x);
y = x.*x;
y = mean(y);
a = y^(0.5);

