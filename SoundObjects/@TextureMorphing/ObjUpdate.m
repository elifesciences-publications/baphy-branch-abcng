function o = ObjUpdate(o,IniSeed)
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
    case 'popupmenu';  Par.(FieldNames{i}) = get(o,FieldNames{i}); 
    otherwise error('FieldType not implemented!');
  end
end

% Add fields to Par because not enough lines in the Baphy dialog box
Par.FrequencyRange_LB = 200;
Par.FrequencyRange_UB = 2500;
Par.ToneDuration = 0.03;
Par.TonesPerOctave = 2;
Par.FrozenPatternDuration = 0;
Par.ToneInterval = 12;
Par.XDistriInterval = 24;
Par.MorphingDuration = 0;
o = set(o,'AllTargetPositions',{'center'});   % for Bernhard script [PerformanceAnalysis.m]
o = set(o,'CurrentTargetPositions',{'center'});
o = set(o,'MorphingDuration',Par.MorphingDuration);
if strcmp(Par.Inverse_D0Dbis,'yes'); ReverseNb = 1; else ReverseNb = 0; end

% SET FREQUENCY RANGE AND ITS MIDDLE POINT F0
ToneInterval = Par.ToneInterval;
XDistriInterval = Par.XDistriInterval;
LB = Par.FrequencyRange_LB;
UB = Par.FrequencyRange_UB;
F0 = log2( LB * 2^(log2(UB/LB)/2) ) ;
OctaveNb = log2(UB/LB);
FrequencySpace = LB* (2.^ (0:(1/ToneInterval):OctaveNb));
XDistri = LB* (2.^ (0:(1/XDistriInterval):OctaveNb));
Par.FrequencySpace = FrequencySpace;
Par.XDistri = XDistri;
% DIFFICULTY LEVELS
ChangedD_Nb = length(find(~strcmp({get(o,'D1shape'),get(o,'D2shape')},'none')));  % Type of changed distributions
for ChangedD_Num = 1:ChangedD_Nb
    DifficultyLvlNb(ChangedD_Num) = length(getfield(Par,[ 'DifficultyLvl_D' num2str(ChangedD_Num)]));
end
Par.DifficultyLvlNb = DifficultyLvlNb;
Par.F0 = F0;
o = set(o,'FrequencySpace',FrequencySpace);
o = set(o,'XDistri',XDistri);
o = set(o,'F0',F0);
sF = get(o,'SamplingRate');

% GENERATION OF A SEED FOR ToCs IF I AM NOT RELOADING A SOUND OBJECT
if ~(exist('IniSeed','var')) || isempty(IniSeed)
    IniSeed = round( rand(1,1)*100 );   % With RandStream('mrg32k3a'), it is important to work with large numbers, 
                                        %because thetre is a heavy correlatio between two seeds that belong to the same integer interval [n,n+1[
end
Par.IniSeed = IniSeed;
o = set(o,'IniSeed',IniSeed);

% GENERATION OF ALL [BINS TO CHANGE] COMBINATIONS FOR D1 AND D2 (<MorphingNb(ChangedD_Num)> number for each)
for ChangedD_Num = 1:ChangedD_Nb
    Dtype = getfield(Par,['D' num2str(ChangedD_Num) 'shape']);   
    switch Dtype
        case 'contig_increm'
            MorphingNb(ChangedD_Num) = 4;
            ChannelDistance = 1;
            ChannelDistancesByMorphing{ChangedD_Num} = ones(1,4)*ChannelDistance;
            Bins2Change{ChangedD_Num} = [1:2 ; 3:4 ; 5:6 ; 7:8];
        case 'non_contig_increm'
            ChannelDistances = getfield(Par,[ 'D' num2str(ChangedD_Num) 'param' ]);
            MorphingNb(ChangedD_Num) = 0; Bins2Change{ChangedD_Num} = [];
            for ChannelDistance = ChannelDistances
                BinNb = 8;
                IntervalNb = BinNb-ChannelDistance;
                MorphingNb(ChangedD_Num) = MorphingNb(ChangedD_Num) + IntervalNb;
                IntervalLst = ( 1:(BinNb-ChannelDistance) );
                IntervalLst = [ IntervalLst' IntervalLst'+ChannelDistance ];
                Bins2Change{ChangedD_Num}( (size(Bins2Change{ChangedD_Num},1)+1) : (size(Bins2Change{ChangedD_Num},1)+IntervalNb) ,:) = IntervalLst;
                ChannelDistancesByMorphing{ChangedD_Num} = ones(1,IntervalNb)*ChannelDistance;
            end
    end
end

% CALCULATE CONDITION NB
MaxIndex = (ReverseNb+1)*sum(DifficultyLvlNb.*MorphingNb);
o = set(o,'MorphingNb',MorphingNb);
o = set(o,'Bins2Change',Bins2Change);
o = set(o,'ChannelDistancesByMorphing',ChannelDistancesByMorphing);
o = set(o,'MaxIndex',MaxIndex);

% DO
PlotDistributions = 0;
D0type = Par.D0shape;

% D1/D2
for ChangedD_Num = 1:ChangedD_Nb
    % DRAW DISTRIBUTIONS FOR EACH CHANGED DISTRIBUTION
    Dtype = getfield(Par,['D' num2str(ChangedD_Num) 'shape']);   
    DifficultyLvl = getfield(Par,['DifficultyLvl_D' num2str(ChangedD_Num)]);
    ChangedDistributions = [];
    for DifficultyNum = 1:DifficultyLvlNb(ChangedD_Num)
        DiffLvl = DifficultyLvl(DifficultyNum);       % given in %   
        for MorphingNum = 1:MorphingNb(ChangedD_Num)
            for UniqueIniDistriNum = 1:Par.UniqueIniDistriNb
                D0param = [F0 Par.Bandwidth Par.IniSeed UniqueIniDistriNum];
                Dparam = [D0param(1:end-2) Bins2Change{ChangedD_Num}(MorphingNum,:)];    % We don't need a Seed to modify the original distribution
                [D0,ChangeD] = BuildMorphing(D0type,Dtype,D0param,Dparam,XDistri,MorphingNum,DiffLvl,PlotDistributions,F0,sF,FrequencySpace);
                D0s{UniqueIniDistriNum} = D0;
                ChangedDistributions{DifficultyNum,MorphingNum,UniqueIniDistriNum} = ChangeD;
            end
        end
    end
    o = set(o,'D0',D0s);    
    o = set(o,['D' num2str(ChangedD_Num)],ChangedDistributions);
end

o = set(o,'Par',Par);

% SET NAMES
Names = cell(MaxIndex,1);
% ENUMERATE ALL CONDITIONS
DistributionTypeByInd = []; MorphingTypeByInd = []; DifficultyLvlByInd = []; ReverseByInd = [];
ConditionNbForEachD = MorphingNb.*DifficultyLvlNb;
for ChangedD_Num = 1:ChangedD_Nb
    MorphingNbForThisCond = MorphingNb(ChangedD_Num); DifficultyLvlNbForThisCond = DifficultyLvlNb(ChangedD_Num);
    DistributionTypeByInd_temp = ones(1,ConditionNbForEachD(ChangedD_Num))*ChangedD_Num;
    DistributionTypeByInd = [DistributionTypeByInd DistributionTypeByInd_temp];

    MorphingTypeByInd_temp = repmat(1:MorphingNbForThisCond,[1 ConditionNbForEachD(ChangedD_Num)/MorphingNbForThisCond]);
    MorphingTypeByInd_temp = sort(MorphingTypeByInd_temp);
    MorphingTypeByInd = [ MorphingTypeByInd MorphingTypeByInd_temp ];

    DifficultyLvlByInd_temp = repmat(1:DifficultyLvlNbForThisCond,[1 ConditionNbForEachD(ChangedD_Num)/(MorphingNbForThisCond*DifficultyLvlNbForThisCond)]);
    DifficultyLvlByInd_temp = sort(DifficultyLvlByInd_temp);
    DifficultyLvlByInd = [ DifficultyLvlByInd repmat(DifficultyLvlByInd_temp,[1 MorphingNbForThisCond]) ];

    ReverseByInd_temp = repmat(0:ReverseNb,[1 ConditionNbForEachD(ChangedD_Num)/(MorphingNbForThisCond*DifficultyLvlNbForThisCond*(ReverseNb+1))]);
    ReverseByInd_temp = sort(ReverseByInd_temp);
    ReverseByInd = [ ReverseByInd repmat(ReverseByInd_temp,[1 (MorphingNbForThisCond*DifficultyLvlNbForThisCond)]) ];
end

for Index = 1:MaxIndex
    % GET PARAMETERS OF CURRENT Index
    DistributionType = DistributionTypeByInd(Index);
    MorphingType = MorphingTypeByInd(Index);
    DifficultyLvl = DifficultyLvlByInd(Index);
    Reverse = ReverseByInd(Index);
    
    Names{Index} = sprintf('DistributionType =  %d  |  MorphingType =  %d  |  DifficultyLvl = %d  |  Reverse = %d  |',...
        DistributionType,MorphingType,DifficultyLvl,Reverse);
end
o = set(o,'DistributionTypeByInd',DistributionTypeByInd);
o = set(o,'MorphingTypeByInd',MorphingTypeByInd);
o = set(o,'DifficultyLvlByInd',DifficultyLvlByInd);
o = set(o,'ReverseByInd',ReverseByInd);
o = set(o,'Names',Names);

