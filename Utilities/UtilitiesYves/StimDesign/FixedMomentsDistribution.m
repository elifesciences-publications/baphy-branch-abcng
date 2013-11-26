function [ParaGaussians,x,MixtureGaussians,y] = FixedMomentsDistribution()
% Targets
M1Target = 15;
M2Target = 0.05;
M3Target = 2;
M4Target = 4;
MTargets = [M1Target,M2Target,M3Target,M4Target];
% Initial parameters
nGaussians = 3;
IniMeanGaussians = ones(1,nGaussians)*M1Target;
IniVarGaussians = ones(1,nGaussians)*5*M2Target;
IniConstantGaussians = ones(1,nGaussians)*.1;
IniPlayPara = IniMeanGaussians;
IniPlayPara(2,:) = IniVarGaussians;
IniPlayPara(3,:) = IniConstantGaussians;

% FMinSearch
options = optimset('MaxFunEvals',25000,'MaxIter',25000);
PreFactors = IniPlayPara;
ParaGaussians = fminsearch(@(PlayPara) DiffGaussians(PlayPara,MTargets,PreFactors),ones(size(IniPlayPara)),options);
ParaGaussians = abs(ParaGaussians.*PreFactors);
disp(ParaGaussians);
[MixtureGaussians,x] = AssemblyGaussians(ParaGaussians(1,:),ParaGaussians(2,:),ParaGaussians(3,:));
y = discretesample(MixtureGaussians,5000);
y = x(y);
Ms = Moments(y);
disp([Ms trapz(MixtureGaussians)])
disp([MTargets 1])
figure; 
subplot(2,1,1); plot(x,MixtureGaussians);
subplot(2,1,2); hist(y,50);
%%
function DiffG = DiffGaussians(PlayPara,MTargets,PreFactors)
PlayPara = PlayPara.*PreFactors;
MeanGaussians = abs(PlayPara(1,:));
VarGaussians = abs(PlayPara(2,:));
ConstantGaussians = abs(PlayPara(3,:));
[MixtureGaussians,x] = AssemblyGaussians(MeanGaussians,VarGaussians,ConstantGaussians);
y = discretesample(MixtureGaussians,5000);
y = x(y);
Ms = Moments(y);
DiffG = sum( (Ms./MTargets-ones(1,length(MTargets))).^2 );

%%
function [MixtureGaussians,x] = AssemblyGaussians(MeanGaussians,VarGaussians,ConstantGaussians)
x = 0:.5:50;
MixtureGaussians = zeros(1,length(x));
Gauss = @(x,p) p(1)*exp(-((x-p(2)).^2)/(2*p(3)));
for numGauss = 1:length(MeanGaussians)
    p = [ ConstantGaussians(numGauss), MeanGaussians(numGauss), VarGaussians(numGauss) ];
    MixtureGaussians = MixtureGaussians + Gauss(x,p);
end

%%
function Ms = Moments(y)
% Moment functions
M1 = @(y) mean(y);
M2 = @(y) (std(y)/mean(y))^2;
M3 = @(y) (std(y)/mean(y))^3;
M4 = @(y) (std(y)/mean(y))^4;
Ms = [M1(y) M2(y) M3(y) M4(y)];