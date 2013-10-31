% gnoise(duration_ms,l_co[Hz],h_co[Hz],[Level(dB)],[circular(0/1)],[SAMPLERATE])
%  Generates Gaussian noise in the spectral domain
% with specified duration, cut-off frequencies
% and level (dB rms re 1. Default = -20).
%   If circular is selected (1), then the buffer is periodic.
% Otherwise (0) the fft is done on a power-of-2 vector and
% then truncated to the desired length (faster).

function noise = gnoise(duration_ms,lco,hco,level,circular,SAMPLERATE)

if nargin < 3
   help gnoise
   return
elseif nargin < 4
  level = -20; circular = 0; SAMPLERATE = 48000;
elseif nargin < 5
   circular = 0; SAMPLERATE = 48000;
elseif nargin < 6
   SAMPLERATE = 48000;
end

dur_smp = round(duration_ms * SAMPLERATE / 1000);
bandwidth = hco - lco;
max_bw = SAMPLERATE / 2;

if (circular==1)
   fftpts = dur_smp;
else
   fftpts = findnextpow2(dur_smp);
end

binfactor = fftpts / SAMPLERATE;
LPbin = round(lco*binfactor) + 1;
HPbin = round(hco*binfactor) + 1;

a = zeros(1,fftpts);
b = a;

a(LPbin:HPbin) = randn(1,HPbin-LPbin+1);
b(LPbin:HPbin) = randn(1,HPbin-LPbin+1);
spec = a + i*b;

noise = ifft(spec);
noise = real(noise(1:dur_smp));
%normalize level
noise = noise .* sqrt(2*fftpts*max_bw/bandwidth);
noise = noise .* 10^(level/20);
