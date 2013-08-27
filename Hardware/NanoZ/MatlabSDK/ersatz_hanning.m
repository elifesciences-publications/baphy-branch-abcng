function x = ersatz_hanning(n)
% ersatz_hanning     Hanning window.
% This function returns the N-point symmetric Hanning window
% in a row vector. It partially implements the functionality
% of the HANNING function from Signal Processing Toolbox

%      This file is a part of nanoZ Matlab SDK

t = (1:n)/(n+1);
x = 0.5*(1-cos(2*pi*t));
