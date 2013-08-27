function [ w , ev , O ] = waveform(O,Index,IsRef,Mode);
% Waveform generator for the class BiasedShepardPair
% See main file for how the Index selects the stimuli
%
% benglitz 2010

% GET PARAMETERS
SR = get(O,'SamplingRate');
PreStimSilence = get(O,'PreStimSilence');
PostStimSilence = get(O,'PostStimSilence');
P = get(O,'Par');
NPitchClasses = length(P.PitchClasses);
NBiasDirections = length(P.BiasDirections);
P.Biases = repmat(1,1,P.NBiases);

% CHECK WHETHER Index EXCEEDED AVAILABLE INDICES
MaxIndex = get(O,'MaxIndex');
if Index > MaxIndex error('Number of available Stimuli exceeded'); end

% GET PARAMETERS OF CURRENT Index
tmp = get(O,'NBiasStimByIndex'); cNBiasStims = tmp(Index); 
tmp = get(O,'PitchClassByIndex'); cPitchClass = tmp(Index); 
tmp = get(O,'BiasByIndex'); cBias = tmp(Index); 
tmp = get(O,'BiasDirectionByIndex'); cBiasDirection = tmp(Index); 
O = set(O,'LastBiasDirection',cBiasDirection);

% FIRST BUILD BIAS ('REFERENCE')
% Random stream for drawing the bias offsets
R = RandStream('mrg32k3a','Seed',Index*10);
Shifts = R.rand(cNBiasStims,1);
Shifts = cBiasDirection*P.BiasPitchRange*Shifts;
O = set(O,'LastShifts',Shifts);
P.Durations = P.BiasDurations;
P.PitchClasses = cPitchClass;

% ADD STIMULI AND EVENTS
% uses phase and duration of the blocks
w=[]; ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); 
if exist('Mode','var') && strcmp(Mode,'Simulation') return; end

TotalDurations = get(O,'Duration');
w = zeros(round(TotalDurations(Index)*SR),1); k=round(PreStimSilence*SR);

for i=1:cNBiasStims
  P.PitchClassShift = Shifts(i);
  cBlock = buildShepardTone(P,SR);
  cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
  w(k+1:k+length(cBlock)) = w(k+1:k+length(cBlock)) + cBlock; 
  k = k+round(P.BiasDurations*SR);
  ev = AddEvent(ev,['STIM , ShepardTone ',num2str(Index),' - ',num2str(i)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.Durations);
  if i<cNBiasStims
    k = k + round(P.BetweenBiasPause*SR);
    ev = AddEvent(ev,['PAUSE , ShepardTone ',num2str(Index),' - ',num2str(i)],...
      [ ],ev(end).StopTime,ev(end).StopTime+P.BetweenBiasPause);
  end
end
k = k + round(P.AfterBiasPause*SR);
ev = AddEvent(ev,['PAUSE , ShepardTone ',num2str(Index),' - ',num2str(i)],...
  [ ],ev(end).StopTime,ev(end).StopTime+P.AfterBiasPause);

% THEN BUILD TARGET ('REFERENCE')
P.Durations = P.PairDurations;
P.ComponentJitter = 0;
for i=1:2
  P.PitchClassShift = (i-1)*6;
  cBlock = buildShepardTone(P,SR);
  cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
  w(k+1:k+length(cBlock)) = w(k+1:k+length(cBlock)) + cBlock; 
  k = k+round(P.PairDurations*SR);
  ev = AddEvent(ev,['STIM , ShepardTone ',num2str(Index),' - ',num2str(i+cNBiasStims)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.PairDurations);
  if i==1
     k = k + round(P.BetweenPairPause*SR);
    ev = AddEvent(ev,['PAUSE , ShepardTone ',num2str(Index),' - ',num2str(i+cNBiasStims)],...
      [ ],ev(end).StopTime,ev(end).StopTime+P.BetweenPairPause);
  end
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

