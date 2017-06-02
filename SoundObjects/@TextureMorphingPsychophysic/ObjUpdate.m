function o = ObjUpdate(o)
% Update the changes of a MultiStream object - benglitz 2010
% Adapted to TextureMorphing - Yves 2013

FieldNames = get(o,'FieldNames');
FieldTypes = get(o,'FieldTypes');
for i=1:length(FieldNames)
  switch FieldTypes{i}
    case 'edit';
      tmp = get(o,FieldNames{i});
      if ~isnumeric(tmp) tmp = eval(['[',tmp,']']); end
      Par.(FieldNames{i}) = tmp;
    case 'popupmenu';
      StrWithSpaces = get(o,FieldNames{i});
      LastSpaceInd = find(StrWithSpaces==' ',1,'first');
      if ~isempty(LastSpaceInd)
        Par.(FieldNames{i}) = StrWithSpaces(1:(LastSpaceInd-1));
        o = set(o,FieldNames{i},StrWithSpaces(1:(LastSpaceInd-1)));
      else
        Par.(FieldNames{i}) = StrWithSpaces;
      end
    otherwise error('FieldType not implemented!');
  end
end

% Add items previsouly in the user menu
Par.D2shape=get(o,'D2shape');
Par.DifficultyLvl_D2=get(o,'DifficultyLvl_D2');
Par.D2param=get(o,'D2param');
Par.FrozenPatternsAdress=get(o,'FrozenPatternsAdress');
Par.FrozenPatternsNb=get(o,'FrozenPatternsNb');

% Add fields to Par because not enough lines in the Baphy dialog box
Par.LRextraFrequencies = 0.7;   % Oct.; empty space on left and right sides of the frequency axis
Par.FrequencyRange_LB = Par.FrequencyRange(1);
Par.FrequencyRange_UB = Par.FrequencyRange(2);
% Par.ToneDuration = 0.03;
% Par.TonesPerOctave = 2;
if Par.FrozenPatternsNb==0
  Par.FrozenPatternDuration = 0;
else
  FrozenPatternsAdress = get(o,'FrozenPatternsAdress');
  load([ FrozenPatternsAdress filesep 'FrozenPatterns.mat' ]);
  Par.FrozenPatternDuration = (length(FrozenPatterns{1})-1)/get(o,'SamplingRate');
  Par.FrozenPatternChordNb = Par.FrozenPatternDuration/Par.ToneDuration;
end
Par.ToneInterval = 12;            % For tone frequency in binned frequency axis. Defines STRF resolution.
Par.XDistriInterval = 24;         % Denser, for plotting purposes, area calculation and so forth
Par.MorphingDuration = 0;
o = set(o,'AllTargetPositions',{'center'});   % for Bernhard script [PerformanceAnalysis.m]
o = set(o,'CurrentTargetPositions',{'center'});
o = set(o,'MorphingDuration',Par.MorphingDuration);
if strcmp(get(o,'Inverse_D0Dbis'),'yes'); ReverseNb = 1; else ReverseNb = 0; end

% SET BIN NUMBER IN THE DISTRIBUTION + FREQUENCY RANGE AND ITS MIDDLE POINT F0
tmp = str2num(get(o,'Distri_Morphing_BinNb'));
if isempty(tmp)
  DistriBinNb = 8; MaxMorphingNb = 4;      % Usual Psychophysics parameter
else
  DistriBinNb = tmp(1); MaxMorphingNb = tmp(2);
end
Par.DistriBinNb = DistriBinNb; Par.MaxMorphingNb = MaxMorphingNb;
F0 = log2( Par.FrequencyRange_LB * 2^(log2(Par.FrequencyRange_UB/Par.FrequencyRange_LB)/2) ) ;  % center of the distribution
ToneInterval = Par.ToneInterval;
XDistriInterval = Par.XDistriInterval;
LB = Par.FrequencyRange_LB*2^(-Par.LRextraFrequencies);   % Left side of the frequency axis
UB = Par.FrequencyRange_UB*2^(Par.LRextraFrequencies);    % Right side of the frequency axis
OctaveNb = log2(Par.FrequencyRange_UB/Par.FrequencyRange_LB);
WholeAxis_OctaveNb = log2(UB/LB);
FrequencySpace = LB* (2.^ (0:(1/ToneInterval):WholeAxis_OctaveNb));
XDistri = LB* (2.^ (0:(1/XDistriInterval):WholeAxis_OctaveNb));
Par.FrequencySpace = FrequencySpace;
Par.XDistri = XDistri;
% DIFFICULTY LEVELS
ChangedD_Nb = length(find(~strcmp({get(o,'D1shape'),get(o,'D2shape')},'none')));  % Type of changed distributions
for ChangedD_Num = 1:ChangedD_Nb
  DifficultyLvlNb(ChangedD_Num) = length(getfield(Par,[ 'DifficultyLvl_D' num2str(ChangedD_Num)]));
end
Par.DifficultyLvlNb = DifficultyLvlNb;
Par.F0 = F0;
Par.OctaveNb = OctaveNb;
o = set(o,'FrequencySpace',FrequencySpace);
o = set(o,'XDistri',XDistri);
o = set(o,'F0',F0);

% CHORDDURATION & AVERAGENBTONESPEROCTAVE
% Par.ToneDuration = 0.03;
% Par.TonesPerOctave = 2;
ChordDurationNb= length(getfield(Par,'ChordDuration'));
AverageNbTonesChordNb= length(getfield(Par,'AverageNbTonesChord'));
% GENERATION OF A SEED FOR ToCs IF I AM NOT RELOADING A SOUND OBJECT
if isempty(get(o,'IniSeed'))
  Rtoday = RandStream('mrg32k3a','Seed',mod(prod(clock),2^ 20));
  IniSeed = round( Rtoday.rand(1,1)*100 );   % With RandStream('mrg32k3a'), it is important to work with large numbers,                                         %because there is a heavy correlation between two seeds that belong to the same integer interval [n,n+1[
else
  IniSeed = get(o,'IniSeed');
end
Par.IniSeed = IniSeed;
o = set(o,'IniSeed',IniSeed);

% GENERATION OF ALL [BINS TO CHANGE] COMBINATIONS FOR D1 AND D2 (<MorphingNb(ChangedD_Num)> number for each)
for ChangedD_Num = 1:ChangedD_Nb
  Dtype = getfield(Par,['D' num2str(ChangedD_Num) 'shape']);
  switch Dtype
    case 'contig_increm'
      MorphingNb(ChangedD_Num) = MaxMorphingNb;
      ChannelDistance = 1;
      ChannelDistancesByMorphing{ChangedD_Num} = ones(1,MaxMorphingNb)*ChannelDistance;
      Bins2Change{ChangedD_Num} = repmat([1 2],MaxMorphingNb,1) + repmat((0:2:((MaxMorphingNb-1)*2))',1,2);  %[1:2 ; 3:4 ; 5:6 ; 7:8];
    case 'fixed_increm'
      Bin2ChangeIndex = getfield(Par,[ 'D' num2str(ChangedD_Num) 'param' ]);
      MorphingNb(ChangedD_Num) = length(Bin2ChangeIndex); % this allows several bins to be chosen, in different proportions (like for Difficulty)
      ChannelDistance = 1;
      ChannelDistancesByMorphing{ChangedD_Num} = ones(1,MaxMorphingNb)*ChannelDistance;
      PossibleBins = repmat([1 2],MaxMorphingNb,1) + repmat((0:2:((MaxMorphingNb-1)*2))',1,2);  %{1:2 ; 3:4 ; 5:6 ; 7:8};
      Bins2Change{ChangedD_Num} = PossibleBins(Bin2ChangeIndex,:);
    case 'non_contig_increm'
      ChannelDistances = getfield(Par,[ 'D' num2str(ChangedD_Num) 'param' ]);
      MorphingNb(ChangedD_Num) = 0; Bins2Change{ChangedD_Num} = []; ChannelDistancesByMorphing{ChangedD_Num} = [];
      for ChannelDistance = ChannelDistances
        IntervalNb = DistriBinNb-ChannelDistance;
        MorphingNb(ChangedD_Num) = MorphingNb(ChangedD_Num) + IntervalNb;
        IntervalLst = ( 1:(DistriBinNb-ChannelDistance) );
        IntervalLst = [ IntervalLst' IntervalLst'+ChannelDistance ];
        Bins2Change{ChangedD_Num}( (size(Bins2Change{ChangedD_Num},1)+1) : (size(Bins2Change{ChangedD_Num},1)+IntervalNb) ,:) = IntervalLst;
        ChannelDistancesByMorphing{ChangedD_Num} = [ChannelDistancesByMorphing{ChangedD_Num} ones(1,IntervalNb)*ChannelDistance];
      end
  end
end

% CALCULATE CONDITION NB % JL 01/05/17
% if ~isempty(o.ChangeTimeBlocks)
%   MaxIndex = (ReverseNb+1)*sum(DifficultyLvlNb);
% else
  MaxIndex = (ReverseNb+1)*sum(DifficultyLvlNb.*MorphingNb.*ChordDurationNb.*AverageNbTonesChordNb);
% end
o = set(o,'MorphingNb',MorphingNb);
o = set(o,'Bins2Change',Bins2Change);
o = set(o,'ChannelDistancesByMorphing',ChannelDistancesByMorphing);
o = set(o,'MaxIndex',MaxIndex);
o = set(o,'Par',Par);

% SET NAMES
Names = cell(MaxIndex,1);
% ENUMERATE ALL CONDITIONS
DistributionTypeByInd = []; MorphingTypeByInd = []; DifficultyLvlByInd = []; ReverseByInd = []; ChordDurationByInd= []; AverageNbTonesChordByInd= [];
ConditionNbForEachD = MorphingNb.*ChordDurationNb.*AverageNbTonesChordNb.*DifficultyLvlNb*(ReverseNb+1);
for ChangedD_Num = 1:ChangedD_Nb
  MorphingNbForThisDistri = MorphingNb(ChangedD_Num); DifficultyLvlNbForThisDistri = DifficultyLvlNb(ChangedD_Num); DifficultyLvlNbForThisDistri = DifficultyLvlNb(ChangedD_Num);
  DistributionTypeByInd_temp = ones(1,ConditionNbForEachD(ChangedD_Num))*ChangedD_Num;
  DistributionTypeByInd = [DistributionTypeByInd DistributionTypeByInd_temp];
  
  MorphingTypeByInd_temp = repmat(1:MorphingNbForThisDistri,[1 ConditionNbForEachD(ChangedD_Num)/MorphingNbForThisDistri]);
  MorphingTypeByInd_temp = sort(MorphingTypeByInd_temp);
  MorphingTypeByInd = [ MorphingTypeByInd MorphingTypeByInd_temp ];
  
  DifficultyLvlByInd_temp = repmat(1:DifficultyLvlNbForThisDistri,[1 ConditionNbForEachD(ChangedD_Num)/(MorphingNbForThisDistri*DifficultyLvlNbForThisDistri)]);
  DifficultyLvlByInd_temp = sort(DifficultyLvlByInd_temp);
  DifficultyLvlByInd = [ DifficultyLvlByInd repmat(DifficultyLvlByInd_temp,[1 MorphingNbForThisDistri]) ];
  
  ReverseByInd_temp = repmat(0:ReverseNb,[1 ConditionNbForEachD(ChangedD_Num)/(MorphingNbForThisDistri*DifficultyLvlNbForThisDistri*(ReverseNb+1))]);
  ReverseByInd_temp = sort(ReverseByInd_temp);
  ReverseByInd = [ ReverseByInd repmat(ReverseByInd_temp,[1 (MorphingNbForThisDistri*DifficultyLvlNbForThisDistri)]) ];
  
  ChordDurationByInd_temp = repmat(1:ChordDurationNb,[1 ConditionNbForEachD(ChangedD_Num)/(MorphingNbForThisDistri*DifficultyLvlNbForThisDistri*(ReverseNb+1)*ChordDurationNb)]);
  ChordDurationByInd_temp = sort(ChordDurationByInd_temp);
  ChordDurationByInd = [ ChordDurationByInd repmat(ChordDurationByInd_temp,[1 (MorphingNbForThisDistri*DifficultyLvlNbForThisDistri*(ReverseNb+1))]) ];
  
  AverageNbTonesChordByInd_temp = repmat(1:AverageNbTonesChordNb,[1 ConditionNbForEachD(ChangedD_Num)/(MorphingNbForThisDistri*DifficultyLvlNbForThisDistri*(ReverseNb+1)*ChordDurationNb*AverageNbTonesChordNb)]);
  AverageNbTonesChordByInd_temp = sort(AverageNbTonesChordByInd_temp);
  AverageNbTonesChordByInd = [ AverageNbTonesChordByInd repmat(AverageNbTonesChordByInd_temp,[1 (MorphingNbForThisDistri*DifficultyLvlNbForThisDistri*(ReverseNb+1)*ChordDurationNb)]) ];
end

% WARNING
if strcmp(get(o,'Inverse_D0Dbis'),'yes') && Par.FrozenPatternsNb~=0
  disp('************ You should not have Frozen pattern in Reverse Mode. ************')
end

for Index = 1:MaxIndex
  % GET PARAMETERS OF CURRENT Index
  DistributionType = DistributionTypeByInd(Index);
  MorphingType = MorphingTypeByInd(Index);
  DifficultyLvl = DifficultyLvlByInd(Index);
  Reverse = ReverseByInd(Index);
  ChordDuration=ChordDurationByInd(Index);
  AverageNbTonesChord=AverageNbTonesChordByInd(Index);
  
  Names{Index} = sprintf('DistributionType =  %d  |  MorphingType =  %d  |  DifficultyLvl = %d  |  Reverse = %d  | ChordDuration = %d | AverageNbTonesChord = %d', ...
    DistributionType,MorphingType,DifficultyLvl,Reverse,ChordDuration,AverageNbTonesChord);
end
o = set(o,'DistributionTypeByInd',DistributionTypeByInd);
o = set(o,'MorphingTypeByInd',MorphingTypeByInd);
o = set(o,'DifficultyLvlByInd',DifficultyLvlByInd);
o = set(o,'ReverseByInd',ReverseByInd);
o = set(o,'ChordDurationByInd',ChordDurationByInd);
o = set(o,'AverageNbTonesChordByInd',AverageNbTonesChordByInd);
% o = set(o,'ChangeTimeBlocks',ChangeTimeBlocksByInd);

o = set(o,'Names',Names);
