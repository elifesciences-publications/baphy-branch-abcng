function [f,D0information] = DrawDistribution(DistributionName,DistributionPara,X,DistriBinNb)

x = X;	% x-abscissa used for normalizing distribution function area
switch DistributionName
    case 'uniform'
        mu = DistributionPara(1);
        HalfCutOct = DistributionPara(2)/2;
        ConstantValue = 1/(2*HalfCutOct);
        g =  @(x,x1,x2,ConstantValue) (x>x1) .* (x<x2) .* ConstantValue;
        f =  @(x) g(x,mu-HalfCutOct,mu+HalfCutOct,ConstantValue);
	case 'random_spectra'
        MaxDelta = 50;  % in %
        mu = DistributionPara(1);        
        HalfCutOct = DistributionPara(2)/2;
        DCoffset = 1/(2*HalfCutOct);
        SeedPerm = DistributionPara(3);    
        RPerm = RandStream('mrg32k3a','Seed',SeedPerm);   % mcg16807 is fucked up
        Deltas = ( (RPerm.rand(1,4)-.5)*2 )*MaxDelta;
        Deltas = [Deltas -Deltas];
        Deltas = Deltas(RPerm.randperm(length(Deltas)));
        Deltas = [-100 Deltas -100];
        Fbins = [0 mu-HalfCutOct mu-(HalfCutOct-HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-2*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-3*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-4*HalfCutOct/(DistriBinNb/2)) ...
            mu-(HalfCutOct-5*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-6*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-7*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-8*HalfCutOct/(DistriBinNb/2))];
        
        g = @(x,Fbins,Deltas,DCoffset) DCoffset * (1+ Deltas( cell2mat(arrayfun(@(x)find(x>=(Fbins),1,'last'),x,'UniformOutput',0)) ) /100);
        f = @(x) g(x,Fbins,Deltas,DCoffset);
	case 'quantal_random_spectra'
        mu = DistributionPara(1);        
        HalfCutOct = DistributionPara(2)/2;
        DCoffset = 1/(2*HalfCutOct);
        SeedPerm = DistributionPara(3);    
        if DistriBinNb==8
          QuantalWeights = [-1 -1 -1 0 0 1 1 1];
        elseif DistriBinNb==6
          QuantalWeights = [-1 -1 0 0 1 1];
        else
          error({'Please indicate the quantal weight distribution for this <DistriBinNb>';'<DistriBinNb> should be even'});
        end
        UniqueIniDistriNum = DistributionPara(4);         % used to have uniform distribution of levels in all channels
        Quantal_Delta = DistributionPara(5);                    % in %
        IniDistriNum = mod(UniqueIniDistriNum-1,DistriBinNb)+1;
        BlockNb = ((UniqueIniDistriNum-IniDistriNum)/DistriBinNb) + 1;
        
        DeltasBlock = BuildDeltasBlock(QuantalWeights,BlockNb*SeedPerm);   % The same block is built for the [n,n+DistriBinNb-1] following D0s
                                                                                                                                     %with uniform probability of -1 and +1 bins.
        Deltas = DeltasBlock(IniDistriNum,:);
        Deltas = [-100/Quantal_Delta Deltas -100/Quantal_Delta];
        Deltas = Deltas*Quantal_Delta;
        Fbins = [0 mu-HalfCutOct];
        for BinNum = 1:length(QuantalWeights)
          Fbins = [Fbins  mu-(HalfCutOct-BinNum*HalfCutOct/(DistriBinNb/2))];
        end
        
        g = @(x,Fbins,Deltas,DCoffset) DCoffset * ( 1+ Deltas( cell2mat(arrayfun(@(x)find(x>=(Fbins),1,'last'),x,'UniformOutput',0)) )/100 );
        f = @(x) g(x,Fbins,Deltas,DCoffset);
    case 'increment'
        h = DistributionPara{2};
        DistributionPara = DistributionPara{1};
        mu = DistributionPara(1);
        HalfCutOct = DistributionPara(2)/2;
        ConstantValue = 1/(2*HalfCutOct);
        Bins2Change = DistributionPara(3:4);        
        PercentChange = DistributionPara(5)/100;
        FBins2Change = [mu-(HalfCutOct-(Bins2Change(1)-1)*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-(Bins2Change(1))*HalfCutOct/(DistriBinNb/2))  ; ...
            mu-(HalfCutOct-(Bins2Change(2)-1)*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-(Bins2Change(2))*HalfCutOct/(DistriBinNb/2))  ];
        
        x3 = mu-HalfCutOct; x4 = mu+HalfCutOct;
        Increment = ConstantValue*PercentChange;
        Decrement = ConstantValue*PercentChange/(DistriBinNb/2-1);
        g =  @(x,FBins2Change,Increment ,x3,x4,Decrement,h) ( ( (x>=FBins2Change(1,1)) .* (x<FBins2Change(1,2)) ) | ( (x>=FBins2Change(2,1)) .* (x<FBins2Change(2,2)) ) ).* (h(2.^x)+Increment) + ( ( not( (x>=FBins2Change(1,1)) .* (x<FBins2Change(1,2)) ) & not( (x>=FBins2Change(2,1)) .* (x<FBins2Change(2,2)) ) ) .* ((x>=x3) .* (x<x4)) ) .* (h(2.^x)-Decrement);
        f =  @(x) g(x,FBins2Change,Increment ,x3,x4,Decrement,h);
    case 'moving'
        D0 = DistriBinNb;
        D0values = sort(unique(D0)); D0values = D0values(2:end);  % exclude 0
        mu = DistributionPara(1); HalfCutOct = DistributionPara(2)/2; DCoffset = 1/(2*HalfCutOct);
        MovingSpeed = DistributionPara(3); MovingDuration = DistributionPara(4); MovingTimeStep = DistributionPara(5);
        
        preD0nb = round(MovingDuration/MovingTimeStep);
        DistanceToD0 = MovingSpeed*MovingDuration;
        preD0(1:preD0nb,1) = -100; preD0(1:preD0nb,length(D0)) = -100;
        BalanceMediumNum = 1; BalanceMediumValues = [-1 1]; BalanceMediumValues = BalanceMediumValues(randperm(2));
        for BinNum = 2:(length(D0)-1)
            switch find(D0values==D0(BinNum))
                case 1
                    preD0(1,BinNum) = D0(1,BinNum)+DistanceToD0;
                case 2
                    if BalanceMediumValues(BalanceMediumNum)==1
                        preD0(1,BinNum) = D0(1,BinNum)+DistanceToD0;
                    elseif BalanceMediumValues(BalanceMediumNum)==-1
                        preD0(1,BinNum) = D0(1,BinNum)-DistanceToD0;
                    end
                    BalanceMediumNum = BalanceMediumNum+1;
                case 3
                    preD0(1,BinNum) = D0(1,BinNum)-DistanceToD0;
            end
        end
        preD0(2:preD0nb,:) = interp1([1 preD0nb+1],[preD0(1,:) ; D0],2:preD0nb);
        D0 = preD0; Deltas = preD0;
        Fbins = [0 mu-HalfCutOct];
        for BinNum = 1:(size(D0,2)-2)
          Fbins = [Fbins  mu-(HalfCutOct-BinNum*HalfCutOct/((size(D0,2)-2)/2))];
        end
        
        for preD0num = 1:preD0nb
            DeltasT = Deltas(preD0num,:);
            g = @(x,Fbins,DeltasT,DCoffset) DCoffset * ( 1+ DeltasT( cell2mat(arrayfun(@(x)find(x>=(Fbins),1,'last'),x,'UniformOutput',0)) )/100 );
            f{preD0num} = @(x) g(x,Fbins,DeltasT,DCoffset);
        end
end
if exist('Deltas','var'); D0information = Deltas; else D0information = []; end
% Normalize curve area to 1
if length(f)==1
    CurveArea = trapz(log2(x),f(log2(x)));
    NormFactor = 1/CurveArea;
    Normf = @(x,K) f(x)*K;
    f = @(x) Normf(log2(x),NormFactor);
    if any(f(x)<0)
      error('Please adjust Difficulty level')
    end
else
    fStock = f;
    for fNum = 1:length(fStock)
        f = fStock{fNum};
        CurveArea = trapz(log2(x),f(log2(x)));
        NormFactor = 1/CurveArea;
        Normf = @(x,K) f(x)*K;
        f = @(x) Normf(log2(x),NormFactor);
        if any(f(x)<0)
          error('Please adjust Difficulty level')
        end
        fStock{fNum} = f;
    end
    f = fStock;
end

function DeltasBlock = BuildDeltasBlock(QuantalWeights,SeedPerm)
RPerm = RandStream('mrg32k3a','Seed',SeedPerm);   % mcg16807 is fucked up
for BinNum = 1:length(QuantalWeights)
    DeltasBlock(BinNum,:) = [QuantalWeights((end-BinNum+2):end) QuantalWeights(1:(end-BinNum+1))];
end
DeltasBlock = DeltasBlock(RPerm.randperm(length(QuantalWeights)),:);
DeltasBlock = DeltasBlock(:,RPerm.randperm(length(QuantalWeights)));


