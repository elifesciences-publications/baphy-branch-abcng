function [w, ev,o] = waveform (o,index,IsRef,Mode,TrialNum)
%  14/05-TP/YB
% index is the Nb of CT
% function w=waveform(t);
% this function is the waveform generator for objectMemoClicks

fs              = get(o,'SamplingRate');
PreStimSilence  = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

%% PARAMETERS OF MemoClicks OBJECT

RateRC    = get(o,'RateRCPercent');
RateRefRC = get(o,'RateRefRCPercent');
prestim   = zeros(round(PreStimSilence*fs),1);
poststim  = zeros(round(PostStimSilence*fs),1);
SeqGap    = get(o,'SequenceGap');  % duration in second
w = [];ev = [];

%% INITIALIZE Daniel's OBJECT
sP.fs         = fs;
sP.replength = get(o,'ClickTrainDur'); % duration of a single repeat
sP.nreps = get(o,'nreps'); % number of repeats
sP.testtype = 1;
sP.seed = [];
sP.highpass = get(o,'highfreq'); % high-pass filter cutoff
sP.noiseSNR = get(o,'SNR'); % add lowpass noise with given SNR. Cutoff is = highpass, noise is pink. Positive values means softer noise.
sP.clickdur = 0.00005;
sP.maxgap = get(o,'maxgap');
sP.mingap = get(o,'mingap');
  
%% RANDOM NUMBER GENERATOR
Key = get(o,'Key');
TrialKey = RandStream('mrg32k3a','Seed',Key);
PastRef = get(o,'PastRef');
sP.seed = Key;

% Pointer to the position in RandSequence
% PastRef STORES THE PREVIOUS INDEX
if isempty(PastRef)  % First trial
   RefNow = 0;
   o = set(o,'PastRef',[PastRef index]);
elseif length(PastRef) < TrialNum   % during the experiment, only this condition should be true
   RefNow = sum(PastRef);
   o = set(o,'PastRef',[PastRef index]);
elseif length(PastRef) >= TrialNum && index == PastRef(TrialNum)  % When you load a SO from a previous experiment
   RefNow = sum(PastRef(1:TrialNum)) - PastRef(TrialNum);
elseif length(PastRef) > TrialNum && index ~= PastRef(TrialNum)
   error('Valeur index attendue: %d', PastRef(TrialNum));
end

%% Sequences of 0 1 2 (stimtype)
RandSequence = [ones(1,floor(RateRC)) 2*ones(1,floor(RateRefRC)) zeros(1,floor((100-RateRC - RateRefRC)))];
RandPick = [];
for i = 1:4
    RandPick = [RandPick TrialKey.randperm(100)];
end

gapSeq = zeros(round(SeqGap*fs),1);
ev     = AddEvent(ev,'PreStimSilence',[],0,PreStimSilence); 
w      = [w ; prestim(:)];

%% GENERATE CLICK TRAINS
for j = (RefNow+1) : (RefNow+index)    
    sP.stimtype = RandSequence(RandPick(j)); % stimulus type: 0 is C, 1 is RC, 2 is RefRC
    
    if sP.stimtype == 2
       sP.seed = Key;
    else
       sP.seed = Key*(RefNow+j);
    end
    
    [wSeq, sP] = genmemoclicks(sP);    
    MSeq = maxLocalStd(wSeq(:),fs,length(wSeq(:))/fs);
    w=[w ; wSeq(:)/MSeq ; gapSeq(:)];
    
    ev = AddEvent(ev, ['ReferenceSequence , ', num2str(j-RefNow), ' / ',num2str(index), ' - ', num2str(TrialNum) ],...
        [ ], ev(end).StopTime, ev(end).StopTime + length([wSeq(:) ; gapSeq(:)])/fs );     
end

%% END WITH NOISE
% Taken from Noise.waveform
% Params: Duration, HighPassFc, LowPassFc, PreStimSilence, PostStimSilence

NoisePreStimSilence  = get(o,'NoisePreStim');
NoisePostStimSilence = get(o,'NoisePostStim');
NoiseDuration        = get(o,'NoiseDur');
hp_f                 = get(o,'NoiseHPF');
lp_f                 = get(o,'NoiseLPF');
bp_option            = get(o,'NoiseFilter'); 
TotalBins            = fs.*(NoisePreStimSilence+NoiseDuration+NoisePostStimSilence);

% noise vector
wn=randn(TotalBins,1);

% band pass filter 
if ~isempty(bp_option),
    [Bh,Ah]=butter(2,hp_f*2/fs,'high');
    wn = filter(Bh,Ah,wn);
    
    [Bl,Al]=butter(2,lp_f*2/fs,'low');
    wn = filter(Bl,Al,wn);
    
end

% make pre- and post-stim silences actually silent
wn   = wn(round(NoisePreStimSilence.*fs+1):round((NoisePreStimSilence+NoiseDuration).*fs));
ramp = hanning(round(.01 * fs*2));
ramp = ramp(1:floor(length(ramp)/2));
wn(1:length(ramp))         = wn(1:length(ramp)) .* ramp;
wn(end-length(ramp)+1:end) = wn(end-length(ramp)+1:end) .* flipud(ramp);

% normalize min/max +/-5
wn = 5 ./ max(abs(wn(:))) .* wn;

% Now, put it in the silence:
wn = [zeros(NoisePreStimSilence*fs,1) ; wn(:) ; zeros(NoisePostStimSilence*fs,1)];

%%
% Add white noise to stimulus vector
w = [w; wn];

% Event3:
ev = AddEvent(ev, ['TargetSequence ' , ' - ',num2str(TrialNum) ],...
  [ ], ev(end).StopTime, ev(end).StopTime + length(wn(:))/fs );

% Add poststim to stimulus vector
w = [w ; poststim(:)];
ev = AddEvent(ev, 'PostSilence', [], ev(end).StopTime, ev(end).StopTime + PostStimSilence);

if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end


