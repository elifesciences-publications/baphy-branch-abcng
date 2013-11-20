function [moments,distances] = PlotDistributions(o,PlotD2)
% Method of class TextureMorphing to plot distributions (D1,D2 and Merged).
%% PARAMETERS    
Par = get(o,'Par');
DifficultyLvl = [Par.DifficultyLvl_KeepBody ; Par.DifficultyLvl_KeepTails];
MorphingNb = max(get(o,'MorphingTypeByInd'));

if nargin<2; PlotD2 = 0; end
FrozenPatternsNb = 16;
ConditionNb = get(o,'MaxIndex');
GenerateFrozen = 0;
NicePlotConfig;
if strcmp(Par.Inverse_D1D2,'yes'); ReverseNb = 1; else ReverseNb = 0; end

%% CREATION OF THE SOUND OBJECT
MaxIndex = get(o,'MaxIndex');
sF = get(o,'SamplingRate');
% ToneDuration = str2num( get(o,'ToneDuration') );
ToneDuration = Par.ToneDuration;
FrequencySpace = get(o,'FrequencySpace'); 
XDistri = get(o,'XDistri');
D1 = get(o,'D1'); MergedD_KeepBody = get(o,'MergedD_KeepBody'); MergedD_KeepTails = get(o,'MergedD_KeepTails');
D2s{1,:} = MergedD_KeepBody; D2s{2,:} = MergedD_KeepTails;

%% CREATION/PLOT OF THE STIMULUS
if PlotD2
    figure('name','Distributions');
    subplot(MorphingNb+1,1,1);
end
% for Global_TrialNb = 1:3
% 	IsFef = []; Mode = []; 
%     IndexNum = 0;
%     for Index = 1:Par.DifficultyLvlNb
%         IndexNum = IndexNum + 1;
%         D2 = D2s{IndexNum};
%         [w,ev,o,FrozenToneMatrix,S1Matrix,S2Matrix] = waveformOutputToneMatrix(o,Index,IsFef,Mode,Global_TrialNb,GenerateFrozen);
%         SummedToneMatrix(:,Global_TrialNb) = sum(FrozenToneMatrix,2) + sum(S1Matrix,2);
%         SummedToneMatrix(:,Global_TrialNb) = SummedToneMatrix(:,Global_TrialNb)*max(D1(XDistri))/max(SummedToneMatrix(:,Global_TrialNb));
%         SummedToneMatrix2{IndexNum}(:,Global_TrialNb) = sum(S2Matrix,2);
%         SummedToneMatrix2{IndexNum}(:,Global_TrialNb) = SummedToneMatrix2{IndexNum}(:,Global_TrialNb)*max(D2(XDistri))/max(SummedToneMatrix2{IndexNum}(:,Global_TrialNb));    
%     end
% end
% SummedToneMatrix = mean(SummedToneMatrix,2); SummedToneMatrix2{1} = mean(SummedToneMatrix2{1},2); SummedToneMatrix2{2} = mean(SummedToneMatrix2{2},2);
% bar(log2(FrequencySpace),SummedToneMatrix);
hold all; plot(log2(XDistri),D1(XDistri),'r');
xlabel('Tone freq. (oct.)'); ylabel('Original distribution');

%% PLOT D2
cm = colormap(lines(Par.DifficultyLvlNb));
if PlotD2
    for Index = 1:Par.DifficultyLvlNb
        if MorphingNb > 2
            for BinNum = 1:MorphingNb
                subplot(MorphingNb+1,1,BinNum+1); hold all;
                D2 = D2s{1}{Index,BinNum};
                %bar(log2(FrequencySpace),SummedToneMatrix2{1});    
                AreaOfThis = trapz(log2(XDistri),D2(XDistri));
                hold all; plot(log2(XDistri),D2(XDistri),'color',cm(Par.DifficultyLvlNb-Index+1,:),'displayname',['A=' num2str(AreaOfThis)]);
            end
        elseif MorphingNb == 2
            subplot(3,1,2); hold all; ylabel('MergedD KeepBody');
            D2 = D2s{1}{Index};
            %bar(log2(FrequencySpace),SummedToneMatrix2{1});    
            AreaOfThis = trapz(log2(XDistri),D2(XDistri));
            hold all; plot(log2(XDistri),D2(XDistri),'color',cm(Par.DifficultyLvlNb-Index+1,:),'displayname',['A=' num2str(AreaOfThis)]);
            subplot(3,1,3); hold all; ylabel('MergedD KeepTails');
            D2 = D2s{2}{Index};
            %bar(log2(FrequencySpace),SummedToneMatrix2{2});     
            AreaOfThis = trapz(log2(XDistri),D2(XDistri));
            hold all; plot(log2(XDistri),D2(XDistri),'color',cm(Index,:),'displayname',['A=' num2str(AreaOfThis)]);  
            xlabel('Tone freq. (oct.)')   
        end
    end
end

%% DRAW SAMPLES IF MOMENTS ARE NEEDED
if nargout>0
    SampleNb = 75000;
    X = XDistri;
    clear UniIndex
    Distribution = D1;
    % SamplesToneFrequencies = slicesample(IniSeed,N,'pdf',Distribution,'thin',5,'burnin',1000);
    CumDistri = cumsum(Distribution(X));
    CumDistri = CumDistri/max(CumDistri);

    [FirstCumDistri,FirstUniIndex] = unique(CumDistri,'first');
    [LastCumDistri,LastUniIndex] = unique(CumDistri,'last');
    MidIndex = round(length(LastUniIndex)/2);
    UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
    UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
    UniX = X(UniIndex);
    CumDistri = CumDistri(UniIndex);
    CumDistri(1) = 0;
    ToneFrequencies = interp1(CumDistri,UniX,rand(1,SampleNb));
    [mimi,MinInd] = min( abs( repmat(FrequencySpace',1,size(ToneFrequencies,2))-repmat(ToneFrequencies,size(FrequencySpace,2),1) ) ,[], 1 );
    samples = log2(FrequencySpace(MinInd'));

    moments{3} = [mean(samples) var(samples) skewness(samples) kurtosis(samples)];
            
    for Index = 1:Par.DifficultyLvlNb
        for DistriNum = 1:2
            clear UniIndex
            Distribution = D2s{DistriNum}{Index};
            % SamplesToneFrequencies = slicesample(IniSeed,N,'pdf',Distribution,'thin',5,'burnin',1000);
            CumDistri = cumsum(Distribution(X));
            CumDistri = CumDistri/max(CumDistri);

            [FirstCumDistri,FirstUniIndex] = unique(CumDistri,'first');
            [LastCumDistri,LastUniIndex] = unique(CumDistri,'last');
            MidIndex = round(length(LastUniIndex)/2);
            UniIndex(1:MidIndex) = max([FirstUniIndex(1:MidIndex) ; LastUniIndex(1:MidIndex)]);
            UniIndex(MidIndex+1:length(LastUniIndex)) = min([FirstUniIndex(MidIndex+1:length(LastUniIndex)) ; LastUniIndex(MidIndex+1:length(LastUniIndex))]);
            UniX = X(UniIndex);
            CumDistri = CumDistri(UniIndex);
            CumDistri(1) = 0;
            ToneFrequencies = interp1(CumDistri,UniX,rand(1,SampleNb));
            [mimi,MinInd] = min( abs( repmat(FrequencySpace',1,size(ToneFrequencies,2))-repmat(ToneFrequencies,size(FrequencySpace,2),1) ) ,[], 1 );
            samples = log2(FrequencySpace(MinInd'));

            moments{DistriNum}(Index,:) = [mean(samples) var(samples) skewness(samples) kurtosis(samples)];
            
%             distances = kldiv_CaseWith0(log2(X),D1(X),D2(X));
        end
    end
end