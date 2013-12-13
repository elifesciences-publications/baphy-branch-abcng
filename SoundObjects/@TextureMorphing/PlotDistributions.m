function [] = PlotDistributions(o,PlotDbis,DistributionType,UniqueIniDistriNum)
% Method of class TextureMorphing to plot distributions (D1,ChangeD and Merged).
%% PARAMETERS   
if nargin<4; UniqueIniDistriNum = 1; end
Par = get(o,'Par');
if nargin<2; PlotDbis = 0; end
NicePlotConfig;

%% CREATION OF THE SOUND OBJECT
MaxIndex = get(o,'MaxIndex');
sF = get(o,'SamplingRate');
% ToneDuration = str2num( get(o,'ToneDuration') );
ToneDuration = Par.ToneDuration;
FrequencySpace = get(o,'FrequencySpace'); 
XDistri = get(o,'XDistri');
D0 = get(o,'D0');
D0 = D0{UniqueIniDistriNum};

%% CREATION/PLOT OF THE STIMULUS
if PlotDbis
    MorphingNb = get(o,'MorphingNb');
    MorphingNb = MorphingNb(DistributionType);
    CoLineNb = ceil(sqrt(MorphingNb));
    figure('name','Distributions');
    subplot(CoLineNb+1,CoLineNb,1:CoLineNb);
end
hold all; plot(log2(XDistri),D0(XDistri),'r'); 
ylim([0 1.2]); xlabel('Tone freq. (oct.)'); ylabel('Original distribution');

%% PLOT D1 or D2
% LOAD THE DESIRED Changed Distributions
if PlotDbis
    MorphingNb = get(o,'MorphingNb');
    MorphingNb = MorphingNb(DistributionType);
    ChangeDistributions = get(o,['D' num2str(DistributionType)]);
    DifficultyLvl = str2num( get(o,['DifficultyLvl_D' num2str(DistributionType)]) );
    cm = colormap(lines(length(DifficultyLvl)));    
    for DifficultyNum = 1:length(DifficultyLvl)
        for BinNum = 1:MorphingNb
            subplot(CoLineNb+1,CoLineNb,BinNum+CoLineNb); hold all;
            ChangeD = ChangeDistributions{DifficultyNum,BinNum,UniqueIniDistriNum};
            AreaOfThis = trapz(log2(XDistri),ChangeD(XDistri));
            hold all; plot(log2(XDistri),ChangeD(XDistri),'color',cm(length(DifficultyLvl)-DifficultyNum+1,:),'displayname',['A=' num2str(AreaOfThis)]);
            plot(log2(XDistri),D0(XDistri),'k'); 
            ylim([0 1.2]); 
        end
    end
end
