function o = TextureMorphing(varargin)
% TextureMorphing produces a morphing between cloud of tones drawn from 2
% different distributions
%
% Yves 2013

% Initial Set of Trials (for the moment: Bernhard):
% Index selects between 20 Indices
% 4 Pitchclasses for the Biasing Region
% 5 Randomizations
% 24 TestPitches
% 10 Repetitions
%
% Length of each presentation 5*24*0.15 = 18s


switch nargin
  case 0  % if no input arguments, create a default object

    Fields = {...
      'D0shape','popupmenu','uniform|random_spectra|quantal_random_spectra',...
      'FrequencyRange','edit','400;1840',...
      'D1shape','popupmenu','contig_increm|non_contig_increm',...
      'DifficultyLvl_D1','edit','150',...
      'D1param','edit','[]',...                % in case we need extra params
      'D2shape','popupmenu','contig_increm|non_contig_increm',...
      'DifficultyLvl_D2','edit','110',...
      'D2param','edit','2 3 5 7',...           % in case we need extra params
      'Inverse_D0Dbis','popupmenu','no|yes',...
      'MinToC','edit','0',...
      'MaxToC','edit','8',...
      'StimulusBisDuration','edit','2',...
      'FrozenPatternsAdress','popupmenu','C:\Code\baphy\UtilitiesYves\FrozenPatterns|/home/yves/baphy/UtilitiesYves/FrozenPatterns|C:\Users\Booth1\Dropbox\FrozenPatterns',...
      'FrozenPatternsNb','edit','0',...
      'RovingLoudness','popupmenu','no|yes',...
      'AttenuationD0','edit','0'};  
  
    s = SoundObject ('TextureMorphing',100000, 0,0.4, 0, {''}, 1, Fields);
    for i=1:length(Fields)/3; o.(Fields{(i-1)*3+1}) = Fields{i*3}; end
    o.Fields = Fields;
    o.FieldNames = Fields(1:3:end-2); 
    o.FieldTypes = Fields(2:3:end-1);
    o.MaxIndex = 0;
    o.RunClass = 'TMG'; o.Duration = NaN;

    o.FrequencySpace = []; o.XDistri = []; o.F0 = [];
    o.IniSeed = []; o.MorphingDuration = [];
    o.DistributionTypeByInd = []; o.MorphingTypeByInd = []; o.DifficultyLvlByInd = []; o.ReverseByInd = [];
    o.MorphingNb = []; o.Bins2Change = []; o.ChannelDistancesByMorphing = [];
    o.AllTargetPositions = []; o.CurrentTargetPositions = [];
    
    o.Names = {};
    o.Ranges = {}; o.VarFieldNames = {};  o.VarFieldInds = []; o.Par = [];    o = class(o,'TextureMorphing',s);
    o = ObjUpdate(o);
  case 1 % if single argument of class SoundObject, return it
    if isa(varargin{1},'SoundObject')   s = varargin{1};
    else        error('Wrong argument type');     end
  otherwise error('Wrong number of input arguments');
end

% List of places where IniSeed (generated in ObjUpdate) is used:
%-- <IniSeed> sent to [BuildMorphing/DrawDistribution] for genesis of random D0s or block of 8x8 block of D0s (in the latter case, multiplied by <BlockNb>)
%-- <IniSeed*Global_TrialNb> sent to [waveform/PoissonProcessPsychophysics] for picking up ToC
%-- <IniSeed*RepNum> sent to [waveform] for generating the <FrozenPatternsSequence> [only if not( strcmp(Mode,'NoFrozen') ) ]
%-- <Global_TrialNb*Index> sent to [waveform/AssemblyTones] for generating the tone frequency according to D0 + nb of tones in each octave
%-- <Global_TrialNb*Index*2> sent to [waveform/AssemblyTones] for generating the tone frequency according to ChangeD + nb of tones in each octave
%-- <IniSeed*Global_TrialNb*Index> sent to [waveform] for roving loudness
