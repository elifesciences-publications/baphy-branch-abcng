function [w, event]=waveform(o,index,IsRef);
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
bp_f=get(o,'Filter');
Names=get(o,'Names');

TotalBins=SamplingRate.*(PreStimSilence+Duration+PostStimSilence);

if strcmpi(NoiseType,'white'),
   % even for white, always load if from file. (Jan-9-2008, Nima)
   randn('seed',index);
   
   w=randn(TotalBins,1);
   
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
if ~isempty(bp_f),
   w=filtfilt(bp_f,1,w);
end

% make pre- and post-stimsilences actually silent
w=w(round(PreStimSilence.*SamplingRate+1):...
    round((PreStimSilence+Duration).*SamplingRate));

ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);

% normalize min/max +/-5
w = 5 ./ max(abs(w(:))) .* w;

% Now, put it in the silence:
w = [zeros(PreStimSilence*SamplingRate,1) ; w(:) ;zeros(PostStimSilence*SamplingRate,1)];

% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
