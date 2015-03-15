function [D0,ChangeD,DOinformation,Stimulus1,Stimulus2] = BuildMorphing(varargin)

D0type = varargin{1};
Dtype = varargin{2};
D0para = varargin{3};
Dpara = varargin{4};
DistriBinNb = varargin{5};
X = varargin{6};
MorphingNum = varargin{7};
DiffLvl = varargin{8};
PlotMe = varargin{9};
sF = varargin{10};
FrequencySpace = varargin{11};
[D0,DOinformation] = DrawDistribution(D0type,D0para,X,DistriBinNb);   % so far, only uniform or random_spectra (seed is given for random_spectra)
LineName = [MorphingNum ' ' num2str(DiffLvl) '%'];
 
D2paraTemp = Dpara; clear Dpara; Dpara{1} = [D2paraTemp DiffLvl]; Dpara{2} = D0;
if ~isempty(strfind(Dtype,'increm')); Dtype = 'increment'; end
ChangeD = DrawDistribution(Dtype,Dpara,X,DistriBinNb);

% Build the stimulus from the 2 distributions
if nargout>3 || (nargin>=7 && PlotMe)
    Stimulus1 = AssemblyTones(FrequencySpace,D0,X,3,sF,PlotMe); Stimulus2 = AssemblyTones(FrequencySpace,ChangeD,X,3,sF,PlotMe,LineName);
end
if nargin>=7 && PlotMe
    plot(log2([FrequencySpace(1) FrequencySpace(1)]),[0 max(ChangeD(X))],'k','linewidth',2);
    plot(log2([FrequencySpace(end) FrequencySpace(end)]),[0 max(ChangeD(X))],'k','linewidth',2);
    LogXTick = get(gca,'XTick');
    NonLogXTick = [];
    for TickNum = 1:length(LogXTick)
        NonLogXTick{TickNum} = [ num2str(LogXTick(TickNum)) ' / ' num2str(2^LogXTick(TickNum)) ];
    end
    set(gca,'XTickLabel',NonLogXTick);
    xlabel('Freq. (oct./Hz)');
end

