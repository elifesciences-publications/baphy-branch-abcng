function [ w , ev , O ] = waveform(O,Index,IsFef,Mode,Global_TrialNb)
% Waveform generator for the class TextureMorphing
% See main file for how the Index selects the stimuli
% Adapted from BiasedShepardPair - Yves 2013
% <Index> is the local random index (used for picking up conditions within 
%a repetition [of all conditions]) whereas <Global_TrialNb> is the ordered index 
%at the scale of the whole session

% GET PARAMETERS
sF = get(O,'SamplingRate');
PreStimSilence = get(O,'PreStimSilence');
PostStimSilence = get(O,'PostStimSilence');
IniSeed = get(O,'IniSeed');
FrozenPatternsAdress = get(O,'FrozenPatternsAdress');
P = get(O,'Par');
FrozenPatternsNb = P.FrozenPatternsNb;
if FrozenPatternsNb == 0; Mode = 'NoFrozen'; end
StimulusBisDuration = P.StimulusBisDuration;
FrequencySpace = P.FrequencySpace;
XDistri = P.XDistri;
D0 = get(O,'D0');
Par = get(O,'Par'); FrozenPatternDuration = Par.FrozenPatternDuration;
AfterChangeSoundDuration = StimulusBisDuration;

% CHECK WHETHER Index EXCEEDED AVAILABLE INDICES
MaxIndex = get(O,'MaxIndex');
if Index > MaxIndex; error('Number of available Stimuli exceeded'); end
% CURRENT REPETITION NB
CurrentRepetitionNb = ceil(Global_TrialNb/MaxIndex);

% GENERATE Timing of Change [ToC]
RToC = RandStream('mrg32k3a','Seed',IniSeed*Global_TrialNb);   % mcg16807 is fucked up
lambda = 0.15; 
ToC = PoissonProcessPsychophysics(lambda,P.MaxToC-P.MinToC,1,RToC);
ToC = ToC + P.MinToC;

% GET PARAMETERS OF CURRENT Index
tmp = get(O,'DistributionTypeByInd'); DistributionType = tmp(Index);
tmp = get(O,'MorphingTypeByInd'); MorphingType = tmp(Index);
tmp = get(O,'DifficultyLvlByInd'); DifficultyNum = tmp(Index);
tmp = get(O,'ReverseByInd'); Reverse = tmp(Index); 

% LOAD THE DESIRED Changed Distributions
ChangeDistributions = get(O,['D' num2str(DistributionType)]);
if size(ChangeDistributions,3) < 2
    D0 = D0{1};
    ChangeD = ChangeDistributions{DifficultyNum,MorphingType,1};
else % case where there is a unique distribution for each trial
    IniDistriNum = mod(Global_TrialNb-1,size(ChangeDistributions,3))+1;  % UniqueIniDistriNum could be < Global_TrialNb
	D0 = D0{IniDistriNum};
    ChangeD = ChangeDistributions{DifficultyNum,MorphingType,IniDistriNum};
end

% GENERATE SEQUENCES OF FROZEN PATTERNS // LOAD THE APPROPRIATE ONE
if not( strcmp(Mode,'NoFrozen') )
    FrozenRepetitionNb = ceil(MaxIndex*CurrentRepetitionNb/FrozenPatternsNb);
    FrozenPatternsSequence = zeros(1,FrozenRepetitionNb*FrozenPatternsNb);
    for RepNum = 1:FrozenRepetitionNb
        Rfrozen = RandStream('mt19937ar','Seed',IniSeed*RepNum);
        reset(Rfrozen)
        FrozenPatternsSequence(1,(RepNum-1)*FrozenPatternsNb + (1:FrozenPatternsNb)) = Rfrozen.randperm(FrozenPatternsNb);
    end
    if Global_TrialNb<=length(FrozenPatternsSequence)
        FrozenPatternNum = FrozenPatternsSequence(Global_TrialNb);
    else % if more global trials than expected in the sequence, we loop
        FrozenPatternNum = FrozenPatternsSequence(mod(Global_TrialNb,length(FrozenPatternsSequence)));
    end
    load([ FrozenPatternsAdress filesep 'FrozenPatterns.mat' ]);
    FrozenPattern = FrozenPatterns{FrozenPatternNum};
end

if Reverse
    Stimulus0Duration = StimulusBisDuration;
    StimulusBisDuration = ToC + FrozenPatternDuration;
    FrozenPatternNum = 0;
elseif not(Reverse) && not( strcmp(Mode,'NoFrozen') )
    Stimulus0Duration = ToC;
elseif not(Reverse) && strcmp(Mode,'NoFrozen')
    Stimulus0Duration = ToC + FrozenPatternDuration;
    FrozenPatternNum = 0;
end

% BUILD D0 STIMULUS ('REFERENCE' located in the TARGET)
%AND Dbis STIMULUS ('TARGET' located in the TARGET)
% Random stream to draw tones for each distribution
PlotDistributions = 0;
RtonesD0 = RandStream('mrg32k3a','Seed',Global_TrialNb*Index);
Stimulus0 = AssemblyTones(FrequencySpace,D0,XDistri,Stimulus0Duration,sF,PlotDistributions,[],RtonesD0); 

RtonesD = RandStream('mrg32k3a','Seed',Global_TrialNb*Index*2);
StimulusBis = AssemblyTones(FrequencySpace,ChangeD,XDistri,StimulusBisDuration,sF,PlotDistributions,[],RtonesD);

% CONCATENATE THE WHOLE STIMULUS
if not(Reverse) && not( strcmp(Mode,'NoFrozen') )
    w = [FrozenPattern' Stimulus0 StimulusBis]; StimulusOrderStr = 'S0Sbis';
elseif Reverse
    w = [StimulusBis Stimulus0]; StimulusOrderStr = 'SbisS0';
elseif not(Reverse) && strcmp(Mode,'NoFrozen')
    w = [Stimulus0 StimulusBis]; StimulusOrderStr = 'S0Sbis';
end

% % RAMP FOR FERRET TRAINING
% if  strcmp('yes',get(O,'RampFirstSound'))
%     RampDuration = ToC;
%     ramp = hanning(round(RampDuration * sF*2));
%     ramp = ramp(1:floor(length(ramp)/2))';
%     ramp = [ramp ones(1,length(w)-length(ramp))];
%     w = w.*ramp;
% end

% NORMALIZE IT TO +/-5V
AverageNbTonesChord = round(2*log(FrequencySpace(end)/FrequencySpace(1))/log(2));    % Average of 2 tones per octave (cf. Ahrens 2008) / see AssemblyTones.m
w = w*5/AverageNbTonesChord;
w = w';    % column shape
w = [zeros((PreStimSilence*sF),size(w,2)) ; w ; zeros((PostStimSilence*sF),size(w,2))];

% ROVING LOUDNESS IN CASE OF PSYCHOPHYSICS
if strcmp('yes',get(O,'RovingLoudness'))
    RovingLoudnessSeed = IniSeed*Global_TrialNb*Index;
    RgeneRovingLoudness = RandStream('mrg32k3a','Seed',RovingLoudnessSeed);
    PickedUpLoudness = RgeneRovingLoudness.randi(21) - 11;  % Roving between -10 and +10dB
    RatioTo80dB = 10^(PickedUpLoudness/10);   % dB to ratio in SPL
    w = w*RatioTo80dB;
end

% ADD EVENTS
ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); 
if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end

ev = AddEvent(ev,['STIM , ' StimulusOrderStr ' ' num2str(Index),' - ',num2str(Global_TrialNb) ' - ' num2str(DistributionType) ' - ' num2str(MorphingType) ' - ' num2str(DifficultyNum) ' - ' num2str(FrozenPatternNum) ' - ' num2str(ToC)],...
  [ ],ev(end).StopTime,ev(end).StopTime+FrozenPatternDuration+ToC);

[a,b,c]  = ParseStimEvent(ev(2),0);
ev(1).Note = ['PreStimSilence ,' b ',' c];
[a,b,c]  = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence ,' b ',' c],[],ev(end).StopTime,ev(end).StopTime+AfterChangeSoundDuration+PostStimSilence);

