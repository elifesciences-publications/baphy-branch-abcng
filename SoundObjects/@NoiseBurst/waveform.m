function [w, event]=waveform(o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object NoiseBurst
%
% created SVD 2007-03-30

event = [];

LowFreq=get(o,'LowFreq');
HighFreq=get(o,'HighFreq');
Count=get(o,'Count');
SimulCount=get(o,'SimulCount');
TotalCount=Count.^SimulCount;
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
NoiseBand= get(o,'NoiseBand');
TonesPerBurst=get(o,'TonesPerBurst');
Names = get(o,'Names');

if SimulCount==1,
    toneset=index;
elseif SimulCount==2,
    toneset=[mod((index-1),Count)+1 floor((index-1)./Count)+1];
else
    error('Sorry, SimulCount>2 not supported!')
end

timesamples = (1 : round(Duration*SamplingRate))' / SamplingRate;
w=zeros(size(timesamples));

if Count==1 % added by Serin Atiani 8/17/09 to allow for a single noise burst at the target
    logfreq=[log(LowFreq) log(HighFreq)];
    logfreqdiff=log(HighFreq)-log(LowFreq);
    lfstep=logfreqdiff./TonesPerBurst;
else
    logfreq=linspace(log(LowFreq),log(HighFreq),Count);
    logfreqdiff=logfreq(2)-logfreq(1);
    lfstep=logfreqdiff./TonesPerBurst;
end

% record state of random number generator
s=rand('state');

if NoiseBand % added by Serin Atiani 07/08 to activate the bandpass white noise option
    % less beautiful way to do it?  band-pass filter white noise
    for ii=toneset,
        % mod SVD 2012-12-11 use standard BP noise function.
        lf = round(exp(logfreq(ii)-(logfreqdiff-lfstep)./2));
        hf = round(exp(logfreq(ii)+(logfreqdiff-lfstep)./2));
        w0=BandpassNoise(lf,hf,Duration,SamplingRate);
        w=w+w0;
    end
else
    % this seems to give cleaner results.. just add a bunch of tones at
    % nearby frequencies
    
    % frozen noise--always the same composition of phases for same BNB
    % parameters
    % 
    % rand('state',index.*100);
    % To randomize the phase
    rand('state',sum(100*clock));
    for ii=toneset,
        w0=zeros(size(w));
        lfrange=linspace(logfreq(ii)-(logfreqdiff-lfstep)./2,logfreq(ii)+(logfreqdiff-lfstep)./2,TonesPerBurst);
        
        for lf=lfrange,
            %round(exp(lf))
            phase=rand* 2.*pi;
            w0 = w0 + sin(2*pi*round(exp(lf))*timesamples+phase);
        end
        
        % normalize each w0 before adding
        w0=w0./max(abs(w0(:)));
        w=w+w0;
    end
end

% return random number generator to previous state
rand('state',s);


% 10ms ramp at onset and offset:
w = w(:);
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
