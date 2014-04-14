function [w, ev,o]=waveform (o,index,IsRef,Mode,TrialNum)
% function w=waveform(t);
% this function is the waveform generator for object TonesSequence
%
%Pingbo, December 2005.

fs = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
MaxIndex = get(o,'MaxIndex');

o = set(o,'DifficultyLvlByInd',index);

% the parameters of Stream_AB object
IsRef = get(o,'IsRef');
IsBuzz = get(o,'IsBuzz');
NoteDur = get(o,'NoteDur');
NoteGap = get(o,'NoteGap');
SeqGap = get(o,'SequenceGap');% duration is second

FirstFrequency = get(o,'FirstFrequency');
Intervals = get(o,'Intervals');
SimilareTones= get(o,'SimilareTones')

TORC = get(o,'TORC');
TorcDur = get(o,'TorcDuration');
TorcFreq = get(o,'FrequencyRange');
TorcRates = get(o,'TorcRates');

Key = get(o,'Key')
TrialKey = RandStream('mrg32k3a','Seed',Key)
PastRef = get(o,'PastRef');

if index > MaxIndex
  index = MaxIndex;
end

if isempty(PastRef) 
   RefNow = 0;
   o = set(o,'PastRef',[PastRef index]);
elseif length(PastRef) >= TrialNum && index == PastRef(TrialNum)
   RefNow = sum(PastRef(1:TrialNum)) - PastRef(TrialNum);
elseif length(PastRef) > TrialNum && index ~= PastRef(TrialNum)
   error('Valeur index attendue: %d', PastRef(TrialNum));
elseif length(PastRef) < TrialNum
   RefNow = sum(PastRef);
   o = set(o,'PastRef',[PastRef index]);
end


% create an instance of torc object:
global globalparams;
global exptparams_Copy;

TorcObj = Torc(fs,...
    0, ...                          % No Loudness
    PreStimSilence, ...    % Put the PreStimSilence before torc.
    PostStimSilence, ...     % Put half of gap after torc, the other half goes before tone
    TorcDur, TorcFreq, TorcRates);

% now generate a tone with specified frequency:

Frequency =[FirstFrequency];
for k = 2:length(Intervals)
    Frequency(k) = Frequency(k-1)*2^(Intervals(k)/12);
    
end

PermIndex = find(SimilareTones ~= 1);
MustPermIndex = find(SimilareTones == -1);
NoPermIndex = find(SimilareTones == 1);
[RandTaille, ~] = size(perms(Frequency(PermIndex)));
SeqFrequencyPerm = zeros(RandTaille,length(Frequency));
SeqFrequencyNoPerm = SeqFrequencyPerm;
SeqFrequencyPerm(:,PermIndex) = perms(Frequency(PermIndex));

SeqFrequencyNoPerm(1,NoPermIndex) = Frequency(NoPermIndex);
size(SeqFrequencyNoPerm(2:RandTaille,:));
size(repmat(SeqFrequencyNoPerm(1,:),RandTaille-1,1));
SeqFrequencyNoPerm(2:RandTaille,:) = repmat(SeqFrequencyNoPerm(1,:),RandTaille-1,1);
SeqFrequency = SeqFrequencyNoPerm + SeqFrequencyPerm;

for q = 1:length(MustPermIndex)
    if ismember(Frequency(q),SeqFrequency(:,q))
       [BadSeq, ~] = find(SeqFrequency(:,q) == Frequency(q));
       SeqFrequency(BadSeq,:) = [];
    end
end


[RandTaille, ~] = size(SeqFrequency);
RandSequence = [];
RandTORC = [];
for i = 1:100
    RandSequence = [RandSequence TrialKey.randperm(RandTaille)];
    RandTORC = [RandTORC TrialKey.randperm(30)];
end

TargetFreq = Frequency;
TargetSequence = [];

t=0:1/fs:NoteDur;

gap=zeros(round(NoteGap*fs),1);
gapSeq=zeros(round(SeqGap*fs),1);
NoteDur=length(t)/fs;
NoteGap=length(gap)/fs;

w=[];ev=[];
prestim=zeros(round(PreStimSilence*fs),1);
poststim=zeros(round(PostStimSilence*fs),1);

if strcmp(IsBuzz,'yes')
      Tbuzz = [0:1/fs:0.7]; Xbuzz = sin(2.*pi.*110.*Tbuzz); 
      Ybuzz = square(2*pi*440*Tbuzz + Xbuzz);
      Mbuzz = maxLocalStd(Ybuzz,fs,length(Tbuzz)/fs);
      Ybuzz = Ybuzz/Mbuzz;
else
      Ybuzz = 0;
end

ev = AddEvent(ev,['PreStimSilence 1 / 1'],[],0,PreStimSilence); 
w = [w ; prestim(:)];

INDEX = index
NextTry = 1;
%index -1 pour obtenir trial sans ref
for j = RefNow+1:RefNow+index
  
  if j <  RefNow+index
   % if strcmp(IsRef,'yes')
      
      LocalSeq = SeqFrequency(RandSequence(j),:) ;
      
      if strcmp(TORC,'yes')
        [wTorc, eTorc] = waveform(TorcObj, RandTORC(j));
      else
        wTorc = 0;
      end
      
      while LocalSeq == Frequency
        LocalSeq = SeqFrequency(RandSequence(RefNow+NextTry+index),:);
        NextTry = NextTry +1;
      end
      
      wSeq = zeros(1,1);
      
      for i=1:length(Frequency)
        w0=addenv(sin(2*pi*LocalSeq(i)*t),fs);
        wSeq=[wSeq;w0(:);gap(:)];
      end
      
      MSeq = maxLocalStd(wSeq,fs,length(wSeq)/fs);
      MTORC = maxLocalStd(wTorc,fs,length(wTorc)/fs);
      
      ev = AddEvent(ev, ['ReferenceSequence , ', num2str(j-RefNow), ' / ',num2str(index), ' - ', num2str(TrialNum) ],...
        [ ], ev(end).StopTime, ev(end).StopTime + length([wSeq(:);gapSeq(1:round(length(gapSeq)/2));wTorc(:);gapSeq(:)])/fs );
      
      w=[w;wSeq(:)/MSeq;gapSeq(1:round(length(gapSeq)/2));wTorc(:)/MTORC;gapSeq(:)];
      
      %     if i==1
      %        w=[prestim;w];
      %        ev=ev_struct(ev,['Note ' num2str(Frequency(i))],PreStimSilence,NoteDur,NoteGap);
      %     else
      %        ev=ev_struct(ev,['Note ' num2str(Frequency(i))],0,NoteDur,NoteGap);
      %     end
  %  end
    
  elseif j == RefNow+index
    
    for k=1:length(Frequency)
      
      wTarg=addenv(sin(2*pi*Frequency(k)*t),fs);
      TargetSequence=[TargetSequence;wTarg(:);gap(:)];
      
    end
    
    if strcmp(TORC,'yes')
      [wTorc, eTorc] = waveform(TorcObj, RandTORC(j+1));
    else
      wTorc = 0;
    end
    MSeq = maxLocalStd(TargetSequence(:),fs,length(TargetSequence(:))/fs);
    MTORC = maxLocalStd(wTorc,fs,length(wTorc)/fs);
    
    ev = AddEvent(ev, ['TargetSequence ' , ' - ',num2str(TrialNum) ],...
      [ ], ev(end).StopTime, ev(end).StopTime + length(TargetSequence(:))/fs );
    
    %w=[TargetSequence(:);zeros(3*fs,1);w;TargetSequence(:);gapSeq(:);wTorc(:)];
    w=[w;TargetSequence(:)/MSeq;gapSeq(1:round(length(gapSeq)/2));wTorc(:)/MTORC;gapSeq(:);Ybuzz(:)];
    %ev=ev_struct(ev,['Note ' num2str(Frequency(i))],0,NoteDur,PostStimSilence);
    
  end
  
end

w = 5 * w/max(abs(w));
%soundsc(w,fs);
%wavwrite(w,fs,'4 sequences 150 ms');


% ADD EVENTS
%ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); 
if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end
    TimeEndRefSeq = length(w) - length([TargetSequence(:);gapSeq(1:round(length(gapSeq)/2));wTorc(:)/MTORC;gapSeq(:);Ybuzz(:)]); 
    TimeEndTargSeq = length(w) - length([gapSeq(1:round(length(gapSeq)/2));wTorc(:)/MTORC;gapSeq(:);Ybuzz(:)]); 
    TimeLickWindow = length([gapSeq(1:round(length(gapSeq)/2));wTorc(:)/MTORC;gapSeq(:)]);
% 
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

ev = AddEvent(ev, 'LickWindow', [], ev(end).StopTime, ev(end).StopTime+TimeLickWindow/fs);
ev = AddEvent(ev, 'BuzzSnooze', [], ev(end).StopTime, ev(end).StopTime+length(Ybuzz)/fs);
% x: duree entre la fin de la sequence et la fin du son



%add 5 ms rise/fall time ===================================
function s=addenv(s1,fs);
f=ones(size(s1));
pn=round(fs*0.005);    % 5 ms rise/fall time 
up = sin(2*pi*(0:pn-1)/(4*pn)).^2;   %add sinramp
down = sin(2*pi*(pn+1:2*pn)/(4*pn)).^2;
f = [up ones(1,length(s1)-2*pn) down]';
s=s1(:).*f(:);

%create Event structure======================================
function ev=ev_struct(ev,Name,PreStim,Duration,PostStim);
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


%============================================= 
function [x] = dosynth(freqs,amps,phase,d,fs);
% function [x] = dosynth(freqs,amps,phase,d,fs);
% freqs: list of frequencies;
% amps: list of amplitudes
% phase: list of phases (in radian)
% d: duration
% fs: sampling frequency

t = [0:1/fs:d-1/fs];
x = zeros(size(t));
for i = 1:1:length(freqs);
	x = x+amps(i)*cos(2*pi*freqs(i)*t+phase(i));
end
    
%=============================================
function [xr] = ramp(x,rtime,fs);
% [xr] = ramp(x,rtime,fs);
% rtime in seconds!!

lt = length(x);
tr = [0:1/fs:rtime-1/fs];
lr = length(tr);
rampup = ((cos(2*pi*tr/rtime/2+pi)+1)/2).^2; 
rampdown = ((cos(2*pi*tr/rtime/2)+1)/2).^2; 
xr = x;
xr(:,1:lr) = rampup.*x(:,1:lr);
xr(:,lt-lr+1:lt) = rampdown.*x(:,lt-lr+1:lt);

%============================================================
function [r] = rms(x)

if size(x,1)>size(x,2)
  x = x';
end

if size(x,1) == 1
  r = sqrt(x*x'/size(x,2));
else
  r(1) = sqrt(x(1,:)*x(1,:)'/size(x,2));
  r(2) = sqrt(x(2,:)*x(2,:)'/size(x,2));
end


