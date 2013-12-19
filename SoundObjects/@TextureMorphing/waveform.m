function [ w , ev , O , D0 , ChangeD] = waveform(O,Index,IsFef,Mode,Global_TrialNb)
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
Par = get(O,'Par');
FrozenPatternsNb = Par.FrozenPatternsNb;
if FrozenPatternsNb == 0; Mode = 'NoFrozen'; end
StimulusBisDuration = Par.StimulusBisDuration;
FrequencySpace = Par.FrequencySpace;
XDistri = Par.XDistri;
FrequencyRange_LB = Par.FrequencyRange_LB;
FrequencyRange_UB = Par.FrequencyRange_UB;
FO = Par.F0;
OctaveNb = Par.OctaveNb;
FrozenPatternDuration = Par.FrozenPatternDuration;
AfterChangeSoundDuration = StimulusBisDuration;

% CHECK WHETHER Index EXCEEDED AVAILABLE INDICES
MaxIndex = get(O,'MaxIndex');
if Index > MaxIndex; error('Number of available Stimuli exceeded'); end
% CURRENT REPETITION NB
CurrentRepetitionNb = ceil(Global_TrialNb/MaxIndex);

% GENERATE Timing of Change [ToC]
RToC = RandStream('mrg32k3a','Seed',IniSeed*Global_TrialNb);   % mcg16807 is fucked up
lambda = 0.15; 
ToC = PoissonProcessPsychophysics(lambda,Par.MaxToC-Par.MinToC,1,RToC);
ToC = ToC + Par.MinToC;

% GET PARAMETERS OF CURRENT Index
tmp = get(O,'DistributionTypeByInd'); ChangedD_Num = tmp(Index);
tmp = get(O,'MorphingTypeByInd'); MorphingNum = tmp(Index);
tmp = get(O,'DifficultyLvlByInd'); DifficultyNum = tmp(Index);
tmp = get(O,'ReverseByInd'); Reverse = tmp(Index); 
Bins2Change = get(O,'Bins2Change');

% DO
PlotDistributions = 0;
D0type = Par.D0shape;

% D0/D1/D2 -- DRAW DISTRIBUTIONS FOR EACH CHANGED DISTRIBUTION
Dtype = getfield(Par,['D' num2str(ChangedD_Num) 'shape']);   
DifficultyLvl = getfield(Par,['DifficultyLvl_D' num2str(ChangedD_Num)]);
DiffLvl = DifficultyLvl(DifficultyNum);       % given in %
    
D0param = [FO OctaveNb Par.IniSeed Global_TrialNb];
Dparam = [D0param(1:end-2) Bins2Change{ChangedD_Num}(MorphingNum,:)];    % We don't need a Seed to modify the original distribution
[D0,ChangeD] = BuildMorphing(D0type,Dtype,D0param,Dparam,XDistri,MorphingNum,DiffLvl,PlotDistributions,sF,FrequencySpace);

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

% PREPARE THE 2 Parts OF THE WHOLE STIMULUS
if not(Reverse) && not( strcmp(Mode,'NoFrozen') )
    FirstPart = [ FrozenPattern' Stimulus0 ];     SecondPart = StimulusBis;
    StimulusOrderStr = 'S0Sbis';
elseif Reverse
    FirstPart = StimulusBis;      SecondPart = Stimulus0;
    StimulusOrderStr = 'SbisS0';
elseif not(Reverse) && strcmp(Mode,'NoFrozen')
    FirstPart = Stimulus0;     SecondPart = StimulusBis;
    StimulusOrderStr = 'S0Sbis';
end

% ATTENUATE THE FIRST PART OF THE STIMULUS
if Par.AttenuationD0~=0
  % No need of  <LoudnessAdjusted>=1 because it is the maxstd that is used for fixing the loudness in IOLoadSound.m
  NormFactor = maxLocalStd(SecondPart,sF,length(SecondPart)/sF);
  RatioToDesireddB = 10^(Par.AttenuationD0/20);   % dB to ratio in SPL
  FirstPart = FirstPart*RatioToDesireddB/NormFactor;
end
w = [FirstPart' ; SecondPart'];
w = [zeros((PreStimSilence*sF),size(w,2)) ; w ; zeros((PostStimSilence*sF),size(w,2))];

% ROVING LOUDNESS IN CASE OF PSYCHOPHYSICS
if strcmp('yes',get(O,'RovingLoudness'))
  global LoudnessAdjusted; LoudnessAdjusted  = 1;
  NormFactor = maxLocalStd(w,sF,floor(length(w)/sF));
  
  RovingLoudnessSeed = IniSeed*Global_TrialNb*Index;
  RgeneRovingLoudness = RandStream('mrg32k3a','Seed',RovingLoudnessSeed);
  PickedUpLoudness = -(RgeneRovingLoudness.randi(21) - 1);  % Roving between -20 and +0dB
  RatioToDesireddB = 10^(PickedUpLoudness/20);   % dB to ratio in SPL
  w = w*RatioToDesireddB/NormFactor;
end

% ADD EVENTS
ev=[]; ev = AddEvent(ev,[''],[],0,PreStimSilence); 
if exist('Mode','var') && strcmp(Mode,'Simulation'); return; end

ev = AddEvent(ev,['STIM , ' StimulusOrderStr ' ' num2str(Index),' - ',num2str(Global_TrialNb) ' - ' num2str(ChangedD_Num) ' - ' num2str(MorphingNum) ' - ' num2str(DifficultyNum) ' - ' num2str(FrozenPatternNum) ' - ' num2str(ToC)],...
  [ ],ev(end).StopTime,ev(end).StopTime+FrozenPatternDuration+ToC);

[a,b,c]  = ParseStimEvent(ev(2),0);
ev(1).Note = ['PreStimSilence ,' b ',' c];
[a,b,c]  = ParseStimEvent(ev(end),0); 
ev = AddEvent(ev,['PostStimSilence ,' b ',' c],[],ev(end).StopTime,ev(end).StopTime+AfterChangeSoundDuration+PostStimSilence);

