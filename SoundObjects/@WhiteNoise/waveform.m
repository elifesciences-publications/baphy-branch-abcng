function [ w , ev , o ] = waveform(o,Index,IsReference,Mode);
% Waveform generator for the class WhiteNoise
% See main file for how the Index selects the stimuli
%
% benglitz 2013

% GET PARAMETERS
SR = get(o,'SamplingRate');
PreStimSilence = get(o,'PreStimSilence');
PostStimSilence = get(o,'PostStimSilence');
P = get(o,'Par');

% CHECK WHETHER Index EXCEEDED AVAILABLE INDICES
MaxIndex = get(o,'MaxIndex');
if Index > MaxIndex error('Number of available Stimuli exceeded'); end

w=[]; ev=[]; if exist('Mode','var') && strcmp(Mode,'Simulation') return; end

%% ADD STIMULI AND EVENTS
TotalDurations = get(o,'Duration');
w = zeros(round(TotalDurations(Index)*SR),1); 
k=round(PreStimSilence*SR); ev = AddEvent(ev,['PreStimSilence'],[],0,PreStimSilence); 

StimSteps = P.StimDuration*SR;
w(k+1:k+StimSteps) = randn(StimSteps,1);
ev = AddEvent(ev,['STIM , Noise ',num2str(Index)],...
    [ ],ev(end).StopTime,ev(end).StopTime+P.StimDuration);

[a,b,c]  = ParseStimEvent(ev(2),0);
ev(1).Note = ['PreStimSilence ,' b ',' c];
[a,b,c]  = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence ,' b ',' c],[],ev(end).StopTime,ev(end).StopTime+PostStimSilence);
if ~isnan(TotalDurations(Index)) % if Duration was set to a numeric value
 % if round(RequestedDuration*SR) > length(wr) + length(wt)
%    error('Requested stimulus length longer than stimulus actually produced!');
%  end
end