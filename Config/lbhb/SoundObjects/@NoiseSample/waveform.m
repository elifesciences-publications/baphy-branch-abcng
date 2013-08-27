function [w, event]=waveform(o,index,IsRef)
% function w=waveform(t);
% this function is the waveform generator for object StreamNoise
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
      p.Count,round(p.Duration.*1000),p.LowFreq,p.HighFreq,...
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

w=temp_wav(index,:);
if max(abs(w))>0,
    w = 5*w/max(abs(w));
end

if 0,
    %  10ms ramp at onset:
    ramp = hanning(.01 * SamplingRate*2);
    ramp = ramp(1:floor(length(ramp)/2));
    w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
    w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);
end

% Now, put it in the silence:
w = [zeros(ceil(p.PreStimSilence*p.SamplingRate),1) ; 
     w(:) ;
     zeros(ceil(p.PostStimSilence*p.SamplingRate),1)];

 % and generate the event structure:
 event = struct('Note',['PreStimSilence , ' p.Names{index}],...
     'StartTime',0,'StopTime',p.PreStimSilence,'Trial',[]);
 event(2) = struct('Note',['Stim , ' p.Names{index}],'StartTime',...
     p.PreStimSilence, 'StopTime', p.PreStimSilence+p.Duration, 'Trial',[]);
 event(3) = struct('Note',['PostStimSilence , ' p.Names{index}],...
     'StartTime',p.PreStimSilence+p.Duration, 'StopTime',p.PreStimSilence+p.Duration+p.PostStimSilence,'Trial',[]);



