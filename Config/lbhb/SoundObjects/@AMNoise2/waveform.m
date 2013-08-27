function [w, event]=waveform(o,index,IsRef);
% function [w, event]=waveform(o,index);
% this function is the waveform generator for object AMNoise2
%
% created SVD 2013-03-22

if ~exist('index','var') || isempty(index)
    index = 1;
end

% the parameters of tone object
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
AM1=get(o,'AM1');
AM2=get(o,'AM2');
LowFreq1=get(o,'LowFreq1');
HighFreq1=get(o,'HighFreq1');
LowFreq2=get(o,'LowFreq2');
HighFreq2=get(o,'HighFreq2');
ModDepth=get(o,'ModDepth');
RelAttenuatedB=get(o,'RelAttenuatedB');
SplitChannels='Yes';
bSplitChannels=strcmpi(SplitChannels,'Yes');
TonesPerOctave=get(o,'TonesPerOctave');
UseBPNoise=get(o,'UseBPNoise');

IdxMtx = get(o,'IdxMtx'); % duration is second
Names = get(o,'Names');

if isempty(RelAttenuatedB),
   RelAttenuatedB=[0 0];
elseif length(RelAttenuatedB)<2,
   RelAttenuatedB=RelAttenuatedB.*[1 1];
end

PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
if length(PostStimSilence)>1
    PostStimSilence = PostStimSilence(1) + diff(PostStimSilence) * rand(1);
end

% generate the tone
timesamples = (1 : Duration*SamplingRate)' / SamplingRate;
w=zeros(size(timesamples));

band1idx=IdxMtx(index,1);
am1=AM1(IdxMtx(index,2));
band2idx=IdxMtx(index,3);
am2=AM2(IdxMtx(index,4));

if UseBPNoise,
   % use Utility to make consistent across sound objects
   tw1=BandpassNoise(LowFreq1(band1idx),HighFreq1(band1idx),Duration,SamplingRate);
   tw2=BandpassNoise(LowFreq2(band2idx),HighFreq2(band2idx),Duration,SamplingRate);
   
   if length(tw1)>size(w,1),
      disp('trimming');
      tw1=tw1(1:size(w,1));
      tw2=tw2(1:size(w,1));
   elseif length(tw1)<size(w,1),
      disp('padding');
      tw1(end+1:size(w,1))=0;
      tw2(end+1:size(w,1))=0;
   end
        
else
   tw1=zeros(size(w,1),1);
   tw2=zeros(size(w,1),1);
   TonesPerBurst1=round(log2(HighFreq1(band1idx)./LowFreq1(band1idx)).*TonesPerOctave);
   TonesPerBurst2=round(log2(HighFreq2(band2idx)./LowFreq2(band2idx)).*TonesPerOctave);
   
   if TonesPerBurst1==1,
      lfrange1=mean(log([LowFreq1(band1idx) HighFreq1(band1idx)]));
      lfrange2=mean(log([LowFreq2(band2idx) HighFreq2(band2idx)]));
   else
      lfrange1=linspace(log(LowFreq1(band1idx)),log(HighFreq1(band1idx)),TonesPerBurst1);
      lfrange2=linspace(log(LowFreq2(band2idx)),log(HighFreq2(band2idx)),TonesPerBurst2);
   end
   
   % add a bunch of tones at random phase
   for lf=lfrange1,
      phase=rand* 2.*pi;
      tw1 = tw1 + sin(2*pi*round(exp(lf))*timesamples+phase);
   end
   for lf=lfrange2,
      phase=rand* 2.*pi;
      tw2 = tw2 + sin(2*pi*round(exp(lf))*timesamples+phase);
   end
end
[am1 am2]
Names{index}
% apply AM modulation:
tw1=tw1./max(abs(tw1(:)));
tw2=tw2./max(abs(tw2(:)));
if am1>0,
   tw1=tw1.*(1-ModDepth + ModDepth .* abs(sin(pi*am1*timesamples)) ./ 0.4053);
end
if am2>0,
   tw2=tw2.*(1-ModDepth + ModDepth .* abs(sin(pi*am2*timesamples)) ./ 0.4053);
end

level_scale=10.^(-RelAttenuatedB(1)./20);
tw1=tw1.*level_scale;

level_scale=10.^(-RelAttenuatedB(2)./20);
tw2=tw2.*level_scale;

if bSplitChannels,
   w=cat(2,tw1,tw2);
else
   w=tw1+tw2;
end

chancount=size(w,2);

% 10ms ramp at onset and offset:
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
ramp=repmat(ramp,[1,chancount]);
w(1:length(ramp),:) = w(1:length(ramp),:) .* ramp;
w(end-length(ramp)+1:end,:) = w(end-length(ramp)+1:end,:) .* flipud(ramp);

% Now, put it in the silence:
w = [zeros(round(PreStimSilence*SamplingRate),chancount) ; 
    w;
    zeros(round(PostStimSilence*SamplingRate),chancount)];

% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
  'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],...
  'StartTime',PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
  'StartTime',PreStimSilence+Duration, ...
  'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
w = 5 * w/max(abs(w(:)));

