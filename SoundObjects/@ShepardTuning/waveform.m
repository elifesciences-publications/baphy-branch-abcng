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
% Random stream for drawing the random sequences
Base = 12;
switch P.PitchSteps
  case {12,24,48,96}; MaxExp = round(log2(P.PitchSteps/Base))+1;
  otherwise error('Steps not implemented, to keep randomization incremental. Choose from [12,24,48,96].'); 
end
Pitches = [0:1/Base:(Base-1)/Base]; Lengths(1) = length(Pitches);
for i=2:MaxExp
  cBase = Base*2^(i-1);
  NewPitches = [1/cBase:2/cBase:(cBase-1)/cBase];
  Lengths(i) = length(NewPitches);
  Pitches = [Pitches,NewPitches];
end
Pitches = Pitches*12;

% RANDOMIZE SEQUENCE
R = RandStream('swb2712','Seed',Index*pi); cStart = 0;
for i=1:MaxExp
  cInd = [cStart+1:cStart+Lengths(i)];
  [~,cPerm] = sort(R.rand(Lengths(i),1)); % Code from randperm to use RandStream
  PitchSequence(cInd) = Pitches(cInd(cPerm));
  cStart = cStart + Lengths(i);
end
o = set(o,'LastPitchSequence',PitchSequence);
Seeds = Index*PitchSequence; % Ensures that phases are randomized across Position, Index and Frequency (in buildShepardTone)
o = set(o,'LastSeeds',Seeds);

% ADD STIMULI AND EVENTS
% uses phase and duration of the blocks
w = [ ]; ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); 
if exist('Mode','var') && strcmp(Mode,'Simulation') return; end

% FIRST BUILD BIAS ('REFERENCE')
P.Durations = P.StimDur; P.PitchClasses = 0;
TotalDurations = get(o,'Duration');
w = zeros(round(TotalDurations(Index)*SR),1); k=round(PreStimSilence*SR);
for i=1:P.PitchSteps
  P.PitchClassShift = PitchSequence(i);
  cBlock = buildShepardTone(P,SR,Seeds(i));
  cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
  w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
  ev = AddEvent(ev,['STIM , ShepardTone ',num2str(Index),' - ',num2str(i)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.Durations);
  cBlock = zeros(round(P.PauseDur*SR),1);
  w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
  ev = AddEvent(ev,['PAUSE , ShepardTone ',num2str(Index),' - ',num2str(i)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.PauseDur);
end
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