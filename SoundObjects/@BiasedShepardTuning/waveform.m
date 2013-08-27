function [ w , ev , o ] = waveform(o,Index,IsRef,Mode);
% Waveform generator for the class BiasedShepardPair
% See main file for how the Index selects the stimuli
%
% benglitz 2010

% GET PARAMETERS
SR = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
P = get(o,'Par');
NBiasBasePitches = length(P.BiasBasePitches);

% CHECK WHETHER Index EXCEEDED AVAILABLE INDICES
MaxIndex = get(o,'MaxIndex');
if Index > MaxIndex error('Number of available Stimuli exceeded'); end

% GET PARAMETERS OF CURRENT INDEX
iBiasBasePitch = ceil(Index/P.Randomizations);
cBiasBasePitch = P.BiasBasePitches(iBiasBasePitch);
cRandomization = mod(Index,P.Randomizations);
if ~cRandomization cRandomization = P.Randomizations; end 
o = set(o,'LastRandomization',cRandomization);

P.PitchClasses = 0; % MAKE ALL PITCHCLASSES ABSOLUTE (SIMPLIFIES ANALYSIS)

% GENERATE BIAS PITCHES FOR THE CURRENT 
% Bias sequences are only randomized for each randomization
% i.e. the same sequences exist for different Pitchclassranges
% Could be useful for averaging and comparing across ranges.
R = RandStream('swb2712','Seed',cRandomization*10*pi);
Sequence = R.rand(P.PitchSteps*P.NBiasStim+P.NBiasLeadIn,1);
BiasPitches = cBiasBasePitch + Sequence*P.BiasPitchRange;
o = set(o,'LastBiasPitches',BiasPitches);
BiasLeadInPitches = BiasPitches(1:P.NBiasLeadIn);
BiasPitches = reshape(BiasPitches(P.NBiasLeadIn+1:end),P.PitchSteps,P.NBiasStim);

% GENERATE TEST PITCHES FOR AN ENTIRE OCTAVE AT DIFFERENT RESOLUTIONS
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

% RANDOMIZE TEST SEQUENCE
R = RandStream('swb2712','Seed',Index*pi); cStart = 0;  TestPerm = [];
for i=1:MaxExp
  cInd = [cStart+1:cStart+Lengths(i)];
  [~,cPerm] = sort(R.rand(Lengths(i),1)); % Code from randperm to use RandStream
  TestPerm = [TestPerm;cPerm];
  TestPitches(cInd) = Pitches(cInd(cPerm));
  cStart = cStart + Lengths(i);
end
o = set(o,'LastTestPitches',TestPitches);
Seeds = cRandomization*[Sequence;TestPerm];
o = set(o,'LastSeeds',Seeds);

% ADD STIMULI AND EVENTS
w = []; ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); iStim = 0;
if exist('Mode','var') && strcmp(Mode,'Simulation') return; end

% BUILD STIMULUS
TotalDurations = get(o,'Duration');
w = zeros(round(TotalDurations(Index)*SR),1); k=round(PreStimSilence*SR);
for iT = 1:P.PitchSteps
  P.Durations = P.BiasDur;
  % ADD LEADIN SEQUENCE FOR ADAPTATION
  if iT == 1
    for i=1:P.NBiasLeadIn
      iStim = iStim + 1;
      P.PitchClassShift = BiasLeadInPitches(i);
      cBlock = buildShepardTone(P,SR,Seeds(iStim));
      cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
      w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
      ev = AddEvent(ev,['STIM , ShepardTone ',num2str(Index)],...
        [ ],ev(end).StopTime,ev(end).StopTime+P.Durations);
      cBlock = zeros(round(P.BetweenBiasPause*SR),1);
      w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
      ev = AddEvent(ev,['PAUSE , ShepardTone ',num2str(Index)],...
        [ ],ev(end).StopTime,ev(end).StopTime+P.BetweenBiasPause);
    end
  end
  
  % FIRST BUILD BIAS
  for i=1:P.NBiasStim
    iStim = iStim + 1;
    P.PitchClassShift = BiasPitches(iT,i);
    cBlock = buildShepardTone(P,SR,Seeds(iStim));
    cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
    w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
    ev = AddEvent(ev,['STIM , ShepardTone ',num2str(Index)],...
      [ ],ev(end).StopTime,ev(end).StopTime+P.Durations);
    if i<P.NBiasStim
      cBlock = zeros(round(P.BetweenBiasPause*SR),1);
      w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
      ev = AddEvent(ev,['PAUSE , ShepardTone ',num2str(Index)],...
        [ ],ev(end).StopTime,ev(end).StopTime+P.BetweenBiasPause);
    end
  end
  cBlock = zeros(round(P.AfterBiasPause*SR),1);
  w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
  ev = AddEvent(ev,['PAUSE , ShepardTone ',num2str(Index)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.AfterBiasPause);
  
  % THEN BUILD TEST
  iStim = iStim + 1;
  P.Durations = P.TestDur;
  P.PitchClassShift = TestPitches(iT);
  cBlock = buildShepardTone(P,SR,Seeds(iStim));
  cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
  w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
  ev = AddEvent(ev,['STIM , ShepardTone ',num2str(Index)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.TestDur);
  cBlock = zeros(round(P.BetweenBiasPause*SR),1);
  w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
  ev = AddEvent(ev,['PAUSE , ShepardTone ',num2str(Index)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.BetweenBiasPause);
end
[a,b,c]  = ParseStimEvent(ev(2),0);
ev(1).Note = ['PreStimSilence ,' b ',' c];
[a,b,c]  = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence ,' b ',' c],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);
if ~isnan(TotalDurations(Index)) % if Duration was set to a numeric value
 % if round(RequestedDuration*SR) > length(wr) + length(wt)
%    error('Requested stimulus length longer than stimulus actually produced!');
%  end
end