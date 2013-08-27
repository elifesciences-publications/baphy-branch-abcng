function signaldata = plating_loop(hdev,raw_wf,interpol,sam_to_collect)
% This function initiates, performs and stops electroplating.
% Plating time is determined by requested number of voltage feedback
% samples to collect
% Arguments:
% hdev - handle of opened nanoZ device
% raw_wf - raw DAC waveform to be used for sampling
% interpol - interpolation factor to be applied during waveform generation
% sam_to_collect - number of voltage feedback samples to collect
% Return values:
% signaldata - voltage measured on the electrode during the process, in
%              volts
% Remarks:
% Prior to calling this function, a channel must be selected.
% This function may return more samples than it was requested,
% in order to allow determining the exact plating time.

%      This file is a part of nanoZ Matlab SDK

% Reserve a bit larger array than necessary
signaldata = zeros(1,sam_to_collect + 1000);

collected_samples = 0;
try
    % Enclose the section when electroplating current is switched on
    % In a try-catch block, to ensure that plating current is turned off
    % on error
    nanoz('startplating',hdev,raw_wf,interpol);
    while collected_samples < sam_to_collect
        % Yield the processor to other system activities
        % while data accumulates in the buffer
        pause(0.01);
        sda = nanoz('getplatingdata',hdev);
        if ~isempty(sda)
            signaldata(collected_samples+1:collected_samples+length(sda)) = sda;
            collected_samples = collected_samples + length(sda);
        end
    end
    nanoz('stop',hdev);
catch
    % Emergency shutdown of all nanoZ's
    % Invalidates all handles to open devices
    % clear nanozm
    rethrow(lasterror);
end

% Get all samples that are remaining in the buffer
sda = nanoz('getplatingdata',hdev);
if ~isempty(sda)
    signaldata(collected_samples+1:collected_samples+length(sda)) = sda;
    collected_samples = collected_samples + length(sda);
end

% Truncate the output array to the amount of actually acquired samples
signaldata = signaldata(1:collected_samples);
