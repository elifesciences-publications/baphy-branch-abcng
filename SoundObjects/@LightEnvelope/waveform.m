function [w, event]=waveform(o,index,IsRef)
% function w=waveform(t);
% this function is the waveform generator for object ComplexChord
%
% created SVD 2007-03-30

event = [];

LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
SimulCount=get(o,'SimulCount');
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
TonesPerBurst=get(o,'TonesPerBurst');
Names = get(o,'Names');
Bandwidth=get(o,'Bandwidth');
ModLow=get(o,'ModLow');
ModHigh=get(o,'ModHigh');
ModDepth=get(o,'ModDepth');

LightAmp=get(o,'LightAmp');
NoiseCount=get(o,'NoiseCount');
LightCount=length(LightAmp);
Count=get(o,'MaxIndex');
TotalCount=Count.^SimulCount;

if SimulCount==1,
    toneset=index;
elseif SimulCount==2,
    toneset=[mod((index-1),Count)+1 floor((index-1)./Count)+1];
else
    error('Sorry, SimulCount>2 not supported!')
end

timesamples = (1 : round(Duration*SamplingRate))' / SamplingRate;
w=zeros(length(timesamples),2);

if NoiseCount==1,
   % added by Serin Atiani 8/17/09 to allow for a single noise burst
    logfreq=mean([log2(LowFreq) log2(HighFreq)]);
    logfreqdiff=log2(HighFreq)-log2(LowFreq);
    lfstep=logfreqdiff./TonesPerBurst;
else
    logfreq=linspace(log2(LowFreq),log2(HighFreq),NoiseCount);
    logfreqdiff=logfreq(2)-logfreq(1);
    lfstep=logfreqdiff./TonesPerBurst;
end
logfreq=repmat(logfreq,[1, LightCount]);

lightstat=repmat(LightAmp,[NoiseCount 1]);
lightstat=lightstat(:)';


if Bandwidth>0,
   % force bandwidth (octaves)
   lfstep=Bandwidth;
end

% record state of random number generator
s=rand('state');

% frozen noise--always the same composition of phases for same BNB
% parameters
rstate=round(2.^logfreq(toneset(1)).*100);
rand('state',rstate);

% To randomize the phase
%rand('state',sum(100*clock));

%
% narrow-band noise carrier
%

for ii=toneset,
   w0=zeros(length(w),1);
   e0=zeros(length(w),1);
   l0=zeros(length(w),1);
   lfrange=linspace(logfreq(ii)-(logfreqdiff-lfstep)./2,logfreq(ii)+(logfreqdiff-lfstep)./2,TonesPerBurst);
   modrange=linspace(log2(ModLow),log2(ModHigh),TonesPerBurst);
   
   for lf=lfrange,
      %round(exp(lf))
      phase=rand* 2.*pi;
      w0 = w0 + sin(2*pi*round(2.^lf)*timesamples+phase);
   end
   
   for mf=modrange,
      phase=rand* 2.*pi;
      e0 = e0 + sin(2*pi*round(2.^mf)*timesamples+phase);
      phase=rand* 2.*pi;
      l0 = l0 + sin(2*pi*round(2.^mf)*timesamples+phase);
   end
   
   % apply envelope
   w0=w0.*(abs(e0.*0.5+0.5) .* ModDepth + (1-ModDepth));
   
   % normalize each w0 before adding
   w0=w0./max(abs(w0(:)));
   
   w(:,1)=w(:,1)+w0;
   w(:,2)=w(:,2)+(abs(l0.*0.5+0.5) .* ModDepth + (1-ModDepth));
end

% return random number generator to previous state
rand('state',s);


% 10ms ramp at onset and offset:
ramp = hanning(round(.01 * SamplingRate*2));
ramp = ramp(1:floor(length(ramp)/2));
w(1:length(ramp),1) = w(1:length(ramp),1) .* ramp;
w(end-length(ramp)+1:end,1) = w(end-length(ramp)+1:end,1) .* flipud(ramp);

% normalize min/max +/-5
w(:,1) = 5 ./ max(abs(w(:,1))) .* w(:,1);
if lightstat(toneset(1))>0,
    w(:,2) = lightstat(toneset(1)) ./ max(abs(w(:,2))) .* w(:,2);
else
    w(:,2)=0;
end

% add pre-/poststimsilence:
w = [zeros(PreStimSilence*SamplingRate,2) ; w ;zeros(PostStimSilence*SamplingRate,2)];

% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);

