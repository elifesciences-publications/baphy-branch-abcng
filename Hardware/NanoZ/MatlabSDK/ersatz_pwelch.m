function fsum = ersatz_pwelch(x,wind,noverlap,nfft,fs)
% Power Spectral Density estimate using Welch's averaged,
% modified periodogram method. This function partially implements
% the functionality of PWELCH function from the Signal Processing Toolbox.
%
% Usage:
% ersatz_pwelch(x,wind,noverlap,fs)
%
%  x - signal vector
%  wind - the window weights vector
%  noverlap - number of overlapping samples in two neighboring segments
%  fs - sampling frequency, in Hz

%      This file is a part of nanoZ Matlab SDK

% Make all vectors row vectors
wind = wind(:)';
x = x(:)';

lwnd = length(wind);
nspecpts = floor(nfft/2)+1;
fsum = zeros(1,nspecpts);
optr = 1;
numfts = 0;
while optr <= length(x)-noverlap
    if optr + lwnd <= length(x)
        xe = x(optr:optr+lwnd-1);
    else
        xe = x(end-lwnd+1:end);
    end
    xe = xe .* wind;
    % Pad with zeros, if necessary
    if lwnd < nfft
        xe(lwnd+1:nfft) = 0;
    end
    xef = fft(xe);
    % Take only right-hand side of the transform
    fsum = fsum + abs(xef(1:nspecpts)).^2;
    % Advance data pointer
    numfts = numfts+1;
    optr = optr + lwnd-noverlap;
end
fsum = fsum ./ numfts ./ nfft ./ fs;
% Compensate for the window energy
fsum = fsum ./ (sum(wind.^2)./lwnd);
% Compensate for taking right-hand side only
fsum(2:end-1) = fsum(2:end-1)*2;
% Convert into decibels
db = 10*log10(fsum);
f = (0:(nspecpts-1))/(nspecpts-1)*fs/2;
if fs/2 < 3000
    units = 'Hz';
elseif fs/2 < 3e6
    units = 'kHz';
    f = f/1000;
else
    units = 'MHz';
    f = f/1e6;
end
plot(f,db);
xlabel(sprintf('Frequency [%s]',units));
ylabel('Power/frequency [db/Hz]');
title('Welch Power Spectral Density Estimate');
xlim([0 max(f)]);
grid on;
