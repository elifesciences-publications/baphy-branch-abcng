function [DiffSTRFs] = computeDiffSTRF(varargin)

%% PARSE PARAMETERS
P = parsePairs(varargin);
checkField(P,'Pre');
checkField(P,'Act');
checkField(P,'Post');
checkField(P,'IPre');
checkField(P,'IAct');
checkField(P,'IPost');
checkField(P,'Target');

DiffSTRFs.Depths = [P.IPre.Electrodes.DepthBelowSurface];

DiffSTRFs.ActVsPre = LF_computeDiffSTRF(P.Pre,P.Act,P.IPre,P.IAct,P.Target);
DiffSTRFs.PostVsPre = LF_computeDiffSTRF(P.Pre,P.Post,P.IPre,P.IPost,P.Target);
DiffSTRFs.PostVsAct = LF_computeDiffSTRF(P.Act,P.Post,P.IAct,P.IPost,P.Target);
if isfield(P.IPre.ElectrodesByChannel(1),'Array')
  DiffSTRFs.Array = P.IPre.ElectrodesByChannel(1).Array;
else
  DiffSTRFs.Array = P.IPre.ElectrodesByChannel(1).Name;
end

function DSTRF = LF_computeDiffSTRF(STRF1,STRF2,I1,I2,Target)

NM = {'','Norm'} ; dT = diff(STRF1(1).T([1:2]));

% INTEGRATE DEPTH SHIFT BETWEEN RECORDINGS
DepthShift = (I2.Electrodes(1).DepthBelowSurface - I1.Electrodes(1).DepthBelowSurface)/diff([I1.Electrodes(1:2).DepthBelowSurface]);
if isempty(DepthShift) | isnan(DepthShift) DepthShift = 0; end
DepthShift = round(DepthShift);
if DepthShift >= 0 
  Ind1 = [DepthShift+1:length(STRF1)];
  Ind2 = [1:length(STRF1)-DepthShift];
else
  Ind1 = [1:length(STRF1)+DepthShift];
  Ind2 = [-DepthShift+1:length(STRF1)];
end

for iE = 1:length(Ind1) % LOOP OVER DEPTHS
  I(1) = round(Ind1(iE));
  I(2) = round(Ind2(iE));
  
  % SAVE BASE INFORMATION
  DSTRF(iE).T = STRF1(I(1)).T;
  DSTRF(iE).Fs = STRF1(I(1)).Fs;
  DSTRF(iE).Octs = STRF1(I(1)).Octs;
  DSTRF(iE).CellID = STRF1(I(1)).CellID;
  DSTRF(iE).Electrode = STRF1(I(1)).Electrode;

  % COMPUTE NUMBER TO IDENTIFY A LOCATION
  cCellID = DSTRF(iE).CellID;
  Pos = find(cCellID==' '); cCellID = cCellID([1:Pos-3,Pos:end]);
  DSTRF(iE).CellIDNum =  prod(double(cCellID)/100);
  
  % LOOP OVER NORMED OR NOT
  for iN = 1:2
    DSTRF(iE).(['DSTRF',NM{iN}]) = STRF2(I(2)).(['STRF',NM{iN}]) - STRF1(I(1)).(['STRF',NM{iN}]) ;
    for iT=1:2 % LOOP OVER FIRST AND SECOND STRF
      cSTRF = eval(['STRF',n2s(iT),'(I(',n2s(iT),')).STRF',NM{iN}]);
      DSTRF(iE).(['STRF',n2s(iT),NM{iN}]) = cSTRF;
      DSTRF(iE).SNR(iT) = eval(['STRF',n2s(iT),'(I(',n2s(iT),')).SNR']);
     
      [cBFBin{iT,iN},cTimeBin{iT,iN}] = find(abs(cSTRF(:,1:15))==max(abs(mat2vec(cSTRF(:,1:15)))));
      if length(cTimeBin{iT,iN}) > 1 & iT ==1;
        fprintf([I1.IdentifierFull,' El.',n2s(iE),' Multiple equal maxima in Time.\n']);
        cTimeBin{iT,iN} = cTimeBin{iT,iN}(1);
        cBFBin{iT,iN} = cBFBin{iT,iN}(1);
      end
      if cTimeBin{iT,iN}==1   cTimeBin{iT,iN} = cTimeBin{iT,iN}+1; end
      DSTRF(iE).(['TimeBin',n2s(iT),NM{iN}]) = cTimeBin{iT,iN};
      
      % FIND CENTER OF GRAVITY
      CenterGrav(iT,iN) = get_centergravity(cSTRF,4:4:48,'t',1);
      DSTRF(iE).(['CenterGrav',n2s(iT),NM{iN}]) = CenterGrav(iT,iN);
    end
    DSTRF(iE).(['PeakLatDiff',NM{iN}]) = cTimeBin{2,iN} - cTimeBin{1,iN};
    DSTRF(iE).(['CenterGravDiff',NM{iN}])  = diff(CenterGrav(:,iN));
  end

  % FIND TARGET FREQUENCY (FOR PTD, BF FOR OTHER RECORDINGS)
  Fs = STRF1(I(1)).Fs; Octs = log(Fs);
  if isfield(I1.exptparams.TrialObject.TargetHandle,'Frequencies')
    cTargetFrequency = I1.exptparams.TrialObject.TargetHandle.Frequencies;
    cFreqBin = find(log(cTargetFrequency)>Octs,1,'last');
    if isempty(cFreqBin) cFreqBin = 1; end
  else
    cFreqBin = cBFBin{1};
    cTargetFrequency = mean(Fs(cFreqBin+[0,1]));
  end
  DSTRF(iE).TargetFrequency = cTargetFrequency;

  % ADDING NEW FIELDS
  %DSTRF(iE).NewField = NewAnalysis(Parameters);
  
  for iN=1:2
    cFreqBins  = cFreqBin + [-1:1];
    if cFreqBin==1 cFreqBins = [1,2]; end;
    if cFreqBin==15 cFreqBins = [14:15]; end
    
    DSTRF(iE).(['TargetDiff',NM{iN}]) = mean(mat2vec(DSTRF(iE).(['DSTRF',NM{iN}])(cFreqBins,cTimeBin{1,iN}+[-1:1])));
    DSTRF(iE).(['FreqBin',NM{iN}]) = cFreqBin;
  end
end
