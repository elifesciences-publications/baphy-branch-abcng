function PoissonSamples = PoissonProcessPsychophysics(lambda,Tmax,nSamples,Rgenerator)
if nargin <4; Rgenerator = RandStream('mt19937ar','Seed',rand(1,1)*1000); end
% Example call: PoissonSamples = PoissonProcessPsychophysics(.15,10,100)
reset(Rgenerator)
X = 0:.1:Tmax;
ExpDecay = @(lambda,X) lambda*exp(-lambda*X);

HighX = X(end):.1:(10*X(end));
Offset = trapz( HighX , ExpDecay(lambda,HighX)) / (X(end)-X(1));
OffsetExpDecay = @(lambda,X,Offset) ExpDecay(lambda,X)+Offset;

% CumDistri = cumsum(OffsetExpDecay(lambda,X,Offset));
% CumDistri = CumDistri/max(CumDistri);
% PoissonSamples = interp1(CumDistri,X,Rgenerator.rand(nSamples,1));
PoissonSamples = interp1(OffsetExpDecay(lambda,X,Offset),X,Rgenerator.rand(nSamples,1)*(OffsetExpDecay(lambda,X(1),Offset)-OffsetExpDecay(lambda,X(end),Offset))+OffsetExpDecay(lambda,X(end),Offset));