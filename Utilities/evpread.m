function [rs,strialidx,ra,atrialidx,rl,ltrialidx,Info] = evpread(filename,varargin)
% function [rS,STrialIdx,rA,ATrialIdx,rL,LTrialIdx]=evpread(filename,spikechans[=all],
%                                                   auxchans[=none],trials[=all],lfpchans[=none]);
%
% Read EVP files versions 3-5
%
% Arguments: (can be provided in sequence or as name-value-pairs)
% - rawchans     : set of raw channels
% - spikechans  : set of spike channels [all]
% - auxchans     : set of auxilliary channels (only V3-4) [none]
% - trials              : set of trials [all] 
% - lfpchans       : set of LFP channels [none]
% - filterstylbe      : how to filter the spike-data
%     'none';         : no filtering
%     'filtfilthum'   : combines faithulness with some speed increase [default]
%     'filtfiltold'     : old filtering, strong, possibly too strong: introduces some ringing
%     'butter'        : very fast, not strong enough for heavy noise, some distortion, a few steps shift.
% - dataformat  : 'linear' (Linear Data + TrialIndices) or 'separated' (Separated in a Cell)
%
% Return variables :
% NOTE: if only a single argument is returned, it is a struct with the
% requested fields, othewise the following arguments are returned:
% - rS               : spike data (time X spike channels)
% - STrialIdx   : the index of the first sample in each trial for the spike data
% - rA               : auxiliary data (time X aux channels)
% - ATrialIdx   : the index of the first sample in each trial for the auxiliary data
% - rL               : LFP data (time X lfp channels)
% - LTrialIdx   : the index of the first sample in each trial for the LFP data
% - Info            : Struct containing information about the recording
%
% Examples: 
% For a single output argument (a struct with all results field) 
% R = evpread('pathtoyourfilename.evp','spikeelecs',[1:10],'lfpchans',[1:5],'trials',[1:50]);
% 
% For multiple output arguments 
% [RSpike,SpikeIndices,tmp,tmp,RLFP,LFPIndices] = evpread('pathtoyourfilename.evp',[1:10],[],[1:50],[1:5]);
%
% created SVD 2005-11-07
% modified BE 2010-12-14
global C_r C_raw C_lfp C_mfilename C_evpfilename C_ENABLE_CACHING USECOMMONREFERENCE

if isempty(C_ENABLE_CACHING) C_ENABLE_CACHING=1; end
ENABLE_MAP_READ=1;
if isempty(USECOMMONREFERENCE) USECOMMONREFERENCE = 0; end
Info = [];

%% PARSE ARGUMENTS
if length(varargin) > 0 & ~ischar(varargin{1}) % OLD ARGUMENT STYLE
  %P.spikechans = varargin{1};
  P.spikeelecs = varargin{1};
  if length(varargin)>1 P.auxchans = varargin{2}; end
  if length(varargin)>2 P.trials = varargin{3}; end
  %if length(varargin)>3 P.lfpchans = varargin{4}; end
  if length(varargin)>3 P.lfpelecs = varargin{4}; end
else % NEW ARGUMENT STYLE
  P = parsePairs(varargin);
end
if ~isfield(P,'spikechans'),
if ~isfield(P,'spikeelecs') | isempty(P.spikeelecs),
  %if isempty(P.spikeelecs),   %replaced this line with above -KJD  %6.25.2012
      P.spikechans = []; 
   else
      P.spikechans = inf;
   end
end
if ~isfield(P,'auxchans') P.auxchans = [ ]; end
if ~isfield(P,'lfpchans') P.lfpchans = [ ]; end
if ~isfield(P,'rawchans') P.rawchans = [ ]; end
if ~isfield(P,'trials') || isempty(P.trials), P.trials = inf; end
if ~isfield(P,'filterstyle') P.filterstyle = 'butter'; end
if ~isfield(P,'wrap') P.wrap = 0; end
if ~isfield(P,'SRlfp') P.SRlfp = 2000; end
if ~isfield(P,'PreStimSilence') P.PreStimSilence = 0; end
if ~isfield(P,'dataformat') P.dataformat = 'linear'; end

%% CHECK EVP VERSION

if isempty(P.spikechans) && exist(filename,'file'),
    EVPVERSION=evpversion(filename,0);  % 0 means don't remap to
                                        % MANTA evp file
else
    EVPVERSION=evpversion(filename);
end

% If loading spikes or only zipped file exists, make a local copy
if ( ~isempty(P.spikechans) || ~exist(filename,'file')),
  evplocal=evpmakelocal(filename);
  if isempty(evplocal) error('evp file not found'); else filename=evplocal; end
end

%% CHECK FOR RESORTING OF CHANNELS (MAPS CHANNEL TO ELECTRODES)
P = LF_checkElecs2Chans(filename,P);

%% BRANCH FOR DIFFERENT EVP VERSIONS
switch EVPVERSION
  case 3; 
    %disp('EVP version 3 ...');
    [rs,strialidx,ra,atrialidx]=...
      evpread3(filename,P.spikechans,P.auxchans,P.trials);
    rl=[]; ltrialidx=[];
    
  case 4; 
    %disp('EVP version 4 ...');
    [fid,sError]=fopen(filename,'r','l');
    header(1:7)=double(fread(fid,7,'uint32'));
    header(8:10)=double(fread(fid,3,'single'));
    spikechancount=header(2);
    auxchancount=header(3);
    trialcount=header(6);
    lfpchancount=header(7);
    lfpfs=header(5);  % 15/03-YB/CB: was 8 before
    if isinf(P.spikechans) P.spikechans=1:spikechancount; end
    if isinf(P.trials)  P.trials=1:header(6); end
    
    if spikechancount<max(P.spikechans),
      error('invalid spike channel');
    end
    if auxchancount<max(P.auxchans),
      error('invalid aux channel');
    end
    if trialcount<max(P.trials),
      error('invalid trial range');
    end
    
    rs=[];
    ra=[];
    rl=[];
    strialidx=[];
    atrialidx=[];
    ltrialidx=[];
    if length(P.spikechans)==0;
      spikechansteps=spikechancount;
    else
      spikechansteps=diff([0; P.spikechans(:); spikechancount+1])-1;
    end
    if length(P.auxchans)==0;
      auxchansteps=auxchancount;
    else
      auxchansteps=diff([0; P.auxchans(:); auxchancount+1])-1;
    end
    if length(P.lfpchans)==0;
      lfpchansteps=lfpchancount;
    else
      lfpchansteps=diff([0; P.lfpchans(:); lfpchancount+1])-1;
    end
    
    % try to load from cache
    if C_ENABLE_CACHING && ...
        (~strcmp(basename(C_evpfilename),basename(filename)) || isempty(C_raw)),
      C_evpfilename=filename;
      C_mfilename=strrep(filename,'.evp','');
      C_raw={};
      C_lfp={};
      C_r={};
    end
    
    % try to load from map files... faster?
    [pp,bb]=fileparts(filename);
    mappath=[pp,filesep,'tmp',filesep];
    if ENABLE_MAP_READ && length(P.auxchans)==0 && exist([mappath sprintf([bb '%.3d.map'],P.trials(1))],'file'),
      if P.trials(1)==1,
        disp('loading from MAPs');
      end
      for i = 1:spikechancount
        channame{i} = ['SPK',num2str(i)];
      end
      for i = 1:lfpchancount
        lfpchanname{i} = ['LFP',num2str(i)];
      end
      
      for tt=1:length(P.trials),
        trialnum=P.trials(tt);
        evpdaq=[mappath sprintf([bb '%.3d.map'],trialnum)];
        
        data = [mapread(evpdaq,'Channels',channame,'DataFormat','Native')];
        ldata = [mapread(evpdaq,'Channels',lfpchanname,'DataFormat','Native')];
        
        if ~iscell(data) data = {data};end
        if C_ENABLE_CACHING,
          if tt==1,
            fprintf('%s: Creating evp cache for %s\n',mfilename,filename);
          end
          C_raw{trialnum}=cat(2,data{:});
          C_lfp{trialnum}=cat(2,ldata{:});
        end
        strialidx=[strialidx; length(rs)+1];
        rs=cat(1,rs,double(C_raw{trialnum}(:,P.spikechans)));
        ltrialidx=[ltrialidx; length(rl)+1];
        rl=cat(1,rl,double(cat(2,ldata{:})));
      end
      
    elseif C_ENABLE_CACHING && length(P.auxchans)==0 && ...
        length(C_raw)>=max(P.trials) && ~isempty(C_raw{max(P.trials)}) &&...
        ~isempty(C_raw{1}),
      
      % ie, contents of evp file were already saved in C_raw
      for tt=P.trials(:)',
        strialidx=[strialidx; length(rs)+1];
        atrialidx=[atrialidx; length(ra)+1];
        ltrialidx=[ltrialidx; length(rl)+1];
        
        rs=cat(1,rs,C_raw{tt}(:,P.spikechans));
        rl=cat(1,rl,C_lfp{tt}(:,P.lfpchans));
      end
      rs=double(rs);
      rl=double(rl);
    else
      
      for tt=1:max(P.trials),
        %drawnow;
        
        trhead=fread(fid,3,'uint32');
        if isempty(trhead) break; end
        ts=[];
        ta=[];
        tl=[];
        if ismember(tt,P.trials),
          
          % read spike data
          for ii=1:length(P.spikechans),
            if spikechansteps(ii)>0,
              % skip data from unwanted channels
              fseek(fid,trhead(1)*2*spikechansteps(ii),0);
            end
            ts=[ts fread(fid,trhead(1),'short')];
          end
          if spikechansteps(length(P.spikechans)+1)>0,
            fseek(fid,trhead(1)*2*spikechansteps(length(P.spikechans)+1),0);
          end
          
          %read aux data
          for ii=1:length(P.auxchans),
            if auxchansteps(ii)>0,
              fseek(fid,trhead(2)*2*auxchansteps(ii),0);
            end
            ta=[ta fread(fid,trhead(2),'short')];
          end
          fseek(fid,trhead(2)*2*auxchansteps(length(P.auxchans)+1),0);
          
          %read LFP data
          for ii=1:length(P.lfpchans),
            if lfpchansteps(ii)>0,
              fseek(fid,trhead(3)*2*lfpchansteps(ii),0);
            end
            tl=[tl fread(fid,trhead(3),'short')];
          end
          fseek(fid,trhead(3)*2*lfpchansteps(length(P.lfpchans)+1),0);
          
          strialidx=[strialidx; length(rs)+1];
          atrialidx=[atrialidx; length(ra)+1];
          ltrialidx=[ltrialidx; length(rl)+1];
          rs=cat(1,rs,ts);
          ra=cat(1,ra,ta);
          rl=cat(1,rl,tl);
        else
          % jump to start of next trial
          fseek(fid,(trhead(1)*spikechancount+trhead(2)*auxchancount+ ...
            trhead(3)*lfpchancount)*2,0);
        end
      end
    end
    
    
    fclose(fid);
    
    %% FILTER LFP
    if ~isempty(P.lfpchans)
      order = 2; Nyquist = P.SRlfp/2;
      fHigh = 1; fLow = 0.3*Nyquist;
      [bLow,aLow] = butter(order,fLow/Nyquist,'low');
      [bHigh,aHigh] = butter(order,fHigh/Nyquist,'high');    
      if P.wrap
        tmp = single(NaN*zeros(round((max(diff(cstrialidx))-1)/lfpfs*P.SRlfp),length(P.lfpchans),length(cstrialidx)-1));
        for i=1:length(cstrialidx)-1
          tmp2 = single(resample(double(rl(cstrialidx(i):cstrialidx(i+1)-1,:)),P.SRlfp,lfpfs));
          tmp(1:length(tmp2),:,i) = tmp2;
        end
        rl = tmp;
      else
        rl = single(resample(double(rl),P.SRlfp,lfpfs));
        ltrialidx = ceil(ltrialidx*P.SRlfp/lfpfs);
      end
      rl = filter(bLow,aLow,rl);
      rl = filter(bHigh,aHigh,rl);
     
%       bHumbug = [0.997995527211068  -5.987297083916456  14.967228743433322 -19.955854373444378  14.967228743433322  -5.987297083916456   0.997995527211068];
%       aHumbug = [1.000000000000000  -5.995310048314492  14.977237236960848 -19.955846338529373  14.957216231994666  -5.979292154433458   0.995995072333299];
%      rl = filter(bHumbug,aHumbug,rl);
    end

  case 5; fprintf('EVP version 5 :   ');
    fileroot = filename(1:end-10); 
    [SpikechannelCount,AuxChannelCount,TrialCount,...
      SR,Auxfs,LFPChannelCount,LFPfs]=evpgetinfo(filename);
    Info.SR = SR;
 
    if isinf(P.spikechans)  P.spikechans = [1:SpikechannelCount];  end
    if isinf(P.trials)             P.trials            = [1:TrialCount];   end
    
    loadchans = unique([P.rawchans,P.spikechans,P.lfpchans]);
    SortRaw = []; for iC = 1:length(P.rawchans) SortRaw(iC) = find(loadchans==P.rawchans(iC)); end
    SortSpike = []; for iC = 1:length(P.spikechans) SortSpike(iC) = find(loadchans==P.spikechans(iC)); end
    SortLFP = []; for iC = 1:length(P.lfpchans) SortLFP(iC) = find(loadchans==P.lfpchans(iC)); end
    
    %% LOOP OVER TRIALS & CHANNELS
    iCurrent = 0; Breaking = 0; rs = [];
    strialidx = []; ltrialidx = []; atrialidx = []; ra = []; rl = [];
    alltrialidx = zeros(length(P.trials),1); triallengths = zeros(length(P.trials),1);
    fprintf('Reading Trials  '); PrintCount = 0; 
    NDots = round(length(P.trials)/10); Dots = repmat('.',1,NDots);
    for tt = 1:length(P.trials)
      trialidx = P.trials(tt);
 
      % PRINT PROGRESSBAR
      BackString = repmat('\b',1,PrintCount);
      Division = ceil(tt/length(P.trials)*NDots);
      PreDots = Dots(1:Division-1); PostDots = Dots(Division:end-1);
      PrintCount = fprintf([BackString,'[ ',PreDots,' %d ',PostDots,' ]'],trialidx);
      PrintCount = PrintCount - length(BackString)/2;
            
      for cc = 1:length(loadchans)
        spikeidx = loadchans(cc);
        cFilename=[fileroot,sprintf('.%03d.%d.evp',trialidx,spikeidx)];
        trs = []; AttemptCounter = 0;
        while isempty(trs) && AttemptCounter<20  % 15/03-YB: Multiple attempts when lfp cannot be loaded
            AttemptCounter = AttemptCounter+1;
            [trs,Header]=evpread5(cFilename);
            if isempty(trs); disp('evpread: trial empty! I try again.'); pause(0.5); end
        end
        if USECOMMONREFERENCE
          % COMPUTE COMMON REFERENCE
          cFilename=[fileroot,sprintf('.%03d.%d.evp',trialidx,1)]; % COMMON REF INDEPENDENT OF EL.
          if cc == 1
            [CommonRef,BanksByChannel] = ...
              evpread5commonref(cFilename,length(trs),USECOMMONREFERENCE);
            % BREAK because error in CommonRef computation
            if isnan(CommonRef) Breaking = 1; error('error computing common reference'); break; end
          end
          if length(trs)==size(CommonRef,1) 
            % FORCE RECOMPUTE MEAN, PROBABLY BROKEN DURING COMPUTATION
            if spikeidx>length(BanksByChannel) 
              [CommonRef,BanksByChannel] = evpread5commonref(cFilename,length(trs),2);
            end
            trs = trs - CommonRef(:,BanksByChannel(spikeidx));
          else  % Delete MeanFile
            evpread5commonref(cFilename,length(trs),-1); Breaking = 1; break;
          end
        end
        if isempty(trs),
          error('evpread: trial empty!');
        end
        trs = [trs;trs(end)*ones(100,1)]; 
        ltrs = length(trs);
        if tt==1 && cc==1
          EstimatedSteps = length(P.trials)*ltrs;
          rall = zeros([EstimatedSteps,length(loadchans)],'single'); 
          Info = transferFields(Info,Header);
        end
        rall(iCurrent+1:iCurrent+ltrs,cc) = trs - trs(1);
      end
      if Breaking break; end
      alltrialidx(tt) =  iCurrent+1;
      triallengths(tt) = ltrs;
      iCurrent = iCurrent + ltrs;
    end;
    if Breaking tt=tt-1; end
    alltrialidx = alltrialidx(1:tt);
    fprintf('\n');
    
    %% SELECT CHANNELS FOR RAW, SPIKE & LFP
    if ~isempty(SortRaw)    rr = rall(1:iCurrent,SortRaw); rtrialidx = alltrialidx; end
    if ~isempty(SortSpike)  rs = rall(1:iCurrent,SortSpike); strialidx = alltrialidx; end
    if ~isempty(SortLFP)     rl = rall(1:iCurrent,SortLFP); ltrialidx = alltrialidx; end
    cstrialidx = [alltrialidx;iCurrent];
    NN=SR./2;
    
    %% FILTER SPIKES
    if ~isempty(P.spikechans)
      lof=300;  hif=6000;  
      
      bHumbug = [0.997995527211068  -5.987297083916456  14.967228743433322 -19.955854373444378  14.967228743433322  -5.987297083916456   0.997995527211068];
      aHumbug = [1.000000000000000  -5.995310048314492  14.977237236960848 -19.955846338529373  14.957216231994666  -5.979292154433458   0.995995072333299];
      
      switch P.filterstyle
        case 'butter';
          order = 2;
          [bLow,aLow] = butter(order,hif/NN,'low');
          [bHigh,aHigh] = butter(order,lof/NN,'high');
          for j=1:length(strialidx)
            tmp = filter(bLow,aLow,rs(cstrialidx(j):cstrialidx(j+1)-1,:));
            %tmp = filter(bHumbug,aHumbug,tmp);
            tmp = filter(bLow,aLow,tmp);
            rs(cstrialidx(j):cstrialidx(j+1)-1,:) = filter(bHigh,aHigh,tmp);
          end
          
        case 'filtfiltsep';
          orderhp=50; orderlp=10;
          f_hp = firls(orderhp,[0 (0.95.*lof)/NN lof/NN 1],[0 0 1 1])';
          f_lp = firls(orderlp,[0 hif/NN (hif./0.95)./NN 1],[1 1 0 0])';
          for j=1:length(strialidx)
            tmp = double(rs(cstrialidx(j):cstrialidx(j+1)-1,:));
            %tmp = filter(bHumbug,aHumbug,tmp);
            tmp = filtfilt(f_lp,1,tmp);
            rs(cstrialidx(j):cstrialidx(j+1)-1,:) = single(filtfilt(f_hp,1,tmp));
          end
          
        case 'filtfiltold'
          for j=1:length(strialidx)
            orderbp=min(floor(length(rs(cstrialidx(j):cstrialidx(j+1)-1,:))/3),round(SR./lof*5));
            f_bp = firls(orderbp,[0 (0.95.*lof)/NN lof/NN  hif/NN (hif./0.95)./NN 1],[0 0 1 1 0 0])';
            rs(cstrialidx(j):cstrialidx(j+1)-1,:) = single(filtfilt(f_bp,1,double(rs(cstrialidx(j):cstrialidx(j+1)-1,:))));
          end
          
        case 'filtfilthum'
          orderbp=50;
          f_bp = firls(orderbp,[0 (0.95.*lof)/NN lof/NN  hif/NN (hif./0.95)./NN 1],[0 0 1 1 0 0])';
          for j=1:length(strialidx)
            tmp = filter(bHumbug,aHumbug,rs(cstrialidx(j):cstrialidx(j+1)-1,:));
            rs(cstrialidx(j):cstrialidx(j+1)-1,:) = single(filtfilt(f_bp,1,double(tmp)));
          end
          
        case 'none'; % no Filtering
        otherwise error('Filter not implemented.');
      end
    end
   
    %% FILTER LFP
    if ~isempty(P.lfpchans)
      order = 2; Nyquist = P.SRlfp/2;
      fHigh = 1; fLow = 0.3*Nyquist;
      [bLow,aLow] = butter(order,fLow/Nyquist,'low');
      [bHigh,aHigh] = butter(order,fHigh/Nyquist,'high');    
      bHumbug=[0.995386247699319  -5.972013278489225  14.929576915653460  -19.905899769726052  14.929576915653460  -5.972013278489225  0.995386247699319 ];
      aHumbug = [ 1.000000000000000  -5.990446012819222  14.952579842917430  -19.905857198474035  14.906552701679249  -5.953623115411301  0.990793782108932  ];
      LHumbug = length(bHumbug)-1;
      if P.wrap
          % 16/11-YB: remove humbug on a per trial basis otherwise slow artifact at the trial start
          Raw = double(rl);
          tmp = Raw;
%           for i=1:length(cstrialidx)-1
%               tmp2 = double(Raw(cstrialidx(i):cstrialidx(i+1)-1,:));
%               tmp(cstrialidx(i):cstrialidx(i+1)-1,:) = filtfilt(bHumbug,aHumbug,tmp2);
%           end
          rl = tmp;
          
          tmp = single(NaN*zeros(round((max(diff(cstrialidx))-1)/SR*P.SRlfp),length(P.lfpchans),length(cstrialidx)-1));
          ltrialidx = 1;
          for i=1:length(cstrialidx)-1
              tmp2 = single(resample(double(rl(cstrialidx(i):(cstrialidx(i+1)-1),:)),P.SRlfp,SR));
              tmp2 = tmp2(2:end,:); % % 16/11-YB: resampling sucks
              tmp(1:size(tmp2,1),:,i) = tmp2;
              ltrialidx(i+1,1) = ltrialidx(i)+size(tmp2,1);
          end
          rl = tmp;
      else
          % 16/11-YB: moved within the IF condition for the above reason
          Raw=double(rl)';
          % IVHumbug = zeros(LHumbug,size(Raw,2));
          [Raw] = filter(bHumbug,aHumbug,Raw);
          rl = Raw';
          
          rl = single(resample(double(rl),P.SRlfp,SR));
          ltrialidx = ceil(cstrialidx*P.SRlfp/SR);
      end
      rl = cat(1,rl(round(P.PreStimSilence*P.SRlfp):-1:1,:,:),rl);
      rl = filter(bLow,aLow,rl);
      rl = filter(bHigh,aHigh,rl);
      rl = rl(round(P.PreStimSilence*P.SRlfp + 1):end,:,:);
      if P.wrap
          rlTemp = zeros(ltrialidx(end),length(P.lfpchans));
          for i=2:length(ltrialidx)
            rlTemp( ltrialidx(i-1) : (ltrialidx(i)-1) , :) = rl(1:(ltrialidx(i)-ltrialidx(i-1)),:,i-1);
          end
          rl = rlTemp;
      end
     
      %bHumbug = [0.997995527211068  -5.987297083916456  14.967228743433322 -19.955854373444378  14.967228743433322  -5.987297083916456   0.997995527211068];
      %aHumbug = [1.000000000000000  -5.995310048314492  14.977237236960848 -19.955846338529373  14.957216231994666  -5.979292154433458   0.995995072333299];
     %rl = filter(bHumbug,aHumbug,rl);
    end
      
  otherwise error('Invalid evp version!');
end

%% COLLECT ALL RESULTS INTO A SINGLE STRUCT
if nargout == 1
  switch P.dataformat
    case 'linear'; % 
      if ~isempty(P.rawchans) R.Raw = rr;  R.RTrialidx = rtrialidx; end; clear rr;
      if ~isempty(P.spikechans) R.Spike = rs; R.STrialidx = strialidx; end; clear rs;
      if ~isempty(P.lfpchans) R.LFP = rl; R.LTrialidx = ltrialidx; end; clear rl;
      if ~isempty(P.auxchans) R.AUX = ra; R.ATrialidx = atrialidx; end; clear ra;

    case 'separated'
      Fields = {'Raw','Spike','LFP','AUX'}; 
      for iF=1:length(Fields)
        cField = Fields{iF};
        cChans = P.([lower(cField),'chans']);
        if ~isempty(cChans)
          eval(['cidx = ',lower(Fields{iF}(1)),'trialidx;']);
          R.(Fields{iF}) = cell(length(cidx)-1,1);
          eval(['cData = r',lower(cField(1)),';'])
          cidx(end+1) = size(cData,1);
          for iT=1:length(cidx)-1
            R.(cField){iT} = cData(cidx(iT):cidx(iT+1)-1,:);
          end
        end
      end
  end
  R.Info  = Info;
  rs = R;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P = LF_checkElecs2Chans(filename,P)
% Translates electrode numbers into lowlevel channel numbers
% see M_RecSystemInfo & M_ArrayInfo & M_Arrays & M
Sep = HF_getSep;

cSpike = isfield(P,'spikeelecs') && ~isempty(P.spikeelecs);
cRaw = isfield(P,'rawelecs') && ~isempty(P.rawelecs);
cLFP = isfield(P,'lfpelecs') && ~isempty(P.lfpelecs);
maxchan=1;
if cSpike,
   maxchan=max([maxchan;P.spikeelecs(:)]);
end
if cRaw,
   maxchan=max([maxchan;P.rawelecs(:)]);
end
if cLFP,
   maxchan=max([maxchan;P.lfpelecs(:)]);
end

if cSpike || cRaw || cLFP
%   R = MD_dataFormat('FileName',filename);
%   try,
%      [ElectrodesByChannel,Electrode2Channel] ...
%         = MD_getElectrodeGeometry('Identifier',R.FileName,'FilePath',fileparts(filename));
%   catch
     ElectrodesByChannel=1:maxchan;
     Electrode2Channel=1:maxchan;
%   end
end
if cSpike
  P.spikechans =Electrode2Channel(P.spikeelecs);
  fprintf('Spike (El => Ch) : ');
  for i=1:length(P.spikechans) fprintf([' %d=>%d | '],P.spikeelecs(i),P.spikechans(i)); end
  fprintf('\n');
end
if cRaw
  P.rawchans =Electrode2Channel(P.rawelecs);  
  fprintf('Raw (El => Ch) : ');
  for i=1:length(P.rawchans) fprintf([' %d=>%d | '],P.rawelecs(i),P.rawchans(i)); end
  fprintf('\n');
end
if cLFP 
  P.lfpchans =Electrode2Channel(P.lfpelecs); 
  fprintf('LFP (El => Ch) : ');
  for i=1:length(P.lfpchans) fprintf([' %d=>%d | '],P.lfpelecs(i),P.lfpchans(i)); end
  fprintf('\n');
end

