function [ w , ev , o ] = waveform(o,Index,IsReference,Mode);
% Waveform generator for the class ShepardPair
% See main file for how the Index selects the stimuli
%
% TODO: 
% - connection with Bias or other stimuli
% - listen to stimuli for testing
%
% benglitz 2010

% GET PARAMETERS
SR = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
P = get(o,'Par');
NPitchClasses = length(P.PitchClasses);

% CORRECT PARAMETER WHITESPACE
cPos = find(P.EnvStyle==' ',1,'first');
if ~isempty(cPos) P.EnvStyle = P.EnvStyle(1:cPos-1); end

% CHECK WHETHER Index EXCEEDED AVAILABLE INDICES
MaxIndex = get(o,'MaxIndex');
if Index > MaxIndex error('Number of available Stimuli exceeded'); end

% GET PARAMETERS OF CURRENT Index
iPitchStep = ceil(Index/NPitchClasses);
cPitchStep = P.PitchSteps(iPitchStep);
iPitchClass = Index - (iPitchStep-1)*NPitchClasses;
cPitchClass = P.PitchClasses(iPitchClass);
Pitches = [cPitchClass,cPitchClass+cPitchStep];
o = set(o,'LastPitchSequence',Pitches);

%% DETERMINE DIRECTION OF PITCH STEP
switch P.EnvStyle
  case {'Constant','Gaussian'};
    Pitches = mod(Pitches,12);
    dPitch = diff(Pitches);
    if (dPitch>0 & dPitch<6) || (dPitch<-6 & dPitch>-12) cDirection = 1;
    elseif (dPitch<0 & dPitch>-6) || (dPitch>6 & dPitch<12) cDirection = -1;
    elseif abs(dPitch) == 6 cDirection = 0;
    else error('Undefined PitchStep!');
    end
  case 'Tones'; cDirection = sign(cPitchStep);
  otherwise error('Envelope Style not implemented');
end

%% SET LOCATION OF THE CORRECT ANSWER
AllTargetPositions = {'left','right'};
switch cDirection
  case -1; cTargetPosition = {'left'};
  case 1; cTargetPosition = {'right'};
  case 0; cTargetPosition = {'left','right'};
  otherwise error('Undefined value for Frequency change direction found!'); 
end
o = set(o,'CurrentTargetPositions',cTargetPosition);
o = set(o,'AllTargetPositions',AllTargetPositions);

w=[]; ev=[]; if exist('Mode','var') && strcmp(Mode,'Simulation') return; end

%% ADD STIMULI AND EVENTS
TotalDurations = get(o,'Duration');
w = zeros(round(TotalDurations(Index)*SR),1); 
k=round(PreStimSilence*SR); ev = AddEvent(ev,['PreStimSilence'],[],0,PreStimSilence); 

P.PitchClasses = 0; 
if length(P.PairDurations)==1 P.PairDurations = [P.PairDurations,P.PairDurations]; end
for i=1:2
  P.PitchClassShift = Pitches(i);
  P.Durations = P.PairDurations(i);
  if P.Durations>0
  cBlock = buildShepardTone(P,SR);
  cBlock = addSinRamp(cBlock,0.002,SR,'<=>');
  w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
  ev = AddEvent(ev,['STIM , ShepardTone ',num2str(Index),' - ',num2str(i)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.PairDurations(i));
  end
  if i==1
    cBlock = zeros(round(P.BetweenPairPause*SR),1);
    w(k+1:k+length(cBlock)) = cBlock; k = k+length(cBlock);
    ev = AddEvent(ev,['PAUSE , ShepardTone ',num2str(Index),' - ',num2str(i)],...
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