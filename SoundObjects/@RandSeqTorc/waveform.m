function [w,ev,o,Parameters] = waveform(o,index,IsRef,Mode,TrialNum)
% 2013: Thomas // 2014: Yves
% index is the Nb of Ref+1 (total nb of sequences)
Parameters = [];
fs = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');

% PARAMETERS OF RandSeqTorc OBJECT
SameRef = get(o,'SameRef');                  % unique tone in the reference
RampProbability = get(o,'RampProbability');  % probability of having descending or ascending ramp
UniqueToneIndex = get(o,'UniqueToneIndex');
ToneDur = get(o,'ToneDur');  % sec.
ToneGap = get(o,'ToneGap');  % sec.
SeqGap = get(o,'SequenceGap');  % sec.

TargetF = get(o,'TargetF');
RampInterval = get(o,'RampInterval');     % in semitones
IdenticalTones= get(o,'IdenticalTones');
LoudnessCue = get(o,'LoudnessCue');

Parameters.Sequences = [];

% Create an instance of TORC object:
TORC = get(o,'TORC');
TorcDur = get(o,'TorcDuration');
TorcFreq = get(o,'FrequencyRange');
TorcRates = get(o,'TorcRates');
TORCPreStimSilence = 0; TORCPostStimSilence = 0;
TorcObj = Torc(fs,0, ...                          % No Loudness
    TORCPreStimSilence,TORCPostStimSilence,TorcDur, TorcFreq, TorcRates);
  
% RANDOM NUMBER GENERATOR
Key = get(o,'Key');
TrialKey = RandStream('mrg32k3a','Seed',Key);
PastRef = get(o,'PastRef');

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

% MATRIX OF PERMUTATION WITH CONTRAINS
PermIndex = find(IdenticalTones ~= 1);
MustPermIndex = find(IdenticalTones == -1);
NoPermIndex = find(IdenticalTones == 1);
[PermSizeRow,PermSizeCol] = size(perms(TargetF(PermIndex)));
SeqFrequencyPerm = zeros(PermSizeRow,length(TargetF));
SeqFrequencyNoPerm = SeqFrequencyPerm;

SeqFrequencyPerm(:,PermIndex) = perms(TargetF(PermIndex));
SeqFrequencyNoPerm(:,NoPermIndex) = repmat(TargetF(NoPermIndex),PermSizeRow,1);
SeqFrequency = SeqFrequencyNoPerm + SeqFrequencyPerm;

for q = 1:length(MustPermIndex)
    if any(SeqFrequency(:,q) == TargetF(q))
       [BadSeq, ~] = find(SeqFrequency(:,q) == TargetF(q));
       SeqFrequency(BadSeq,:) = [];
    end
end
% Remove potential Target sequence
for q = size(SeqFrequency,1):-1:1
    if all(SeqFrequency(q,:) == TargetF)
       SeqFrequency(q,:) = [];
    end
end

% MATRIX OF PERMUTATION AND TORC INDICES FOR MAKING SURE WE PRESENT
%EACH OF THEM IN A BALANCED WAY
[RefNb,~] = size(SeqFrequency);
RandSequence = [];
RandTORC = [];
TorcNb = 30;
for RepNum = 1:(ceil(RefNow/RefNb)+RefNb)
    RandSequence = [RandSequence TrialKey.randperm(RefNb)];
    RandTORC = [RandTORC TrialKey.randperm(TorcNb)];
end

% BUILD THE WAVEFORM
t = 0:1/fs:ToneDur;
gap = zeros(round(ToneGap*fs),1);
gapSeq = zeros(round(SeqGap*fs),1);
prestim = zeros(round(PreStimSilence*fs),1);
poststim = zeros(round(PostStimSilence*fs),1);

w = []; ev = [];
% PRESTIM
ev = AddEvent(ev,['PreStimSilence - ' , num2str(TrialNum)],[],0,PreStimSilence); 
w = [w ; prestim(:)];

% REFERENCE(S)
% 1) RAMP
if RampProbability>0
  RampPosition = find(TrialKey.rand(1,(index-1))<RampProbability);
  AscRampPosition = RampPosition(TrialKey.rand(1,length(RampPosition))>0.5);  % Half ascending
  DescRampPosition = setdiff(RampPosition,AscRampPosition);                   % Half descending
else RampPosition = []; AscRampPosition = []; DescRampPosition = []; end
for j = (RefNow+1) : (RefNow+index-1)  % index-1 is the number of Ref  
  LocalSeq = SeqFrequency(RandSequence(j),:);  % Select the right permutation
  % TORC
  if strcmp(TORC,'yes')
    [wTorc, eTorc] = waveform(TorcObj, RandTORC(j));
    MTORC = maxLocalStd(wTorc,fs,length(wTorc)/fs);
  else
    wTorc = []; MTORC = 1;
  end 
  
  wSeq = [];
  % 2) SINGLE-FREQUENCIED REF
  if strcmp(SameRef,'yes')
    ThisTrial_FreqNum = TrialKey.randi(length(UniqueToneIndex),1);
    if any(AscRampPosition==(j-RefNow)) && ThisTrial_FreqNum == 3
      DescRampPosition = [DescRampPosition j-RefNow];
      AscRampPosition(AscRampPosition==(j-RefNow)) = [];
    elseif any(DescRampPosition==(j-RefNow)) && ThisTrial_FreqNum == 4
      AscRampPosition = [AscRampPosition j-RefNow];
      DescRampPosition(DescRampPosition==(j-RefNow)) = [];
    end
  end
  
  % BUILD TONES
  for FreqNum = 1:length(TargetF)
      if strcmp(SameRef,'yes')
          if any(RampPosition==(j-RefNow))
              if any(AscRampPosition==(j-RefNow))
                  w0 = addenv(sin(2*pi*TargetF(UniqueToneIndex(ThisTrial_FreqNum))*2^(RampInterval*(FreqNum-1)/12) *t),fs);
              elseif any(DescRampPosition==(j-RefNow))
                  w0 = addenv(sin(2*pi*TargetF(UniqueToneIndex(ThisTrial_FreqNum))*2^(-RampInterval*(FreqNum-1)/12) *t),fs);
              else disp('BUG'); end
          else
              w0 = addenv(sin(2*pi*TargetF(UniqueToneIndex(ThisTrial_FreqNum))*t),fs);
          end
      else
          w0 = addenv(sin(2*pi*LocalSeq(FreqNum)*t),fs);
      end
      wSeq = [wSeq;w0(:);gap(:)];
  end
  
  MSeq = maxLocalStd(wSeq,fs,length(wSeq)/fs);
  Segment2Add = [10^(LoudnessCue/20)*wSeq(:)/MSeq ; gapSeq(:) ; wTorc(:)/MTORC ; gapSeq(:)];
  
  ev = AddEvent(ev, ['ReferenceSequence , ', num2str(j-RefNow), ' / ',num2str(index), ' - ', num2str(TrialNum) ],...
    [ ], ev(end).StopTime, ev(end).StopTime + length(Segment2Add)/fs );
  
  w = [w ; Segment2Add];
  
  % LABEL OF SEQUENCE TONES
  if strcmp(SameRef,'yes')
      Parameters.Sequences(j-RefNow,:) = ones(1,4)*UniqueToneIndex(ThisTrial_FreqNum);
  else
      for FreqNum = 1:length(TargetF); Parameters.Sequences(j-RefNow,FreqNum) = find( TargetF == LocalSeq(FreqNum) ); end
  end
end

% TARGET
TargetSequence = [];
for FreqNum = 1:length(TargetF)
  wTarg = addenv(sin(2*pi*TargetF(FreqNum)*t),fs);
  TargetSequence = [TargetSequence ; wTarg(:) ; gap(:)];
end
if strcmp(TORC,'yes')
  [wTorc, eTorc] = waveform(TorcObj, RandTORC(j+1));
  MTORC = maxLocalStd(wTorc,fs,length(wTorc)/fs);
else
  wTorc = []; MTORC = 1;
end
MSeq = maxLocalStd(TargetSequence(:),fs,length(TargetSequence(:))/fs);
ev = AddEvent(ev, ['TargetSequence' , ' - ',num2str(TrialNum)  , ' - ' , num2str(index) ],...
  [ ], ev(end).StopTime, ev(end).StopTime + length(TargetSequence(:))/fs );

%w=[TargetSequence(:);zeros(3*fs,1);w;TargetSequence(:);gapSeq(:);wTorc(:)];
Segment2Add = [TargetSequence(:)/MSeq ; gapSeq(:) ; wTorc(:)/MTORC ; gapSeq(:)];
w = [w ; Segment2Add];
%ev=ev_struct(ev,['Note ' num2str(TargetF(i))],0,ToneDur,PostStimSilence);
TimeLickWindow = length([gapSeq(:) ; wTorc(:) ; gapSeq(:)]);
ev = AddEvent(ev, 'LickWindow', [], ev(end).StopTime, ev(end).StopTime+TimeLickWindow/fs);

% POSTSTIM
w = [w ; poststim(:)];
ev = AddEvent(ev,['PostStimSilence - ' , num2str(TrialNum)],[], ev(end).StopTime, ev(end).StopTime + PostStimSilence); 

% ev = AddEvent(ev, ['RefSequence , ' num2str(index),' - ',num2str(TrialNum) ],...
%   [ ], ev(end).StopTime, ev(end).StopTime + TimeEndRefSeq);    
%     
% ev = AddEvent(ev, ['TargetSequence , ' num2str(index),' - ',num2str(TrialNum) ],...
%   [ ], ev(end).StopTime, ev(end).StopTime+ TimeEndTargSeq);
% %y: duree jusqu'a la fin de la sequence cible

% [a,b,c]  = ParseStimEvent(ev(2),0);
% ev(1).Note = ['PreStimSilence ,' b ',' c];
% % [a,b,c]  = ParseStimEvent(ev(end),0); 
% ev = AddEvent(ev, ['LickWindow ,' b ',' c], [], ev(end).StopTime, ev(end).StopTime+TimeLickWindow);

if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end


%add 5 ms rise/fall time ===================================
function s=addenv(s1,fs)
f=ones(size(s1));
pn=round(fs*0.005);    % 5 ms rise/fall time 
up = sin(2*pi*(0:pn-1)/(4*pn)).^2;   %add sinramp
down = sin(2*pi*(pn+1:2*pn)/(4*pn)).^2;
f = [up ones(1,length(s1)-2*pn) down]';
s=s1(:).*f(:);

%create Event structure======================================
function ev=ev_struct(ev,Name,PreStim,Duration,PostStim)
N=length(ev);
if N==0
    offset=0;
    ev=struct(ev);
else
    offset=ev(end).StopTime; 
end

if N==0
    ev= struct('Note',['PreStimSilence , ' Name],...
              'StartTime',offset,'StopTime',offset+PreStim,'Trial',[]);
else
    ev(N+1)= struct('Note',['PreStimSilence , ' Name],...
              'StartTime',offset,'StopTime',offset+PreStim,'Trial',[]);
end
ev(N+2) = struct('Note',['Stim , ' Name],'StartTime',...
              offset+PreStim, 'StopTime', offset+PreStim+Duration,'Trial',[]);
ev(N+3) = struct('Note',['PostStimSilence , ' Name],...
              'StartTime',offset+PreStim+Duration, 'StopTime',offset+PreStim+Duration+PostStim,'Trial',[]);

