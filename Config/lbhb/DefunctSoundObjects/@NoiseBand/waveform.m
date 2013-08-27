function [w, event]=waveform(o,index,IsRef);
% function w=waveform(t);
% this function is the waveform generator for object NoiseBurst
%
% created SVD 2007-03-30

event = [];

Frequencies=get(o,'Frequencies');
Bandwidth=get(o,'Bandwidth');
SamplingRate = get(o,'SamplingRate');
Duration = get(o,'Duration'); % duration is second
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
CombinationSet = get(o,'CombinationSet');
NoiseBand= get(o,'NoiseBand');
TonesPerBurst=get(o,'TonesPerBurst');
Names = get(o,'Names');

ThisCombo=CombinationSet(index,:);

timesamples = (1 : round(Duration*SamplingRate)) / SamplingRate;
w=zeros(size(timesamples));

BandFreq=ThisCombo(1);
ThisBand=ThisCombo(2);
lfstep=ThisBand/TonesPerBurst;

% record state of random number generator
s=rand('state');

if NoiseBand % added by Serin Atiani 07/08 to activate the bandpass white noise option
    % less beautiful way to do it?  band-pass filter white noise

    f1 = round(exp(BandFreq-(ThisBand-lfstep)./2));
    f2 = round(exp(BandFreq+(ThisBand-lfstep)./2));
    f1 = f1/SamplingRate*2;
    f2 = f2/SamplingRate*2;
    [b,a] = ellip(4,.5,20,[f1 f2]);
    FilterParams = [b;a];

    w0=randn(size(w));
    w=w+filtfilt(FilterParams(1,:),FilterParams(2,:),w0);
   
else
    % this seems to give cleaner results.. just add a bunch of tones at
    % nearby frequencies
    
    % frozen noise--always the same composition of phases for same BNB
    % parameters
    rand('state',index.*100);
    
    w0=zeros(size(w));
    lfrange=linspace(log(BandFreq)-(ThisBand-lfstep)./2,log(BandFreq)+(ThisBand-lfstep)./2,TonesPerBurst);

    for lf=lfrange,
        %round(exp(lf))
        phase=rand* 2.*pi;
        w0 = w0 + sin(2*pi*round(exp(lf))*timesamples+phase);
    end

    % normalize each w0 before adding
    w0=w0./max(abs(w0(:)));
    w=w+w0;
    
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
disp(num2str(ThisBand))
disp(num2str(BandFreq))
disp(num2str(index))

% and generate the event structure:
event = struct('Note',['PreStimSilence , ' Names{index}],...
    'StartTime',0,'StopTime',PreStimSilence,'Trial',[]);
event(2) = struct('Note',['Stim , ' Names{index}],'StartTime'...
    ,PreStimSilence, 'StopTime', PreStimSilence+Duration,'Trial',[]);
event(3) = struct('Note',['PostStimSilence , ' Names{index}],...
    'StartTime',PreStimSilence+Duration, 'StopTime',PreStimSilence+Duration+PostStimSilence,'Trial',[]);
