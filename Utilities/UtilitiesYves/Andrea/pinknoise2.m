function [noise] = pinknoise(TPts,lco,hco,dboct);
% function [noise] = pinknoise(TPts,lco,hco,dboct);
% TPts: number of points to generate
% lco: low cutoff frequency in Hz (fs is assumed to be 44100Hz)
% hco: high cutoff frequency in Hz
% dboct: slope in dB per octave 
% (positive slope: a decrease, so use dboct = +3 for real pink noise)

if nargin < 4
    dboct = 3;
end

exponent = dboct/(20*log10(2));

fs = 44100;

bandwidth = hco - lco;
fftpts = pow2(nextpow2(TPts));
binfactor = fftpts / fs;
LPbin = round(lco*binfactor) + 1;
HPbin = round(hco*binfactor) + 1;
pink_weight = [1:fftpts] .* binfactor;
a = zeros(1,fftpts);
b = a;
a(LPbin:HPbin) = randn(1,HPbin-LPbin+1);
b(LPbin:HPbin) = randn(1,HPbin-LPbin+1);
fspec = a + i*b;
zweight = 1./((pink_weight).^exponent);
pspec = fspec.*zweight ;
noise = ifft(pspec);
noise = real(noise(1:TPts));
