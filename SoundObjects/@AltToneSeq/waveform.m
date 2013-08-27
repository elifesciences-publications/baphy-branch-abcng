function [ w , ev , o ] = waveform(o,Index,IsRef,Mode);
% Waveform generator for the class ShepardTuning
% See main file for how the Index selects the stimuli
%
% benglitz 2010

% GET PARAMETERS
SR = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
P = get(o,'Par');

% CHECK WHETHER Index EXCEEDED AVAILABLE INDICES
MaxIndex = get(o,'MaxIndex');
if Index > MaxIndex error('Number of available Stimuli exceeded'); end

% GET PARAMETERS OF CURRENT Index

% ADD STIMULI AND EVENTS
% uses phase and duration of the blocks
w = [ ]; ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); 
if exist('Mode','var') && strcmp(Mode,'Simulation') return; end

% FIRST BUILD BIAS ('REFERENCE')
TotalDurations = get(o,'Duration');
w = zeros(round(TotalDurations(Index)*SR),1); k=round(PreStimSilence*SR);

cBlock = LF_buildTone(P.FrequencyTone,P.ToneDur,1,SR);
cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
ev = AddEvent(ev,['STIM , Tone ',num2str(Index),' - ',num2str(1)],...
  [ ],ev(end).StopTime,ev(end).StopTime+P.ToneDur);
cBlock = zeros(round(P.AfterTonePause*SR),1);
w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
ev = AddEvent(ev,['PAUSE , Tone ',num2str(Index),' - ',num2str(1)],...
  [ ],ev(end).StopTime,ev(end).StopTime+P.AfterTonePause);

for i=1:P.NTonesSeq
  cBlock = LF_buildTone(P.FrequencySeq,P.SeqToneDur,1,SR);
  cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
  w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
  ev = AddEvent(ev,['STIM , Tone ',num2str(Index),' - ',num2str(i+1)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.ToneDur);
  cBlock = zeros(round(P.WithinSeqPause*SR),1);
  w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
  ev = AddEvent(ev,['PAUSE , Tone ',num2str(Index),' - ',num2str(i+1)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.WithinSeqPause);
end

cBlock = zeros(round((P.AfterSeqPause-P.WithinSeqPause)*SR),1);
w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
ev = AddEvent(ev,['PAUSE , Tone ',num2str(Index),' - ',num2str(i+2)],...
  [ ],ev(end).StopTime,ev(end).StopTime+P.AfterSeqPause-P.WithinSeqPause);
cBlock = LF_buildTone(P.FrequencyTone,P.ToneDur,1,SR);
cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
ev = AddEvent(ev,['STIM , Tone ',num2str(Index),' - ',num2str(i+2)],...
  [ ],ev(end).StopTime,ev(end).StopTime+P.ToneDur);

[a,b,c]  = ParseStimEvent(ev(2),0);
ev(1).Note = ['PreStimSilence ,' b ',' c];
[a,b,c]  = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence ,' b ',' c],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);
RequestedDuration = get(o,'Duration');
if ~isnan(RequestedDuration) % if Duration was set to a numeric value
 % if round(RequestedDuration*SR) > length(wr) + length(wt)
%    error('Requested stimulus length longer than stimulus actually produced!');
%  end
end

function Tone =  LF_buildTone(F,Dur,A,SR)

Time = [0:1/SR:Dur];
Tone = A*sin(2*pi*F*Time);

