function [w, ev,o] = waveform (o,index,IsRef,Mode,TrialNum)
%  14/05-TP/YB
% index is the Nb of CT
% function w=waveform(t);
% this function is the waveform generator for objectMemoClicks
% Sundeep, Dec. 2014 -fix #CT=1

index           = 1;
fs              = get(o,'SamplingRate');
PreStimSilence  = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

%% PARAMETERS OF MemoClicks OBJECT

RateRC    = get(o,'RateRCPercent');
RateRefRC = get(o,'RateRefRCPercent');
prestim   = zeros(round(PreStimSilence*fs),1);
poststim  = zeros(round(PostStimSilence*fs),1);
SeqGap    = get(o,'SequenceGap');  % duration in second
w         = [];
ev        = [];

%% INITIALIZE Daniel's click train OBJECT

sP.fs         = fs;
sP.replength  = get(o,'ClickTrainDur'); % duration of a single repeat
sP.nreps      = get(o,'nreps'); % number of repeats
sP.testtype   = 1;
sP.seed       = [];
sP.highpass   = get(o,'highfreq'); % high-pass filter cutoff
sP.noiseSNR   = get(o,'SNR'); % add lowpass noise with given SNR. Cutoff is = highpass, noise is pink. Positive values means softer noise.
sP.clickdur   = 0.00005;
sP.maxgap     = get(o,'maxgap');
sP.mingap     = get(o,'mingap');
sP.clicktimes = get(o,'ClickTimes');

%% Create an instance of TORC object:

PutTORC               = get(o,'IntroduceTORC');

if PutTORC
  TorcDur             = get(o,'TorcDuration');
  TorcFreq            = get(o,'FrequencyRange');
  TorcRates           = get(o,'TorcRates');
  TORCPreStimSilence  = 0;
  TORCPostStimSilence = 0;
  TorcObj             = Torc(fs,0, ...                    % No Loudness
    TORCPreStimSilence,TORCPostStimSilence,TorcDur, TorcFreq, TorcRates);
end

%% RANDOM NUMBER GENERATOR

Key      = get(o,'Key');
TrialKey = RandStream('mrg32k3a','Seed',Key);
PastRef  = get(o,'PastRef');
sP.seed  = Key;

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

%% Sequences of 0 1 2 (stimtype)

RandSequence = [ones(1,floor(RateRC)) 2*ones(1,floor(RateRefRC)) zeros(1,floor((100-RateRC - RateRefRC)))];
RandPick     = [];
for i = 1:4
  RandPick = [RandPick TrialKey.randperm(100)];
end

gapSeq = zeros(round(SeqGap*fs),1);
ev     = AddEvent(ev,'PreStimSilence',[],0,PreStimSilence);
w      = [w ; prestim(:)];

%% GENERATE CLICK TRAINS

for j = (RefNow+1) : (RefNow+index)
  
  sP.stimtype  = RandSequence(RandPick(j)); % stimulus type: 0 is C, 1 is RC, 2 is RefRC
  StimulusType = get(o,'Stimulus');
  o            = set(o,'Stimulus',[StimulusType sP.stimtype]);
  
  if sP.stimtype == 2
    sP.seed = Key;
  else
    sP.seed = Key*(RefNow+j);
  end
  
  Seed = get(o,'Seeds');
  o      = set(o,'Seeds',[Seed sP.seed]);
  
  ReSeed = get(o,'ReSeed');
  o      = set(o,'ReSeed',ReSeed);
  
  [wSeq, sP] = genmemoclicks(sP);
  ClickTimes = get(o,'ClickTimes');
  o               = set(o,'ClickTimes',[ClickTimes sP.clicktimes]);
  
  MSeq       = maxLocalStd(wSeq(:),fs,length(wSeq(:))/fs);
  w          = [w ; wSeq(:)/MSeq ; gapSeq(:)];
  
  ev = AddEvent(ev,  ['ClickSequence',  num2str(TrialNum),  'Type: ' num2str(sP.stimtype) '; Seed: ' num2str(sP.seed)],  [ ] , ev(end).StopTime,  ev(end).StopTime + length([wSeq(:) ; gapSeq(:)])/fs );
  
  
end

%% END WITH TORC

TorcSequence = [];
if PutTORC
  [wTarg, eTorc] = waveform(TorcObj, 1);    % so far, only 1 TORC pattern
  TorcSequence   =  [TorcSequence; wTarg(:); gapSeq(:)];
  MSeq           = maxLocalStd(TorcSequence(:),sP.fs,length(TorcSequence(:))/fs);
  TorcSequence   = [TorcSequence(:)/MSeq ; gapSeq(:)];
  w              = [w ; TorcSequence];
end

ev               = AddEvent(ev, ['TorcSequence ' ,num2str(TrialNum) ],[],...
  ev(end).StopTime, ev(end).StopTime + length(TorcSequence(:))/fs );

w                = [w ; poststim(:)];
ev               = AddEvent(ev, 'PostSilence', [], ev(end).StopTime, ev(end).StopTime + PostStimSilence);

if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end

