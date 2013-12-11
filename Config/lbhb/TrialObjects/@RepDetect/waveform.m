function [TrialSound, events , o] = waveform (o,TrialIndex)
% SVD 2012-10-19
global REPDETECT_NOISE_SAMPLES

par = get(o); % get the parameters of the trial object
RefObject=par.ReferenceHandle;
RefObject = set(RefObject, 'SamplingRate', par.SamplingRate);

% get the index of reference sounds for current trial
PreTrialSilence = par.PreTrialSilence;
PreTrialBins=round(PreTrialSilence.*par.SamplingRate);
PostTrialSilence = par.PostTrialSilence;
PostTrialBins=round(PostTrialSilence.*par.SamplingRate);

TrialSound = []; % initialize the waveform
events = [];
events(1).Note=['PreStimSilence , ',par.ReferenceClass,' , Reference'];
events(1).StartTime = 0;
events(1).StopTime = PreTrialSilence;
events(1).Trial = TrialIndex;

LastEvent = PreTrialSilence;

% generate the reference sound
RefTrialIndex=par.Sequences{par.ThisRepIdx(TrialIndex)};
RefCount=par.ReferenceCount(par.ThisRepIdx(TrialIndex));
RandStreamScaleBy=10^(par.RelativeTarRefdB/20);
PreTargetScaleBy=10^(-par.PreTargetAttenuatedB/20);

Names=get(RefObject,'Names');
SampleCount=size(RefTrialIndex,1);
for cnt1 = 1:SampleCount  % go through all the sound samples in the trial
    for jj=1:find(RefTrialIndex(cnt1,:)>0, 1, 'last' ),
        sidx=RefTrialIndex(cnt1,jj);
        [tw,ev]=waveform(RefObject, sidx);
        if cnt1<=RefCount && par.RefStaticNoiseFrac>0,
          tw=tw.*(1-par.RefStaticNoiseFrac) + ...
              REPDETECT_NOISE_SAMPLES(:,sidx).* 5*par.RefStaticNoiseFrac;
        elseif cnt1>RefCount && par.TarStaticNoiseFrac>0
          tw=tw.*(1-par.TarStaticNoiseFrac) + ...
              REPDETECT_NOISE_SAMPLES(:,sidx).* 5*par.TarStaticNoiseFrac;
        end
        
        if jj==1,
            w=tw;
            Note=ev(2).Note;
        else
            w=w+tw./RandStreamScaleBy;
            Note=[Note,'+',Names{RefTrialIndex(cnt1,jj)}];
        end
    end
    
    % svd 2009-06-29 make sure that sound is in a column
    if size(w,2)>size(w,1),
        w=w';
    end
    
    % add "Reference" to the note, correct the time stamp in respect to
    % last event, and concatenate w onto TrialSound. and don't include
    % pre/post-stim silences if they're zero length
    if ev(1).StopTime-ev(1).StartTime==0,
        ev=ev(2:end);
    end
    if ev(end).StopTime-ev(end).StartTime==0,
        ev=ev(1:(end-1));
    end
    for cnt2 = 1:length(ev)
       if cnt1<=RefCount,
          ev(cnt2).Note = [Note ' , Reference'];
       elseif cnt1==RefCount+1,
          ev(cnt2).Note = [Note ' , Target'];
          fprintf('Target %d at bin %d\n',...
              RefTrialIndex(cnt1,1),RefCount+1);
       else
          ev(cnt2).Note = [Note ' , TargetRep'];
       end
       ev(cnt2).StartTime = ev(cnt2).StartTime + LastEvent;
       ev(cnt2).StopTime = ev(cnt2).StopTime + LastEvent;
       ev(cnt2).Trial = TrialIndex;
    end
    LastEvent = ev(end).StopTime;
    if cnt1>RefCount,
        % attenuate pre-target samples if PreTargetAttenuatedB>0
        w=w./PreTargetScaleBy;
    end
    TrialSound = [TrialSound ;w];
    events = [events ev];
    
%     if ((cnt1==RefCount && par.RefStaticNoiseFrac>0) || ...
%           (cnt1==size(RefTrialIndex,1) && par.TarStaticNoiseFrac>0)) &&...
%           strcmp(par.ReferenceClass,'NoiseSample'),
%        if cnt1==RefCount,
%           NoiseSize=size(TrialSound);
%        else
%           lastrefbin=RefCount.*length(w);
%           TarRange=(lastrefbin+1):size(TrialSound,1);
%           NoiseSize=[length(TarRange) size(TrialSound,2)];
%        end 
%        Noise=randn(NoiseSize); % Noise signal
%        Noise=Noise./max(abs(Noise(:))).*max(abs(TrialSound));
%        fup = get(par.ReferenceHandle,'HighFreq');
%        flo = get(par.ReferenceHandle,'LowFreq');
%        fc=2.^((log2(fup)+log2(flo))./2);
%        fs = par.SamplingRate;
%        Wp = [flo fup]/(fs/2); % normalized passband interval
%        Ws = [(fc/2) (fc+(fc/2))]/(fs/2); % normalized stopband interval
%        Rp = 3; % 3-dB attenuation at passband
%        Rs = 30; % 30-dB attenuation at stopband
%        [n,Wn] = buttord(Wp,Ws,Rp,Rs); % Butterworth filter
%        [b,a] = butter(n,Wn);
%        bandNoise = filter(b,a,Noise); % Band-limiting the noise
%        if cnt1==RefCount,
%           TrialSound=TrialSound.*(1-par.RefStaticNoiseFrac) + ...
%              bandNoise .* 5 * par.RefStaticNoiseFrac;
%        else
%           TrialSound(TarRange,:)=...
%              TrialSound(TarRange,:).*(1-par.TarStaticNoiseFrac) + ...
%              bandNoise .* 5 * par.TarStaticNoiseFrac;
%        end
%        
%     end
end

if par.OnsetRampSec>0,
   % add a ramp
   OnsetRampBins=round(par.OnsetRampSec.*par.SamplingRate);
   OnsetRamp=linspace(0,1,OnsetRampBins)';
   TrialSound(1:OnsetRampBins)=TrialSound(1:OnsetRampBins).*OnsetRamp;
end

events(end+1).Note=['PostStimSilence , ',par.ReferenceClass,' , Reference'];
events(end).StartTime = LastEvent;
events(end).StopTime = LastEvent+PostTrialSilence;
events(end).Trial = TrialIndex;

chancount=size(TrialSound,2);

TrialSound=cat(1,zeros(PreTrialBins,chancount),...
    TrialSound,zeros(PostTrialBins,chancount));


