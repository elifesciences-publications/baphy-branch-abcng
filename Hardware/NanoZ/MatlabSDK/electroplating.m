% Example script for electroplating with constant current

% Edit the parameters below to see how this affects the results
% ---------- BEGIN USER-EDITABLE BLOCK ------------------------
channel = 32;         % Channel to electroplate
pla_current = 0.5e-6; % [A] Plating current
pla_time = 1;         % [s] Plating time
% ---------- END OF USER-EDITABLE BLOCK -----------------------

%      This file is a part of nanoZ Matlab SDK

clear nanoz   % Close any nanoZ handles that might have been erroneously left open
devs = nanoz('enumdevs');
if isempty(devs)
    disp('No nanoZ devices attached, or all are in use by other Windows applications');
    return;
end

% This script works on the first found nanoZ in the system
hdev = nanoz('open',devs{1},64);% last parameter determines the pla_time resolution: 
                                % increase this value if you experience hardware
                                % buffer overruns (see User Manual for details) 
fprintf('\nOpened nanoZ %s\n',devs{1});

% Get waveform capabilities to determine the ADC sampling frequency
wfcaps = nanoz('getwaveformcaps',hdev);
fs = wfcaps.fs_adc;

% Select channel. We don't need to wait after switching the channel,
% because the transient effect applies only to impedance measurements
nanoz('selectchannel',hdev,channel);

% Convert our single datapoint into the device's raw value
% and get the achieved current value
[raw_wf,ach_current] = nanoz('preparewaveform',hdev,pla_current);

% Do electroplating...
fprintf('Electroplating, achieved current=%.3fuA\n',ach_current*1e6);
signaldata = plating_loop(hdev,raw_wf,1,round(pla_time*fs));
% Print the actual plating time
fprintf('Actual plating time = %.3fs\n',length(signaldata)/fs);
% Plot time course of the voltage feedback signal
figure(1);
clf;
t = (0:(length(signaldata)-1))/fs; % Time axis
plot(t,signaldata);
xlabel('Time [s]');
ylabel('Voltage [v]');
title(sprintf('nanoZ %s, channel %d, current %.3fuA: voltage feedback',devs{1},channel,ach_current*1e6));

nanoz('close',hdev);
