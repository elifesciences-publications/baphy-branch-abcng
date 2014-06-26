%function w=BandpassNoise(LowFreq,HighFreq,Duration,SamplingRate);
%
% utility to generate a standard format bandpass noise using a method that
% doesn't cause weird failures by Matlab at very low frequencies.
% Basically generate noise with sampling rate HighFreq*2, highpass filter
% at LowFreq and then upsample to the final SamplingRate using resample().
%
% created SVD 2012-12-11
%
function w=BandpassNoise(LowFreq,HighFreq,Duration,SamplingRate)

% high pass filter white noise and then resample to higher rate to
% create bandpass noise

tempFs=HighFreq.*2;
if tempFs>20000,
    tempFs=round(tempFs./1000)*1000;
elseif tempFs>10000,
    tempFs=round(tempFs./500)*500;
elseif tempFs>5000,
    tempFs=round(tempFs./250)*250;
end

tempbins=round(Duration*tempFs)+100;
f1 = LowFreq/tempFs*2;
[b,a] = ellip(4,.5,20,f1,'high');
FilterParams = [b;a];

% apply highpass filter to gaussian white noise
tw=randn(tempbins,1);
tw=filtfilt(FilterParams(1,:),FilterParams(2,:),tw);

% resample to higher rate
%[tempFs SamplingRate]
w=resample(tw,SamplingRate,tempFs);
if length(w)>ceil(SamplingRate*Duration),
  w=w(1:ceil(SamplingRate*Duration));
end
