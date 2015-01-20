function [w, ev,o] = waveform (o,index,IsRef,Mode,TrialNum)
% Sundeep, 16.01.2015

index           = 1;
fs              = get(o,'SamplingRate');
PreStimSilence  = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

%% PARAMETERS OF MemoClicks OBJECT

RateRTC    = get(o,'RateRTCPercent');
RateRefRTC = get(o,'RateRefRTCPercent');
prestim    = zeros(round(PreStimSilence*fs),1);
poststim   = zeros(round(PostStimSilence*fs),1);
SeqGap     = get(o,'SequenceGap');  % duration in second
w          = [];
ev         = [];

%% INITIALIZE Daniel's click train OBJECT

sP.fs               = fs;
sP.segdur           = get(o,'SegDur'); % duration of a single repeat
sP.nrepeats         = get(o,'nreps'); % number of repeats
sP.tpersecond       = get(o,'tonespersecond');     % number of tones per second (1/sP.tonedur?)
sP.chperoctave      = get(o,'chperoctave');        % number of channels per octave
sP.lowchan          = get(o,'lowchannel');         % lowest frequency is 8 octaves below Nyquist
sP.highchan         = get(o,'highchannel');        % Hz
sP.seed             = [];
sP.repetitionflag   = 1;         %false for an equivalent unrepeated noise of the same duration
sP.tonedur          = 0.05;         %the duration of each pure tone (in seconds)
sP.mingapt          = 0;            %the smallest acceptable gap between tones (0 to not check)
sP.mingapf          = 0;            %the smallest acceptable frequency between tones (0 to not check)
sP.mingaplogf       = 0;            %1/12; %the smallest acceptable octave between tones (0 to not check)
sP.rtime            = sP.tonedur/2;
sP.rmsnorm          = 0.05;         %the desired rms
sP.freqrampoctaves  = 2;            %octaves
sP.freqrampdepth    = 60;           %dB
sP.levelmapper      = 'default';

%% Create an instance of TORC object:

PutTORC                 = get(o,'IntroduceTORC');

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

RandSequence = [ones(1,floor(RateRTC)) 2*ones(1,floor(RateRefRTC)) zeros(1,floor((100-RateRTC - RateRefRTC)))];
RandPick     = [];
for i = 1:4
    RandPick = [RandPick TrialKey.randperm(100)];
end

gapSeq = zeros(round(SeqGap*fs),1);
ev     = AddEvent(ev,'PreStimSilence',[],0,PreStimSilence);
w      = [w ; prestim(:)];

%% GENERATE TONE CLOUDS

for j = (RefNow+1) : (RefNow+index)
    
    sP.repetitiongflag  = RandSequence(RandPick(j)); % repetitionflag: 0 is TC, 1 is RTC, 2 is RefRTC
    StimulusType        = get(o,'Stimulus');
    o                   = set(o,'Stimulus',[StimulusType sP.repetitiongflag]);
    
    if sP.repetitiongflag == 2
        sP.seed = Key;
    else
        sP.seed = Key*(RefNow+j);
    end
    
    Seed   = get(o,'Seeds');
    o      = set(o,'Seeds',[Seed sP.seed]);
    
    [wSeq, sP] = gentonecloud22(sP);
    MSeq       = maxLocalStd(wSeq(:),fs,length(wSeq(:))/fs);
    w          = [w ; wSeq(:)/MSeq ; gapSeq(:)];
    
    ev = AddEvent(ev,  ['ToneCloudSequence ',  num2str(TrialNum),  ', Type: ' num2str(sP.repetitiongflag) ', Seed: ' num2str(sP.seed) ', ChPerOct: ' num2str(sP.chperoctave) ', TonesPerSec: ' num2str(sP.tpersecond)],  [ ] , ev(end).StopTime,  ev(end).StopTime + length([wSeq(:) ; gapSeq(:)])/fs );    
    
end

%% END WITH TORC

TorcSequence = [];
if PutTORC
    [wTarg, eTorc] = waveform(TorcObj, 1);    % so far, only 1 TORC pattern
    TorcSequence   = [TorcSequence; wTarg(:); gapSeq(:)];
    MSeq           = maxLocalStd(TorcSequence(:),sP.fs,length(TorcSequence(:))/fs);
    TorcSequence   = [ gapSeq(:); TorcSequence(:)/MSeq; gapSeq(:)];
    w              = [w ; TorcSequence];
end

ev               = AddEvent(ev, ['TorcSequence ' ,num2str(TrialNum) ],[],...
    ev(end).StopTime, ev(end).StopTime + length(TorcSequence(:))/fs );

w                = [w ; poststim(:)];
ev               = AddEvent(ev, 'PostSilence', [], ev(end).StopTime, ev(end).StopTime + PostStimSilence);

if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end

