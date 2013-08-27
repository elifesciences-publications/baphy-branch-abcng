% Example script for 'impedance-match' electroplating
% Applies a constant current to the electrode
% until the desired target impedance is reached
% Also plots the Z profile as a function of plating time.

%      This file is a part of nanoZ Matlab SDK
 
% Edit the parameters below to see how this affects the results
% ---------- BEGIN USER-EDITABLE BLOCK ------------------------
adaptor  = 'N2TA64';        % electrode adaptor from 'electrodes.ini'
sites    = [4 22 29 60 64]; % electrode sites to perform plating on
pla_current = 100e-9;       % [A] Plating current
stop_z_lo = 200e3;          % [Ohm] target impedance (magnitude) - lower bound
                            % electroplating will stop at this or lower impedance
stop_z_hi = 5e6;            % [Ohm] target impedance (magnitude) - upper bound
                            % electroplating will stop at this or higher impedance
stop_t = 30;                % [seconds] the electroplating will stop after this time,
                            % if the target impedance was not reached first
pla_time_run = 5;           % [s] Plating time each run (i.e. interval between Z measurements)
pla_fudge_t = -0.05;        % [s] Fudge factor to adjust plating time (system dependent)
z_frequency = 1000;         % [Hz] at which frequency to measure Z between plating runs
nsam_measure = 10000;       % Number of samples per Z reading
numdsps = 2;                % Number of overlapping Z readings
z_to_collect = 3;           % Number of Z datapoints to collect
% ---------- END OF USER-EDITABLE BLOCK -----------------------

defs = load_definitions('electrodes.ini');
channels = defs.(genvarname(adaptor)).ChMap(sites); % vector maps nanoZ-> adaptor channels

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
% Convert our single current value into the device's raw value
% and get the achieved current value
[raw_pla_wf,ach_current] = nanoz('preparewaveform',hdev,pla_current);

% Setup a new plotting window
figure(1);
subplot(311);
grid on;
xlabel('Time [s]');
ylabel('Voltage [mV]');
xlim([0.5 0.51]);
hold on;
subplot(312);
grid on;
xlabel('Time [s]');
xlim('manual');
xlim([0 stop_t]);
ylabel('Impedance magnitude [MOhm]');
title(sprintf('Impedance vs. electroplating time, %.3fuA constant current',ach_current*1e6));
hold on;
subplot(313);
grid on;
xlabel('Time [s]');
xlim('manual');
xlim([0 stop_t]);
ylabel('Impedance phase [deg]');
hold on;

% Pre-allocate vectors to store the graph of Z over time
n_estimated_runs = stop_t / pla_time_run;
n_chans = length(channels);
progress_t = zeros(n_estimated_runs,n_chans);
progress_z = complex(zeros(n_estimated_runs,n_chans));

% Process each channel in the channel list
for ch = 1:n_chans
    % Select channel
    nanoz('selectchannel',hdev,channels(ch));
    pause(0.5); % Pause 0.5s for circuit settlement after a channel switch
    % Initial impedance measurement - the plating will not start if it is
    % already outside of the working bounds
    achieved_frq = nanoz('setfreq',hdev,z_frequency);
    [signaldata,impedance] = impedance_loop(hdev,nsam_measure,numdsps,z_to_collect);
    impedance = mean(impedance);
    progress_t(1,ch) = 0;
    progress_z(1,ch) = impedance;
    % Plot the impedance at t0
    subplot(311); cla;
    t = (0:(length(signaldata)-1))/fs; % Time axis
    plot(t,signaldata*1000); % Convert volts to microvolts
    title(sprintf('Site %d, Z test frequency %.1f',sites(ch),achieved_frq));
    subplot(312); cla;
    plot(progress_t,abs(progress_z)/1e6,'o');
    subplot(313); cla;
    plot(progress_t,angle(progress_z)/pi*180,'o');
    n_runs = 0;
    aot = 0; % Cumulative plating time on this electrode
    while abs(impedance) > stop_z_lo && abs(impedance) < stop_z_hi && round(aot) < stop_t
        fprintf('Site %d, at %.1fHz, Z=%5.3f MOhm (%3d deg), plating with %.3f uA\n',sites(ch),...
                achieved_frq,abs(impedance)/1e6,round(angle(impedance)/pi*180),ach_current*1e6);
        v_feedback = plating_loop(hdev,raw_pla_wf,1,round((pla_time_run+pla_fudge_t)*fs));
        % Print the voltage feedback for evaluation
        fprintf('Voltage feedback=%.2fV, DCR=%5.3fMOhm\n',mean(v_feedback),mean(v_feedback)/1e6/ach_current);
        % Additional voltage feedback evaluation code may be inserted here (e.g. compliance check)
        n_runs = n_runs+1;
        aot = aot+length(v_feedback)/fs; % Exact plating time for this run
        progress_t(n_runs+1,ch) = aot;
        % Measure impedance after each electroplating run
        pause(0.5) % [s] wait for electrode to settle, may need to be longer
        achieved_frq = nanoz('setfreq',hdev,z_frequency);
        [signaldata,impedance] = impedance_loop(hdev,nsam_measure,numdsps,z_to_collect);
        impedance = mean(impedance);
        progress_z(n_runs+1,ch) = impedance;
        % Update plots
        subplot(311); cla;
        t = (0:(length(signaldata)-1))/fs; % Time axis
        plot(t,signaldata*1000); % Convert volts to microvolts
        title(sprintf('Site %d, Z test frequency %.1f',sites(ch),achieved_frq));
        subplot(312); cla;
        plot(progress_t,abs(progress_z)/1e6,'o');
        subplot(313); cla;
        plot(progress_t,angle(progress_z)/pi*180,'o');        
    end
    % Print the impedance, and exit condition
    fprintf('Site %d, at %.1fHz, final Z=%5.3f MOhm (%3d deg), total plating time=%0.1fs\n',sites(ch),...
                                            achieved_frq, abs(impedance)/1e6, round(angle(impedance)/pi*180),aot);
    if abs(impedance) <= stop_z_lo
        fprintf('Impedance is below the lower bound, stopping.\n');
    elseif abs(impedance) >= stop_z_hi
        fprintf('Impedance is above the upper bound, stopping.\n');
    else
        fprintf('Maximum plating time reached, the Z target for this site was not met.\n');
    end
end
% Close the device
nanoz('close',hdev);
