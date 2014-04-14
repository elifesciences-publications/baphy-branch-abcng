function [f,D0information] = DrawDistribution(DistributionName,DistributionPara,X)

x = X;	% x-abscissa used for normalizing distribution function area
switch DistributionName
    case 'uniform'
        mu = DistributionPara(1);
        HalfCutOct = DistributionPara(2)/2;
        ConstantValue = 1/(2*HalfCutOct);
        g =  @(x,x1,x2,ConstantValue) (x>x1) .* (x<x2) .* ConstantValue;
        f =  @(x) g(x,mu-HalfCutOct,mu+HalfCutOct,ConstantValue);
	case 'random_spectra'
        DistriBinNb = 8;
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
        DistriBinNb = 8;
        Quantal_Delta = 30;  % in %
        mu = DistributionPara(1);        
        HalfCutOct = DistributionPara(2)/2;
        DCoffset = 1/(2*HalfCutOct);
        SeedPerm = DistributionPara(3);    
        QuantalWeights = [-1 -1 -1 0 0 1 1 1];
        UniqueIniDistriNum = DistributionPara(4);         % used to have uniform distribution of levels in all channels
        IniDistriNum = mod(UniqueIniDistriNum-1,DistriBinNb)+1;
        BlockNb = ((UniqueIniDistriNum-IniDistriNum)/DistriBinNb) + 1;
        
        DeltasBlock = BuildDeltasBlock(QuantalWeights,BlockNb*SeedPerm);   % The same block is built for the [n,n+DistriBinNb-1] following D0s
                                                                           %with uniform probability of -1 and +1 bins.
        Deltas = DeltasBlock(IniDistriNum,:);
        Deltas = [-100/Quantal_Delta Deltas -100/Quantal_Delta];
        Deltas = Deltas*Quantal_Delta;
        Fbins = [0 mu-HalfCutOct mu-(HalfCutOct-HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-2*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-3*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-4*HalfCutOct/(DistriBinNb/2)) ...
            mu-(HalfCutOct-5*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-6*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-7*HalfCutOct/(DistriBinNb/2)) mu-(HalfCutOct-8*HalfCutOct/(DistriBinNb/2))];
        
        g = @(x,Fbins,Deltas,DCoffset) DCoffset * ( 1+ Deltas( cell2mat(arrayfun(@(x)find(x>=(Fbins),1,'last'),x,'UniformOutput',0)) )/100 );
        f = @(x) g(x,Fbins,Deltas,DCoffset);            
    case 'increment'
        DistriBinNb = 8;
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
        Decrement = ConstantValue*PercentChange/3;
        g =  @(x,FBins2Change,Increment ,x3,x4,Decrement,h) ( ( (x>=FBins2Change(1,1)) .* (x<FBins2Change(1,2)) ) | ( (x>=FBins2Change(2,1)) .* (x<FBins2Change(2,2)) ) ).* (h(2.^x)+Increment) + ( ( not( (x>=FBins2Change(1,1)) .* (x<FBins2Change(1,2)) ) & not( (x>=FBins2Change(2,1)) .* (x<FBins2Change(2,2)) ) ) .* ((x>=x3) .* (x<x4)) ) .* (h(2.^x)-Decrement);
        f =  @(x) g(x,FBins2Change,Increment ,x3,x4,Decrement,h);
end
if exist('Deltas','var'); D0information = Deltas; else D0information = []; end
% Normalize curve area to 1
CurveArea = trapz(log2(x),f(log2(x)));
NormFactor = 1/CurveArea;
Normf = @(x,K) f(x)*K;
f = @(x) Normf(log2(x),NormFactor);


function DeltasBlock = BuildDeltasBlock(QuantalWeights,SeedPerm)
RPerm = RandStream('mrg32k3a','Seed',SeedPerm);   % mcg16807 is fucked up
for BinNum = 1:length(QuantalWeights)
    DeltasBlock(BinNum,:) = [QuantalWeights((end-BinNum+2):end) QuantalWeights(1:(end-BinNum+1))];
end
DeltasBlock = DeltasBlock(RPerm.randperm(length(QuantalWeights)),:);
DeltasBlock = DeltasBlock(:,RPerm.randperm(length(QuantalWeights)));


