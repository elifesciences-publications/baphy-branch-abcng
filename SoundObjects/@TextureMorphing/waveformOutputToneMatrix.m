function [ w , ev , O , FrozenToneMatrix,S1Matrix,S2Matrix] = waveformOutputToneMatrix(O,Index,IsFef,Mode,Global_TrialNb,GenerateFrozen)
% Waveform generator for the class TextureMorphing
% See main file for how the Index selects the stimuli
% Adapted from BiasedShepardPair - Yves 2013
% <Index> is the local random index (used for picking up conditions within 
%a repetition [of all conditions]) whereas <Global_TrialNb> is the ordered index 
%at the scale of the whole session

FrozenToneMatrix = [];
if nargin<6; GenerateFrozen = 0; end
% GET PARAMETERS
sF = get(O,'SamplingRate');
PreStimSilence = get(O,'PreStimSilence');
PostStimSilence = get(O,'PostStimSilence');
IniSeed = get(O,'IniSeed');
FrozenPatternsAdress = get(O,'FrozenPatternsAdress');
P = get(O,'Par');
FrozenPatternsNb = P.FrozenPatternsNb;
if FrozenPatternsNb == 0; Mode = 'NoFrozen'; end
Stimulus2Duration = P.Stimulus2Duration;
FrequencySpace = P.FrequencySpace;
XDistri = P.XDistri;
D1 = get(O,'D1');
MergedD_KeepBody = get(O,'MergedD_KeepBody');
MergedD_KeepTails = get(O,'MergedD_KeepTails');
Par = get(O,'Par'); D1MinimalDuration = Par.D1MinimalDuration;
AfterChangeSoundDuration = Stimulus2Duration;

% CHECK WHETHER Index EXCEEDED AVAILABLE INDICES
MaxIndex = get(O,'MaxIndex');
if Index > MaxIndex; error('Number of available Stimuli exceeded'); end
% CURRENT REPETITION NB
CurrentRepetitionNb = ceil(Global_TrialNb/MaxIndex);

% GENERATE Timing of Change [ToC]
RToC = RandStream('mrg32k3a','Seed',IniSeed*Global_TrialNb);   % mcg16807 is fucked up
lambda = 0.15; 
ToC = PoissonProcessPsychophysics(lambda,P.MaxToC,1,RToC);

% GET PARAMETERS OF CURRENT Index
tmp = get(O,'MorphingTypeByInd'); MorphingType = tmp(Index); MorphingNb = max(tmp);
tmp = get(O,'DifficultyLvlByInd'); DifficultyNum = tmp(Index);
tmp = get(O,'ReverseByInd'); Reverse = tmp(Index); 

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

if not(GenerateFrozen)
    load([ FrozenPatternsAdress filesep 'FrozenPatterns.mat' ]);
    load([ FrozenPatternsAdress filesep 'FrozenToneMatrices.mat' ]);
    FrozenPattern = FrozenPatterns{FrozenPatternNum};
    FrozenToneMatrix = FrozenToneMatrices{FrozenPatternNum};
end

if Reverse
    Stimulus1Duration = Stimulus2Duration;
    Stimulus2Duration = ToC + D1MinimalDuration;  % frozen patterns last D1MinimalDuration
    FrozenPatternNum = 0;
elseif not(Reverse) && not( strcmp(Mode,'NoFrozen') )
    Stimulus1Duration = ToC;
elseif not(Reverse) && strcmp(Mode,'NoFrozen')
    Stimulus1Duration = ToC + D1MinimalDuration;
    FrozenPatternNum = 0;
end
    
if MorphingNb >2
    MergedD = MergedD_KeepBody{DifficultyNum,MorphingType};
elseif MorphingType ==1
    MergedD = MergedD_KeepBody{DifficultyNum};
elseif MorphingType ==2
    MergedD = MergedD_KeepTails{DifficultyNum};
end

% BUILD D1 STIMULUS ('REFERENCE' located in the TARGET)
%AND D2 STIMULUS ('TARGET' located in the TARGET)
% Random stream to draw tones for each distribution
PlotDistributions = 0;
RtonesD1 = RandStream('mrg32k3a','Seed',Global_TrialNb*Index);
Stimulus1 = AssemblyTones(FrequencySpace,D1,XDistri,Stimulus1Duration,sF,PlotDistributions,[],RtonesD1); 

RtonesD2 = RandStream('mrg32k3a','Seed',Global_TrialNb*Index*2);
Stimulus2 = AssemblyTones(FrequencySpace,MergedD,XDistri,Stimulus2Duration,sF,PlotDistributions,[],RtonesD2);

% TEMP. SINCE I HAVEN'T GENERATED FROZEN PATTERNS YET
if GenerateFrozen
    [FrozenPattern , FrozenToneMatrix] = AssemblyTones(FrequencySpace,D1,XDistri,2,sF,PlotDistributions,[],RtonesD1);
end

% CONCATENATE THE WHOLE STIMULUS
if not(Reverse) && not( strcmp(Mode,'NoFrozen') )
    w = [FrozenPattern Stimulus1 Stimulus2]; StimulusOrderStr = 'S1S2';
elseif Reverse
    w = [Stimulus2 Stimulus1]; StimulusOrderStr = 'S2S1';
elseif not(Reverse) && strcmp(Mode,'NoFrozen')
    w = [Stimulus1 Stimulus2]; StimulusOrderStr = 'S1S12';
end
% No NORMALIZATION of amplitude because it is done in waveform.m
w = w';    % column shape
w = [zeros((PreStimSilence*sF),size(w,2)) ; w ; zeros((PostStimSilence*sF),size(w,2))];

% ADD EVENTS
ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); 
if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end

if not(Reverse) && not( strcmp(Mode,'NoFrozen') ); FrozenPatternDuration = (length(FrozenPattern)-1)/sF; else FrozenPatternDuration = D1MinimalDuration; end
ev = AddEvent(ev,['STIM , ' StimulusOrderStr ' ' num2str(Index),' - ',num2str(Global_TrialNb) ' - ' num2str(MorphingType) ' - ' num2str(DifficultyNum) ' - ' num2str(FrozenPatternNum) ' - ' num2str(ToC)],...
  [ ],ev(end).StopTime,ev(end).StopTime+FrozenPatternDuration+ToC);

[a,b,c]  = ParseStimEvent(ev(2),0);
ev(1).Note = ['PreStimSilence ,' b ',' c];
[a,b,c]  = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence ,' b ',' c],[],ev(end).StopTime,ev(end).StopTime+AfterChangeSoundDuration+PostStimSilence);


