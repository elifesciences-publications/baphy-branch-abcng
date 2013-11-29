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
    case 'popupmenu';  Par.(FieldNames{i}) = get(o,FieldNames{i}); 
    otherwise error('FieldType not implemented!');
  end
end

% Add fields to Par because not enough lines in the Baphy dialog box
Par.FrequencyRange_LB = 200;
Par.FrequencyRange_UB = 2500;
Par.ToneDuration = 0.03;
Par.TonesPerOctave = 2;
% Par.Stimulus2Duration = 3;        % set in GUI
Par.D1MinimalDuration = 0;
Par.ToneInterval = 12;
Par.XDistriInterval = 24;
Par.MorphingDuration = 0;
o = set(o,'AllTargetPositions',{'center'});   % for Bernhard script [PerformanceAnalysis.m]
o = set(o,'CurrentTargetPositions',{'center'});
o = set(o,'MorphingDuration',Par.MorphingDuration);

MorphingNb = 2;
DifficultyLvlNb = max([length(Par.DifficultyLvl_KeepTails) length(Par.DifficultyLvl_KeepBody)]);
if strcmp(Par.D2shape_KeepTails,'none')
    MorphingNb = MorphingNb-1;
end
if strcmp(Par.D2shape_KeepBody,'none')
    MorphingNb = MorphingNb-1;
end
if strcmp(Par.Inverse_D1D2,'yes'); ReverseNb = 1; else ReverseNb = 0; end
% Particular case [DIY):
if (ReverseNb == 0 && MorphingNb == 1); MorphingNb = 4; end
MaxIndex = (ReverseNb+1)*DifficultyLvlNb*MorphingNb;
o = set(o,'MaxIndex',MaxIndex);

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
Par.DifficultyLvlNb = DifficultyLvlNb;
Par.F0 = F0;
o = set(o,'FrequencySpace',FrequencySpace);
o = set(o,'XDistri',XDistri);
o = set(o,'F0',F0);

% DRAW DISTRIBUTIONS FOR BOTH KEEP TAILS AND KEEP BODY
sF = get(o,'SamplingRate');
MorphingCategory = Par.MorphingCategory;
D1type = Par.D1shape;   D1param = [F0 Par.D1param];
D2type_KeepTails = Par.D2shape_KeepTails;   D2param_KeepTails = [F0 Par.D2param_KeepTails];
D2type_KeepBody = Par.D2shape_KeepBody;   D2param_KeepBody = [F0 Par.D2param_KeepBody];
PlotDistributions = 0;
for DifficultyNum = 1:DifficultyLvlNb
    if strcmp(MorphingCategory,'none')      % No morphing to perform on D1. Just pure change in distributions (e.g. normal->cauchy)
        if MorphingNb == 1
            DiffLvl = Par.DifficultyLvl_KeepBody(DifficultyNum);       % given in %    
            D2type = D2type_KeepBody; D2param = D2param_KeepBody;
            [D1,D2_KeepBody,MergedD_KeepBody] = BuildMorphing(D1type,D2type,D1param,D2param,XDistri,'none',DiffLvl,PlotDistributions,F0,sF,FrequencySpace,MorphingCategory);
            D2_KeepBodyDistributions{DifficultyNum} = D2_KeepBody;
            MergedD_KeepBodyDistributions{DifficultyNum} = MergedD_KeepBody;
            D2_KeepTailsDistributions{DifficultyNum} = D2_KeepBody;
            MergedD_KeepTailsDistributions{DifficultyNum} = MergedD_KeepBody;
        elseif MorphingNb > 2
            D2_KeepTailsDistributions = []; MergedD_KeepTailsDistributions = [];
            DiffLvl = Par.DifficultyLvl_KeepBody(DifficultyNum);       % given in %   
            for BinNum = 1:MorphingNb
                D2type = D2type_KeepBody; D2param = D2param_KeepBody;
                [D1,D2_KeepBody,MergedD_KeepBody] = BuildMorphing(D1type,D2type,D1param,D2param,XDistri,BinNum,DiffLvl,PlotDistributions,F0,sF,FrequencySpace,MorphingCategory);
                D2_KeepBodyDistributions{DifficultyNum,BinNum} = D2_KeepBody;
                MergedD_KeepBodyDistributions{DifficultyNum,BinNum} = MergedD_KeepBody;
            end
        elseif MorphingNb == 2
            DiffLvl = Par.DifficultyLvl_KeepBody(DifficultyNum);       % given in %   
            
            % Keep body
            D2type = D2type_KeepBody; D2param = D2param_KeepBody;
            [D1,D2_KeepBody,MergedD_KeepBody] = BuildMorphing(D1type,D2type,D1param,D2param,XDistri,'KeepBody',DiffLvl,PlotDistributions,F0,sF,FrequencySpace,MorphingCategory);
            D2_KeepBodyDistributions{DifficultyNum} = D2_KeepBody;
            MergedD_KeepBodyDistributions{DifficultyNum} = MergedD_KeepBody; 

            % Keep tails
            D2type = D2type_KeepTails; D2param = D2param_KeepTails;
            [D1,D2_KeepTails,MergedD_KeepTails] = BuildMorphing(D1type,D2type,D1param,D2param,XDistri,'KeepTails',DiffLvl,PlotDistributions,F0,sF,FrequencySpace,MorphingCategory);
            D2_KeepTailsDistributions{DifficultyNum} = D2_KeepTails;
            MergedD_KeepTailsDistributions{DifficultyNum} = MergedD_KeepTails;
        end
    else % Actual morphing of D1
        % Keep body
        DeviantPrctile = Par.DifficultyLvl_KeepBody(DifficultyNum)/100;       % given in %    
        D2type = D2type_KeepBody; D2param = D2param_KeepBody;
        [D1,D2_KeepBody,MergedD_KeepBody] = BuildMorphing(D1type,D2type,D1param,D2param,XDistri,'KeepBody',DeviantPrctile,PlotDistributions,F0,sF,FrequencySpace,MorphingCategory);
        D2_KeepBodyDistributions{DifficultyNum} = D2_KeepBody;
        MergedD_KeepBodyDistributions{DifficultyNum} = MergedD_KeepBody; 

        % Keep tails
        DeviantPrctile = Par.DifficultyLvl_KeepTails(DifficultyNum)/100;       % given in %    
        D2type = D2type_KeepTails; D2param = D2param_KeepTails;
        [D1,D2_KeepTails,MergedD_KeepTails] = BuildMorphing(D1type,D2type,D1param,D2param,XDistri,'KeepTails',DeviantPrctile,PlotDistributions,F0,sF,FrequencySpace,MorphingCategory);
        D2_KeepTailsDistributions{DifficultyNum} = D2_KeepTails;
        MergedD_KeepTailsDistributions{DifficultyNum} = MergedD_KeepTails;   
    end
end
o = set(o,'D1',D1);
o = set(o,'D2_KeepBody',D2_KeepBodyDistributions);
o = set(o,'MergedD_KeepBody',MergedD_KeepBodyDistributions);
o = set(o,'D2_KeepTails',D2_KeepTailsDistributions);
o = set(o,'MergedD_KeepTails',MergedD_KeepTailsDistributions);

% GENERATION OF A SEED FOR ToCs
IniSeed = round( rand(1,1)*100 );
Par.IniSeed = IniSeed;
o = set(o,'IniSeed',IniSeed);

o = set(o,'Par',Par);

% SET NAMES
Names = cell(MaxIndex,1);
% ENUMERATE ALL CONDITIONS
MorphingTypeByInd = repmat(1:MorphingNb,[1 MaxIndex/MorphingNb]);
MorphingTypeByInd = sort(MorphingTypeByInd);

DifficultyLvlByInd = repmat(1:DifficultyLvlNb,[1 MaxIndex/(MorphingNb*DifficultyLvlNb)]);
DifficultyLvlByInd = sort(DifficultyLvlByInd);
DifficultyLvlByInd = repmat(DifficultyLvlByInd,[1 MorphingNb]);

ReverseByInd = repmat(0:ReverseNb,[1 MaxIndex/(MorphingNb*DifficultyLvlNb*(ReverseNb+1))]);
ReverseByInd = sort(ReverseByInd);
ReverseByInd = repmat(ReverseByInd,[1 (MorphingNb*DifficultyLvlNb)]);

for Index = 1:MaxIndex
    % GET PARAMETERS OF CURRENT Index
    MorphingType = MorphingTypeByInd(Index);
    DifficultyLvl = DifficultyLvlByInd(Index);
    Reverse = ReverseByInd(Index);
    
    Names{Index} = sprintf('MorphingType =  %d  |  DifficultyLvl = %d  |  Reverse = %d  |',...
        MorphingType,DifficultyLvl,Reverse);
end
o = set(o,'MorphingTypeByInd',MorphingTypeByInd);
o = set(o,'DifficultyLvlByInd',DifficultyLvlByInd);
o = set(o,'ReverseByInd',ReverseByInd);
o = set(o,'Names',Names);
