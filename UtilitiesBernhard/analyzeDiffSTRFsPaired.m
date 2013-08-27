function [R,I] = analyzeDiffSTRFsPaired(varargin)
% Function to plot the data from the difference analysis of STRFs 
%
% Usage examples:
% To plot the differences at the TargetFrequency
%  analyzeDiffSTRFs(P.R1,'SNRThresh',0.5,'Normed',1,'Quantity','TargetDiff');
% To plot the TimeBins (note, that the TimeBin1 does not exist for the normed case because it would be the same)
%  analyzeDiffSTRFs(P.R1,'SNRThresh',0.5,'Normed',0,'Quantity','TimeBin1');
%
% Return Values:
%  R : Collection of the data used for plotting
%  I : Information from the Plotting, e.g. the CellIDs, for each of the plots.

P = parsePairs(varargin);
checkField(P,'R1');
checkField(P,'R2',[]);
checkField(P,'Plotting',1);
checkField(P,'FIG',1);
checkField(P,'SNRThresh',0.2);
checkField(P,'Quantity','TargetDiff');
checkField(P,'Normed',1);
checkField(P,'ShowDist',1);
checkField(P,'FusePlextrodes',1);

% BUILD A DEPTH DEPENDENT DISTRIBUTION OF CHANGES
R.Depths = []; R.ActVsPre = []; R.PostVsPre = []; R.PostVsAct = [];
Conds = {'ActVsPre','PostVsPre','PostVsAct'}; iA = 0;


% LOOP OVER RECORDINGS
for iR = 1:length(P.R1)
  cElecType = P.R1{iR}.Array;
  % LOOP OVER ELECTRODES
  for iE = 1:length(P.R1{iR}.Depths)
    iA = iA + 1;
    R(iA).Depth = P.R1{iR}.Depths(iE);
    R(iA).ElecType = P.R1{iR}.Array;
    if P.FusePlextrodes
      if strcmp(R(iA).ElecType(1:9),'plextrode')
        R(iA).ElecType = 'plextrode';
      end
    end
    R(iA).CellID = P.R1{iR}.ActVsPre(iE).CellID;
    for iC = 1:length(Conds)
      cData = P.R1{iR}.(Conds{iC})(iE);
      if P.Normed 
        cVal = cData.([P.Quantity,'Norm']); 
        cDSTRF = cData.DSTRFNorm; 
        cSTRF1 = cData.STRF1Norm; 
        cSTRF2 = cData.STRF2Norm; 
      else
        cVal = cData.(P.Quantity); 
        cDSTRF = cData.DSTRF; 
        cSTRF1 = cData.STRF1; 
        cSTRF2 = cData.STRF2; 
      end
      R(iA).(Conds{iC}).Quantity = cVal;
      if min(cData.SNR)<P.SNRThresh  
        R(iA).(Conds{iC}).Quantity = NaN;
      end
      R(iA).(Conds{iC}).DiffSTRF = cDSTRF;
      R(iA).(Conds{iC}).STRF1 = cSTRF1;
      R(iA).(Conds{iC}).STRF2 = cSTRF2;
      R(iA).(Conds{iC}).TimeBin1 = cData.TimeBin1;
      R(iA).(Conds{iC}).TimeBin2 = cData.TimeBin2;
      R(iA).(Conds{iC}).FreqBin = cData.FreqBin;
      R(iA).(Conds{iC}).SNR = cData.SNR;
      if iC==1
        R(iA).T = cData.T;
        R(iA).Octs = cData.Octs;
        R(iA).Fs = cData.Fs;
        R(iA).TargetFrequency = cData.TargetFrequency;
      end
    end
  end
end

if P.Plotting
  ElecTypes = {R.ElecType};
  UElecTypes = unique(ElecTypes);
  NElecs = length( UElecTypes);
  ColorsByCond = {[0,0,0],[0,0,0],[0,0,0]};
  MarkersByElec = {'o','o','o','o'}; N = zeros(3,NElecs);
  figure(P.FIG); clf; 
  DC = HF_axesDivide(length(UElecTypes),length(Conds))';
  colormap(HF_colormap({[0,0,1],[1,1,1],[1,0,0]},[-1,0,1]));
  H = cell(length(UElecTypes),1);
  clear global VisibleByCond VisibleByType; 
  global VisibleByCond VisibleByType;
  VisibleByCond = ones(1,length(Conds));
  VisibleByType = ones(1,length(Conds));
  XMAX = 0; YMAX = 1; YMIN = -1; YMINA = -1.8; SH = [];
  for iT = 1:length(UElecTypes)
    H{iT} = cell(1,length(Conds));
    cElecType = UElecTypes{iT};
    cInd = find(strcmp(ElecTypes,cElecType));
    for iC = 1:length(Conds)
      AH(iT,iC) = axes('Pos',DC{iT,iC}); hold on; grid on;
      imagesc([-100,100],[-1,1],[-1,1]); caxis([-10,10]);
      text(0.95,0.95,[MarkersByElec{iT},' = ',UElecTypes{iT}],'Units','norm','Horiz','right',...
        'Color',ColorsByCond{iC},'FontWeight','bold','Interpreter','none',...
        'ButtonDownFcn',{@LF_showElecs,iT});
      plot([-100,100],[0,0],'Color',[0.5,0.5,0.5]);
      text(-0.5,0.02,'L4','FontWeight','bold');
      plot([0,0],[-1.5,1.5],'Color',[0.5,0.5,0.5]);
      ylabel('Depth [mm]');
      xlabel([P.Quantity]);
      cVals = [];
      for iM=1:length(cInd)
        cDepth = [R(cInd(iM)).Depth];
        cVal = R(cInd(iM)).(Conds{iC}).Quantity;
        cVals(end+1) = cVal;
        cCellID = {R(cInd(iM)).CellID};
        if ~isnan(cVal)
          H{iT}{iC}(end+1)=plot(cVal,-cDepth+0.5,'Marker',MarkersByElec{iT},'MarkerSize',8,'MarkerFaceColor',ColorsByCond{iC},'MarkerEdgeColor',[1,1,1]);
          cNum = length(H{iT}{iC});
          set(H{iT}{iC}(end),'ButtonDownFcn',{@LF_showInfo,cInd(iM),Conds{iC}});
          I.CellIDs{iT}{iC}(cNum) = cCellID;
          XMAX = max([abs(cVal),XMAX]);
          YMAX = max([YMAX,-cDepth+0.5]);
          YMIN = min([YMIN,-cDepth+0.5]);
          N(iC,iT)=N(iC,iT)+1; 
        end
      end
      text(1,0.05,['N = ',n2s(N(iC,iT))],'Units','N','HOriz','right');      
      if iT==1
        text(0.05,1,Conds{iC},'Units','norm','Color',ColorsByCond{iC},'FontWeight','bold','ButtonDownFcn',{@LF_showConds,iC});
      end
      
      % PLOT DISTRIBUTION & SIGNIFICANCE
      if P.ShowDist
        XBins = linspace(-XMAX,XMAX,13);
        HIST = hist(cVals,XBins);
        HIST = HIST*0.5/max(HIST) +YMINA;
        area(XBins,HIST,'FaceColor',[0.5,0.5,0.5],'BaseValue',YMINA);
        [Hypothesis,Prob] = ttest(cVals,0.05);
        if ~isnan(Hypothesis) & Hypothesis 
          SH(end+1)=plot(0.95*sign(nanmean(cVals))*XMAX,YMINA+0.4,'h','Color',[1,1,1],'MarkerSize',12,'LineWidth',2,'MarkerFaceColor',[1,1,1]);
        end
        
      end
    end
  end
  set(AH,'XLim',[-1.1*XMAX,1.1*XMAX],'YLim',[min(1.1*YMIN,YMINA),1.1*YMAX]);
  D.R = R;
  D.H = H;
  set(P.FIG,'UserData',D); 
  
end

function LF_showInfo(Handle,Event,cInd,Cond)

D = get(gcf,'UserData');
R = D.R;
cR = R(cInd);
cCellID = cR.CellID;
FIG = figure(sum(int8([cCellID,Cond]))); clf; 
set(FIG,'NumberTitle','Off','Name',[cCellID,' ',Cond],'Position',[200,200,900,200]);
DC = HF_axesDivide([1,1,1.2],1,[0.08,0.2,0.87,0.67],[0.3],[]);
Fields = {'STRF1','STRF2','DiffSTRF'};
colormap(HF_colormap({[0,0,1],[1,1,1],[1,0,0]},[-1,0,1]));
for i=1:numel(DC)
  AH(i) = axes('Pos',DC{i}); hold on;
  imagesc(cR.T,[1:size(cR.(Cond).(Fields{i}),1)],cR.(Cond).(Fields{i})); set(gca,'YDir','normal');
  MAX(i) = max(abs(cR.(Cond).(Fields{i})(:)));  
  plot3(cR.T(cR.(Cond).TimeBin1),cR.(Cond).FreqBin,5,'og','MarkerSize',26);
  if i<3 SNRString = n2s(cR.(Cond).SNR(i),2); else SNRString = []; end
  title([Fields{i},' | F_T: ',sprintf('%i',cR.TargetFrequency),'  |  SNR:',SNRString]);
  axis tight;
  xlabel('Time [s]');
  if i==1
    ylabel('Frequency [Oct]'); set(gca,'YTick',[0.5:15.5],'YTickLabel',cR.Fs);
  else 
    set(gca,'YTick',[]);
  end
end

MAX = max(MAX);
for i=1:numel(DC)
  caxis(AH(i),[-MAX,MAX]);
  if i==3 colorbar; end
end

function LF_showConds(Handle,Event,iC)

global VisibleByCond VisibleByType
if isempty(VisibleByCond) VisibleByCond = [1,1,1]; end
D = get(gcf,'UserData');
H = D.H;
VisibleByCond(iC) = mod(VisibleByCond(iC)+1,2);

States = {'off','on'};
for iT=1:length(H)
  if VisibleByType(iT)
    set([H{iT}{iC}],'Visible',States{VisibleByCond(iC)+1});
  end
end

function LF_showElecs(Handle,Event,iT)

global VisibleByCond VisibleByType 
if isempty(VisibleByType) VisibleByType = [1,1,1]; end
D = get(gcf,'UserData');
H = D.H;
VisibleByType(iT) = mod(VisibleByType(iT)+1,2);
States = {'off','on'};
for iC = 1:length(VisibleByCond)
  if VisibleByCond(iC)
    set([H{iT}{iC}],'Visible',States{VisibleByType(iT)+1});
  end
end



