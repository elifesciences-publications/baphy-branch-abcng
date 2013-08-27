function signalout=envel(signal,rampdur,samprate)
% Where signal is the raw stuff, rampdur is in milliseconds, samprate is
% sample/sec.  Returns the signal with raised cos on/off ramps.
rampdur = rampdur/1000;
signalout = signal;
% On ramp, if we're going to have two or more samples to ramp
if round(rampdur*samprate) > 2
    % Compute the set of indices into the wfm vector that will be ramped
    ramp_start_samples = 1:(round(rampdur*samprate));
    % And multiple them by a raised cosine between [0,1] for that many samples
    % (or "ramp_on" seconds)
    signalout(ramp_start_samples) = signal(ramp_start_samples) .* ((1 + cos(-pi:pi/(length(ramp_start_samples) - 1):0))/2);

    sigsize=length(signal);
    % Compute the indices of the last n msec of samples
    ramp_end_samples = round(rampdur*samprate):-1:1;
    ramp_end_samples = sigsize - (ramp_end_samples - 1);
    signalout(ramp_end_samples) = signalout(ramp_end_samples) .* ((1 + cos(0:pi/(length(ramp_end_samples) - 1):pi))/2);
end
