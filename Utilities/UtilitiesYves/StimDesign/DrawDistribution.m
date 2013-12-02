function [f,Moments] = DrawDistribution(DistributionName,DistributionPara,X,D1,D2,ThreshDeviantTones,MorphingCategory)
StepF = @(x)sign(x).*(sign(x)+1)/2;  % null function value for x<=0 !! Pb since (0*nan = nan) and (0*inf = nan)
x = X;                               % x-abscissa used for normalizing distribution function area
switch DistributionName
    case 'normal'
        mu = DistributionPara(1);
        sigma = DistributionPara(2);
        Distribution = @(x,mu,sigma) (1/(2*sigma*sqrt(2*pi))) *...
            exp(- (x-mu).^2/(2*sigma^2));
        f = @(x)Distribution(x,mu,sigma);
        Moments = [mu sigma^2 0 0];
    case 'laplace'
        mu = DistributionPara(1);
        b = DistributionPara(2);
        Distribution = @(x,mu,b) (1/(2*b)) * exp(-abs(x-mu)/b);        
        f = @(x)Distribution(x,mu,b);
        Moments = [mu 2*b^2 0 3];  
    case 'cauchy'
        x0 = DistributionPara(1);
        gamma = DistributionPara(2);
        Distribution = @(x,x0,gamma) ( 1./ ( (pi*gamma) * (1+((x-x0)./gamma).^2) ) );        
        f = @(x)Distribution(x,x0,gamma);
        Moments = [x0 0 0 0];      
    case 'offset_normal'
        mu = DistributionPara(1);
        sigma = DistributionPara(2);
        HalfCutOct = DistributionPara(3)/2;
        NonTruncatedDistribution = @(x,mu,sigma) (1/(2*sigma*sqrt(2*pi))) *...
            exp(- (log2(x)-mu).^2/(2*sigma^2));
        f = @(x)TruncatedDistribution(@(x)NonTruncatedDistribution(x,mu,sigma),x,HalfCutOct,mu);
        Moments = [0 0 0 0];      
    case 'offset_normal_smooth_tails'
        mu = DistributionPara(1);
        sigma = DistributionPara(2);
        HalfCutOct = DistributionPara(3)/2;
        NonTruncatedDistribution = @(x,mu,sigma) (1/(2*sigma*sqrt(2*pi))) *...
            exp(- (log2(x)-mu).^2/(2*sigma^2));
        BasalLvl = max( NonTruncatedDistribution( mu.*(2.^(-(4/24):(1/24):(4/24))) ,mu,sigma) )/100;
        f = @(x)TruncatedDistributionWithSmoothTails(@(x)NonTruncatedDistribution(x,mu,sigma),x,HalfCutOct,mu,BasalLvl);
        Moments = [0 0 0 0];  
	case 'shuffle_normal'        % from offset_normal
        mu = DistributionPara(1);
        sigma = DistributionPara(2);
        HalfCutOct = DistributionPara(3)/2;
        WidthCreneau = DistributionPara(4);
        RandSeed = DistributionPara(5);
        s = RandStream('mt19937ar','Seed',RandSeed);
        NonTruncatedDistribution = @(x,mu,sigma) (1/(2*sigma*sqrt(2*pi))) *...
            exp(- (log2(x)-mu).^2/(2*sigma^2));
        g = @(x)TruncatedDistribution(@(x)NonTruncatedDistribution(x,mu,sigma),x,HalfCutOct,mu);
        f = @(x)ShuffleCreneau(x,g,WidthCreneau,HalfCutOct,s,mu);
        Moments = [0 0 0 0];
    case 'creneau_normal'         % from offset_normal
        mu = DistributionPara(1);
        sigma = DistributionPara(2);
        HalfCutOct = DistributionPara(3)/2;
        WidthCreneau = DistributionPara(4);
        SignFirstCreneau = DistributionPara(5);
        Increment = DistributionPara(6);
        NonTruncatedDistribution = @(x,mu,sigma) (1/(2*sigma*sqrt(2*pi))) *...
            exp(- (log2(x)-mu).^2/(2*sigma^2));
        g = @(x)TruncatedDistribution(@(x)NonTruncatedDistribution(x,mu,sigma),x,HalfCutOct,mu);
        f = @(x)CutCreneau(x,g,WidthCreneau,SignFirstCreneau,Increment,HalfCutOct,mu);
        Moments = [0 0 0 0];
    case 'uniform'
        mu = DistributionPara(1);
        HalfCutOct = DistributionPara(2)/2;
        ConstantValue = 1/(2*HalfCutOct);
        g =  @(x,x1,x2,ConstantValue) (x>x1) .* (x<x2) .* ConstantValue;
        f =  @(x) g(x,mu-HalfCutOct,mu+HalfCutOct,ConstantValue);
        Moments = [0 0 0 0];
    case 'almost_uniform'
        DistriBinNb = 4;
        mu = DistributionPara(1);
        HalfCutOct = DistributionPara(2)/2;
        ConstantValue = 1/(2*HalfCutOct);
        PercentChange = DistributionPara(3)/100;
        Bin2Change = DistributionPara(4);
        if Bin2Change ==1; x1 = mu-HalfCutOct; x2 = mu-HalfCutOct/2;
        elseif Bin2Change == 2; x1 = mu-HalfCutOct/2; x2 = mu;
        elseif Bin2Change == 3; x1 = mu; x2 = mu+HalfCutOct/2;
        elseif Bin2Change == 4; x1 = mu+HalfCutOct/2; x2 = mu+HalfCutOct; end    
        x3 = mu-HalfCutOct; x4 = mu+HalfCutOct;
        ChangedConstantValue = ConstantValue*(1+PercentChange);
        UpdatedConstantValue = ConstantValue*(1-PercentChange/3);
        g =  @(x,x1,x2,ChangedConstantValue ,x3,x4,UpdatedConstantValue) (x>=x1) .* (x<x2) .* ChangedConstantValue + ( not((x>=x1) .* (x<x2)) .* ((x>=x3) .* (x<x4)) ) .* UpdatedConstantValue;
        f =  @(x) g(x,x1,x2,ChangedConstantValue ,x3,x4,UpdatedConstantValue);
        Moments = [0 0 0 0];        
        
%         mu = DistributionPara(1); F0 = mu;
%         sigma = DistributionPara(2);
%         HalfCutOct = DistributionPara(3)/2;
%         NonTruncatedDistribution = @(x,mu,sigma) (1/(2*sigma*sqrt(2*pi))) *...
%             exp(- (x-mu).^2/(2*sigma^2));
%         LeftFreqRange = (F0-HalfCutOct) : .5 : (F0+HalfCutOct);
%         LeftArea = trapz(log(LeftFreqRange)/log(2) , NonTruncatedDistribution(log(LeftFreqRange)/log(2),mu,sigma));  % Offset due to truncation
%         WholeRange = ;
%         TotalArea = trapz( log(WholeRange)/log(2) , NonTruncatedDistribution(WholeRange,mu,sigma) );
%         Offset = (TotalArea-LeftArea)/(log(LeftFreqRange(end)/LeftFreqRange(1))/log(2));
%         f = @(x)TruncatedDistribution(@(x)NonTruncatedDistribution(x,mu,sigma),x,HalfCutOct,mu,Offset);
        
%     case 'inverse-gaussian'
%         beta = DistributionPara(1);
%         lambda = DistributionPara(2);
%         Distribution = @(x,beta,lambda)diff(X). StepF(x) .* sqrt(lambda./(2*pi*x.^3)) .*...
%             exp(-lambda*(x-beta).^2 ./ (2*beta^2*x) );        
%         f = @(x)Distribution(x,beta,lambda);
%         Moments = [beta beta^3/lambda 3*sqrt(beta/lambda) 15*beta/lambda];
%     case 'gamma'
%         k = DistributionPara(1);
%         theta = DistributionPara(2);
%         Distribution = @(x,k,theta) StepF(x) .* (1/(gamma(k)*theta^k)) *...
%             (x.^(k-1)) .* exp(-x/theta);        
%         f = @(x)Distribution(x,k,theta);
%         Moments = [k*theta k*theta^2 2/sqrt(k) 6/k];
%     case 'log-normal'
%         mu = DistributionPara(1);
%         sigma = DistributionPara(2);
%         Distribution = @(x,mu,sigma) StepF(x) .* (1./(x*sqrt(2*pi*sigma^2))) .* exp(-(log(x)-mu).^2/(2*sigma^2));        
%         f = @(x)Distribution(x,mu,sigma);
%         Moments = [exp(mu+sigma^2/2) (exp(sigma^2)-1)*exp(2*mu+sigma^2) (exp(sigma^2)+2)*sqrt(exp(sigma^2)-1) exp(4*sigma^2)+2*exp(3*sigma^2)+3*exp(2*sigma^2)-6];
    otherwise  % MERGING        
        % Merging: KeepBody or KeepTails
        if nargin<5; disp('You miss inputs'); end
        f = @(x)Merge2Distributions(x,D1,D2,ThreshDeviantTones,DistributionName,MorphingCategory);
        Moments = [0 0 0 0];        
end
% Normalize curve area to 1 % for distribution without NaN only
if not(strcmp(DistributionName,'KeepBody')) && not(strcmp(DistributionName,'KeepTails')) && isempty(strfind(DistributionName,'offset'))
    CurveArea = trapz(log2(x),f(log2(x)));
    NormFactor = 1/CurveArea;
    Normf = @(x,K) f(x)*K;
    f = @(x) Normf(log2(x),NormFactor);
elseif not( isempty(strfind(DistributionName,'offset')) ) && not( isempty(strfind(DistributionName,'creneau')) ) &&...
        not( isempty(strfind(DistributionName,'shuffle')) )
    CurveArea = trapz(log2(x),f(x));
    NormFactor = 1/CurveArea;
    Normf = @(x,K) f(x)*K;    
    f = @(x) Normf(x,NormFactor);
else  % After merging
%     disp('Pas de rerenormalisation')
%     disp(trapz(log2(x),f(x)));  
end


function D = TruncatedDistribution(NonTruncatedDistribution,X,HalfCutOct,F0)
InsideLogic = bitand( X>=2^(F0-HalfCutOct) , X<=2^(F0+HalfCutOct) );
D(InsideLogic) = NonTruncatedDistribution(X(InsideLogic));
D(not(InsideLogic)) = 0;
CenterFreqRange = 2^(F0-HalfCutOct) : .01 : 2^(F0+HalfCutOct);
CenterArea = trapz(log(CenterFreqRange)/log(2) , NonTruncatedDistribution(CenterFreqRange));  % Offset due to truncation
TotalFreqRange = 2^(F0-4) : .01 : 2^(F0+4);
TotalArea = trapz(log(TotalFreqRange)/log(2) , NonTruncatedDistribution(TotalFreqRange));
D(InsideLogic) = D(InsideLogic) + ( (TotalArea-CenterArea)/(log(CenterFreqRange(end)/CenterFreqRange(1))/log(2)) ) ;


function D = CutCreneau(X,g,WidthCreneau,SignFirstCreneau,Increment,HalfCutOct,F0)
D = g(2.^X);
CreneauSides = (F0-HalfCutOct) : WidthCreneau : (F0+HalfCutOct);
CreneauSides = [CreneauSides (F0+HalfCutOct)];
if mod(length(CreneauSides),2); CreneauSides(end-1) = []; end
RepeatedX = repmat(X',1,length(CreneauSides)/2);
RepeatedCreneau = repmat(CreneauSides,length(X),1);
InsideLogic = bitand( RepeatedX>=RepeatedCreneau(:,1:2:end) , RepeatedX<=RepeatedCreneau(:,2:2:end) );
InsideLogic = bitand( any(InsideLogic') , X>=(F0-HalfCutOct) );
InsideLogic = bitand( InsideLogic , X<=(F0+HalfCutOct) );
NotInsideLogic = bitand( not(InsideLogic) , X>=(F0-HalfCutOct) );
NotInsideLogic = bitand( NotInsideLogic , X<=(F0+HalfCutOct) );
D(InsideLogic) = g(2.^X(InsideLogic))+SignFirstCreneau*Increment;
D(NotInsideLogic) = g(2.^X(NotInsideLogic))-SignFirstCreneau*Increment;
D(D<0) = 0;


function D = ShuffleCreneau(X,g,WidthCreneau,HalfCutOct,s,F0)
D = g(2.^X);
LeftF = (F0-HalfCutOct);
CreneauSides = (F0-HalfCutOct) : WidthCreneau : (F0+HalfCutOct);
CreneauNb = length(CreneauSides);
reset(s);
ShuffledCreneauNum = randperm(s,length(CreneauSides))-1 ;

CreneauNum = floor((X-LeftF)/WidthCreneau);
InsideLogic = bitand( X>=(F0-HalfCutOct) , X<=(F0+HalfCutOct) );
NewX = X(InsideLogic)-CreneauNum(InsideLogic)*WidthCreneau+ShuffledCreneauNum(CreneauNum(InsideLogic)+1)*WidthCreneau;

D(InsideLogic) = g(2.^NewX);


function D = Merge2Distributions(X,D1,D2,ThreshDeviantTones,What2Do,MorphingCategory)
switch MorphingCategory
    case 'ClampedLimit'
        switch What2Do
            case 'KeepBody'
                InsideLogic = bitand( X>=ThreshDeviantTones(1,1) , X<=ThreshDeviantTones(1,2) );
                D(InsideLogic) = D1(X(InsideLogic));
                D(X<ThreshDeviantTones(1,1)) = D2(X(X<ThreshDeviantTones(1,1)));
                D(X>ThreshDeviantTones(1,2)) = D2(X(X>ThreshDeviantTones(1,2)));
            case 'KeepTails'
                % Keep D1 tails and stick D2 body in between
                InsideLogic = bitor( X<ThreshDeviantTones(1,1) , X>ThreshDeviantTones(1,2) );
                D(InsideLogic) = D1(X(InsideLogic));
                D(not(InsideLogic)) = D2(X(not(InsideLogic)));
        end
    case 'MovingLimit'
        switch What2Do
            case 'KeepBody'
                % Keep D1 body and stick to it D2 tails (defined by the deviant threshold)
                InsideLogic = bitand( X>=ThreshDeviantTones(1,1) , X<=ThreshDeviantTones(1,2) );
                D(InsideLogic) = D1(X(InsideLogic));

                Xdeviant = X(X<ThreshDeviantTones(1,1));
                TranslatedX = ( log(Xdeviant) - log(ThreshDeviantTones(3,1)) ) / (log(ThreshDeviantTones(1,1))-log(ThreshDeviantTones(3,1))); 
                TranslatedX = ( TranslatedX * (log(ThreshDeviantTones(2,1))-log(ThreshDeviantTones(3,1))) ) + log(ThreshDeviantTones(3,1));
        %         TranslatedX = log( X(X<ThreshDeviantTones(1,1)) ) - log(ThreshDeviantTones(1,1)) + log(ThreshDeviantTones(2,1));  % !!Warning!! pass it in log???
                D(X<ThreshDeviantTones(1,1)) = D2(exp(TranslatedX));

                Xdeviant = X(X>ThreshDeviantTones(1,2));
                TranslatedX = ( log(Xdeviant) - log(ThreshDeviantTones(1,2)) ) / (log(ThreshDeviantTones(3,2))-log(ThreshDeviantTones(1,2))); 
                TranslatedX = ( TranslatedX * (log(ThreshDeviantTones(3,2))-log(ThreshDeviantTones(2,2))) ) + log(ThreshDeviantTones(2,2));
        %         TranslatedX = log( X(X>ThreshDeviantTones(1,2)) ) - log(ThreshDeviantTones(1,2)) + log(ThreshDeviantTones(2,2));
                D(X>ThreshDeviantTones(1,2)) = D2(exp(TranslatedX));
            case 'KeepTails'
                % Keep D1 tails and stick D2 body in between
                InsideLogic = bitor( X<ThreshDeviantTones(1,1) , X>ThreshDeviantTones(1,2) );
                D(InsideLogic) = D1(X(InsideLogic));
                TranslatedX = ( log(X(not(InsideLogic))) - log(ThreshDeviantTones(1,1)) ) / (log(ThreshDeviantTones(1,2))-log(ThreshDeviantTones(1,1)));  % !!! for symmetrical distribution
                TranslatedX = ( TranslatedX * (log(ThreshDeviantTones(2,2))-log(ThreshDeviantTones(2,1))) ) + log(ThreshDeviantTones(2,1));   
                D(not(InsideLogic)) = D2(exp(TranslatedX));        
            otherwise
                disp('DistributionName not recognized');         
        end    
end


function D = TruncatedDistributionWithSmoothTails(NonTruncatedDistribution,X,HalfCutOct,F0,BasalLvl)
InsideLogic = bitand( X>=2^(F0-HalfCutOct) , X<=2^(F0+HalfCutOct) );
D(InsideLogic) = NonTruncatedDistribution(X(InsideLogic));

% Add one fastly decayong tail to each side of the truncation to avoid
% binary step and to ease the calculus of the KL-divergence.
Xcut_ = (F0-HalfCutOct);
JunctionValue = NonTruncatedDistribution(2^Xcut_);
LeftD2 = @(X_,Xcut_,BasalLvl,JunctionValue) BasalLvl+exp((log2(X_)-Xcut_)*25).*(JunctionValue-BasalLvl);

Xcut_plus = (F0+HalfCutOct);
JunctionValue = NonTruncatedDistribution(2^Xcut_plus);
RightD2 = @(X_plus,Xcut_plus,BasalLvl,JunctionValue) BasalLvl+exp((Xcut_plus-log2(X_plus))*25)*(JunctionValue-BasalLvl);

CombinedF = @(x,f0,Xcut_,Xcut_plus,BasalLvl,JunctionValue)  ((1-sign(x-f0))/2).*LeftD2(x,Xcut_,BasalLvl,JunctionValue) + ((1+sign(x-f0))/2).*RightD2(x,Xcut_plus,BasalLvl,JunctionValue) ;
ReducedD2 = @(x) CombinedF(x,2^F0,Xcut_,Xcut_plus,BasalLvl,JunctionValue);
        
% D(not(InsideLogic)) = 0;
D(not(InsideLogic)) = ReducedD2(X(not(InsideLogic)));
% CenterFreqRange = 2^(F0-HalfCutOct) : .01 : 2^(F0+HalfCutOct);
CenterFreqRange = 2.^ ( (F0-HalfCutOct):(1/24):(F0+HalfCutOct) );
CenterArea = trapz(log2(CenterFreqRange) , NonTruncatedDistribution(CenterFreqRange));  % Offset due to truncation
TotalFreqRange = 2.^ ( (F0-4):(1/24):(F0+4) );
TotalArea = trapz(log2(TotalFreqRange) , NonTruncatedDistribution(TotalFreqRange));
D(InsideLogic) = D(InsideLogic) + ( (TotalArea-CenterArea)/log2(CenterFreqRange(end)/CenterFreqRange(1)) ) ;