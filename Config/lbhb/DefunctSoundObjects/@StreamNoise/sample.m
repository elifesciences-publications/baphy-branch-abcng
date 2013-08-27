function w=SNsample(o,index,IsRef);
% function w=specgram(t,index);
% return specgram for sample # index
%
% created SVD 2011-08-11

global STREAMNOISEWAV STREAMNOISESPECGRAM
p=get(o);

if isempty(STREAMNOISEWAV),
   disp('StreamNoise/waveform: generating noise samples...');
   
   % fix random state for deterministic noise patterns
   saverandstate=rand('state');
   rand('state',2);
   saverandnstate=randn('state');
   randn('state',3);
   
   [temp_wav, temp_specgram] = generate_gauss_sounds_general(...
      p.Count,round(p.SampleDuration.*1000),p.LowFreq,p.HighFreq,...
      40,p.FreqCorr,p.TempCorr,.5,p.SamplingRate,1);
   for t=1:p.Count,
      temp_wav(t,:)=hann(temp_wav(t,:),10,p.SamplingRate);
   end
   STREAMNOISEWAV=temp_wav;
   STREAMNOISESPECGRAM=temp_specgram;
   
   % restore random number generator to previous state
   rand('state',saverandstate);
   randn('state',saverandnstate);
else
   temp_wav=STREAMNOISEWAV;
   temp_specgram=STREAMNOISESPECGRAM;
end
w=temp_wav(index,:)';
