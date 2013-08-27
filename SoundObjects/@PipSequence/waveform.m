function [ w , ev , o ] = waveform(o,Index,IsRef)
% Waveform generator for the class PipSequence
%
% svd 2013-04-26

par=get(o);

TotalBins=par.Duration.*par.SamplingRate;
w=zeros(TotalBins,1);
ff=find(par.PipSet(:,1)==Index);

if par.NoiseBand,
   lf=log2(par.Frequencies);
   df=mean(diff(lf))./2;
   uf=round(2.^(lf+df));
   bf=round(2.^(lf-df));
   saveseed=rand('seed');
   rand('seed',mod(par.LowFrequency*par.HighFrequency*par.MaxIndex,5550));
   
   PipBins=round(par.PipDuration*par.SamplingRate);
   NoiseSet=zeros(PipBins,par.BandCount);
   
   timesamples=(1:PipBins)'./par.SamplingRate;
   TonesPerBurst=400;
   logfreqdiff=lf(2)-lf(1);
   lfstep=logfreqdiff./(TonesPerBurst+1);
   for bb=1:par.BandCount,
      for tt=1:TonesPerBurst,
         phase=rand* 2.*pi;
         tf=round(2^(log2(bf(bb))+lfstep.*(tt-0.5)));
         NoiseSet(:,bb) = NoiseSet(:,bb) + sin(2*pi*tf*timesamples+phase);
      end
      NoiseSet(:,bb)=NoiseSet(:,bb)./max(abs(NoiseSet(:,bb)));
      %NoiseSet(:,bb)=BandpassNoise(bf(bb),uf(bb),...
      %   par.PipDuration,par.SamplingRate);
   end
   
   rand('seed',saveseed);
end

for ii=ff(:)',
   scaleby=10.^(-par.PipSet(ii,4)./20);
   if par.NoiseBand,
      t=NoiseSet(:,par.PipSet(ii,3));
   else
      t=LF_buildTone(par.Frequencies(par.PipSet(ii,3)),par.PipDuration,...
         5.*scaleby,par.SamplingRate);
   end
   
   startbin=round(par.SamplingRate.*par.PipSet(ii,2));
   w(startbin-1+(1:length(t)))= w(startbin-1+(1:length(t)))+t;
end

PreBins=round(par.SamplingRate.*par.PreStimSilence);
PostBins=round(par.SamplingRate.*par.PostStimSilence);
w=cat(1,zeros(PreBins,1),w,zeros(PostBins,1));

% and generate the event structure:
ev = struct('Note',['PreStimSilence , ' par.Names{Index}],...
    'StartTime',0,'StopTime',par.PreStimSilence,'Trial',[]);
ev(2) = struct('Note',['Stim , ' par.Names{Index}],'StartTime'...
    ,par.PreStimSilence, 'StopTime', par.PreStimSilence+par.Duration,'Trial',[]);
ev(3) = struct('Note',['PostStimSilence , ' par.Names{Index}],...
    'StartTime',par.PreStimSilence+par.Duration, 'StopTime',par.PreStimSilence+par.Duration+par.PostStimSilence,'Trial',[]);


function Tone =  LF_buildTone(F,Dur,A,SR)

Time = [0:1/SR:Dur]';
Tone = A*sin(2*pi*F*Time);

% add 1ms ramp
ramp = hanning(round(.001 * SR*2));
ramp = ramp(1:floor(length(ramp)/2));
Tone(1:length(ramp)) = Tone(1:length(ramp)) .* ramp;
Tone(end-length(ramp)+1:end) = Tone(end-length(ramp)+1:end) .* flipud(ramp);

