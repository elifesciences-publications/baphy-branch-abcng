function [w, event]=waveform(o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object NoiseBurst
%
% created SVD 2007-03-30

event = [];
LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
AM=get(o,'AM');
ModDepth=get(o,'ModDepth');
FirstSubsetIdx=get(o,'FirstSubsetIdx');
SecondSubsetIdx=get(o,'SecondSubsetIdx');
SecondRelAtten=get(o,'SecondRelAtten');
Count=get(o,'Count');
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
TonesPerOctave=get(o,'TonesPerOctave');
Names = get(o,'Names');
Square=get(o,'Square');
SquareDuration=get(o,'SquareDuration'); %Everything linked to square added by CB 17/12/15
SquareDuty = SquareDuration*AM*100;

Frequencies=round(exp(linspace(log(LowFreq),log(HighFreq),Count+1)));
logfreq=log(Frequencies);

if ~isnumeric(FirstSubsetIdx),
    FirstSubsetIdx=str2num(FirstSubsetIdx);
end
if ~isnumeric(SecondSubsetIdx),
    SecondSubsetIdx=str2num(SecondSubsetIdx);
end

if isempty(SecondRelAtten),
   SecondRelAtten=0;
end
if isempty(AM),
   AM=0;
end
if isempty(ModDepth),
   ModDepth=1;
end
if length(ModDepth)<length(AM),
   ModDepth=ones(size(AM)).*ModDepth(1);
end
NBCount=Count*length(AM);

if isempty(FirstSubsetIdx),
   FirstSubsetIdx=1:NBCount;
end

if isempty(SecondSubsetIdx) || ~ismember(SecondSubsetIdx(1),1:NBCount),
   Count1=length(FirstSubsetIdx);
   Count2=0;
   TotalCount=Count1;
else
   Count1=length(FirstSubsetIdx);
   Count2=length(SecondSubsetIdx);
   TotalCount=Count1*Count2;
end

timesamples = (1 : round(Duration*SamplingRate))' / SamplingRate;
w=zeros(size(timesamples));

% record state of random number generator
s=rand('state');

rand('state',index.*120);
% To randomize the phase
% rand('state',sum(100*clock));

i1=FirstSubsetIdx(mod((index-1),Count1)+1);
i1freq=mod(i1-1,Count)+1;
i1AM=floor((i1-1)./Count)+1;

w0=zeros(size(w));
TonesPerBurst=ceil(Frequencies(i1freq+1)./Frequencies(i1freq) .* TonesPerOctave);

if TonesPerBurst==0,
  f1 = Frequencies(i1freq);
  f2 = Frequencies(i1freq+1);
  w0=BandpassNoise(f1,f2,Duration,SamplingRate);
      
else
    lfrange=linspace(logfreq(i1freq),logfreq(i1freq+1),TonesPerBurst.*2+1);
    lfrange=lfrange(2:2:end);

    for lf=lfrange,
        %round(exp(lf))
        phase=rand* 2.*pi;
        w0 = w0 + sin(2*pi*round(exp(lf))*timesamples+phase);
    end
end

% normalize each w0 before adding
w0=w0./max(abs(w0(:)));
if AM(i1AM)>0,
  if Square
    w0=w0.*(1-ModDepth(i1AM) + ModDepth(i1AM) .* ...
      abs((square(2*pi*AM(i1AM)*timesamples,SquareDuty)+1)/2) ./ 0.4053);
  else  
    w0=w0.*(1-ModDepth(i1AM) + ModDepth(i1AM) .* ...
      abs(sin(pi*AM(i1AM)*timesamples)) ./ 0.4053);
  end  
end
w=w+w0;

if Count2>0,
   i2=SecondSubsetIdx(floor((index-1)./Count1)+1);
   i2freq=mod(i2-1,Count)+1;
   i2AM=floor((i2-1)./Count)+1
   
   w0=zeros(size(w));
   TonesPerBurst=ceil(Frequencies(i2freq+1)./Frequencies(i2freq) .* TonesPerOctave);
   
   % interleave sub-frequencies in second tone to avoid phase
   % cancelation for two overlappings bursts with the same bandwidth
   lfrange2=linspace(logfreq(i2freq),logfreq(i2freq+1),TonesPerBurst.*2+1);
   lfrange2=lfrange2(1:2:end-1);
   
   for lf=lfrange2,
      phase=rand* 2.*pi;
      w0 = w0 + sin(2*pi*round(exp(lf))*timesamples+phase);
   end
   
   % normalize each w0 before adding
   w0=w0./max(abs(w0(:)));
   if AM(i2AM)>0,
      w0=w0.*(1-ModDepth(i2AM) + ModDepth(i2AM) .* ...
              abs(sin(pi*AM(i2AM)*timesamples)) ./ 0.4053);
   end
   
   if SecondRelAtten,
      w0=w0.*10.^(-SecondRelAtten./20);
   end
   
   % skip geometric mean, match absolute level for ref-tar level normalization
   %w=w./sqrt(2)+w0./sqrt(2);
   w=w+w0;
end

%normalize to approx min/max of 5V
% attenuate by 5dB to avoid clipping. so 80=75!!!
w=10.^(-5./20) .* 5.*w;


% return random number generator to previous state
rand('state',s);


% 10ms ramp at onset and offset:
w = w(:);
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp)) = w(1:length(ramp)) .* ramp;
w(end-length(ramp)+1:end) = w(end-length(ramp)+1:end) .* flipud(ramp);

% Now, put it in the silence:
w = [zeros(PreStimSilence*SamplingRate,1) ; w(:) ;zeros(PostStimSilence*SamplingRate,1)];

% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
