function [w, event]=waveform(o,index,IsRef);
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

IdxSet=p.IdxSet;
GapDur=p.GapDur;
w=zeros(p.Duration.*p.SamplingRate,1);
stepsize=length(w)./p.Count;
for ii=1:size(IdxSet,1),
   if IdxSet(ii,2,index)>0,
      tmp=temp_wav(IdxSet(ii,1,index),:)+temp_wav(IdxSet(ii,2,index),:);
   else
      tmp=temp_wav(IdxSet(ii,1,index),:);
   end
   w(round(stepsize.*(ii-1))+(1:length(tmp)))=tmp';
end

%normalize to approx min/max of 5V
% attenuate by 5dB to avoid clipping. so 80=75!!!
w=10.^(-5./20) .* 5.*w;

% Now, put it in the silence:
w = [zeros(p.PreStimSilence*p.SamplingRate,1) ; w(:) ;zeros(p.PostStimSilence*p.SamplingRate,1)];

% and generate the event structure:
event = struct('Note',['PreStimSilence , ' p.Names{index}],...
    'StartTime',0,'StopTime',p.PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' p.Names{index}],'StartTime'...
    ,p.PreStimSilence, 'StopTime', p.PreStimSilence+p.Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' p.Names{index}],...
    'StartTime',p.PreStimSilence+p.Duration, 'StopTime',p.PreStimSilence+p.Duration+p.PostStimSilence,'Trial',[]);
