function R =  MD_computeSTRF(varargin)

%% PARSE ARGUMENTS
P = parsePairs(varargin);
Ptmp = MD_I2S2I(P); % PARSE 
P = transferFields(P,Ptmp);
checkField(P,'Method','NSL');
checkField(P,'SR',1000);
checkField(P,'SRana',100);
checkField(P,'RespType','SUA');
checkField(P,'Units','all');
checkField(P,'Plotting',0);
checkField(P,'FIG',1);

%% LOAD DATA 
I = getRecInfo(P.Identifier);
RESP = collectResponse('Identifier',P.Identifier,'Electrodes',P.Electrode,...
  'RespType',P.RespType,'Rasters',1,'IncludeSilence',0,'SR',P.SR,'Units',P.Units);

%% CHECK UNITS
switch P.RespType
  case 'SUA';
    Units = I.UnitsByElectrode{P.Electrode};
    if strcmp(P.Units,'all') UnitInd = 1:length(Units);
    else UnitInd = intersect(P.Units,Units);
    end
    cUnits = Units(UnitInd);
  case 'MUA';
    cUnits = 1; UnitInd = 1;
  otherwise error('ResponseType not implemented!');
end
    
%% COMPUTE STRF
for iU = 1:length(UnitInd)
  switch P.Method
    case 'NSL';
      cUnitInd = UnitInd(iU);
      Raster = double(RESP.Rasters{cUnitInd});
      TORCObject=I.exptparams.TrialObject.ReferenceHandle;
      [R(iU).STRF,R(iU).SNR,StimParam]= strf_est_core(Raster,TORCObject,P.SR);
      
      % ASSIGN REMAINING PARAMETERS
      R(iU).Fs = StimParam.freqs;
      R(iU).Octs = log2(R(iU).Fs);
      R(iU).T = [0:size(R(iU).STRF,2)]*(StimParam.binsize/1000);
      R(iU).CellID = [P.Identifier,' E',n2s(P.Electrode),' U',n2s(cUnits(iU))];
      R(iU).Electrode = P.Electrode;
      R(iU).Unit = cUnits(iU);
      if ~isempty(I.SingleIDsByElectrode{P.Electrode})
        R(iU).SingleID = I.SingleIDsByElectrode{P.Electrode}(iU);
      else 
        R(iU).SingleID = 0;
      end
      
    case 'LinearRegression';
      error('Not implemented yet...');
  end
end

% NORM STRF
%SDBaseline = std(mat2vec(R(iU).STRF(:,end)));
SDBaseline = std(R(iU).STRF(:));
if SDBaseline == 0; SDBaseline = 1; end
R(iU).STRFNorm = R(iU).STRF/SDBaseline;
    
%% PLOT STRF
if P.Plotting
  if mod(P.FIG,1) 
    delete(get(P.FIG,'Children'));
  else figure(P.FIG); clf; end
  DC = HF_axesDivide(length(UnitInd),1);
  for iU=1:length(UnitInd)
    if mod(P.FIG,1)  
      AH = P.FIG;
    else AH = axes('Pos',DC{iU}); end
    imagesc(R(iU).T,R(iU).Octs,R(iU).STRFNorm);
    set(AH,'YDir','normal');
    colormap(HF_colormap({[0,0,1],[1,1,1],[1,0,0]}));
    MAX = max(abs(R(iU).STRFNorm(:))); caxis([-MAX-0.1,MAX+0.1]);
    set(AH,'YTick',R(iU).Octs(1:3:end),'YTickLabel',round(R(iU).Fs(1:3:end)));
    title(AH,[P.Identifier,' El.',n2s(P.Electrode),' Unit ',n2s(cUnits(iU))]);
    %colorbar;
    xlabel(AH,'Time [s]');
    ylabel(AH,'Freq. [Hz]');
  end
end