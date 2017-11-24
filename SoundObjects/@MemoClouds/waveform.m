function [w, ev,o] = waveform (o,index,IsRef,Mode,TrialNum)
% 17/07-YB
% index is the Nb of CT
% this function is the waveform generator for object MemoClouds

index           = 1;
fs              = get(o,'SamplingRate');
PreStimSilence  = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

%% PARAMETERS OF MemoClouds OBJECT
RateRTC    = get(o,'RateRTCPercent');
RateRefRTC = get(o,'RateRefRTCPercent');
prestim   = zeros(round(PreStimSilence*fs),1);
poststim  = zeros(round(PostStimSilence*fs),1);
w         = [];
ev        = [];
%% INITIALIZE Trevor's click train OBJECT
sP.fs = fs; %sample-frequency
sP.tpersecond = get(o,'tonespersecond'); % number of tones per second: set for Yves to give left-most point of Expt 2
sP.cperoctave = get(o,'chperoctave'); % number of channels per octave: set for Yves to give left-most point of Expt 2
sP.segdur = get(o,'SegDur'); %seconds
sP.nrepeats = get(o,'nreps'); %the number of repetitions (and multiplier of the duration)
sP.tonedur = get(o,'tonedur'); %the duration of each pure tone (in seconds)
sP.lowchan = get(o,'lowchannel'); %Hz
sP.highchan = get(o,'highchannel'); %Hz
sP.mingapt = 0; %the smallest acceptable gap between tones (0 to not check)
sP.mingapf = 0; %the smallest acceptable frequency between tones (0 to not check)
sP.mingaplogf = 0;%1/12; %the smallest acceptable octave between tones (0 to not check)
sP.rtime = sP.tonedur/2; %equivalent to a Hanning window
sP.rmsnorm = 0.05; %the desired rms
sP.scannernoise = 999;
sP.levelmapper = 'default'; %dummy function
sP.freqrampoctaves = 2; %octaves
sP.freqrampdepth = 60; %dB
sP.generationtime = 0.5;%used in my expt program to ensure that the gap between trials is the same, irrespective of stimulus-generation time.

%% RANDOM NUMBER GENERATOR
Key      = get(o,'Key');
TrialKey = RandStream('mrg32k3a','Seed',Key);
PastRef  = get(o,'PastRef');

%% Pointer to the position in RandSequence
% PastRef STORES THE PREVIOUS INDEX
if isempty(PastRef)  % First trial
    RefNow = 0;
    o      = set(o,'PastRef',[PastRef index]);
elseif length(PastRef) < TrialNum   % during the experiment, only this condition should be true
    RefNow = sum(PastRef);
    o      = set(o,'PastRef',[PastRef index]);
elseif length(PastRef) >= TrialNum && index == PastRef(TrialNum)  % When you load a SO from a previous experiment
    RefNow = sum(PastRef(1:TrialNum)) - PastRef(TrialNum);
elseif length(PastRef) > TrialNum && index ~= PastRef(TrialNum)
    error('Valeur index attendue: %d', PastRef(TrialNum));
end

%% Sequences of 0 1 2 (refnoise)
RandSequence = [ones(1,floor(RateRTC)) 2*ones(1,floor(RateRefRTC)) zeros(1,floor((100-RateRTC - RateRefRTC)))];
RandPick     = [];
for i = 1:4
    RandPick = [RandPick TrialKey.randperm(100)];
end

ev     = AddEvent(ev,'PreStimSilence',[],0,PreStimSilence);
w      = [w ; prestim(:)];

%% GENERATE TONE CLOUD
sP.refnoise= RandSequence(RandPick(RefNow+1)); % stimulus type: 0 is C, 1 is RC, 2 is RefRC
StimulusType = get(o,'Stimulus');
o = set(o,'Stimulus',[StimulusType sP.refnoise]);

if sP.refnoise == 2
    sP.seed = Key;
else
    sP.seed = Key*(RefNow+1);
end
if sP.refnoise==1 || sP.refnoise==2
    sP.repetitionflag = 1;
else sP.repetitionflag = 0;
end
Seed = get(o,'Seeds');
o = set(o,'Seeds',[Seed sP.seed]);

[wSeq, sP] =  gentonecloud21(sP);
w = [w ; wSeq(:)];
ev = AddEvent(ev,  ['MemoCloud ',  num2str(TrialNum),  '; Type: ' num2str(sP.refnoise) '; Seed: ' num2str(sP.seed)],  [ ] , ev(end).StopTime,  ev(end).StopTime + length(wSeq(:))/fs );

%% POST-STIM SILENCE
w = [w ; poststim(:)];
ev = AddEvent(ev, 'PostSilence', [], ev(end).StopTime, ev(end).StopTime + PostStimSilence);

if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end
    
