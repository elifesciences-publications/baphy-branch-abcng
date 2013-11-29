function [D1,D2,MergedD,Stimulus1,Stimulus2] = BuildMorphing(varargin)
D1type = varargin{1};
D2type = varargin{2};
D1para = varargin{3};
D2para = varargin{4};
X = varargin{5};
MorphingType = varargin{6};
DeviantPrctile = varargin{7};
PlotMe = varargin{8};
F0 = varargin{9};
sF = varargin{10};
FrequencySpace = varargin{11};
MorphingCategory = varargin{12};
[D1,M1] = DrawDistribution(D1type,D1para,X);
LineName = [MorphingType ' ' num2str(DeviantPrctile) '%'];

switch MorphingCategory
%*****************
case 'none'
    switch D2type
	case 'almost_uniform'
            DiffLvl = DeviantPrctile; BinNum = MorphingType;
            D2para = [D2para DiffLvl BinNum];
            [D2,M2] = DrawDistribution(D2type,D2para,X);
            MergedD = D2;
%         switch MorphingType
%             case 'KeepBody'
%                 DiffLvl = DeviantPrctile;
%                 D2para = [D2para DiffLvl 1];
%                 [D2,M2] = DrawDistribution(D2type,D2para,X);
%                 MergedD = D2;
%             case 'KeepTails'
%                 DiffLvl = DeviantPrctile;
%                 D2para = [D2para DiffLvl 2];
%                 [D2,M2] = DrawDistribution(D2type,D2para,X);
%                 MergedD = D2;
%         end
	case 'shuffle_normal'
        DiffLvl = DeviantPrctile;
        KlDiv = kldiv_CaseWith0(log2(X),D1(X),D2(X),'js');
        while KlDiv<(DiffLvl-1) || KlDiv>(DiffLvl+1)
            D2para(5) = round(rand(1,1)*100);
            [D2,M2] = DrawDistribution(D2type,D2para,X);
            KlDiv = kldiv_CaseWith0(log2(X),D1(X),D2(X),'js');
        end
        MergedD = D2;
    end
%*****************        
case 'MovingLimit'    % Difficulty is ajusted by moving the frontier of the morphing along the freq. axis
    disp('Since I added 2 fast decaying tails to the truncated distributions, this morphing is not yet rectified relatively to area normalization when using ''offset_normal_smooth_tails''.');
    [D2,M2] = DrawDistribution(D2type,D2para,X);
switch MorphingType
    case 'KeepTails'       
        % Remove doublons in the CumDistri to allow interpolation
        % and avoid boundary effects
        CumCurveArea1 = cumtrapz(log2(X),D1(X));
        CumCurveArea1 = CumCurveArea1/max(CumCurveArea1);
        [FirstCumDistri,FirstUniIndex] = unique(CumCurveArea1,'first');
        [LastCumDistri,LastUniIndex] = unique(CumCurveArea1,'last');
        MidIndex = round(length(LastUniIndex)/2);
        UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
        UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
        UniX = X(UniIndex);
        CumCurveArea1 = CumCurveArea1(UniIndex);
        CumCurveArea1(1) = 0;
        ThreshDeviantTones(1,1) = interp1(CumCurveArea1,UniX,DeviantPrctile);
        ThreshDeviantTones(1,2) = interp1(CumCurveArea1,UniX,(1-DeviantPrctile));
        
        clear UniIndex        
        CumCurveArea2 = cumtrapz(log2(X),D2(X));
        CumCurveArea2 = CumCurveArea2/max(CumCurveArea2);
        [FirstCumDistri,FirstUniIndex] = unique(CumCurveArea2,'first');
        [LastCumDistri,LastUniIndex] = unique(CumCurveArea2,'last');
        MidIndex = round(length(LastUniIndex)/2);
        UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
        UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
        UniX = X(UniIndex);
        CumCurveArea2 = CumCurveArea2(UniIndex);
        CumCurveArea2(1) = 0;
        ThreshDeviantTones(2,1) = interp1(CumCurveArea2,UniX,DeviantPrctile);
        ThreshDeviantTones(2,2) = interp1(CumCurveArea2,UniX,(1-DeviantPrctile));             
        
%         % Define thresholds for merging distributions
%         CumCurveArea1 = cumtrapz(log2(X),D1(X));
%         [CumCurveArea1,UniIndex] = unique(CumCurveArea1);
%         CumCurveArea1 = CumCurveArea1/max(CumCurveArea1);
%         UniX = X(UniIndex);
%         ThreshDeviantTones(1,1) = interp1(CumCurveArea1,UniX,DeviantPrctile);
%         xxx = X(1) :0.1: ThreshDeviantTones(1,1); DeviantPrctileLeft = trapz(log2(xxx),D1(xxx));
%         ThreshDeviantTones(1,2) = interp1(CumCurveArea1,UniX,(1-DeviantPrctile));
%         xxx = ThreshDeviantTones(1,2) :0.1: X(end); DeviantPrctileRight = trapz(log2(xxx),D1(xxx));
%         CumCurveArea2 = cumtrapz(log2(X),D2(X));
%         CumCurveArea2 = CumCurveArea2/max(CumCurveArea2);
%         [CumCurveArea2,UniIndex] = unique(CumCurveArea2);
%         UniX = X(UniIndex);
%         % ThreshDeviantTones(2,1) = interp1(CumCurveArea2,UniX,DeviantPrctile);
%         % ThreshDeviantTones(2,2) = interp1(CumCurveArea2,UniX,(1-DeviantPrctile));
%         ThreshDeviantTones(2,1) = interp1(CumCurveArea2,UniX,DeviantPrctileLeft);
%         ThreshDeviantTones(2,2) = interp1(CumCurveArea2,UniX,1-DeviantPrctileRight);
        
        % Normalize the area under the D2 body curve
        Xdeviant = ThreshDeviantTones(2,1) :0.1: ThreshDeviantTones(2,2);
        ThreshDeviantTones(2,2) = Xdeviant(end);
        TranslatedX = ( log(Xdeviant) - log(ThreshDeviantTones(2,1)) ) / (log(ThreshDeviantTones(2,2))-log(ThreshDeviantTones(2,1)));  % !!! for symmetrical distribution
        TranslatedX = ( TranslatedX * (log(ThreshDeviantTones(1,2))-log(ThreshDeviantTones(1,1))) ) + log(ThreshDeviantTones(1,1));
        CurveArea = trapz(TranslatedX/log(2),D2(Xdeviant));
        NormFactor = (1-2*DeviantPrctile)/CurveArea;
        Normf = @(x,K) D2(x)*K;
        NormalizedD2 = @(x) Normf(x,NormFactor);
        % Merging of distributions
        MergedD = DrawDistribution(MorphingType,[],X,D1,NormalizedD2,ThreshDeviantTones,MorphingCategory);
    case 'KeepBody'
        
        % Remove doublons in the CumDistri to allow interpolation
        % and avoid boundary effects
        CumCurveArea1 = cumtrapz(log2(X),D1(X));
        CumCurveArea1 = CumCurveArea1/max(CumCurveArea1);
        [FirstCumDistri,FirstUniIndex] = unique(CumCurveArea1,'first');
        [LastCumDistri,LastUniIndex] = unique(CumCurveArea1,'last');
        MidIndex = round(length(LastUniIndex)/2);
        UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
        UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
        UniX = X(UniIndex);
        CumCurveArea1 = CumCurveArea1(UniIndex);
        CumCurveArea1(1) = 0;
        ThreshDeviantTones(1,1) = interp1(CumCurveArea1,UniX,DeviantPrctile);
        ThreshDeviantTones(1,2) = interp1(CumCurveArea1,UniX,(1-DeviantPrctile));
        
        clear UniIndex        
        CumCurveArea2 = cumtrapz(log2(X),D2(X));
        CumCurveArea2 = CumCurveArea2/max(CumCurveArea2);
        [FirstCumDistri,FirstUniIndex] = unique(CumCurveArea2,'first');
        [LastCumDistri,LastUniIndex] = unique(CumCurveArea2,'last');
        MidIndex = round(length(LastUniIndex)/2);
        UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
        UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
        UniX = X(UniIndex);
        CumCurveArea2 = CumCurveArea2(UniIndex);
        CumCurveArea2(1) = 0;
        ThreshDeviantTones(2,1) = interp1(CumCurveArea2,UniX,DeviantPrctile);
        ThreshDeviantTones(2,2) = interp1(CumCurveArea2,UniX,(1-DeviantPrctile));
        
%         % Define thresholds for merging distributions
%         CumCurveArea1 = cumtrapz(log2(X),D1(X));
%         [CumCurveArea1,UniIndex] = unique(CumCurveArea1);
%         CumCurveArea1 = CumCurveArea1/max(CumCurveArea1);
%         UniX = X(UniIndex);
%         ThreshDeviantTones(1,1) = interp1(CumCurveArea1,UniX,DeviantPrctile);
%         ThreshDeviantTones(1,2) = interp1(CumCurveArea1,UniX,(1-DeviantPrctile));
%         CumCurveArea2 = cumtrapz(log2(X),D2(X));
%         CumCurveArea2 = CumCurveArea2/max(CumCurveArea2);
%         [CumCurveArea2,UniIndex] = unique(CumCurveArea2);
%         UniX = X(UniIndex);
%         ThreshDeviantTones(2,1) = interp1(CumCurveArea2,UniX,DeviantPrctile);
%         ThreshDeviantTones(2,2) = interp1(CumCurveArea2,UniX,(1-DeviantPrctile));
        ThreshDeviantTones(3,1) = X(1); % Extreme fringes
        ThreshDeviantTones(3,2) = X(end);
        % Normalize the area under the D2 tails
        Xdeviant = log(ThreshDeviantTones(3,1)) :0.1: ThreshDeviantTones(2,1);
        ThreshDeviantTones(2,1) = Xdeviant(end);
        TranslatedX = ( log(Xdeviant) - log(ThreshDeviantTones(3,1)) ) / (log(ThreshDeviantTones(2,1))-log(ThreshDeviantTones(3,1))); 
        TranslatedX = ( TranslatedX * (log(ThreshDeviantTones(1,1))-log(ThreshDeviantTones(3,1))) ) + log(ThreshDeviantTones(3,1));
        CurveArea = trapz(TranslatedX/log(2),D2(Xdeviant));
        NormFactor = DeviantPrctile/CurveArea;                % for symetrical distributions, low and high tails are same area NOT (1-2*DeviantPrctile)/CurveArea;
        Normf = @(x,K) D2(x)*K;
        NormalizedD2 = @(x) Normf(x,NormFactor);
        % Merging of distributions
        MergedD = DrawDistribution(MorphingType,[],X,D1,NormalizedD2,ThreshDeviantTones,MorphingCategory);
end
%******************
case 'ClampedLimit'      % Frontiers of the morphing are fixed. The difficulty is only adjusted by the ammount of area displaced.
    DifficultyLvl = DeviantPrctile;
    DeviantPrctile = .1;                % on each side
    [D2,M2] = DrawDistribution(D2type,D2para,X);
switch MorphingType
    case 'KeepTails'        
        % Remove doublons in the CumDistri to allow interpolation
        % and avoid boundary effects
        CumCurveArea1 = cumtrapz(log2(X),D1(X));
        CumCurveArea1 = CumCurveArea1/max(CumCurveArea1);
        [FirstCumDistri,FirstUniIndex] = unique(CumCurveArea1,'first');
        [LastCumDistri,LastUniIndex] = unique(CumCurveArea1,'last');
        MidIndex = round(length(LastUniIndex)/2);
        UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
        UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
        UniX = X(UniIndex);
        CumCurveArea1 = CumCurveArea1(UniIndex);
        CumCurveArea1(1) = 0;
        ThreshDeviantTones(1,1) = interp1(CumCurveArea1,UniX,DeviantPrctile);
        ThreshDeviantTones(1,2) = interp1(CumCurveArea1,UniX,(1-DeviantPrctile));
        
        clear UniIndex        
        CumCurveArea2 = cumtrapz(log2(X),D2(X));
        CumCurveArea2 = CumCurveArea2/max(CumCurveArea2);
        [FirstCumDistri,FirstUniIndex] = unique(CumCurveArea2,'first');
        [LastCumDistri,LastUniIndex] = unique(CumCurveArea2,'last');
        MidIndex = round(length(LastUniIndex)/2);
        UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
        UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
        UniX = X(UniIndex);
        CumCurveArea2 = CumCurveArea2(UniIndex);
        CumCurveArea2(1) = 0;
        ThreshDeviantTones(2,1) = interp1(CumCurveArea2,UniX,DeviantPrctile);
        ThreshDeviantTones(2,2) = interp1(CumCurveArea2,UniX,(1-DeviantPrctile));        
                
        % Normalize the area under the D2 body curve
%         Xdeviant = ThreshDeviantTones(2,1) :0.1: ThreshDeviantTones(2,2);
%         ThreshDeviantTones(2,2) = Xdeviant(end);
%         TranslatedX = ( log(Xdeviant) - log(ThreshDeviantTones(2,1)) ) / (log(ThreshDeviantTones(2,2))-log(ThreshDeviantTones(2,1)));  % !!! for symmetrical distribution
%         TranslatedX = ( TranslatedX * (log(ThreshDeviantTones(1,2))-log(ThreshDeviantTones(1,1))) ) + log(ThreshDeviantTones(1,1));
%         CurveArea = trapz(TranslatedX/log(2),D2(Xdeviant));
%         NormFactor = (1-2*DeviantPrctile)/CurveArea;
%         Normf = @(x,K) D2(x)*K;
%         D2 = @(x) Normf(x,NormFactor);

        Xdeviant = ThreshDeviantTones(1,1) :0.1: ThreshDeviantTones(1,2);
        D2area = trapz(log2(Xdeviant),D2(Xdeviant));
        ExcessArea = D2area-(1-2*DeviantPrctile);
        NormFactor = ExcessArea/log2(Xdeviant(end)/Xdeviant(1));
%         Normf = @(x,K) subplus( (D2(x)-K) );
        Normf = @(x,K) max( D1(ThreshDeviantTones(1,1))*.25 , (D2(x)-K) );
        AreaSubtractedD2 = trapz( log2(Xdeviant) , Normf(Xdeviant,NormFactor) );
        SubtractedD2 = @(x,NormFactor,AreaSubtractedD2) Normf(x,NormFactor)*(1-2*DeviantPrctile)/AreaSubtractedD2;
        NormalizedD2 = @(x) SubtractedD2(x,NormFactor,AreaSubtractedD2);
        
%         MaxD1 = max(D1(Xdeviant));
%         MaxD2 = max(D2(Xdeviant));
%         PeakValue = DifficultyLvl*MaxD1;
%         DX = log2(ThreshDeviantTones(1,2)/ThreshDeviantTones(1,1));
%         A = trapz(log2(Xdeviant),D2(Xdeviant));
%         Sol =  A*(MaxD2-PeakValue)/(A-DX*PeakValue);
%         Normf = @(x,a,MaxD2,PeakValue) (D2(x)-a)*PeakValue/(MaxD2-a);
%         NormalizedD2 = @(x) ((sign(Normf(x,Sol,MaxD2,PeakValue))+1)/2).*Normf(x,Sol,MaxD2,PeakValue);
        
        if trapz(log2(Xdeviant),NormalizedD2(Xdeviant)) > ((1-2*DeviantPrctile)+.015) || trapz(log2(Xdeviant),NormalizedD2(Xdeviant)) < ((1-2*DeviantPrctile)-.015)
            disp('WARNING! AREA not respected');
        end
        % Merging of distributions
        MergedD = DrawDistribution(MorphingType,[],X,D1,NormalizedD2,ThreshDeviantTones,MorphingCategory);
        
    case 'KeepBody'        
        % Remove doublons in the CumDistri to allow interpolation
        % and avoid boundary effects
        CumCurveArea1 = cumtrapz(log2(X),D1(X));
        CumCurveArea1 = CumCurveArea1/max(CumCurveArea1);
        [FirstCumDistri,FirstUniIndex] = unique(CumCurveArea1,'first');
        [LastCumDistri,LastUniIndex] = unique(CumCurveArea1,'last');
        MidIndex = round(length(LastUniIndex)/2);
        UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
        UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
        UniX = X(UniIndex);
        CumCurveArea1 = CumCurveArea1(UniIndex);
        CumCurveArea1(1) = 0;
        ThreshDeviantTones(1,1) = interp1(CumCurveArea1,UniX,DeviantPrctile);
        ThreshDeviantTones(1,2) = interp1(CumCurveArea1,UniX,(1-DeviantPrctile));
        
        clear UniIndex
        CumCurveArea2 = cumtrapz(log2(X),D2(X));
        CumCurveArea2 = CumCurveArea2/max(CumCurveArea2);
        [FirstCumDistri,FirstUniIndex] = unique(CumCurveArea2,'first');
        [LastCumDistri,LastUniIndex] = unique(CumCurveArea2,'last');
        MidIndex = round(length(LastUniIndex)/2);
        UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
        UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
        UniX = X(UniIndex);
        CumCurveArea2 = CumCurveArea2(UniIndex);
        CumCurveArea2(1) = 0;
        ThreshDeviantTones(2,1) = interp1(CumCurveArea2,UniX,DeviantPrctile);
        ThreshDeviantTones(2,2) = interp1(CumCurveArea2,UniX,(1-DeviantPrctile));

        ThreshDeviantTones(3,1) = X(1); % Extreme fringes
        ThreshDeviantTones(3,2) = X(end);
%         % Normalize the area under the D2 tails
%         Xdeviant = log(ThreshDeviantTones(3,1)) :0.1: ThreshDeviantTones(2,1);
%         ThreshDeviantTones(2,1) = Xdeviant(end);
%         TranslatedX = ( log(Xdeviant) - log(ThreshDeviantTones(3,1)) ) / (log(ThreshDeviantTones(2,1))-log(ThreshDeviantTones(3,1))); 
%         TranslatedX = ( TranslatedX * (log(ThreshDeviantTones(1,1))-log(ThreshDeviantTones(3,1))) ) + log(ThreshDeviantTones(3,1));
%         CurveArea = trapz(TranslatedX/log(2),D2(Xdeviant));
%         NormFactor = DeviantPrctile/CurveArea;                % for symetrical distributions, low and high tails are same area NOT (1-2*DeviantPrctile)/CurveArea;
%         Normf = @(x,K) D2(x)*K;
%         NormalizedD2 = @(x) Normf(x,NormFactor);
        [MaMa,MaInd] = max(D1(X)); f0 = X(MaInd);
        
        A = DeviantPrctile;
        a = DifficultyLvl*D1(ThreshDeviantTones(1,1));
        f_1 = ThreshDeviantTones(1,1)*2^(-2*A/a);               % f_1 is the frequency where to raccord.
        LeftSlope = a/log2(ThreshDeviantTones(1,1)/f_1);
        Normf = @(x,f_1,Slope) subplus( log2(x)*Slope-log2(f_1)*Slope );
        
        x1Area = max([f_1,ThreshDeviantTones(3,1)]); x2Area = ThreshDeviantTones(1,1);
        xxArea = x1Area * 2.^(0:(1/24):log2(x2Area/x1Area));
        BasalLvl = D1(ThreshDeviantTones(3,1));
        LeftPreNorm = trapz(log2(xxArea),Normf(xxArea,f_1,LeftSlope)+BasalLvl);
        PreNormalizedLeftD2 = @(x,f_1,LeftSlope,PreNorm,BasalLvl) (Normf(x,f_1,LeftSlope)+BasalLvl)*DeviantPrctile/PreNorm;
        
        NormalizedLeftD2 = @(x) PreNormalizedLeftD2(x,f_1,LeftSlope,LeftPreNorm,BasalLvl);
        
        f_2 = ThreshDeviantTones(1,2)*2^(2*A/a);
        RightSlope = -a/log2(f_2/ThreshDeviantTones(1,2));
        Normf = @(x,f_2,Slope) subplus( log2(x)*Slope-log2(f_2)*Slope );

        x1Area = ThreshDeviantTones(1,2); x2Area = min([f_2,ThreshDeviantTones(3,2)]); 
        xxArea = x1Area * 2.^(0:(1/24):log2(x2Area/x1Area));
        BasalLvl = D1(ThreshDeviantTones(3,2));
        RightPreNorm = trapz(log2(xxArea),Normf(xxArea,f_2,RightSlope)+BasalLvl);
        PreNormalizedRightD2 = @(x,f_1,LeftSlope,PreNorm,BasalLvl) (Normf(x,f_1,LeftSlope)+BasalLvl)*DeviantPrctile/PreNorm;
        
        NormalizedRightD2 = @(x) PreNormalizedRightD2(x,f_2,RightSlope,RightPreNorm,BasalLvl);
        
        CombinedF = @(x) ((1-sign(x-f0))/2).*NormalizedLeftD2(x) + ((1+sign(x-f0))/2).*NormalizedRightD2(x);
%         NormalizedD2 = @(x) ((sign(CombinedF(x,f0))+1)/2).*CombinedF(x,f0);
        % Merging of distributions
        MergedD = DrawDistribution(MorphingType,[],X,D1,CombinedF,ThreshDeviantTones,MorphingCategory);
end
end


% Build the stimulus from the 2 distributions
if nargout>3 || (nargin>=7 && PlotMe)
    Stimulus1 = AssemblyTones(FrequencySpace,D1,X,3,sF,PlotMe); Stimulus2 = AssemblyTones(FrequencySpace,MergedD,X,3,sF,PlotMe,LineName);
end
if nargin>=7 && PlotMe
    F0 = varargin{9};
    sF = varargin{10};
    FrequencySpace = varargin{11};
    plot(log2([FrequencySpace(1) FrequencySpace(1)]),[0 max(MergedD(X))],'k','linewidth',2);
    plot(log2([FrequencySpace(end) FrequencySpace(end)]),[0 max(MergedD(X))],'k','linewidth',2);
    LogXTick = get(gca,'XTick');
    NonLogXTick = [];
    for TickNum = 1:length(LogXTick)
        NonLogXTick{TickNum} = [ num2str(LogXTick(TickNum)) ' / ' num2str(2^LogXTick(TickNum)) ];
    end
    set(gca,'XTickLabel',NonLogXTick);
    xlabel('Freq. (oct./Hz)');
end

