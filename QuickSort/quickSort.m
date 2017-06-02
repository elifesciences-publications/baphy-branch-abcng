function quickSort(varargin)
% R = quickSort(Data,varargin)
%
% possible Parameters:
%
% Threshold [Double | NaN] : initial Threshold for triggering
% ClustSel [Vector] : Cluster Selection
% SR [Hz, dim. Var.]  Sampling Rate
% ISIDur [ms, dim. Var.] Spike Duration
% PreDur [ms, dim. Var.] Displayed Duration before Spike
% PostDur [ms, dim. Var.] Displayed Duration after Spike
% OverSampleFact [Double] OverSample Data For Analysis
%
% The following results will be extracted:
%  STs: Spiketimes for each unit
%  mWaves : Average Waveforms for each of the Delays
%  SNRs : averge Signal-to-Noise ratio for each unit
%
% TODO:
% DISPLAY
%   - Fuse ISI Hists & PSTHs for a set of clusters
% ANALYSIS
%   - add separation measure
%   - introduce alternate basedata for PCA
%   - make more efficient (optimize plotting speed by reusing plothandles)
%   - check/increase minimal ISI
%   - select PCA examples based on maximum of mWave
% INTERACTION
%   - fuse with or branch from REPLAY (for selection & control)
%
% AUTOMATIC SORTING
% - Similarity estimated by dynamics (time from min to max, halfwidths, shape of PSTH, e.g. time of peak)
%
% SEE ALSO :

%% SET VARIABLES
global QG U Verbose Plotting; if isempty(U) U = units; end
P = parsePairs(varargin);

if ~isfield(P,'STs') P.STs = NaN; end
if ~isfield(P,'Threshold') P.Threshold = -4; end
if ~isfield(P,'LargeThreshold') P.LargeThreshold = 100; end
if ~isfield(P,'ThreshType') P.ThreshType = 'Amplitude'; end
if ~isfield(P,'ClustSel') ClustSel = NaN; else ClustSel = P.ClustSel; end
if ~isfield(P,'NVec') | isnan(P.NVec) P.NVec = 10; end
if ~isfield(P,'TrialIndices') P.TrialIndices = 1; end
if ~isfield(P,'PermInd') P.PermInd = [ ]; end
if ~isfield(P,'Linkage') P.Linkage = 'ward'; end
if ~isfield(P,'SR') P.SR = 31.25*U.kHz; end
if ~isfield(P,'ISIDur') P.ISIDur = 1.5*U.ms; end
if ~isfield(P,'PreDur') P.PreDur = 2*U.ms; end
if ~isfield(P,'PostDur') P.PostDur = 2.5*U.ms; end
if ~isfield(P,'StimStart') P.StimStart = 0; end
if ~isfield(P,'StimStop') P.StimStop = 0; end
if ~isfield(P,'Nmax') P.Nmax = 3000; end
if ~isfield(P,'HideNoise') P.HideNoise = 0; end
if ~isfield(P,'Verbose') P.Verbose = 0; end
if ~isfield(P,'FIG') P.FIG = mod(round(now*1e6),1e9); end
if ~isDimVar(P.SR) P.SR = P.SR*U.Hz; end
if ~isDimVar(P.ISIDur) P.ISIDur = P.ISIDur*U.ms; end
if ~isDimVar(P.PreDur) P.PreDur = P.PreDur*U.ms; end
if ~isDimVar(P.PostDur) P.PostDur = P.PostDur*U.ms; end
if ~isfield(P,'SaveSorter') P.SaveSorter = 0; end
if ~isfield(P,'TimeIndex') P.TimeIndex = 0; end

checkField(P,'Electrode');
checkField(P,'Sorter');
checkField(P,'Identifier','');
checkField(P,'SortInfo',[]);

%if strcmpi(Data,'test') [Data,P.TrialIndices] = LF_createTestData; end

try import java.awt.Robot; QG.Mouse = Robot; end

% CREATE ID
FID = ['F',n2s(P.FIG)];

% ADD RECORDING IFNO AND FID TO QG
QG.(FID).P = P; QG.(FID).FIG = P.FIG;

% Reject amplitude artifacts
LF_excludeLargeEvents(FID);

% NORMALIZE DATA INTO SD UNITS
SD = std(QG.(FID).Data); 
NSteps = length(QG.(FID).Data);
QG.(FID).Data = QG.(FID).Data/SD;  

% AVOID DISCRETIZATION PLATEAUS BY ADDING A TINY BIT OF NOISE TO THE DATA
cSteps = round(NSteps/10);
QG.(FID).LData = NSteps/P.SR/U.s; 
for i=1:10
    cInd = [(i-1)*cSteps+1 : min(i*cSteps,length(QG.(FID).Data))];
    QG.(FID).Data(cInd) = QG.(FID).Data(cInd)+1e-10*rand(1,length(cInd));
end

% ASSIGN GLOBAL
LF_assignParameters(FID)

%% BUILD GUI
% PREPARE FIGURE
figure(P.FIG); set(gcf,'WindowStyle','normal'); clf; QG.(FID).GUI.SS = get(0,'ScreenSize');

set(P.FIG,'MenuBar','none','Toolbar','figure',...
    'Position',[10,QG.(FID).GUI.SS(4)-850,1200,800],...
    'DeleteFcn',{@LF_closeFig,FID},'NumberTitle','off',...
    'Name',['QuickSort : ',P.Identifier,' - Electrode ',n2s(P.Electrode)]);

% ADD DATA PLOTS
% PREPARE AXES
DM = HF_axesDivide([.2,.8],1,[0.01,0.01,0.95,0.98],[.07],[]);
DM{2} = DM{2}.*[1,1,1,0.95];
tmp = HF_axesDivide([1],[1.5,1],DM{2}+[0,.12,0,-0.1],[],[.4]);
DC([1:2]) = HF_axesDivide([1.4,1],[1],tmp{1},[.3],[]);
DC([3:5]) = HF_axesDivide([1,1,0.5],[1],tmp{2},[.3],[]);
DC{end+1} = [DC{3}(1),0.04,DC{3}(3),DC{3}(2)-0.06];
DC{end+1} = [DC{4}(1),0.04,DC{4}(3),DC{4}(2)-0.06];

DC{end+1} = [DC{5}(1),0.04,DC{5}(3),DC{5}(2)-0.06];

for i=1:numel(DC)
    QG.(FID).GUI.Axes(i) = axes('Pos',DC{i},QG.FigOpt.AxisOpt{:}); hold on;
    if i==7 set(QG.(FID).GUI.Axes(i),'Visible','Off'); end
end

set(QG.(FID).GUI.Axes(3),'ButtonDownFcn',{@LF_CBF_Raster,FID});
QG.(FID).GUI.Waves = QG.(FID).GUI.Axes(1);
QG.(FID).GUI.Clusters = QG.(FID).GUI.Axes(2);
QG.(FID).GUI.Raster = QG.(FID).GUI.Axes(3);
QG.(FID).GUI.Trace = QG.(FID).GUI.Axes(4);
QG.(FID).GUI.ISI = QG.(FID).GUI.Axes(5);
QG.(FID).GUI.PSTH = QG.(FID).GUI.Axes(6);
QG.(FID).GUI.TraceZoom = QG.(FID).GUI.Axes(7);
QG.(FID).GUI.CC = QG.(FID).GUI.Axes(8);

set(QG.(FID).GUI.Clusters,'ButtonDownFcn',{@Rotator});
set(P.FIG,'WindowButtonUpFcn','global Rotating_ ; Rotating_ = 0;');

% ADD TRACE STEPPING
Strings = {'<','>'}; cPos = get(QG.(FID).GUI.Trace,'Position');
Pos = {[cPos(1),cPos(2)+1.05*cPos(4),cPos(3)/8,cPos(4)/8],...
    [cPos(1)+7/8*cPos(3),cPos(2)+1.05*cPos(4),cPos(3)/8,cPos(4)/8]};
for i=1:2
    QG.(FID).GUI.Linkage = uicontrol('style','pushbutton',...
        'Units','normalized','Position',Pos{i},'FontSize',7,...
        'String',Strings{i},'CallBack',{@LF_CBF_stepTrace,FID,Strings{i}});
end

% ADD THRESHOLD CHANGING
set(QG.(FID).GUI.Waves,'ButtonDownFcn',{@LF_CBF_axisClick,FID});

% ADD MOVIE SLIDER
SliderPos = [DC{2}(1)+1.05*DC{2}(3),DC{2}(2),.02,DC{2}(4)];
QG.(FID).GUI.ClusterSlider = uicontrol('style','slider',...
    'Units','norm','Pos',SliderPos,...
    'Callback',{@LF_CBF_SliderPos,FID},...
    'Value',0,'BackGroundColor',[1,1,1]);
% ADD PLAY BUTTON
Pos = [SliderPos(1),SliderPos(2)+1.01*SliderPos(4),SliderPos(3),0.04];
QG.(FID).GUI.MoviePlayer = uicontrol('style','pushbutton',...
    'Units','normalized','Position',Pos,'FontSize',7,...
    'String','>','CallBack',{@LF_CBF_MoviePlayer,FID});

% ADD CONTROLS
DC = HF_axesDivide([1],[10,1,1],DM{1},[],[.1,.1]);
QG.(FID).GUI.ClusterPos = DC{1};
DC2 = HF_axesDivide([1.3,1.3,0.8,3],[1],DC{2},[0],[]);
% ADD THRESHOLD SELECTOR
QG.(FID).GUI.Threshold = LF_addEdit(P.FIG,...
    DC2{1},n2s(P.Threshold),{@LF_CBF_setThreshold,FID},'Set Threshold (in S.D.)');
% ADD NVEC SELECTOR
QG.(FID).GUI.NVec = LF_addEdit(P.FIG,...
    DC2{2},n2s(P.NVec),{@LF_updateFit,FID},'Set Number of Clusters');
% ADD LINKAGE SELECTOR
QG.(FID).Linkages = {'average','centroid','complete','median','single','ward','weighted'};
QG.(FID).LinkageInd = find(strcmp(P.Linkage,QG.(FID).Linkages));
QG.(FID).GUI.Linkage = LF_addDropdown(P.FIG,...
    DC2{4}-[0,.01,0,0],QG.(FID).Linkages,QG.(FID).LinkageInd,...
    {@LF_CBF_setLinkage,FID},'','Choose Linkage Style for Clustering');

DC2 = HF_axesDivide([1,1,0.2],[1],DC{3},[.3,0.3],[]);
% ADD REFIT BUTTON
QG.(FID).GUI.Fit = LF_addPushbutton(P.FIG,...
    DC2{1},'Cluster',{@LF_updateFit,FID},'Rerun clustering ...');
% ADD SAVING BUTTON
QG.(FID).GUI.Save = LF_addPushbutton(P.FIG,...
    DC2{2},'Save',{@LF_saveResults,FID},'Save fitted cells ...');
% ADD PERMIND CHECK
QG.(FID).GUI.UsePermInd = LF_addCheckbox(P.FIG,...
    DC2{3},1,{@LF_CBF_changePermInd,FID},'Unscramble by condition or show in temporal sequence');
QG.(FID).UsePermInd = 1;

QG.(FID).NewThreshold = 1; QG.(FID).NewSorting =1;
QG.(FID).Threshold = P.Threshold; QG.(FID).NVec = P.NVec;
QG.(FID).CurrentRep = 1;
QG.(FID).WaveOpt = 'individual';
QG.(FID).WaveToggle = 0;

% ADD KEYBOARD CONTROL
set(P.FIG,'KeyPressFcn',{@LF_KeyPress,FID});

%% INITIALIZE FIT
% calls fitting function which updates the current fitting state
% with new NVec, Threshold and other parameters
LF_updateFit([],[],FID)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LF_KeyPress(handle,event,FID)

global QG U
CC = get(handle,'CurrentCharacter');
switch CC
    case 'p'; set(QG.(FID).GUI.UsePermInd,'Value',~get(QG.(FID).GUI.UsePermInd,'Value'));
        LF_CBF_changePermInd(QG.(FID).GUI.UsePermInd,[],FID);
    case 'f';
        MaxSize = get(0,'ScreenSize') + [0,40,0,-90]; cPosition = get(gcf,'Position');
        if cPosition == MaxSize   set(gcf,'Position',QG.(FID).OldPosition);
        else QG.(FID).OldPosition = cPosition; set(gcf,'Position',MaxSize);
        end
    case 'c'; LF_updateFit([],[],FID);
    case 's'; LF_saveResults(obj,event,FID);
    case 'w'; % toggle display of individual or sd waves
        if strcmp(QG.(FID).WaveOpt,'sd') QG.(FID).WaveOpt = 'individual'; else QG.(FID).WaveOpt = 'sd'; end
        QG.(FID).WaveToggle = 1;
        LF_plotWaves(FID);
        LF_collectHandles(FID);
    otherwise
        Num = str2num(CC); NVec = QG.(FID).NVec;
        if ~isempty(Num)
            set(QG.(FID).FIG, 'SelectionType','normal');
            if Num==0
                for i=1:NVec LF_CBF_showCluster(QG.(FID).GUI.ClusterLabels(i),event,FID,i,'off'); end
            elseif Num>0 && Num<=NVec
                LF_CBF_showCluster(QG.(FID).GUI.ClusterLabels(Num),event,FID,Num);
            end
        end
end

function LF_assignParameters(FID)
% ASSIGN GLOBAL VARIABLES
global QG U

P = QG.(FID).P;
QG.(FID).PreSteps = fix(P.SR*P.PreDur);
QG.(FID).PostSteps = fix(P.SR*P.PostDur);
QG.(FID).ISIDurSteps = fix(P.SR*P.ISIDur);
QG.(FID).WaveTime = [-QG.(FID).PreSteps:QG.(FID).PostSteps]/P.SR;
QG.(FID).BackwardSteps = round(P.SR*0.2*U.ms);
QG.(FID).ForwardSteps = round(P.SR*0.5*U.ms);
Center = QG.(FID).PreSteps+1;
QG.(FID).ClustRange = ...
    [Center-QG.(FID).BackwardSteps:Center+QG.(FID).ForwardSteps];
QG.(FID).NTrials = length(QG.(FID).P.TrialIndices);
if isempty(QG.(FID).P.PermInd) | isnan(QG.(FID).P.PermInd)
    QG.(FID).P.PermInd = [1:QG.(FID).NTrials];
end
QG.(FID).TrialBounds = zeros(QG.(FID).NTrials,2);
IndTmp = [QG.(FID).P.TrialIndices;length(QG.(FID).Data)];
for i=1:QG.(FID).NTrials
    QG.(FID).TrialBounds(i,1:2) = IndTmp([i,i+1])';
end
QG.(FID).PlotXMax = max(diff(IndTmp))/P.SR/U.s;
QG.(FID).RecordingBounds(:,1) = [1,find(diff(round(QG.(FID).P.Indices)))+1]';
QG.(FID).RecordingBounds(:,2) = [QG.(FID).RecordingBounds(2:end,1)-1;QG.(FID).NTrials];
QG.(FID).CurrentRecording = 'all';

% SET PLOTTING OPTIONS
QG.Colors.ColorOn = [1,1,1];
QG.Colors.ColorOff = [1,0.9,0.9];
QG.Colors.Panel = [1,1,1];
QG.Colors.Font = [0,0,0];
QG.FigOpt.LineWidth = 3;
QG.FigOpt.LineCol = [.6,.6,.6];
QG.FigOpt.AxisOpt = {'FontSize',8,'Box','on','XGrid','on','YGrid','on'};
QG.FigOpt.AxisLabelOpt = {'FontSize',9};
QG.FigOpt.LineCol = [.6,.6,.6];
QG.FigOpt.FontName = 'Dialog';

%
function LF_CBF_excludeLargeEvents(obj,event,FID)
global QG
QG.(FID).LargeTreshold = str2num(get(obj,'String'));
LF_excludeLargeEvents(FID);
LF_updateFit([],[],FID);

function LF_excludeLargeEvents(FID)
global QG

TempData=QG.(FID).RawData./std(QG.(FID).RawData);
LargeThrshold = QG.(FID).P.LargeThreshold;
spikefs = u2num(QG.(FID).P.SR);
Artifacts = find(TempData > LargeThrshold);
QG.(FID).Data=QG.(FID).RawData;
ArtWin = .5*spikefs; % +/-500 ms zeroing window around an amplitude artifact
for tt = 1:length(Artifacts)
    QG.(FID).Data(Artifacts(tt)-ArtWin:Artifacts(tt)+ArtWin)=0;
end


% ANALYSIS FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LF_updateFit(obj,event,FID)
% UPDATE THE FITTING
global QG;

LF_CBF_setNVec(QG.(FID).GUI.NVec,[],FID);
set(QG.(FID).GUI.Fit,'ForeGroundColor',[1,0,0]);
drawnow

% COLLECT EVENTS (IF NECESSARY)
if QG.(FID).NewThreshold
    LF_collectEvents(FID);
    QG.(FID).NewSorting = 1;
end

% RUN SORTING AND PLOT (IF NECESSARY)
if QG.(FID).NewSorting
    LF_runSorting(FID);
    LF_computeSNR(FID);
    LF_setClusterColors(FID);
    LF_showClusterSelect(FID);
    LF_plotFits(FID);
    LF_collectHandles(FID);
end

QG.(FID).NewThreshold = 0; QG.(FID).NewSorting = 0;

set(QG.(FID).GUI.Fit,'ForeGroundColor',[0,0,0]);

%LF_defocus(FID);

function LF_defocus(FID)
global QG
try
    import java.awt.event.*;
    
    FigPos = get(QG.(FID).FIG,'Position');
    QG.Mouse.mouseMove(FigPos(1)+5,FigPos(2)-10);
    QG.Mouse.mousePress(InputEvent.BUTTON1_MASK);
    QG.Mouse.mouseRelease(InputEvent.BUTTON1_MASK)
end

function LF_showClusterSelect(FID)
global QG

NVec = QG.(FID).NVec;
try
    delete(QG.(FID).GUI.ClusterLabels);
    delete(QG.(FID).GUI.ClusterSelects);
    delete(QG.(FID).GUI.ClusterFusion);
    QG.(FID).GUI.ClusterLabels =  zeros(NVec,1);
    QG.(FID).GUI.ClusterSelects =  zeros(NVec,1);
catch; end
DC = HF_axesDivide([0.25,0.75],1,QG.(FID).GUI.ClusterPos,[0.01],[]);
NMaxNormal = max(14,NVec);
NewHeight = NVec/NMaxNormal*DC{1}(4);
DC{1}(2) = DC{1}(2)+DC{1}(4)-NewHeight; DC{1}(4) = NewHeight;

% PLOT THE CLUSTER SEPARATION PLOT
QG.(FID).GUI.ClusterFusion = axes('Position',DC{1}); axis off

% CREATE
for i=1:NVec
    if QG.(FID).GUI.ShowState(i) cColor = QG.Colors.ColorOn; else cColor = QG.Colors.ColorOff; end
    cFrame = [DC{2}(1),1-DC{2}(4)*i/NMaxNormal,DC{2}(3),DC{2}(4)/(1.2*NMaxNormal)];
    cDC = HF_axesDivide([1,3],[1],cFrame,[.2],[]);
    QG.(FID).GUI.ClusterSelects(i) = uicontrol('style','edit',...
        'Units','normalized',...
        'Position',cDC{1}.*[1,1,1,1.2],...
        'String','','ForeGroundColor',[0,0,0],...
        'FontSize',7,...
        'HorizontalAlignment','center',...
        'FontName','Dialog','BackGroundColor',[1,1,1],...
        'Callback',{@LF_showSeparation,FID,i});
%     LS{i} = ['C',n2s(i),' (',sprintf('%1.1f | ',QG.(FID).SNRs(i)),n2s(length(QG.(FID).Inds{i})),')'];
    LS{i} = ['C',n2s(i),' (',sprintf('%1.1f | ',QG.(FID).SNRs(i)),n2s(length(QG.(FID).STs{i})),')'];  % 15/08-YB
    QG.(FID).GUI.ClusterLabels(i) = uicontrol('style','text',...
        'Units','normalized','Enable','inactive',...
        'Position',cDC{2},...
        'String',LS{i},'ForeGroundColor',QG.(FID).Colors{i},...
        QG.FigOpt.AxisLabelOpt{:},'FontWeight','bold',...
        'HorizontalAlignment','left','FontSize',7,...
        'FontName','Dialog','BackGroundColor',cColor,...
        'ButtonDownFcn',{@LF_CBF_showCluster,FID,i});
end

function LF_showSeparation(obj,event,FID,cVec)
global QG

NCells = length(QG.(FID).APInds);
D = QG.(FID).CellSeparation;  k=0;
Dtmp = D; Dtmp(isinf(D)) = NaN;
MaxSep = nanmax(Dtmp(:)); MinSep = nanmin(Dtmp(:));
D(isnan(D))=0; D = D+D';
axes(QG.(FID).GUI.ClusterFusion);
set(QG.(FID).GUI.ClusterFusion,'YDir','reverse'); cla; hold on;
for i=[1:cVec-1,cVec+1:NCells]
    ScaledSep = 1-(D(cVec,i)-MinSep)/(0.5*(MaxSep-MinSep));
    if ScaledSep > 0.5 k=k+1;
        plot(QG.(FID).GUI.ClusterFusion,[-k,-k],[i,cVec],'Color',[ScaledSep,0,0],'LineWidth',(ScaledSep+1));
    end
end;
if k>0 axis([-(k+0.5),-0.5,0.8,NCells+0.8]); end
axis off;

function LF_collectEvents(FID)
% START COLLECTING SPIKES
global QG
FIG = QG.(FID).FIG;
UD = get(FIG,'UserData');
Threshold = QG.(FID).Threshold;
SR = QG.(FID).P.SR;

DataSteps = length(QG.(FID).Data);

% THRESHOLD SPIKES
switch QG.(FID).P.ThreshType
    case 'Amplitude';
        if Threshold > 0  ind = find(QG.(FID).Data>Threshold);
        else ind = find(QG.(FID).Data<Threshold); end
    case 'Rise';
        Threshold = std(diff(QG.(FID).Data))*Threshold;
        if Threshold > 0  ind = find(diff(QG.(FID).Data)>Threshold);
        else ind = find(diff(QG.(FID).Data)<Threshold); end
    otherwise error('ThreshType not implemented!');
end
if isempty(ind) % Possibility to exit with no spikes or change Threshold
    warning('No Spikes found! Choose a lower threshold!'); return;
end
if length(ind) > 1
    dind = diff(ind);  ind2 = find(dind>1);
    SP = zeros(1,length(ind2)+1); SP(1) = ind(1);  SP(2:end) = ind(ind2+1);
else SP = ind; end

Nspikes = length(SP); FiringRate = Nspikes/(length(QG.(FID).Data)/SR); Ncrit = 5;
if Nspikes < Ncrit fprintf(['Only ',n2s(Nspikes),' were found. Proceed with caution!\n']);
else %fprintf(['\n',n2s(Nspikes),' triggers at threshold ',n2s(Threshold),'\n'])
end
clear ind dind

% COLLECT SPIKETIMES
SPmax=zeros(length(SP),2);
iStart = length(find(SP<=QG.(FID).PreSteps))+1;
Walign = zeros(Nspikes,1);
Nspikes = find(SP<length(QG.(FID).Data)-QG.(FID).PostSteps,1,'last');
RemoveInd = [1:iStart-1]; % Remove PreSteps violations
MinSearchSteps =   QG.(FID).ISIDurSteps;
SnippetLength = MinSearchSteps + 2;
CuttingEnd = DataSteps - QG.(FID).PostSteps;
for i=iStart:Nspikes
    Skip = 0;
    Snippet = QG.(FID).Data(SP(i)-1:SP(i)+MinSearchSteps);
    if Threshold > 0    Snippet = -Snippet; end
    [MIN,MinPos] = min(Snippet); % check absolute Minimum first
    if MinPos < SnippetLength Wshift = MinPos - 2;
    else % find smallest local minimum
        LocMinPos = find(diff(sign(diff(Snippet)))==2);
        if isempty(LocMinPos)
            RemoveInd = [RemoveInd,i]; Skip = 1;
        else
            [MIN,MinInd] = min(Snippet(LocMinPos+1));
            Wshift = LocMinPos(MinInd)-1;
        end
    end
    
    if ~Skip
        Walign(i) = SP(i) + Wshift(1);
    end
    if Walign(i) >= CuttingEnd  RemoveInd = [RemoveInd,i]; Skip = 1; end
end
RemainInd = setdiff([1:Nspikes],RemoveInd); Walign = Walign(RemainInd);
Walign = unique(Walign); % remove doubles
Nspikes = length(Walign);

% COLLECT INDIVIDUAL WAVEFORMS
%   SpikeSteps = QG.(FID).PreSteps + QG.(FID).PostSteps + 1;
%   WaveInd = repmat([0:SpikeSteps-1],length(Walign),1);
%   WaveInd = bsxfun(@plus,WaveInd,Walign-QG.(FID).PreSteps)';
%   QG.(FID).Waves = reshape(QG.(FID).Data(WaveInd(:)),SpikeSteps,length(Walign))';
%
QG.(FID).Waves=zeros(Nspikes,QG.(FID).PreSteps+QG.(FID).PostSteps+1,'single');
for i=1:Nspikes
    QG.(FID).Waves(i,:) = QG.(FID).Data(Walign(i)-QG.(FID).PreSteps:Walign(i)+QG.(FID).PostSteps);
end
QG.(FID).Walign = Walign;
QG.(FID).Nspikes = Nspikes;

function LF_plotFits(FID)
global QG

LF_plotWaves(FID);
LF_plotClusters(FID);
LF_plotRaster(FID);
LF_plotPSTH(FID);
LF_plotTrace(FID);
LF_plotISIhist(FID);
LF_plotCrossCorr(FID);

function LF_setClusterColors(FID)
% ASSIGN COLORS
global QG;
NVec = QG.(FID).NVec;
extNVec = QG.(FID).extNVec;
QG.(FID).Colors = cell(extNVec,1);

hh = lines(extNVec);   % 15-06/YB: remove random colors because too much comfound
for i=1:extNVec
    QG.(FID).Colors{i} = hh(i,:);
end
% rand('seed',0);
% for i=1:extNVec
%     %  QG.(FID).Colors{i} = hsv2rgb([1-eps-(i-1)/QG.(FID).NVec,1,1]);
%     QG.(FID).Colors{i} = 0.8*hsv2rgb([rand,1,1]);
% end

function LF_runSorting(FID)
% START SPIKESORTING
global QG U

NVec = QG.(FID).NVec;
Nspikes = QG.(FID).Nspikes;
%Selection = 'Linear';
Selection = 'BySD';
if Nspikes > QG.(FID).P.Nmax
    switch lower(Selection)
        case 'linear';
            QG.(FID).PCAInd = unique(round(linspace(1,Nspikes,QG.(FID).P.Nmax)));
        case 'bysd';
            Variances = var(QG.(FID).Waves(:,QG.(FID).ClustRange),1,2);
            [SVariances,SInd] = sort(Variances,'descend');
            cInds = unique(round(linspace(0,1,QG.(FID).P.Nmax).^4*Nspikes));
            cInds = cInds(cInds>0);
            QG.(FID).PCAInd = SInd(cInds)';
    end
    QG.(FID).iPCAInd = setdiff([1:Nspikes],QG.(FID).PCAInd);
else
    QG.(FID).PCAInd = [1:Nspikes];
    QG.(FID).iPCAInd = [ ];
end;

% PRINCIPAL COMPONENT ANALYSIS
Basis = 'waveform';
switch lower(Basis)
    case 'waveform';
        mWave = mean(QG.(FID).Waves);
        cData = QG.(FID).Waves(:,QG.(FID).ClustRange)...
            - repmat(mWave(QG.(FID).ClustRange),Nspikes,1);
        cData = [cData,diff(QG.(FID).Waves(:,QG.(FID).ClustRange),1,2)];
    case 'properties';
        CutOuts = QG.(FID).Waves(:,QG.(FID).ClustRange);
        cData(:,1) = max(CutOuts,[],2);
        cData(:,2) = min(CutOuts,[],2);
        cData(:,3) = max(diff(CutOuts,1,2),[],2);
        cData(:,4) = min(diff(CutOuts,1,2),[],2);
        cData(:,5) = var(CutOuts,1,2);
end
CovM = double(cov(cData)); [EVec,EVal] = eigs(CovM,3); % Covariance Matrix
PCProj = double(EVec(:,end-2:end)'*cData');
Sample2Remove = [];
for dimNum = 1:3
    Sample2Remove = [Sample2Remove find(abs(PCProj(dimNum,:))>10*std(PCProj(dimNum,:)))];
end
Sample2Remove = unique(Sample2Remove);
if ~isempty(Sample2Remove)
    disp([num2str(length(Sample2Remove)) ' samples removed for PCA calculus'])
    SampleForPCA = setdiff(1:size(cData,1),Sample2Remove);
    CovM = double(cov(cData(SampleForPCA,:))); [EVec,EVal] = eigs(CovM,3); % Covariance Matrix
    PCProj = double(EVec(:,end-2:end)'*cData');
end
% CLUSTERING (faster than clustvec)
Distances = pdist(PCProj(:,QG.(FID).PCAInd)','euclid');
BinTree = linkage(Distances,QG.(FID).Linkages{QG.(FID).LinkageInd});
ClustVec = cluster(BinTree,'maxclust',NVec);

Means = zeros(NVec,QG.(FID).ForwardSteps*2+1);
Strengths = zeros(NVec,1);
for i=1:NVec
    Inds{i}=find(ClustVec==i); WInds{i} = QG.(FID).PCAInd(Inds{i})';
    Means(i,:)=mean(QG.(FID).Waves(WInds{i},...
        QG.(FID).PreSteps+1-QG.(FID).ForwardSteps:...
        QG.(FID).PreSteps+1+QG.(FID).ForwardSteps),1);
    Strengths(i)=std(Means(i,:))*length(Inds{i});
end;

CellLen = cellfun(@length,Inds);
TooSmallCluster = find(CellLen<=10);
if length(TooSmallCluster)>1    
    disp(['Merged ' num2str(length(TooSmallCluster)) ' clusters too small'])
    for CluNum = 2:length(TooSmallCluster)
        Inds{TooSmallCluster(1)} = [Inds{TooSmallCluster(1)};Inds{TooSmallCluster(CluNum)}];
        WInds{TooSmallCluster(1)} = [WInds{TooSmallCluster(1)};WInds{TooSmallCluster(CluNum)}];
    end
    StoreOutlier.Inds = Inds{TooSmallCluster(1)};
    StoreOutlier.WInds = WInds{TooSmallCluster(1)};
    TempPCAInd = setdiff(QG.(FID).PCAInd,StoreOutlier.WInds);
    % RECLUSTERING (faster than clustvec)
    Distances = pdist(PCProj(:,TempPCAInd)','euclid');
    BinTree = linkage(Distances,QG.(FID).Linkages{QG.(FID).LinkageInd});
    ClustVec = cluster(BinTree,'maxclust',NVec-1);
    
    Means = zeros(NVec,QG.(FID).ForwardSteps*2+1);
    Strengths = zeros(NVec,1);
    for i=1:(NVec-1)
        Inds{i}=find(ClustVec==i); WInds{i} = TempPCAInd(Inds{i})';
        Means(i,:)=mean(QG.(FID).Waves(WInds{i},...
            QG.(FID).PreSteps+1-QG.(FID).ForwardSteps:...
            QG.(FID).PreSteps+1+QG.(FID).ForwardSteps),1);
        Strengths(i)=std(Means(i,:))*length(Inds{i});
    end;
    i = NVec;
    Inds{i} = StoreOutlier.Inds;
    WInds{i} = StoreOutlier.WInds;
    Means(i,:)=mean(QG.(FID).Waves(WInds{i},...
        QG.(FID).PreSteps+1-QG.(FID).ForwardSteps:...
        QG.(FID).PreSteps+1+QG.(FID).ForwardSteps),1);
    Strengths(i)=std(Means(i,:))*length(Inds{i});
end

[Strengths,SInd] = sort(Strengths,'descend');
Inds = Inds(SInd); WInds = WInds(SInd);

QG.(FID).PCProj = PCProj;
QG.(FID).Inds = Inds;
QG.(FID).WInds = WInds;

% ASSIGN ALL SPIKES
AllClust = {}; for i=1:NVec AllClust{i} = i; end
LF_assignSpikes(FID,AllClust);

% CHOOSE DISPLAYING EVENTS
QG.(FID).SelInd = cell(NVec,1);
for i=1:NVec
    LI=length(QG.(FID).WInds{i});
    if LI>300 QG.(FID).SelInd{i}=[1:100,101:round(LI/300):LI];
    else QG.(FID).SelInd{i}=[1:LI]; end
end

QG.(FID).YMax = 15;%max(QG.(FID).Waves(:));
QG.(FID).YMin = -15;%min(QG.(FID).Waves(:));
QG.(FID).PlotYMin = QG.(FID).YMin;
QG.(FID).PlotYMax = QG.(FID).YMax;

QG.(FID).GUI.ShowState = ones(NVec,1);
QG.(FID).GUI.ShowState(1) = ~QG.(FID).P.HideNoise;

function LF_computeSNR(FID)
% COLLECT NOISE BASELINE
global QG

AvSteps = 10000; tmp = QG.(FID).Data(1:100000);
AllSTs = sort(cell2mat(QG.(FID).STs));  cInd = AvSteps;
for i=1:length(AllSTs)
    cInd = [AllSTs(i)-QG.(FID).PreSteps:AllSTs(i)+QG.(FID).PostSteps];
    tmp(cInd) = NaN; if cInd(1)>AvSteps break; end
end
QG.(FID).StdNoise = nanstd(tmp(1:AvSteps));

% COMPUTE SNRs
QG.(FID).SNRs = zeros(size(QG.(FID).STs));
for i=1:length(QG.(FID).STs)
    QG.(FID).SNRs(i) = abs(min(QG.(FID).mWaves{i}))/QG.(FID).StdNoise;
end

function LF_assignSpikes(FID,ClustSel)
% MAPS ALL SPIKES TO THE CLOSEST ANALYZED SPIKE
global QG U

NCells = length(ClustSel); NVec = QG.(FID).NVec;
AllSelected = cell2mat(ClustSel); APInd = cell(NCells,1);
for i=1:NCells
    APInd{i} = cell2mat(QG.(FID).WInds(ClustSel{i})');
end
Ntmp = cellfun(@length,APInd,'Un',0); Ntmp = [0,Ntmp{:}];
NonAPInd = sort(cell2mat(QG.(FID).WInds(setdiff([1:NVec],AllSelected))'))';
ClustInd = [cell2mat(APInd);NonAPInd'];
Closest = dsearchn(QG.(FID).PCProj(:,ClustInd)',...
    delaunayn(QG.(FID).PCProj(:,ClustInd)'),...
    QG.(FID).PCProj(:,QG.(FID).iPCAInd)');

QG.(FID).STs = cell(NCells,1);
QG.(FID).NAPs = zeros(NCells,1);
QG.(FID).WavesByAP = cell(NCells,1);
QG.(FID).mWaves = cell(NCells,1);
QG.(FID).APInds = cell(NCells,1);
for i=1:NCells
    AddAPInd = find((Closest > sum(Ntmp(1:i))).*(Closest<=sum(Ntmp(1:i+1))) );
    cAPInd = sort([APInd{i} ; QG.(FID).iPCAInd(AddAPInd)']);
    QG.(FID).APInds{i} = cAPInd;
    QG.(FID).STs{i} = QG.(FID).Walign(cAPInd);
    QG.(FID).NAPs(i) = length(cAPInd);
    QG.(FID).WavesByAP{i} = single(QG.(FID).Waves(cAPInd,:));
    QG.(FID).mWaves{i} = mean(QG.(FID).WavesByAP{i},1);
end

NTrials = QG.(FID).NTrials;
QG.(FID).Trials = cell(NTrials,1);
P.TrialIndices = [QG.(FID).P.TrialIndices;inf];
for j=1:NTrials
    QG.(FID).Trials{j} = cell(NCells,1);
    for i=1:NCells
        Ind = find((QG.(FID).STs{i}>=P.TrialIndices(j)) .* (QG.(FID).STs{i}<P.TrialIndices(j+1)));
        if ~isempty(Ind)
            QG.(FID).Trials{j}{i} = ((QG.(FID).STs{i}(Ind)-P.TrialIndices(j) + 1)/QG.(FID).P.SR)/U.s;
        else
            QG.(FID).Trials{j}{i} = zeros(0,1);
        end
    end
end

LF_sortTrials(FID)
LF_clusterSeparation(FID)

function LF_sortTrials(FID)
% RESORT THE TRIALS FOR DISPLAYING
global QG U

if QG.(FID).UsePermInd
    QG.(FID).SortedTrials = QG.(FID).Trials(QG.(FID).P.PermInd);
    QG.(FID).SortedTrialBounds =  QG.(FID).TrialBounds(QG.(FID).P.PermInd,:);
else
    QG.(FID).SortedTrials = QG.(FID).Trials;
    QG.(FID).SortedTrialBounds = QG.(FID).TrialBounds;
end

function LF_clusterSeparation(FID)
global QG U

NCells = length(QG.(FID).APInds);
Means = zeros(3,NCells);
QG.(FID).CellSeparation = NaN * zeros(NCells);
for i=1:NCells Means(:,i) = mean(QG.(FID).PCProj(:,QG.(FID).APInds{i}),2); end
for i=1:NCells-1
    for j=i+1:NCells
        
        % % PROJECT ALL CLUSTERS ON THEIR CONNECTING DISTANCES
        %MeanVector = Means(:,j) - Means(:,i);
        %ClustProjI = MeanVector'/norm(MeanVector) * QG.(FID).PCProj(:,QG.(FID).APInds{i});
        %ClustProjJ = MeanVector'/norm(MeanVector) * QG.(FID).PCProj(:,QG.(FID).APInds{j});
        %MClustProjI = mean(ClustProjI);  MClustProjJ = mean(ClustProjJ);
        %if MClustProjJ < MClustProjI MClustProjJ = -MClustProjJ; MClustProjI = -MClustProjI; end
        %ClustProjI = ClustProjI(ClustProjI>=MClustProjI);
        %ClustProjJ = ClustProjJ(ClustProjJ<=MClustProjJ);
        %SDClustProjI = sqrt(sum((ClustProjI-MClustProjI).^2)/length(ClustProjI));
        %SDClustProjJ = sqrt(sum((ClustProjJ-MClustProjJ).^2)/length(ClustProjJ));
        %cClusterSep = abs(MClustProjJ - MClustProjI)/((length(ClustProjI)*SDClustProjI + length(ClustProjJ)*SDClustProjJ)/(length(ClustProjI)+length(ClustProjI)));
        %cClusterSep = abs(MClustProjJ - MClustProjI)/(0.5*(SDClustProjI + SDClustProjJ));
        %MOverall = mean([ClustProjJ,MClustProjI]);
        %cClusterSep = (MClustProjJ-MOverall)/SDClustProjJ - (MClustProjI-MOverall)/SDClustProjI;
        
        % TAKE DISTANCE BASED ON A FEW PARAMETERS
        % TIMING
        [MAX(i),MAXPOS(i)] = max(QG.(FID).mWaves{i});
        [MAX(j),MAXPOS(j)] = max(QG.(FID).mWaves{j});
        [MIN(i),MINPOS(i)] = min(QG.(FID).mWaves{i});
        [MIN(j),MINPOS(j)] = min(QG.(FID).mWaves{j});
        cClusterSep(1) = MINPOS(i) - MINPOS(j);
        cClusterSep(2) = (MAXPOS(i)-MINPOS(i)) - (MAXPOS(j)-MINPOS(j));
        
        % SIZE
        %cClusterSep(1) = max(QG.(FID).mWaves{i})-max(QG.(FID).mWaves{j});
        %cClusterSep(2) = min(QG.(FID).mWaves{i})-min(QG.(FID).mWaves{j});
        %cClusterSep(3) = std(QG.(FID).mWaves{i})-std(QG.(FID).mWaves{j});
        
        
        
        QG.(FID).CellSeparation(i,j) = norm(cClusterSep);
    end
end

% CALLBACK FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LF_CBF_showCluster(obj,event,FID,Index,State)

global QG;

cFIG = QG.(FID).FIG;
SelType = get(cFIG, 'SelectionType');
UD = get(cFIG,'UserData');
switch SelType
    case {'normal'}; button = 1; % left
    case {'alt'}; button = 2; % right
    case {'extend'}; button = 3; % middle
    case {'open'}; button = 4; % with shift
    otherwise error('Invalid mouse selection.')
end
switch button
    case 1 % Show/Hide
        h = QG.(FID).GUI.hSet{Index};
        if ~exist('State','var') State = get(h(1),'Visible');
        elseif strcmp(State,'on') State = 'off'; else State ='on'; end % invert the desired state
        if strcmp(State,'on') % invert current state to desired state
            ShowState = 0; NewState = 'off'; NewColor = QG.Colors.ColorOff;
        else
            ShowState = 1; NewState = 'on'; NewColor = QG.Colors.ColorOn;
        end
        QG.(FID).GUI.ShowState(Index) = ShowState;
        set(h,'Visible',NewState);
        set(obj,'BackgroundColor',NewColor);
        LF_showSeparation(obj,event,FID,Index)
        
    case 2 % Show only this cluster
        OtherInd = setdiff([1:length(QG.(FID).GUI.hSet)],Index);
        QG.(FID).GUI.ShowState(:) = 0;
        QG.(FID).GUI.ShowState(Index) = 1;
        h = cell2mat(QG.(FID).GUI.hSet(OtherInd));
        set(h,'Visible','off');
        set(QG.(FID).GUI.ClusterLabels,'BackgroundColor',QG.Colors.ColorOff);
        h = QG.(FID).GUI.hSet{Index};
        set(h,'Visible','on');set(obj,'BackgroundColor',[1,1,1]);
        LF_showSeparation(obj,event,FID,Index)
end

% Hide all merged ISIs
NVec = QG.(FID).NVec;
OtherInd = (NVec+1):QG.(FID).extNVec;
h = cell2mat(QG.(FID).GUI.hISI(OtherInd)); set(h,'Visible','off');
% Show ISI of all displayed clusters merged together
ActiveClusterLst = find(QG.(FID).GUI.ShowState);
ActiveClusterLst = [ActiveClusterLst ; zeros(NVec-length(ActiveClusterLst),1)];
Cluster_extNVec_Table = QG.(FID).extNVec_Table;
a = bsxfun(@eq,Cluster_extNVec_Table,ActiveClusterLst);
b = sum(a);
ActiveMergeLst = find(b==NVec);
h = cell2mat(QG.(FID).GUI.hISI(ActiveMergeLst)); set(h,'Visible','on');

% Hide all CC
h = cell2mat(QG.(FID).GUI.hCC(:)); set(h,'Visible','off');
% Show CC when pair
if length(find(ActiveClusterLst))==2
    inddAct = find(ActiveClusterLst);
    PairNum = ( QG.(FID).NPair_Table(1,:)==ActiveClusterLst(inddAct(1)) & QG.(FID).NPair_Table(2,:)==ActiveClusterLst(inddAct(2)) );
    h = cell2mat(QG.(FID).GUI.hCC(PairNum)); set(h,'Visible','on');
    
    xdata = get(QG.(FID).GUI.hCC{PairNum},'XData');
    ydata = get(QG.(FID).GUI.hCC{PairNum},'YData');
    cAxis = QG.(FID).GUI.CC;
    axis(cAxis,[xdata([1 end]),0,max([ydata,1e-3])]);
end

function LF_CBF_changePermInd(obj,event,FID)
global QG
QG.(FID).UsePermInd = get(obj,'Value');
LF_sortTrials(FID);
LF_plotRaster(FID);
LF_plotPSTH(FID);
LF_plotTrace(FID);
LF_collectHandles(FID);

function LF_CBF_Raster(obj,event,FID)
% CHANGE THE DISPLAYED TRACE
global QG

D = get(obj,'CurrentPoint');
SelType = get(gcf, 'SelectionType');
switch SelType
    case {'normal'}; button = 1; % left
    case {'alt'}; button = 2; % right
    case {'extend'}; button = 3; % middle
    case {'open'}; button = 4; % with shift
    otherwise error('Invalid mouse selection.')
end
switch button
    case 1 % CHOOSE TRACE
        tmp = round(D(1,2));
        if tmp <= 0 tmp = 1; end
        QG.(FID).CurrentRep = min([length(QG.(FID).P.TrialIndices),tmp]);
        LF_plotTrace(FID);
        LF_collectHandles(FID);
    case 2 % CHOOSE RECORDING FOR PSTH
        cTrial = round(D(1,2));
        if cTrial<0 QG.(FID).CurrentRecording = 'all';
        else QG.(FID).CurrentRecording = find(cTrial>QG.(FID).RecordingBounds(:,1),1,'last');
        end
        LF_plotPSTH(FID);
end

function LF_CBF_axisClick(obj,extevent,FID)
% SET THE THRESHOLD GRAPHICALLY
global QG;

D = get(obj,'CurrentPoint');
SelType = get(gcf, 'SelectionType');
switch SelType
    case {'normal','open'}; button = 1; % left
    case {'alt'}; button = 2; % right
    case {'extend'}; button = 3; % middle
    case {'open'}; button = 4; % with shift
    otherwise error('Invalid mouse selection.')
end
switch button
    case 1 % Zoom in or out
        if D(1,2) > 0 % Zoom in
            Factor = 0.5;
        else %Zoom out
            Factor = 2;
        end
        set(obj,'YLim',Factor*get(obj,'YLim'));
    case 2 % Set Threshold
        Threshold = D(1,2);
        set(QG.(FID).GUI.Threshold,'String',sprintf('%2.1f',Threshold));
        LF_CBF_setThreshold(QG.(FID).GUI.Threshold,[],FID)
end

function LF_CBF_stepTrace(obj,event,FID,mode)
% CHANGE THE DISPLAYED TRACE
global QG;

switch mode
    case '<'; tmp = QG.(FID).CurrentRep - 1;
    case '>'; tmp = QG.(FID).CurrentRep +1;
end
if tmp <= 0 tmp = 1; end
QG.(FID).CurrentRep = min([length(QG.(FID).P.TrialIndices),tmp]);
LF_plotTrace(FID);
LF_collectHandles(FID);

function LF_saveResults(obj,event,FID)
% COLLECT RESULTS

global QG U

Triggering = 0; ClustSelStr = ''; ClustSel = {};
NVec = QG.(FID).NVec;
for i=1:NVec
    cSelect = get(QG.(FID).GUI.ClusterSelects(i),'String');
    if isempty(cSelect) | unique(cSelect)==' ' cSelect = '0'; end
    ClustInd(i) = str2num(cSelect);
end
for i=1:NVec
    if ~isempty(find(ClustInd==i)) ClustSel{i} = find(ClustInd==i); end
end

for i=1:length(ClustSel) ClustSelStr = [ClustSelStr,' { ',sprintf('%d ',ClustSel{i}),'}']; end
if isempty(ClustSel) ClustSelStr = 'none'; end
fprintf(['Number of Clusters: ',n2s(NVec),'  -  Chosen Clusters: ',n2s(ClustSelStr),'\n']);
if ~isempty(ClustSel)
    LF_assignSpikes(FID,ClustSel);
    [QG.(FID).SortedSTs,SortInd] = sort(cell2mat(QG.(FID).STs),'ascend');
    QG.(FID).SortedWaves = cell2mat(QG.(FID).WavesByAP);
    QG.(FID).SortedWaves = QG.(FID).SortedWaves(SortInd,:);
else
    QG.(FID).STs = {}; QG.(FID).WavesByAP = {};
    QG.(FID).mWaves = {}; QG.(FID).NAPs = 0;
    return;
end
% COMPUTE SNRs
LF_computeSNR(FID);

fprintf([' < ',n2s(QG.(FID).NAPs'),' > spikes collected at [ ',...
    sprintf('%1.2f ',QG.(FID).NAPs'/QG.(FID).LData),...
    '] Hz and SNRs [ ',sprintf('%1.2f ',QG.(FID).SNRs),'].\n']);

P = QG.(FID).P;
P.SortParameters.Threshold = QG.(FID).Threshold;
P.SortParameters.Linkage = QG.(FID).Linkages{QG.(FID).LinkageInd};
P.SortParameters.ClustSel = ClustSel;
P.SortParameters.Recordings = P.Recordings;

% SAVE RESULTS FOR EACH RECORDING
for iRec = 1:length(P.Recordings)
    
    %cRecInd holds the trial indexes for each recording
    cRecInd = find((QG.(FID).P.Indices>=iRec).*(QG.(FID).P.Indices<iRec+1));
    
    %MinStep is the first index 
    MinStep = P.TrialIndices(cRecInd(1));
    
    %MaxStep is the limit of the last trial index for this recording
    if iRec==length(P.Recordings)
        MaxStep = length(QG.(FID).Data);
    else
        if P.TimeIndex == 1
            MaxStep = P.TrialIndices(cRecInd(end))-1;
            
        else
            MaxStep = P.TrialIndices(cRecInd(end)+1)-1;
            
        end
    end
    
    %cR.STs holds the spike times for each sorted cell
    for iC=1:length(QG.(FID).STs)
        cR.STs{iC,1} = QG.(FID).STs{iC}(logical((QG.(FID).STs{iC}>=MinStep).*(QG.(FID).STs{iC}<=MaxStep)))-MinStep+1;
    end
    
    %cind holds the indexes of sorted spike times within the data points from this recording 
    cInd = logical((QG.(FID).SortedSTs>=MinStep).*(QG.(FID).SortedSTs<=MaxStep));
    
    %collect the sorted waves for this recording
    cR.SortedWaves = QG.(FID).SortedWaves(cInd,:);
    
    %collect trial indexes from this recording and then make the indexes
    %start from 0
    cR.TrialIndices = P.TrialIndices(cRecInd) - MinStep;

    if length(P.Recordings)==1
        %check if there are spikes in this recording
        SpikesInThisRecording = 0;
        for iC=1:length(cR.STs) 
            if ~isempty(cR.STs{iC}) 
                SpikesInThisRecording = 1; 
            end
        end
    else  % 15/06-YB: save in any case when multiple recordings, for ensuring continuity of SU throughout recordings
        SpikesInThisRecording = 1;
    end
    %if there are spikes, then save the data
    if SpikesInThisRecording
        quickSaveResults(cR,'Animal',P.Animal,'Penetration',P.Penetration,'Depth',P.Depth,...
            'Recording',P.Recordings(iRec),'Behavior',P.Behavior,...
            'Runclass',P.Runclass,'Electrode',P.Electrode,'Sorter',P.Sorter,'SortParameters',P.SortParameters,'SaveSorter', P.SaveSorter);
    end
end

disp('DONE SORTING!')
% close(QG.(FID).FIG);

function LF_CBF_setThreshold(obj,event,FID)
global QG
Threshold = str2num(get(obj,'String'));
QG.(FID).NewThreshold = 1;
QG.(FID).Threshold = Threshold;

function LF_CBF_setNVec(obj,event,FID)
global QG
NVec = str2num(get(obj,'String'));
extNVec = NVec;
for VecNum = 2:NVec; extNVec = extNVec + nchoosek(NVec,VecNum); end
NPair = nchoosek(NVec,2);
QG.(FID).NewSorting = 1;
QG.(FID).NVec = NVec;
QG.(FID).extNVec = extNVec;
QG.(FID).NPair = NPair;

function LF_CBF_setLinkage(obj,event,FID)
global QG
Index = get(obj,'Value');
QG.(FID).NewSorting = 1;
QG.(FID).LinkageInd = Index;

function LF_CBF_Trace(obj,event,FID)
global QG U

cAxis = QG.(FID).GUI.TraceZoom;
CP = get(obj,'CurrentPoint');
TSelect = CP(1,1) * U.s;

SR = QG.(FID).P.SR;
iStartTrial = QG.(FID).SortedTrialBounds(QG.(FID).CurrentRep,1);
iStart = iStartTrial + round((TSelect-0.02*U.s)*SR); iStart = max(1,iStart);
iEnd = iStart + round(0.04*U.s*SR); iEnd = min(iEnd,length(QG.(FID).Data));
Trace = QG.(FID).Data(iStart:iEnd);

% PLOT TRACE
Indices = [iStart:iEnd]; Time = (Indices-iStartTrial)/SR/U.s;
set(obj,'XTick',[]); xlabel(obj,'');
delete(get(cAxis,'Children'));
set(cAxis,'NextPlot','Add','Visible','on');
plot(cAxis,Time,Trace,'k');
plot(cAxis,Time([1,end]),repmat(QG.(FID).Threshold,2,1));
MINMAX = [min([Trace,-5]),max([Trace,5])];
axis(cAxis,[Time([1,end]),MINMAX]);
set(cAxis,'YTick',MINMAX);

% PLOT TRIGGERS
for i=1:QG.(FID).NVec
    cSTs = QG.(FID).SortedTrials{QG.(FID).CurrentRep}{i};
    if QG.(FID).GUI.ShowState(i) State='on'; else State='off'; end
    QG.(FID).GUI.hTraceZoom{i} = plot(cAxis,1,1,'Marker','.','LineStyle','none','MarkerSize',20,'HitTest','off');
    set(QG.(FID).GUI.hTraceZoom{i},...
        'XData',cSTs,...
        'YData',repmat(4,length(cSTs),1),...
        'Color',QG.(FID).Colors{i},'Visible',State,'MarkerSize',30);
end


function LF_CBF_MoviePlayer(obj,event,FID)
global QG U

NFrames = 100;
NVec = QG.(FID).NVec;

for i=1:NFrames
    set(QG.(FID).GUI.ClusterSlider,'Value',i/NFrames)
    LF_CBF_SliderPos(QG.(FID).GUI.ClusterSlider,event,FID)
    pause(0.025);
end

pause(1);
delete(QG.(FID).GUI.hClusterTime);
QG.(FID).GUI = rmfield(QG.(FID).GUI,'hClusterTime')
for i=1:NVec
    if QG.(FID).GUI.ShowState(i) State='on'; else State='off'; end
    set(QG.(FID).GUI.hCluster{i},'Visible',State);
end

function LF_CBF_SliderPos(obj,event,FID)
global QG U

cAxis = QG.(FID).GUI.Clusters;
set(cell2mat(QG.(FID).GUI.hCluster),'Visible','off');
SliderVal = get(obj,'Value');
NVec = QG.(FID).NVec;
if isfield(QG.(FID).GUI,'hClusterTime') try delete(QG.(FID).GUI.hClusterTime); end; end
QG.(FID).GUI.hClusterTime = [];
Walign = QG.(FID).Walign;
NSteps = floor(QG.(FID).LData*U.s*QG.(FID).P.SR);

for i=1:NVec
    %  if QG.(FID).GUI.ShowState(i) State='on'; else State='off'; end
    State = 'on';
    cWalign = Walign(QG.(FID).WInds{i}(QG.(FID).SelInd{i}));
    cInd = find((cWalign>=0.9*SliderVal*NSteps).*(cWalign<=1.1*SliderVal*NSteps));
    if ~isempty(cInd)
        QG.(FID).GUI.hClusterTime(end+1) = plot3(cAxis,QG.(FID).PCProj(1,QG.(FID).WInds{i}(QG.(FID).SelInd{i}(cInd))),...
            QG.(FID).PCProj(2,QG.(FID).WInds{i}(QG.(FID).SelInd{i}(cInd))),...
            QG.(FID).PCProj(3,QG.(FID).WInds{i}(QG.(FID).SelInd{i}(cInd))),...
            '.','Color',QG.(FID).Colors{i},'Visible',State,'MarkerSize',15);
    end
end

% PLOTTING FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LF_plotWaves(FID)
% PLOT INDIVIDUAL AND AVERAGE WAVES
global QG U

NVec = QG.(FID).NVec; cAxis = QG.(FID).GUI.Waves;
NewPlot = 0; Toggle = 0;
if ~isfield(QG.(FID).GUI,'hWaves') | QG.(FID).WaveToggle
    try delete(cell2mat(QG.(FID).GUI.hWaves)); end
    if ~QG.(FID).WaveToggle
        NewPlot = 1;
        QG.(FID).GUI.hmWave = cell(NVec,1);
        set(cAxis,'NextPlot','add');
        xlabel(cAxis,'Time [ms] ');
        ylabel(cAxis,'Voltage [S.D.] ');
        grid(cAxis,'on');
        box on;
        QG.(FID).GUI.hWavesStat(1,1) = plot(cAxis,1,1,'Color',QG.FigOpt.LineCol,'HitTest','off');
        QG.(FID).GUI.hWavesStat(2,1) = plot(cAxis,1,1,'Color',[.2,.2,.2],'HitTest','off');
    else
        Toggle =1;
        QG.(FID).WaveToggle = 0;
    end
    QG.(FID).GUI.hWaves = cell(NVec,1);
else % Newplot = 0; Toggle = 0;
    if NVec < size(QG.(FID).GUI.hWaves,1)
        delete(cell2mat(QG.(FID).GUI.hWaves(NVec+1:end)));
        delete(cell2mat(QG.(FID).GUI.hmWave(NVec+1:end)));
        QG.(FID).GUI.hWaves = vertical(QG.(FID).GUI.hWaves(1:NVec));
        QG.(FID).GUI.hmWave = vertical(QG.(FID).GUI.hmWave(1:NVec));
    end
end
title(cAxis,['Waveforms (',n2s(QG.(FID).Nspikes),')'] );

% PLOT STANDARD DEVIATIONS OR WAVES (LATER IS SLOWER)
for i=1:NVec
    if QG.(FID).GUI.ShowState(i) State='on'; else State='off'; end
    switch lower(QG.(FID).WaveOpt)
        case 'sd';
            if NewPlot || Toggle || i>size(QG.(FID).GUI.hWaves,1)
                QG.(FID).GUI.hWaves{i,1} = plot(cAxis,[1,2;1,2],[1,1;1,1],'HitTest','off','LineWidth',QG.FigOpt.LineWidth);
            end
            SD = 2*std(QG.(FID).Waves(QG.(FID).WInds{i}(QG.(FID).SelInd{i}),:));
            set(QG.(FID).GUI.hWaves{i}(1),...
                'XData',QG.(FID).WaveTime/U.ms,...
                'YData',QG.(FID).mWaves{i} + SD,...
                'Color',HF_whiten(QG.(FID).Colors{i},0.7),'Visible',State);
            set(QG.(FID).GUI.hWaves{i}(2),...
                'XData',QG.(FID).WaveTime/U.ms,...
                'YData',QG.(FID).mWaves{i} - SD,...
                'Color',HF_whiten(QG.(FID).Colors{i},0.7),'Visible',State);
        case 'individual';
            try delete(QG.(FID).GUI.hWaves{i}); end
            QG.(FID).GUI.hWaves{i,1} = plot(cAxis,repmat(QG.(FID).WaveTime/U.ms,length(QG.(FID).SelInd{i}),1)',...
                QG.(FID).Waves(QG.(FID).WInds{i}(QG.(FID).SelInd{i}),:)',...
                'Color',HF_whiten(QG.(FID).Colors{i},0.7),'Visible',State);
    end
end

% PLOT MWAVES
for i=1:NVec
    if QG.(FID).GUI.ShowState(i) State='on'; else State='off'; end
    if NewPlot ||  i>size(QG.(FID).GUI.hmWave,1)
        QG.(FID).GUI.hmWave{i,1} = plot(cAxis,1,1,'LineWidth',QG.FigOpt.LineWidth,'HitTest','off');
    end
    set(QG.(FID).GUI.hmWave{i},...
        'XData',QG.(FID).WaveTime/U.ms,...
        'YData',QG.(FID).mWaves{i},...
        'Color',QG.(FID).Colors{i},'Visible',State);
end;

% PLOT DECORATIONS (THRESHOLD, ZERO)
set(QG.(FID).GUI.hWavesStat(1),...
    'XData',QG.(FID).WaveTime/U.ms,...
    'YData',repmat(QG.(FID).Threshold,size(QG.(FID).WaveTime)));
set(QG.(FID).GUI.hWavesStat(2),...
    'XData',QG.(FID).WaveTime/U.ms,...
    'YData',repmat(0,size(QG.(FID).WaveTime)));
set(cAxis,'XLim',[-QG.(FID).P.PreDur,QG.(FID).P.PostDur]/U.ms,...
    'YLim',[QG.(FID).PlotYMin,QG.(FID).PlotYMax]);

% CHECK FOR CELLS FROM PREVIOUS RECORDINGS AND INCLUDE THEM
if NewPlot
    axes(cAxis);
    if ~isempty(QG.(FID).P.SortInfo)
        mWaves = QG.(FID).P.SortInfo.mWaves;  Units = QG.(FID).P.SortInfo.Units;
        cWaveTime = [-QG.(FID).P.PreDur/U.ms:(1./QG.(FID).P.SR)/U.ms:((size(mWaves,1)-1)/QG.(FID).P.SR)/U.ms-QG.(FID).P.PreDur/U.ms]';
        if ~isempty(Units)
            for i=1:length(Units) % LOOP OVER CELLS IN OTHER RECORDING
                plot(cAxis,cWaveTime,mWaves(:,Units(i)),'k');  % 17/03-YB: plot(cAxis,cWaveTime,mWaves(:,i),'k','linewidth',5);
                [MAX,Pos] = max(mWaves(:,i));
                text(cWaveTime(Pos),double(1.2*MAX),n2s(Units(i)));
            end
        end
    end
end

% BRING MWAVES IN FRONT OF REST
Children = get(cAxis,'Children');
Plots = [QG.(FID).GUI.hWavesStat;cell2mat(QG.(FID).GUI.hmWave);cell2mat(QG.(FID).GUI.hWaves)];
set(cAxis,'Children',[setdiff(Children,Plots);Plots])

function LF_plotClusters(FID)
% PLOT PROJECTIONS ONTO EIGENVECTORS
global QG

NVec = QG.(FID).NVec;
cAxis = QG.(FID).GUI.Clusters;
if ~isfield(QG.(FID).GUI,'hCluster') NewPlot = 1;
    QG.(FID).GUI.hCluster = cell(NVec,1);
    set(cAxis,'NextPlot','add');
    title(cAxis,'Largest P.C.s'); grid(cAxis,'on');
    view(cAxis,[45,60]);
else NewPlot = 0;
    if NVec < length(QG.(FID).GUI.hCluster)
        delete([QG.(FID).GUI.hCluster{NVec+1:end}]);
        QG.(FID).GUI.hCluster = QG.(FID).GUI.hCluster(1:NVec);
    end
end

for i=1:NVec
    if QG.(FID).GUI.ShowState(i) State='on'; else State='off'; end
    if NewPlot || i>length(QG.(FID).GUI.hCluster)
        QG.(FID).GUI.hCluster{i} = plot3(cAxis,1,1,1,'Marker','.','LineStyle','none','MarkerSize',15,'HitTest','off');
    end
    set(QG.(FID).GUI.hCluster{i},...
        'XData',QG.(FID).PCProj(1,QG.(FID).WInds{i}(QG.(FID).SelInd{i})),...
        'YData',QG.(FID).PCProj(2,QG.(FID).WInds{i}(QG.(FID).SelInd{i})),...
        'ZData',QG.(FID).PCProj(3,QG.(FID).WInds{i}(QG.(FID).SelInd{i})),...
        'Color',QG.(FID).Colors{i},'Visible',State);
end;
Abs = [min(QG.(FID).PCProj,[],2),max(QG.(FID).PCProj,[],2)]';
Abs = Abs(:);
set(cAxis,'XLim',Abs(1:2),'YLim',Abs(3:4),'ZLim',Abs(5:6));

function LF_plotRaster(FID)
% PLOT THE SPIKETIMES OVER STIMULUS REPETITIONS
global QG U;

NTrials = QG.(FID).NTrials; NVec = QG.(FID).NVec;
cAxis = QG.(FID).GUI.Raster;
if ~isfield(QG.(FID).GUI,'hRaster') NewPlot = 1;
    QG.(FID).GUI.hRaster = cell(NVec,1);
    set(cAxis,'NextPlot','add','XTick',[]);
    title(cAxis,'Raster & PSTH');
    ylabel(cAxis,'Indices [#]')
    grid(cAxis,'on');
else
    NewPlot = 0;
    if NVec < length(QG.(FID).GUI.hRaster)
        delete([QG.(FID).GUI.hRaster{NVec+1:end}]);
        QG.(FID).GUI.hRaster = QG.(FID).GUI.hRaster(1:NVec);
    end
end

QG.(FID).APsOverTrials = cell(NVec,1);
for i=1:NVec
    k=0;
    QG.(FID).APsOverTrials{i} = zeros(length(QG.(FID).STs(i)),2);
    for j=1:NTrials
        cNAP = length(QG.(FID).SortedTrials{j}{i});
        QG.(FID).APsOverTrials{i}(k+1:k+cNAP,:) ...
            = [QG.(FID).SortedTrials{j}{i},repmat(j,cNAP,1)];
        k = k+cNAP;
    end
end

cAxis = QG.(FID).GUI.Raster;
for i=1:NVec
    if QG.(FID).GUI.ShowState(i) State='on'; else State='off'; end
    MarkerSize = 6;
    %  if length(QG.(FID).APsOverTrials{i}) > 10000 MarkerSize = 6; else MarkerSize=6; end
    if NewPlot || i>length(QG.(FID).GUI.hRaster)
        QG.(FID).GUI.hRaster{i} = plot(cAxis,1,1,'Marker','.','LineStyle','none','MarkerSize',MarkerSize,'HitTest','off');
    end
    set(QG.(FID).GUI.hRaster{i},...
        'XData',QG.(FID).APsOverTrials{i}(:,1),...
        'YData',QG.(FID).APsOverTrials{i}(:,2),...
        'Color',QG.(FID).Colors{i},'Visible',State);
end
if NewPlot
    if ~isempty(QG.(FID).P.StimStart)
        plot(cAxis,[QG.(FID).P.StimStart,QG.(FID).P.StimStart],[0,NTrials],...
            'Color',QG.FigOpt.LineCol,'HitTest','Off');
    end;
    if ~isempty(QG.(FID).P.StimStop)
        plot(cAxis,[QG.(FID).P.StimStop,QG.(FID).P.StimStop],[0,NTrials],...
            'Color',QG.FigOpt.LineCol,'HitTest','Off');
    end;
end;
axis(cAxis,[0,QG.(FID).PlotXMax,0,NTrials+1]);
SortedInd = QG.(FID).P.Indices(QG.(FID).P.PermInd);
[Indices,Ticks] = unique(SortedInd,'first');
set(cAxis,'YTick',Ticks,'YTickLabel',Indices);

function LF_plotPSTH(FID)
% PLOT THE SPIKETIMES OVER STIMULUS REPETITIONS
global QG U;

NTrials = QG.(FID).NTrials; NVec = QG.(FID).NVec;
cAxis = QG.(FID).GUI.PSTH;
if ~isfield(QG.(FID).GUI,'hPSTH') NewPlot = 1;
    QG.(FID).GUI.hPSTH = cell(NVec,1);
    set(cAxis,'NextPlot','add');
    grid(cAxis,'on');
    box off; set(cAxis,'YTick',[]);
else
    NewPlot = 0;
    if NVec < length(QG.(FID).GUI.hPSTH)
        delete([QG.(FID).GUI.hPSTH{NVec+1:end}]);
        QG.(FID).GUI.hPSTH = QG.(FID).GUI.hPSTH(1:NVec);
    end
end

BinBounds = [0:0.01:QG.(FID).PlotXMax]';
BinCenters = BinBounds(1:end-1) + 0.005;
for i=1:NVec
    if QG.(FID).GUI.ShowState(i) State='on'; else State='off'; end
    if NewPlot || i>length(QG.(FID).GUI.hPSTH)
        QG.(FID).GUI.hPSTH{i} = plot(cAxis,1,1,'HitTest','off');
    end
    % SELECT FOR ONE OR ALL RECORDINGS
    if strcmp(QG.(FID).CurrentRecording,'all')
        H = histc(QG.(FID).APsOverTrials{i}(:,1),BinBounds);
    else
        Bounds = QG.(FID).RecordingBounds(QG.(FID).CurrentRecording,:);
        [tmp,cInd] = ismember(QG.(FID).APsOverTrials{i}(:,2),Bounds(1):Bounds(2));
        H = histc(QG.(FID).APsOverTrials{i}(find(cInd),1),BinBounds);
    end
    set(QG.(FID).GUI.hPSTH{i},...
        'XData',BinCenters,...
        'YData',H(1:end-1)/max(H),...
        'Color',QG.(FID).Colors{i},'Visible',State);
end

% PLOT STIMULUS START AND END
if NewPlot
    if ~isempty(QG.(FID).P.StimStart)
        plot(cAxis,[QG.(FID).P.StimStart,QG.(FID).P.StimStart],[0,1],...
            'Color',QG.FigOpt.LineCol,'HitTest','Off');
    end;
    if ~isempty(QG.(FID).P.StimStop)
        plot(cAxis,[QG.(FID).P.StimStop,QG.(FID).P.StimStop],[0,1],...
            'Color',QG.FigOpt.LineCol,'HitTest','Off');
    end;
end
axis(cAxis,[0,1,0,1.1]);

function LF_plotTrace(FID)
% PLOT THE TRACE FOR ONE REPETITION
global QG U;

NVec = QG.(FID).NVec;
cAxis = QG.(FID).GUI.Trace;
if ~isfield(QG.(FID).GUI,'hTrace') NewPlot = 1;
    QG.(FID).GUI.hTrace = cell(NVec,1);
    set(cAxis,'NextPlot','add','ButtonDownFcn',{@LF_CBF_Trace,FID});
    xlabel(cAxis,'Time [s] ');
    ylabel(cAxis,'Voltage [S.D.] ');
    grid(cAxis,'on');
    box on;
    QG.(FID).GUI.hTraceStat(1) = plot(cAxis,1,1,'k','HitTest','off');
    QG.(FID).GUI.hTraceStat(2) = plot(cAxis,1,1,'-','Color',[.5,.5,.5],'HitTest','off');
else
    NewPlot = 0;
    if NVec < length(QG.(FID).GUI.hTrace)
        delete([QG.(FID).GUI.hTrace{NVec+1:end}]);
        QG.(FID).GUI.hTrace = QG.(FID).GUI.hTrace(1:NVec);
    end
end
title(cAxis,['Trace [#',n2s(QG.(FID).CurrentRep),']']);

cMax = 0; SR = QG.(FID).P.SR;
iStart = QG.(FID).SortedTrialBounds(QG.(FID).CurrentRep,1);
iEnd = QG.(FID).SortedTrialBounds(QG.(FID).CurrentRep,2);
TStart = iStart/SR; TEnd = iEnd/SR;

% PLOT TRACE
Indices = [iStart:iEnd]; Time = (Indices-iStart)/SR/U.s;
set(QG.(FID).GUI.hTraceStat(1),...
    'XData',Time,...
    'YData',QG.(FID).Data(Indices));

% PLOT TRIGGERS
for i=1:NVec
    cSTs = QG.(FID).SortedTrials{QG.(FID).CurrentRep}{i};
    if QG.(FID).GUI.ShowState(i) State='on'; else State='off'; end
    if NewPlot || i>length(QG.(FID).GUI.hTrace)
        QG.(FID).GUI.hTrace{i} = plot(cAxis,1,1,'Marker','.','LineStyle','none','MarkerSize',6,'HitTest','off');
    end
    set(QG.(FID).GUI.hTrace{i},...
        'XData',cSTs,...
        'YData',repmat(0,length(cSTs),1),...
        'Color',QG.(FID).Colors{i},'Visible',State);
end

set(QG.(FID).GUI.hTraceStat(2),...
    'XData',[0,TEnd/U.s],...
    'YData',[QG.(FID).Threshold,QG.(FID).Threshold]);

if NewPlot
    if ~isempty(QG.(FID).P.StimStart)
        plot(QG.(FID).GUI.Trace,[QG.(FID).P.StimStart,QG.(FID).P.StimStart],...
            1.5*[QG.(FID).YMin,QG.(FID).YMax],'Color',QG.FigOpt.LineCol,'HitTest','off'); end;
    if ~isempty(QG.(FID).P.StimStop)
        plot(QG.(FID).GUI.Trace,[QG.(FID).P.StimStop,QG.(FID).P.StimStop],...
            1.5*[QG.(FID).YMin,QG.(FID).YMax],'Color',QG.FigOpt.LineCol,'HitTest','off');
    end;
end
axis(cAxis,[0,(TEnd-TStart)/U.s,[QG.(FID).PlotYMin,QG.(FID).PlotYMax]]);

function LF_plotISIhist(FID)
% PLOT ISI HISTOGRAMS
global QG U;

cAxis = QG.(FID).GUI.ISI;
NVec = QG.(FID).NVec;
extNVec = QG.(FID).extNVec;
SR = QG.(FID).P.SR;
cMax = 0; Bins = [0:1:50];

% Table of correspondance [selected clusters-extNVec]
Cluster_extNVec_Table = zeros(NVec,extNVec); IndNow = 0;
for VecNum = 1:NVec
    Cluster_extNVec_Table(1:VecNum,(IndNow+1):(IndNow+nchoosek(NVec,VecNum))) = nchoosek(1:NVec,VecNum)';
    IndNow = IndNow+nchoosek(NVec,VecNum);
end
QG.(FID).extNVec_Table = Cluster_extNVec_Table;

if ~isfield(QG.(FID).GUI,'hISI') NewPlot = 1;
    QG.(FID).GUI.hISI = cell(extNVec,1);
    set(cAxis,'NextPlot','add');
    title(cAxis,['ISI Hist']);
    xlabel(cAxis,'Time [ms] ');
    set(cAxis,'xtick',[Bins(1):10:Bins(end)]);
    axis(cAxis,[0,15,0,1.1]);   %15/03-YB: was 50 before
    grid(cAxis,'on');
    box on;
else
    NewPlot = 0;
    if extNVec < length(QG.(FID).GUI.hISI)
        delete([QG.(FID).GUI.hISI{extNVec+1:end}]);
        QG.(FID).GUI.hISI = QG.(FID).GUI.hISI(1:extNVec);
    end
end

% Old version with single clusters
% H = cell(NVec,1);
% for i=1:NVec
%     if length(QG.(FID).STs{i}) > 1
%         ISIhist = vertical(histc(diff(QG.(FID).STs{i}/SR/U.ms),Bins));
%         if ~isempty(ISIhist)  ISIhist = ISIhist(1:end-1);
%             if max(ISIhist) ISIhist = ISIhist/max(ISIhist); end
%             H{i} = ISIhist;
%         else H{i} = [];
%         end
%     else H{i} = [];
%     end
% end

% ISI FOR JOINT CLUSTERS
for i=1:extNVec
    RowN = find(Cluster_extNVec_Table(:,i)~=0);
    SpkMegaCluster = [];
    for j = RowN'
        ClusterNum = Cluster_extNVec_Table(j,i);
        SpkMegaCluster = [SpkMegaCluster ; QG.(FID).STs{ClusterNum}];
    end
    if length(SpkMegaCluster) > 1
        ISIhist = vertical(histc(diff(sort(SpkMegaCluster)/SR/U.ms),Bins));
        if ~isempty(ISIhist)  ISIhist = ISIhist(1:end-1);
            if max(ISIhist) ISIhist = ISIhist/max(ISIhist); end
            H{i} = ISIhist;
        else H{i} = [];
        end
    else H{i} = [];
    end
end

for i=1:extNVec
    if i<=NVec && QG.(FID).GUI.ShowState(i); State='on'; else State='off'; end
    if isempty(H{i}) H{i} = zeros(length(Bins)-1,1); end
    if NewPlot || i>length(QG.(FID).GUI.hISI)
        QG.(FID).GUI.hISI{i} = plot(cAxis,1,1,'HitTest','off');
    end
    if i<=NVec; LW = 1; else LW = 3; end
    set(QG.(FID).GUI.hISI{i},...
        'XData',Bins(1:end-1),...
        'YData',H{i},...
        'linewidth',LW,...
        'Color',QG.(FID).Colors{i},'Visible',State);
end


function LF_plotCrossCorr(FID)
% PLOT CROSS-CORRELOGRAM HISTOGRAMS
global QG U;

cAxis = QG.(FID).GUI.CC;
NVec = QG.(FID).NVec;
NPair = QG.(FID).NPair;
SR = QG.(FID).P.SR;
BinSize = 0.001;          % in s.
cMax = 0; Bins = (-25:25)*BinSize*1000;  % in ms

% Table of correspondance [selected clusters-NPair]
Cluster_NPair_Table = zeros(2,NPair); IndNow = 0;
for VecNum = 1:NVec
    Cluster_NPair_Table(:,(IndNow+1):(IndNow+NVec-VecNum)) = [ ones(1,NVec-VecNum)*VecNum ; (VecNum+1:NVec) ];
    IndNow = IndNow+NVec-VecNum;
end
QG.(FID).NPair_Table = Cluster_NPair_Table;

if ~isfield(QG.(FID).GUI,'hCC') NewPlot = 1;
    QG.(FID).GUI.hCC = cell(NPair,1);
    set(cAxis,'NextPlot','add');
    title(cAxis,'CC Hist');
    xlabel(cAxis,'Time [ms] ');
    set(cAxis,'xtick',sort([-(0:5:-Bins(1)) 5:5:Bins(end)]));
    axis(cAxis,[Bins([1 end]),0,1.1]);
    grid(cAxis,'on');
    box on;
else
    NewPlot = 0;
    if NPair < length(QG.(FID).GUI.hCC)
        delete([QG.(FID).GUI.hCC{NPair+1:end}]);
        QG.(FID).GUI.hCC = QG.(FID).GUI.hCC(1:NPair);
    end
end

% CC FOR PAIR OF CLUSTERS
for PairNum = 1:NPair
    tx = QG.(FID).STs{Cluster_NPair_Table(1,PairNum)}/SR/U.s;
    ty = QG.(FID).STs{Cluster_NPair_Table(2,PairNum)}/SR/U.s;
    C = spike_crossx_matlab(tx,ty,BinSize,length(Bins));
    H{PairNum} = C;
end

for PairNum=1:NPair
    if PairNum<=NVec && QG.(FID).GUI.ShowState(PairNum); State='on'; else State='off'; end
    if isempty(H{PairNum}) H{PairNum} = zeros(length(Bins)-1,1); end
    if NewPlot || PairNum>length(QG.(FID).GUI.hCC)
        QG.(FID).GUI.hCC{PairNum} = plot(cAxis,1,1,'HitTest','off');
    end
    set(QG.(FID).GUI.hCC{PairNum},...
        'XData',Bins(1:end-1),...
        'YData',H{PairNum},...
        'linewidth',2,...
        'Color',QG.(FID).Colors{PairNum},'Visible',State);
end

function [C] = spike_crossx_matlab(tX,tY,binsize,nbins)
% 15/08-YB: taken from FieldTrip
tX = sort(tX(:));
tY = sort(tY(:));

minLag = - binsize * (nbins-1) / 2;
j = 0:nbins-1;
B = minLag + j * binsize;
tX(tX<(tY(1)+minLag) | tX>(tY(end)-minLag))   = [];
if isempty(tX), 
  C = zeros(1,length(B)-1);
  return;
end
tY(tY>(tX(end)-minLag) | tY<(tX(1)+minLag)) = [];
if isempty(tY), 
  C = zeros(1,length(B)-1);
  return;
end
nX = length(tX); nY = length(tY);

% compute all distances at once using a multiplication trick
if (nX*nY)<2*10^7  % allow matrix to grow to about 150 MB, should always work
  D = log(exp(-tX(:))*exp(tY(:)'));
  D = D(:);
  D(abs(D)>abs(minLag)) = [];
  [C] = histc(D,B);
  C(end) = [];  
else  
  % break it down in pieces such that nX*nY<2*10*7
  k   = 2;
  nXs = round(nX/k);
  while (nXs*nY)>=(2*10^7)
    k = k+1;
    nXs = round(nX/k);
  end
  
  % get the indices
  steps = round(nX/k);
  begs = [1:steps:steps*k];
  ends = begs+(steps-1);
  rm   = begs>nX;
  begs(rm) = [];
  ends(rm) = [];
  ends(end) = nX;
  nSteps    = length(begs);
  
  D = [];
  C = zeros(1,length(B));
  for iStep = 1:nSteps
    d = log(exp(-tX(begs(iStep):ends(iStep)))*exp(tY(:)'));
    d = d(:);
    d(abs(d)>abs(minLag)) = [];
    addC = histc(d,B)';
    if size(addC,2)==1; addC = addC'; end      
    C = C + addC;    
  end
  C(end) = [];
end

if isempty(C)
    C = zeros(1,length(B)-1);
end


function LF_collectHandles(FID)
global QG

QG.(FID).GUI.hSet = cell(QG.(FID).NVec,1);
for i=1:QG.(FID).NVec
    QG.(FID).GUI.hSet{i} = ...
        [QG.(FID).GUI.hWaves{i};QG.(FID).GUI.hmWave{i};...
        QG.(FID).GUI.hCluster{i};QG.(FID).GUI.hRaster{i};QG.(FID).GUI.hTrace{i};...
        QG.(FID).GUI.hISI{i};QG.(FID).GUI.hPSTH{i}];
end

function LF_closeFig(obj,event,FID)
global QG

try QG = rmfield(QG,FID); catch end

% GUI HELPERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = LF_addCheckbox(Panel,Pos,Val,CBF,Tooltip,Tag,Color);
global QG Verbose
if ~exist('Color','var') | isempty(Color) Color = QG.Colors.Panel; end
if ~exist('Tag','var') | isempty(Tag) Tag = ''; end
if ~exist('CBF','var') | isempty(CBF) CBF=''; end
if ~exist ('Tooltip','var') | isempty(Tooltip) Tooltip = ''; end
h=uicontrol('Parent',Panel,'Style','checkbox',...
    'Value',Val,'Callback',CBF,'Units','normalized',...
    'Tag',Tag,'Position',Pos,'BackGroundColor',Color,'Tooltip',Tooltip);

function h = LF_addDropdown(Panel,Pos,Strings,Val,CBF,UD,Tooltip,Tag,Color,FontSize);
global QG
if ~exist('Color','var') | isempty(Color) Color = [1,1,1]; end
if ~exist('Tag','var') | isempty(Tag) Tag = ''; end
if ~exist('CBF','var') | isempty(CBF) CBF=''; end
if ~exist('Tooltip','var') | isempty(Tooltip) Tooltip = ''; end
if ~exist('FontSize','var') | isempty(FontSize) FontSize = 8; end
if ~exist('UD','var') | isempty(UD) UD = []; end
h=uicontrol('Parent',Panel,'Style','popupmenu',...
    'Val',Val,'String',Strings,'FontName',QG.FigOpt.FontName,...
    'Callback',CBF,'Units','normalized',...
    'FontSize',FontSize,...
    'Tag',Tag,'Position',Pos,'BackGroundColor',Color,'TooltipString',Tooltip);
set(h,'UserData',UD)

function h = LF_addEdit(Panel,Pos,String,CBF,Tooltip,Tag,Color,FontSize);
global QG
if ~exist('Color','var') | isempty(Color) Color = [1,1,1]; end
if ~exist('Tag','var') | isempty(Tag) Tag = ''; end
if ~exist('CBF','var') | isempty(CBF) CBF=''; end
if ~exist('Tooltip','var') | isempty(Tooltip) Tooltip = ''; end
if ~exist('FontSize','var') | isempty(FontSize) FontSize = 8; end
if ~isstr(String) String = n2s(String); end
h=uicontrol('Parent',Panel,'Style','edit',...
    'String',String,'FontName',QG.FigOpt.FontName,...
    'Callback',CBF,'Units','normalized','Horiz','center',...
    'FontSize',FontSize,...
    'Tag',Tag,'Position',Pos,'BackGroundColor',Color,'ToolTipString',Tooltip);

function h = LF_addPanel(Parent,Title,TitleSize,TitleColor,Color,Position,TitlePos)
global QG
if ~exist('TitlePosition','var') TitlePos = 'centertop'; end
h = uipanel('Parent',Parent,'Title',Title,...
    'FontSize',TitleSize,'FontName',QG.FigOpt.FontName,...
    'ForeGroundColor',TitleColor,'TitlePosition',TitlePos,'BackGroundColor',Color,...
    'Units','normalized','Position',Position,'BorderType','line');

function h = LF_addPushbutton(Panel,Pos,String,CBF,Tooltip,Tag,FGColor,BGColor);
global QG Verbose
if ~exist('BGColor','var') | isempty(BGColor) BGColor = [1,1,1]; end
if ~exist('FGColor','var') | isempty(FGColor) FGColor = [0,0,0]; end
if ~exist('Tag','var') | isempty(Tag) Tag = ''; end
if ~exist('CBF','var') | isempty(CBF) CBF=''; end
if ~exist('Tooltip','var') | isempty(Tooltip) Tooltip = ''; end
h=uicontrol('Parent',Panel,'Style','pushbutton',...
    'String',String,'FontName',QG.FigOpt.FontName,...
    'Callback',CBF,'Units','normalized','Position',Pos,'Tag',Tag,...
    'ToolTipString',Tooltip,'ForegroundColor',FGColor,'BackGroundColor',BGColor);

function h = LF_addText(Panel,Pos,String,Tooltip,Tag,FGColor,BGColor);
global QG
if ~exist('BGColor','var') | isempty(BGColor) BGColor = get(Panel,'BackGroundColor'); end
if ~exist('FGColor','var') | isempty(FGColor) FGColor = [1,1,1]; end
if ~exist('Tag','var') | isempty(Tag) Tag = ''; end
if ~exist('CBF','var') | isempty(CBF) CBF=''; end
if ~exist('Tooltip','var') | isempty(Tooltip) Tooltip = ''; end
h=uicontrol('Parent',Panel,'Style','text',...
    'String',String,'FontName',QG.FigOpt.FontName,...
    'Units','normalized','Position',Pos,...
    'Tag',Tag,'ToolTipString',Tooltip,'HorizontalAlignment','left',...
    'ForegroundColor',FGColor,'BackGroundColor',BGColor);QG.(FID).LinkageInd = find(strcmp(P.Linkage,QG.(FID).Linkages));

function [Data,TrialIdx] = LF_createTestData

NSteps = 10000; NTrials = 100; SR = 31250; FSpike = 1000; NSpikes = 10;
Data = zeros(NTrials,NSteps);
K = sin(2*pi*FSpike*[1:25]/SR);
for i=1:NTrials
    Frac = i/NTrials+0.5;
    for j=1:NSpikes Data(i,700*j) = Frac*mod(j,2)+1; end;
    tmp = conv(Data(i,:),K); Data(i,:) = tmp(1:NSteps);
end
TrialIdx = [1:NSteps:(NTrials-1)*NSteps+1]';
Data = Data'; Data = Data + randn(size(Data))/20;
Data = Data(:);
