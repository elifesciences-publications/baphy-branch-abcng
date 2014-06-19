function [w, ev,o]=waveform (o,index,IsRef,Mode,TrialNum)
%  14/05-TP/YB
% function w=waveform(t);
% this function is the waveform generator for objectMemoClicks

RateRN = get(o,'RateRNPercent');
RateRef = get(o,'RateRefPercent');
%NbTrials = get(o,'NbTrials');
sP.fs = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
sP.replength = get(o,'SingleTrainDuration'); % duration of a single repeat
sP.nreps = get(o,'nreps'); % number of repeats
sP.testtype = 1;
sP.seed = [];
sP.highpass = get(o,'highfreq'); % high-pass filter cutoff
sP.noiseSNR = get(o,'SNR'); % add lowpass noise with given SNR. Cutoff is = highpass, noise is pink. Positive values means softer noise.
sP.clickdur = 0.00005;
o = set(o,'DifficultyLvlByInd',index);
index = index-1;
prestim=zeros(round(PreStimSilence*sP.fs),1);
poststim=zeros(round(PostStimSilence*sP.fs),1);
w=[];ev=[];

Key = get(o,'Key');
TrialKey = RandStream('mrg32k3a','Seed',Key);
PastRef = get(o,'PastRef');
sP.seed = Key;

% Parameters of click trains
sP.maxgap = get(o,'maxgap');
sP.mingap = get(o,'mingap');
SeqGap = get(o,'SequenceGap');% duration is second

% Create an instance of TORC object:
TorcDur = get(o,'TorcDuration');
TorcFreq = get(o,'FrequencyRange');
TorcRates = get(o,'TorcRates');
TorcObj = Torc(sP.fs,...
    0, ...                          % No Loudness
    PreStimSilence, ...    % Put the PreStimSilence before torc.
    PostStimSilence, ...     % Put half of gap after torc, the other half goes before tone
    TorcDur, TorcFreq, TorcRates);

 % Sequences of 0 1 2 (stimtype)
RandSequence = [ones(1,floor(RateRN)) 2*ones(1,floor(RateRef)) zeros(1,floor((100-RateRN - RateRef)))];
RandPick = [];
for i = 1:4
    RandPick = [RandPick TrialKey.randperm(100)];
end
% Pointer to the position in RandSequence
if isempty(PastRef) % First trial
   RefNow = 0;
   o = set(o,'PastRef',[PastRef index]);
elseif length(PastRef) < TrialNum   % during the experiment, only this condition is true
   RefNow = sum(PastRef);
   o = set(o,'PastRef',[PastRef index]);
elseif length(PastRef) >= TrialNum && index == PastRef(TrialNum)
   RefNow = sum(PastRef(1:TrialNum)) - PastRef(TrialNum);
elseif length(PastRef) > TrialNum && index ~= PastRef(TrialNum)
   error('Valeur index attendue: %d', PastRef(TrialNum));
end

gapSeq = zeros(round(SeqGap*sP.fs),1);
ev = AddEvent(ev,'PreStimSilence',[],0,PreStimSilence); 
w = [w ; prestim(:)];
for j = (RefNow+1) : (RefNow+index)    
    sP.stimtype = RandSequence(RandPick(j)); % stimulus type: 0 is N, 1 is RN, 2 is RefRN
    if sP.stimtype == 2
       sP.seed = Key;
    else
       sP.seed = Key*(RefNow+j);
    end
    
    sP.stimtype
    [wSeq, sP] = genmemoclicks(sP);    
    MSeq = maxLocalStd(wSeq(:),sP.fs,length(wSeq(:))/sP.fs);
    w=[w;wSeq(:)/MSeq;gapSeq(:)];
    
    ev = AddEvent(ev, ['ReferenceSequence , ', num2str(j-RefNow), ' / ',num2str(index), ' - ', num2str(TrialNum) ],...
        [ ], ev(end).StopTime, ev(end).StopTime + length([wSeq(:);gapSeq(:)])/sP.fs );     
end
TargetSequence = [];
[wTarg, eTorc] = waveform(TorcObj, 1);    % so far, only 1 TORC pattern
TargetSequence = [TargetSequence;wTarg(:); gapSeq(:)];
MSeq = maxLocalStd(TargetSequence(:),sP.fs,length(TargetSequence(:))/sP.fs);
w=[w;TargetSequence(:)/MSeq;gapSeq(:)];

ev = AddEvent(ev, ['TargetSequence ' , ' - ',num2str(TrialNum) ],...
  [ ], ev(end).StopTime, ev(end).StopTime + length(TargetSequence(:))/sP.fs );
w = [w ; poststim(:)];

%soundsc(w,sP.fs);
%wavwrite(w,fs,'4 sequences 150 ms');

% ADD EVENTS
%ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); 
if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end

ev = AddEvent(ev, 'LastGapEnd', [], ev(end).StartTime, ev(end).StopTime+SeqGap);
ev = AddEvent(ev, 'PostSilence', [], ev(end).StopTime, ev(end).StopTime + PostStimSilence);

