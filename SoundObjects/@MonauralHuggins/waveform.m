function [ w , ev , O ] = waveform(O,Index,IsRef,Mode);
% Waveform generator for the class ShepardTuning
% See main file for how the Index selects the stimuli
%
% benglitz 2010

% GET PARAMETERS
SR = get(O,'SamplingRate');
PreStimSilence = get(O,'PreStimSilence');
PostStimSilence = get(O,'PostStimSilence');
P = get(O,'Par');

% CHECK WHETHER Index EXCEEDED AVAILABLE INDICES
MaxIndex = get(O,'MaxIndex');
if Index > MaxIndex error('Number of available Stimuli exceeded'); end

% GET PARAMETERS OF CURRENT Index
cFrequency = P.Frequencies(Index);

% ADD STIMULI AND EVENTS
% uses phase and duration of the blocks
w = [ ]; ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); 
if exist('Mode','var') && strcmp(Mode,'Simulation') return; end

% FIRST BUILD BIAS ('REFERENCE')
TotalDurations = get(O,'Duration');
w = zeros(round(TotalDurations(Index)*SR),1); k=round(PreStimSilence*SR);

[cBlock,Profile] = MonHuPsycho(cFrequency,P.AngularFrequency,P.Density,P.StimDur,SR,P.ModulationDepth,0);
w(k+1:k+length(cBlock)) = cBlock;
w = 5*w/max(w);
ev = AddEvent(ev,['STIM , MonauralHuggins ',num2str(Index),' - ',num2str(i)],...
  [ ],ev(end).StopTime,ev(end).StopTime+P.StimDur);

[a,b,c]  = ParseStimEvent(ev(2),0);
ev(1).Note = ['PreStimSilence ,' b ',' c];
[a,b,c]  = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence ,' b ',' c],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);

