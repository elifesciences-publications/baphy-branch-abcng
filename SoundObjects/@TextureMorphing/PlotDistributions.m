function [] = PlotDistributions(o,PlotDbis,DistributionType,Global_TrialNb)
% Method of class TextureMorphing to plot distributions (D1,ChangeD and Merged).
%% PARAMETERS   
if nargin<4; Global_TrialNb = 1; end
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
Index = 1;
[ w , ev , o , D0 ] = waveform(o,Index,[],[],Global_TrialNb);

%% CREATION/PLOT OF THE STIMULUS
if PlotDbis
    MorphingNb = get(o,'MorphingNb');
    MorphingNb = MorphingNb(DistributionType);
    CoLineNb = ceil(sqrt(MorphingNb));
    figure('name','Distributions');
    subplot(CoLineNb+1,CoLineNb,1:CoLineNb);
end
hold all; plot(log2(XDistri),D0(XDistri),'k','linewidth',3); 
ylim([0 1.2]); xlabel('Tone freq. (oct.)'); ylabel('Original distribution');

%% PLOT D1 or D2
% LOAD THE DESIRED Changed Distributions
if PlotDbis
    DistributionTypeByInd = get(o,'DistributionTypeByInd');
    MorphingTypeByInd = get(o,'MorphingTypeByInd');
    DifficultyLvlByInd = get(o,'DifficultyLvlByInd');
    ReverseByInd = get(o,'ReverseByInd');
    
    MorphingNb = get(o,'MorphingNb');
    MorphingNb = MorphingNb(DistributionType);
    DifficultyLvl = str2num( get(o,['DifficultyLvl_D' num2str(DistributionType)]) );
    cm = colormap(lines(length(DifficultyLvl)));    
    for DifficultyNum = 1:length(DifficultyLvl)
        for BinNum = 1:MorphingNb
            subplot(CoLineNb+1,CoLineNb,BinNum+CoLineNb); hold all;
            Index = find( DifficultyLvlByInd==DifficultyNum & BinNum==MorphingTypeByInd & DistributionTypeByInd==DistributionType );
            [ w , ev , o , D0 , ChangeD] = waveform(o,Index,[],[],Global_TrialNb);            
            AreaOfThis = trapz(log2(XDistri),ChangeD(XDistri));
            hold all; plot(log2(XDistri),ChangeD(XDistri),'linewidth',3,'color',cm(length(DifficultyLvl)-DifficultyNum+1,:),'displayname',['A=' num2str(AreaOfThis)]);
            plot(log2(XDistri),D0(XDistri),'k','linewidth',3); 
            ylim([0 1.2]); 
        end
    end
end
