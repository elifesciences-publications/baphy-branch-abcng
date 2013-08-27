% Example script to measure impedance on user-specified channel

% Edit the parameters below to see how this affects the results
% ---------- BEGIN USER-EDITABLE BLOCK ------------------------
frequency = 1000;     % [Hz] measurement frequency
channel = 7;          % Channel to perform measurement on
nsam_measure = 10000; % Number of samples per Z reading
numdsps = 2;          % Number of overlapping Z readings
z_to_collect = 3;     % Number of Z measurements to collect

% ---------- END OF USER-EDITABLE BLOCK -----------------------

%      This file is a part of nanoZ Matlab SDK

clear nanoz   % Close any nanoZ handles that might have been erroneously left open
devs = nanoz('enumdevs');
if isempty(devs)
    disp('No nanoZ devices attached, or all are in use by other Windows applications');
    return;
end

% This script works on the first found nanoZ in the system
hdev = nanoz('open',devs{1},64);% last parameter determines the buffer read size: 
                                % increase this value if you experience hardware
                                % buffer overruns (see User Manual for details) 
fprintf('\nOpened nanoZ %s\n',devs{1});

% Get waveform capabilities to determine the ADC sampling frequency
wfcaps = nanoz('getwaveformcaps',hdev);
fs = wfcaps.fs_adc;

% Set frequency, storing the achieved value
achieved_frq = nanoz('setfreq',hdev,frequency);

% Set channel
nanoz('selectchannel',hdev,channel);
pause(0.5); % Pause 0.5s for circuit settlement after a channel switch

% The actual measurement
fprintf('Measuring channel %d at frequency %.1f Hz\n',channel,achieved_frq);
[signaldata,impedance] = impedance_loop(hdev,nsam_measure,numdsps,z_to_collect);

% Print the results
for i=1:length(impedance)
    az = abs(impedance(i));
    phiz = angle(impedance(i));
    fprintf('Z = %.3f MOhm (%.0f deg)\n',az/1e6,phiz*180/pi);
end

% Plot the signal time and frequency course
figure(1);
clf;
t = (0:(length(signaldata)-1))/fs; % Time axis
plot(t,signaldata*1000); % Convert volts to microvolts
title(sprintf('nanoZ %s, channel %d, freq %.1f: time course',devs{1},channel,achieved_frq));
xlabel('Time [s]');
ylabel('Voltage [mV]');
figure(2);
clf;
% Do not plot spectrum if the data is too short
if length(signaldata) >= 4096
    % Welch power spectral density estimate
    % (uses the functions 'ersatz_pwelch' and 'ersatz_hanning'
    %  which implement functionality of 'pwelch' and 'hanning'
    % functions from the Signal Processing Toolbox)
    ersatz_pwelch(signaldata,ersatz_hanning(4096),3072,4096,fs);
end
nanoz('close',hdev);
