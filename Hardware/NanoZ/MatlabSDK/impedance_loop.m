function [signaldata,impedance] = impedance_loop(hdev,nsam_measure,numdsps,z_to_collect)
% This function initiates, performs and stops impedance measurement
% upon collecting the requested number of impedance readings
% Arguments:
% hdev - handle of opened nanoZ device
% nsam_measure - number of samples per impedance reading
% numdsps - number of overlapping impedance measurements
% z_to_collect - number of impedance readings to collect
% Return values:
% signaldata - voltage measured on the electrode during the process
% impedance - measured impedance values, in Ohm, complex
% Remarks:
% Prior to calling this function, frequency must be set and a channel
% must be selected.

%      This file is a part of nanoZ Matlab SDK

expected_samples = (z_to_collect-1)*nsam_measure/numdsps + nsam_measure;
signaldata = zeros(1,expected_samples);
impedance = complex(zeros(1,z_to_collect));

collected_z = 0;
collected_samples = 0;
nanoz('startimpmetering',hdev,nsam_measure,numdsps);
while collected_z < z_to_collect
    % Yield the processor to other system activities
    % while data accumulates in the buffer
    pause(0.01); 
    [sda,za] = nanoz('getimpdata',hdev);
    if ~isempty(sda)
        if collected_samples+length(sda) > expected_samples
            % If amount of returned samples is more than expected,
            % discard extra samples
            sda = sda(1:expected_samples-collected_samples);
        end
        signaldata(collected_samples+1:collected_samples+length(sda)) = sda;
        collected_samples = collected_samples + length(sda);
    end
    if ~isempty(za)
        if collected_z + length(za) > z_to_collect
            % If amount of returned data points is more than requested,
            % discard extra points
            za = za(1:z_to_collect-collected_z);
        end
        impedance(collected_z+1:collected_z+length(za)) = za;
        collected_z = collected_z+length(za);
    end
end
nanoz('stop',hdev);
