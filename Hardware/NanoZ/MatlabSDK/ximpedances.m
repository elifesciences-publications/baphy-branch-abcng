% Check for shorts between all unique channel pairs

% Edit the parameters below to see how this affects the results
% ---------- BEGIN USER-EDITABLE BLOCK ------------------------
frequency = 1000;     % [Hz] measurement frequency
nsam_measure = 10000; % Number of samples per Z reading
numdsps = 2;          % Number of overlapping Z readings
z_to_collect = 1;     % Number of Z measurements to collect
adaptor = 'NZADIP16'; % DIP 16 adaptor
nchans  = 16;         % Test the first 16 channels
% ---------- END OF USER-EDITABLE BLOCK -----------------------

%      This file is a part of nanoZ Matlab SDK

clear nanoz   % Close any nanoZ handles that might have been erroneously left open
devs = nanoz('enumdevs');
if isempty(devs)
    disp('No nanoZ devices attached, or all are in use by other Windows applications');
    return;
end

defs = load_definitions('electrodes.ini');
channels = defs.(genvarname(adaptor)).ChMap(1:nchans); % maps nanoZ-> adaptor channels

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

% Do the Z measurements...
zMag = zeros(nchans,nchans);
for i=1:nchans-1
    fprintf('Connect reference wire to channel %1d, press any key to continue...\n',i);
    pause
    for j=i+1:nchans
        fprintf('testing ch%1d vs. ch%1d...\n',i,j);
        % Set channel
        nanoz('selectchannel',hdev,channels(j));
        pause(0.5); % Pause 0.5s for circuit to settle after channel switch
        [signaldata,impedance] = impedance_loop(hdev,nsam_measure,numdsps,z_to_collect);
        az = abs(impedance);
        phiz = angle(impedance);
        fprintf('Z = %.3f MOhm (%.0f deg)\n',az/1e6,phiz*180/pi);
        zMag(i,j)=az/1e6;
    end
end

% Plot the cross-impedance matrix
figure(1);
clf;
image(zMag);
colormap(hot);
colorbar;
set(gca,'XTick',[1:nchans]);
set(gca,'YTick',[1:nchans]);
xlabel('channel'); ylabel('channel');
title('Cross impedance test');

nanoz('close',hdev);
