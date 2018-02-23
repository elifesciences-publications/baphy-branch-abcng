function [w, event ,o]=waveform(o,index,IsRef)
% function w=waveform(t);
% this function is the waveform generator for object NoiseBurst
%
% created SVD 2007-03-30

event = [];

NoiseType = strrep(get(o,'NoiseType'),' ','');
SoundPath=get(o,'SoundPath');
SamplingRate=get(o,'SamplingRate');
PreStimSilence=get(o,'PreStimSilence');
Duration=get(o,'Duration');
PostStimSilence=get(o,'PostStimSilence');
f_bp=get(o,'Filter');
Names=get(o,'Names');
Frozen=get(o,'Frozen');

TotalBins=round(SamplingRate.*(PreStimSilence+Duration+PostStimSilence));

if strcmpi(NoiseType,'white'),
   % even for white, always load if from file. (Jan-9-2008, Nima)
%    randn('seed',index);
   
  if isempty(Frozen)
    w = randn(TotalBins,1);
  else
    Key = str2num(Frozen);
    TrialKey = RandStream('mrg32k3a','Seed',Key);
    w = TrialKey.randn(TotalBins,1);
  end
   
else
   [w,fs] = wavread([soundpath filesep lower(NoiseType) '.wav']);
   % to add randomness to different samples, shift the noise by
   % the index. So for the same index, the noise is always the
   % same. but for different indices, its different. This assumes
   % that the noise length is x times of the duration and index.
   w(1:floor(index*fs/5.5))=[]; % for each sample, shift the noise by 250ms
   if fs ~= SamplingRate
      w = resample(w,SamplingRate,fs);
   end
   w(TotalBins+1:end)=[]; % assume the noise is always longer than the signal!
end

% bandpass filter the noise between LowFreq and HighFreq
if ~isempty(f_bp),
%    w=filtfilt(f_bp,1,w);
   
   w = filter(f_bp{1,1},f_bp{1,2},w);
   w = filter(f_bp{2,1},f_bp{2,2},w);
end

% make pre- and post-stimsilences actually silent
w=w(round(PreStimSilence.*SamplingRate+1):...
    round((PreStimSilence+Duration).*SamplingRate));

ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);

% normalize min/max +/-5
% w = 5 ./ max(abs(w(:))) .* w;
w = 5 .* w ./ std(w(w~=0));

% Now, put it in the silence:
w = [zeros(PreStimSilence*SamplingRate,1) ; w(:) ;zeros(PostStimSilence*SamplingRate,1)];

% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
