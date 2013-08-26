function [y,h,Fs] = addreverb(data,Fs,reverbTime,method,extendLen)
%[y,h,Fs] = AddReverb2(data,Fs,reverbTime,method,extendLen)
%
%This function adds reverberation to a waveform.
%
%Parameters:
%data =	Input waveform.  This can also be a filename, which is read
%		using wavread().  In this case, Fs is set from the file.
%Fs =		Sample rate of the waveform (Hz).
%reverbTime =	Exponential decay time of the intensity (seconds).
%method =	Method to use for adding reverb
%	1 =	Design exponentially decaying impulse response using
%			Gaussian noise.  Convolve using fftfilt().
%	2 =	Design exponentially decaying impulse response using
%			uniform noise.  Convolve using fftfilt().
%	3 =	Design exponentially decaying impulse response without
%			noise.  Convolve using fftfilt().
%extendLen =	This is the amount of time, in units of reverbTime,
%			of silence added to the input sound before convolving.
%			This amount of time allows the sound to decay away.
%			Setting this to less than 1.0 will chop off the sound
%			at the end.

%
%Defaults:
%	method = 1
%	extendLen = 1.0
%
%Brian Zook, Southwest Research Institute, January 17, 2000

if nargin < 3
   error('Must include at least three parameters');
end
if ischar(data)
   [data,Fs] = wavread(data);
end
if isempty(Fs) | Fs <= 0
   error('The sample rate Fs must be larger than zero');
end
if nargin < 4 | length(method) ~= 1 | ~isnumeric(method)
   method = 1;
end
if nargin < 5 | length(extendLen) ~= 1 | ~isnumeric(extendLen)
   extendLen = 1.0;
end
n = round(extendLen*Fs*reverbTime);
if n <= 0
   %No reverberation to be done
   y = data;
   h = 1;
   return
end
data = [data(:) ; zeros(n,1)];
alpha = 3*log(10) / (2*Fs*reverbTime);
switch method
case 1
   h = randn(n,1) .* exp(-alpha*(0:n-1)');
case 2
   h = 2*(rand(n,1)-0.5) .* exp(-alpha*(0:n-1)');
%    h = 2*(rand(n,1)-0.5);	
case 3
   h = exp(-alpha*(0:n-1)');
otherwise
   error(sprintf('Unknown method "%d"',method))
end
h = h ./ sqrt(sum(h.^2));
%h = max(h, 0); 
y = fftfilt(h,data);
return
