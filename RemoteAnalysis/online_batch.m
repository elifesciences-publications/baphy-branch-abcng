function r=online_batch(mfile,analysis_name,options)
%% function r=online_batch(mfile,analysis_name,options);
%
% options.Electrodes
% options.showinc
% options.datause
% options.sigthreshold
% options.psth
% options.lfp

%% PARSE PARAMETERS
if ~exist('analysis_name','var')   analysis_name='strf'; end
if ~strcmpi(analysis_name,'strf') && ~strcmpi(analysis_name,'raster')   error('unknown analysis.'); end
if ~exist('options','var')  options=[]; end
if ~isfield(options,'showinc')    options.showinc=0;  end
if ~isfield(options,'datause'),    options.datause='Both'; end
if ~isfield(options,'sigthreshold'),  options.sigthreshold=4; end
if ~isfield(options,'psth'),  options.psth=0; end
if ~isfield(options,'psthfs') || isempty(options.psthfs) || options.psthfs<=0,  options.psthfs=30; end
if ~isfield(options,'lfp'),  options.lfp=0; end
if ~isfield(options,'compact'), options.compact=0; end
if ~isfield(options,'ElectrodeMatrix'), options.ElectrodeMatrix=[]; end

[pp,filename,ext]=fileparts(mfile); LoadMFile(mfile);
if exist('MFileDone','var') && ~MFileDone,
    warning('MFileDone==0. M file not complete? Pausing 5 seconds'); pause(5); return
end

%% PARSE ELECTRODE SELECTION
chancount=globalparams.NumberOfElectrodes;
if ~isfield(options,'Electrodes')  options.Electrodes=1:chancount; 
else  options.Electrodes=options.Electrodes(:)';  end
Electrodes=options.Electrodes;

if options.usesorted
    UniqueElectrodes = unique(Electrodes);
    for ii = 1:length(UniqueElectrodes);
        ElectrodesUnits{ii}=find(UniqueElectrodes(ii) == Electrodes);      
    end
    Electrodes = UniqueElectrodes;
end
if ~isempty(options.ElectrodeMatrix) && sum(ismember(Electrodes,options.ElectrodeMatrix))<length(Electrodes),
    errordlg('Channel missing from Grid'); r=1; return;
end
if ~isfield(options,'unit') options.unit=ones(size(Electrodes)); end

%% GET ARRAY OR PLOTTING GEOMETRY
NElectrodes = length(Electrodes); % Number of Electrodes to plot

if isempty(options.ElectrodeMatrix) % IF USER HAS NOT SPECIFIED A DIFFERENT GRID
  try,
     [ElecGeom,Elec2Chan] = ...
        MD_getElectrodeGeometry('Identifier',filename,'FilePath',pp);
     ChannelsXY = reshape([ElecGeom.ChannelXY],2,numel([ElecGeom.ChannelXY])/2)';
     ElectrodesXY = ChannelsXY(Elec2Chan,:);
  catch
     ChannelsXY=[1 1; 1 2; 2 1; 2 2];
     ElectrodesXY=[1 1; 1 2; 2 1; 2 2];
  end
else % ELECTRODE MATRIX HAS BEEN SPECIFIED AS GRID
  EM = flipud(options.ElectrodeMatrix);
  for i=1:length(Electrodes)
    [cY,cX] = find(EM==Electrodes(i)); ElectrodesXY(Electrodes(i),1:2) = [cX,cY];
  end
end
Tiling  = max(ElectrodesXY,[],1); 
if length(ElectrodesXY)<4,
    Tiling(end)=size(ElectrodesXY,1);
    ElectrodesXY(:,2)=ElectrodesXY(:,2)-min(ElectrodesXY(:,2))+1;
end
%% SETUP FIGURE
global BATCH_FIGURE_HANDLE
if isempty(BATCH_FIGURE_HANDLE)  
  BATCH_FIGURE_HANDLE=figure; SS = get(0,'ScreenSize'); set(gcf,'Pos',[10,2*SS(4)/3-50,SS(3:4)/3]); ReuseFigure = 0;
else figure(BATCH_FIGURE_HANDLE); ReuseFigure = 1; end
set(BATCH_FIGURE_HANDLE,'Name',sprintf('%s',[filename,ext]),'KeyPressFcn',{@LF_KeyPress});
cols=max(ElectrodesXY(:,1));  rows=max(ElectrodesXY(:,2));
if Tiling(1)==1
  set(BATCH_FIGURE_HANDLE,'PaperPosition',[1 1 cols*2 rows]);
elseif max(Tiling)<=4,
  set(BATCH_FIGURE_HANDLE,'PaperPosition',[1 1 cols*2 rows*2]);
else
  set(BATCH_FIGURE_HANDLE,'PaperPosition',[0 0 cols rows]);
end
global CPOS; if ~isempty(CPOS) set(BATCH_FIGURE_HANDLE,'Position',CPOS); end
UH(1)=uicontrol('style','pushbutton','Units','Normalized','Position',[0.01,0.01,0.08,0.02],...
  'String','Save Size','Callback','global CPOS; CPOS = get(gcf,''Position'');');
UH(2)=uicontrol('style','pushbutton','Units','Normalized','Position',[0.1,0.01,0.08,0.02],...
  'String','Print Color','Foregroundcolor','red','Callback','set(gcf,''PaperSize'',[8.5,11],''PaperPosition'',[0.8,0.8,7,9.4]); print(gcf,''-Pcolor''); set(gco,''ForegroundColor'',''black'');');
UH(3)=uicontrol('style','pushbutton','Units','Normalized','Position',[0.19,0.01,0.08,0.02],...
  'String','Print B/W','Foregroundcolor','red','Callback','set(gcf,''PaperSize'',[8.5,11],''PaperPosition'',[0.8,0.8,7,9.4]); print(gcf,''-Plyra''); set(gco,''ForegroundColor'',''black'');');
UT=uicontrol('style','text','string',sprintf('%s',[filename,ext]),'Units','Normalized', ...
             'Position',[0.8 0.01 0.18 0.02],'HorizontalAlignment','right');

%% SETUP AXES
% DEFINE SEPARATION
if options.compact   Sep = [0.4,0.55];
else   Sep = [0.4,0.8]; end
  
% DEFINE INSET
OverHang = (1 ./ (Tiling-0.3) .* Sep ./ (1+Sep));
Range(1:2,1) = 0.7*OverHang;
Range(1:2,2) = 1-OverHang;

if Tiling(1)==1 && Tiling(2)==1,
    DCAll={[0.13 0.11 0.775 0.815]};
else
    DCAll = HF_axesDivide(Tiling(1),Tiling(2),Range(1,1:2),Range(2,1:2),Sep(1),Sep(2));
end

if ~ReuseFigure
  % CREATE NEW AXES
  for ii=1:NElectrodes
    Electrode = Electrodes(ii);
    DC{ii} = DCAll{end-round(ElectrodesXY(Electrode,2))+1,round(ElectrodesXY(Electrode,1))};
    figure(BATCH_FIGURE_HANDLE); % MAKE SURE TO PLOT INTO CORRECT FIGURE
    AH(ii) = axes('Position',DC{ii},'FontSize',6);
  end
else % REUSE AXES
  AH = get(BATCH_FIGURE_HANDLE,'Children');
  Types = get(AH,'Type'); Ind = strcmp(Types,'axes');
  AH = sort(AH(Ind));
end
drawnow;

%% START PLOTTING LOOP
try clear global GPROPS; end
for ii=1:NElectrodes
  cla(AH(ii));
  % OPTION FOR SORTED DATA
  if ~options.usesorted
    Electrode=Electrodes(ii);
    unit=options.unit(ii);
  else
    Electrode=Electrodes(ii);
    SortedUnits = options.unit(ElectrodesUnits{ii});
    disp(['Sorted Units on Electrode ', num2str(Electrode), ': ',num2str(SortedUnits)]);
    if length(SortedUnits) > 1   unit = input('Choose a unit: ');
    else                                         unit=SortedUnits;     end
    options.sortedunit = unit;
  end
  
  %% PLOT DIFFERENT ANALYSES
  switch analysis_name,
    case 'strf'
      if strcmpi(options.runclass,'ALM'),
        % for audio-visual stimuli, special analysis
        alm_online(mfile,Electrode,unit,AH(ii),options);
        if ii<NElectrodes && options.compact,
          legend off
        end
        
        % BIASED SHEPARD PAIR
      elseif strcmpi(options.runclass,'BSP'),
        MD_computeShepardTuning('MFile',mfile,'Electrode',Electrode,'Unit',unit,...
          'Axis',AH(ii),'SigmaThreshold',options.sigthreshold);
        
      elseif strcmpi(options.runclass,'AMT'),
        % for audio-visual stimuli, special analysis
        psth_heatmap(mfile,Electrode,unit,AH(ii),options);
        
      elseif strcmpi(options.runclass,'SPN') || strcmpi(options.ReferenceClass,'SpNoise'),
        options.filtfmt='envelope';
        options.chancount=0;
        options.rasterfs=100;
        % for speech and sporcs, use boosting to estimate strf
        boost_online(mfile,Electrode,unit,AH(ii),options);
      elseif strcmpi(options.runclass,'PPS') || strcmpi(options.ReferenceClass,'PipSequence'),
        options.filtfmt='parm';
        options.chancount=0;
        options.rasterfs=100;
        % for tone pip sequence, use boosting to estimate STRF from Pip
        % parameters
        boost_online(mfile,Electrode,unit,AH(ii),options);
      elseif strcmpi(options.runclass,'CCH') || strcmpi(options.ReferenceClass,'ComplexChord') || ...
          strcmpi(options.runclass,'BNB') || strcmpi(options.ReferenceClass,'NoiseBurst') || ...
          strcmpi(options.runclass,'FTC'),
        % two-tone 2nd-order tuning surface
        chord_strf_online(mfile,Electrode,unit,AH(ii),options);
      elseif strcmpi(options.runclass,'RDT') || ...
              strcmpi(options.ReferenceClass,'NoiseSample'),
          if strcmp(options.datause,'Per trial') || strcmp(options.datause,'Per trial pre-target'),
              options.filtfmt='qlspecgram';
              options.rasterfs=100;
              
              % for RDT NoiseSamples, use boosting to estimate strf
              boost_online(mfile,Electrode,unit,AH(ii),options);
          else
              chord_strf_online(mfile,Electrode,unit,AH(ii),options);
          end
      elseif strcmpi(options.runclass(1:2),'SP') || strcmpi(options.runclass,'SNS'),
        % for speech and sporcs, use boosting to estimate strf
        boost_online(mfile,Electrode,unit,AH(ii),options);
      elseif strcmpi(options.runclass,'VOC'),
        %options.filtfmt='specgramv';
        options.filtfmt='gamma';
        % for speech and sporcs, use boosting to estimate strf
        boost_online(mfile,Electrode,unit,AH(ii),options);
      elseif strcmpi(options.runclass,'tst')  %for multi-level tuning
        mltc_online(mfile,Electrode,unit,AH(ii),options);
      else
        if ~options.usesorted
          % standard TORC strf
          options.usefirstcycle=0;
          options.tfrac = 1;
          [strf,snr(ii)]=strf_online(mfile,Electrode,AH(ii),options);
        else
          mfilename = [mfile,'.m'];
          spkpath = mfile(1:strfind(mfile,filename)-1);
          
          if strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64')
            spikefile = [spkpath,'sorted\',filename,'.spk.mat'];
          else
            spikefile = [spkpath,'sorted/',filename,'.spk.mat'];
          end
          
          [strf,snr(ii)]=strf_offline2(mfilename,spikefile,Electrode,options.sortedunit);
        end
      end
      
    case 'raster',
      if 0 && options.lfp,
        stim_spectrum(mfile,Electrode,AH(ii));
      elseif options.lfp
        psth_lfp(mfile,Electrode,unit,AH(ii),options);
      elseif strcmpi(options.runclass,'RDT')
          options.PreStimSilence=0.2;
          options.PostStimSilence=0.2;
          raster_online(mfile,Electrode,unit,AH(ii),options);
      else
          raster_online(mfile,Electrode,unit,AH(ii),options);
      end
  end
  set([gca;get(gca,'Title');get(gca,'Children')],'ButtonDownFcn',...
    ['H = gca; NFig = figure; SS = get(0,''ScreenSize''); set(NFig,''Pos'',[10,3*SS(4)/4-100,SS(3:4)/4]); '...
    'NH = copyobj(H,NFig); set(NH,''Position'',[0.15,0.1,0.8,0.85]); xlabel(''Time [s]'')'])
  drawnow;
  if exist('snr','var') fprintf('Electrode %d snr=%.3f\n',ii,snr(ii)); end
end

if isfield(globalparams,'ExperimentComplete'),
  r=globalparams.ExperimentComplete; disp('Experiment complete.');
else r=0; end

%% SETUP FOR PRINTING
baphy_remote_figsave(BATCH_FIGURE_HANDLE,UH,globalparams,analysis_name,options.psth)

function LF_KeyPress(Obj,Event)

CC = get(Obj,'CurrentCharacter');
switch CC
  case {'+','-','='};
    if CC=='-'; Increment = -4; else Increment = +4; end
    C = get(Obj,'Children');
    for i=1:length(C)
      if strcmp(get(C(i),'Type'),'axes')
        P = get(C(i),'Children');
        for j=1:length(P)
          if strcmp(get(P(j),'Type'),'line')
            set(P(j),'MarkerSize',max([1,get(P(j),'MarkerSize')+Increment]));
          end;
        end;
      end;
    end
  otherwise
end

% TEMPORARY CODE FOR UNSCRAMBLING EARLY DIGITAL RECORDINGS
% InMANTASelect = setdiff([1:96],[2:3:95]);
% BR = [1:2:63,2:2:64]; % New Bankselection Indices
% RM = [8 16 7 15 6 14 5 13 4 12 3 11 2 10 1 9 [8 16 7 15 6 14 5 13 4 12 3 11 2 10 1 9]+16]; % Within bank unscrambling
% RM64 = [RM,RM+32]; % Unscrambling across two banks
% Rec2ChanInd = BR(RM64); % Selection indices that should make current recorded channels into the unsscrambled channels
% Chan2ElecInd = [17:32,1:16,49:64,33:48]; % Selection indices that shoud transition from chans to electrodes
% ChanData = RawData(Rec2ChanInd); ElecData = ChanData(Rec2ChanInd);
