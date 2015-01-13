function PoissonSamples = PoissonProcessPsychophysics(lambda,Tmax,nSamples,Rgenerator,BinToC)
if nargin < 4 || isempty(Rgenerator); Rgenerator = RandStream('mt19937ar','Seed',rand(1,1)*1000); end
if nargin < 5; BinToC = 0; end
% Example call: PoissonSamples = PoissonProcessPsychophysics(.15,10,100)
reset(Rgenerator)
X = 0:.1:Tmax;
ExpDecay = @(lambda,X) lambda*exp(-lambda*X);

HighX = X(end):.1:(10*X(end));
Offset = trapz( HighX , ExpDecay(lambda,HighX)) / (X(end)-X(1));
OffsetExpDecay = @(lambda,X,Offset) ExpDecay(lambda,X)+Offset;

% DISCRETIZE DISTRIBUTIONS
if BinToC>0
    BinX = linspace(0,Tmax,BinToC+1);
    BinX = BinX(1:end-1) + diff(BinX)/2;
    BinP = OffsetExpDecay(lambda,BinX,Offset);
    DrawnP = Rgenerator.rand(nSamples,1)*(OffsetExpDecay(lambda,X(1),Offset)-OffsetExpDecay(lambda,X(end),Offset))+OffsetExpDecay(lambda,X(end),Offset);
    for DrawNum = 1:nSamples; [a,DrawInd(DrawNum)] = min(abs(BinP-DrawnP(DrawNum))); end
    PoissonSamples = BinX(DrawInd);
else
    % CumDistri = cumsum(OffsetExpDecay(lambda,X,Offset));
    % CumDistri = CumDistri/max(CumDistri);
    % PoissonSamples = interp1(CumDistri,X,Rgenerator.rand(nSamples,1));
    PoissonSamples = interp1(OffsetExpDecay(lambda,X,Offset),X,Rgenerator.rand(nSamples,1)*(OffsetExpDecay(lambda,X(1),Offset)-OffsetExpDecay(lambda,X(end),Offset))+OffsetExpDecay(lambda,X(end),Offset));
end


