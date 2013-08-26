function [data] = SpeakerCalibrationGolay (inputstim)

if ~exist('globalparams','var'),
    globalparams=[];
    globalparams.HWSetup=5;
end
globalparams.Physiology = 'No';
HW = InitializeHW(globalparams);

% init signal to tones of above frequencies
voltage      = 10.0;   %This is the peak-to-peak of the output from computer.

if ~exist('inputstim','var'),
    load GolayStims
    disp('need to convert StimA/StimB into format expected by this function');
    keyboard
end

samplingfreq = 100000;%actfreq*mult_fact;
signal=inputstim.*voltage;
signaldur=length(signal)./samplingfreq;
%actfreq=2000;
% signaldur=2;
%signal = voltage/2*sin(2*pi*actfreq/samplingfreq*(1:numsamples)');

HW.params.fsAux = samplingfreq;
numsamples   = floor(signaldur*samplingfreq);
pause(0.5)
HW = IOSetSamplingRate (HW, [samplingfreq samplingfreq]);
IOSetAnalogInDuration (HW, signaldur , []);

IOLoadSound(HW,signal);
IOStartAcquisition (HW);
while IOGetTimeStamp(HW)<signaldur end
IOStopAcquisition (HW);
[AuxData, SpikeData, AINames] = IOReadAIData(HW);
niStop(HW);
% now, extract the lick, spike and microphone data.
MicChannel  = find(strcmpi(AINames,'Microphone'));
data        = AuxData(:,MicChannel);

data=data(1:length(signal));

data_disp=data;
Vm = rmsvalue(data);

figure(1);
clf
plot(data)
%plot([signal data./Vm]);

ShutdownHW(HW);
return




% function rmsvalue:
function a = rmsvalue(x)
x = x-mean(x);
y = x.*x;
y = mean(y);
a = y^(0.5);
