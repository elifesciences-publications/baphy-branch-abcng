% Example script to get information about attached nanoZ devices


%      This file is a part of nanoZ Matlab SDK

clear nanoz   % Close any nanoZ handles that might have been erroneously left open
nanoz_version = nanoz('getversion');
fprintf('\nnanoZ MEX Matlab library version %d.%d\n',nanoz_version(1),nanoz_version(2));

devs = nanoz('enumdevs');
disp('List of attached nanoZ devices:');
for i=1:length(devs)
    fprintf('%d. Serial number %s\n',i,devs{i});
end
if isempty(devs)
    disp('No devices attached, or all are in use by other Windows applications');
end

% Loop through all devices to get information about them
for i=1:length(devs)
    hdev = nanoz('open',devs{i},64);
    fprintf('\nOpened device %s\n',devs{i});
    % Query hardware and firmware versions
    hwfw = nanoz('getdeviceversion',hdev);
    disp('Device version information:');
    fprintf('Hardware version id:          %d\n',hwfw.hardware_version_id);
    fprintf('Hardware model name:          %s\n',hwfw.hardware_version_str);
    fprintf('Firmware version (maj.min):   %d.%d\n',hwfw.firmware_version(1),hwfw.firmware_version(2));
    fprintf('Firmware version as string:   %s\n',hwfw.firmware_version_str);

    % Query and display the waveform capabilities
    wfcaps = nanoz('getwaveformcaps',hdev);
    disp('Waveform generation capabilities:');
    fprintf('Generator sampling frequency: %.1f\n',wfcaps.fs_gen);
    fprintf('ADC sampling frequency:       %.1f\n',wfcaps.fs_adc);
    fprintf('Maximum length (samples):     %d\n',wfcaps.maxsam);
    fprintf('Interpolation factors:        ');
    % Loop through all interpolation factors
    for j=1:length(wfcaps.interpol)
        if j>1
            fprintf(',');
        end
        fprintf('%d',wfcaps.interpol(j));
    end
    fprintf('\n');
    % Query and display electroplating capabilities
    placaps = nanoz('getplatingcaps',hdev);
    disp('Electroplating capabilities:');
    fprintf('Minimum current (uA):     %.2f\n',placaps.min_current*1e6);
    fprintf('Maximum current (uA):     %.2f\n',placaps.max_current*1e6);
    fprintf('Current step (nA):        %.0f\n',placaps.current_step*1e9);
    fprintf('Minimum voltage (V):      %.2f\n',placaps.min_voltage);
    fprintf('Maximum voltage (V):      %.2f\n',placaps.max_voltage);
    nanoz('close',hdev);
end
