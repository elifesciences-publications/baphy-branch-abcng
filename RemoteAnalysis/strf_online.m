% function [strfest,snr] = strf_online(mfilename,channel,axeshandle,options);
%
%
% defaults
% options.sigthreshold=4;
% options.lfp = 0;
% options.usefirstcycle = 0;
%
%
function [strfest,snr] = strf_online(mfilename,channel,axeshandle,options,divisionhandle);

if ~exist('axeshandle','var'),
    axeshandle=gca;
end
AH(1) = axeshandle;
if ~exist('channel','var'),
    channel=1;
end
if ~exist('options','var'),
    options = [];
end
if ~isfield(options,'rasterfs'),
    options.rasterfs=1000;
end
if ~isfield(options,'sigthreshold'),
    options.sigthreshold=4;
end
if ~isfield(options,'lfp')
    options.lfp = 0;
end
if ~isfield(options,'compact')
    options.compact = 0;
end
if ~isfield(options,'usefirstcycle')
    options.usefirstcycle = 0;
end
if ~isfield(options,'scalesnr')
    options.scalesnr = 0;
end

if options.lfp
    fprintf('Analyzing channel %d (LFP; rasterfs %d)\n',...
        channel,options.rasterfs);
else
    fprintf('Analyzing channel %d (spike thresh %.1f std; rasterfs %d)\n',...
        channel,options.sigthreshold,options.rasterfs);
end
LoadMFile(mfilename);

tic;
disp('Loading evp...');
loadoptions=struct;
loadoptions.rasterfs=options.rasterfs;
loadoptions.channel=channel;
loadoptions.sigthreshold=options.sigthreshold;
loadoptions.includeprestim=0;
loadoptions.tag_masks={'TORC'};
loadoptions.lfp=options.lfp;
[r,tags]=loadevpraster(mfilename,loadoptions);
toc
tic;
disp('Estimating STRF...');

if isfield(exptparams.TrialObject,'Torchandle'),
    TorcObject=exptparams.TrialObject.Torchandle;
else
    TorcObject=exptparams.TrialObject.ReferenceHandle;
end
TorcNames=TorcObject.Names;
for ii=1:length(TorcNames),
    bb=strsep(TorcNames{ii},' ',0);
    TorcNames{ii}=bb{1};
end

rold=r;
rini = rold; tagsini = tags;

notempty = @(x) ~isempty(x);
nolightindex = strfind(tags,'NoLight');
if any(cellfun(notempty,nolightindex))
  TwolightConditions = 1;
  DCAll = HF_axesDivide(1,[1,1],divisionhandle,[],0.4);
  for ii = 1:2 % 2 light conditions
    AH(ii) = axes('Position',DCAll{ii},'FontSize',6);
  end
  LightConditionNb = 2;
  LightPatternStr{1} = '+NoLight'; LightPatternStr{2} = '+Light';
else
  LightConditionNb = 1;
  LightPatternStr{1} = 'TORC';
end

for LightNum = 1:LightConditionNb
axeshandle = AH(LightNum);
index = strfind(tagsini,LightPatternStr{LightNum});
index = find( cellfun(notempty,index) );
rold = rini(:,:,index);
tags = {tagsini{index}};

r=zeros(size(r,1),size(r,2),length(TorcNames)).*nan;
for ii=1:length(tags),
    bb=strsep(tags{ii},',',1);
    if ~strcmpi(strtrim(bb{3}),'Target')
        bb=strtrim(bb{2});
        jj=find(strcmp(bb,TorcNames));
        if ~isempty(jj),
            minrep=min(find(isnan(r(1,:,jj))));
            r(:,minrep:end,jj)=rold(:,1:(end-minrep+1),ii);
            %tags{ii}
            %[ii jj minrep]
            %r(:,:,jj)=rold(:,:,ii);
            % fprintf('mapping %d -> %d\n',jj,ii);
        end
    end
end

%referencecount=exptparams.TrialObject.ReferenceMaxIndex;
referencecount=TorcObject.MaxIndex;

%triallen=exptparams.LogDuration;
if isfield(TorcObject,'Duration'),
    refduration=ifstr2num(TorcObject.Duration);
elseif isfield(TorcObject,'TorcDuration'),
    refduration=ifstr2num(TorcObject.TorcDuration);
end

StimParam.numrecs   = referencecount; %get(t,'Index');
StimParam.mf        = options.rasterfs/1000; % config('mf');
dur = refduration;
StimParam.ddur      = round(1000*dur);
StimParam.stdur     = round(1000*dur);
StimParam.stonset   = 0;

StimParam.lfreq     = TorcObject.Params(1).LowestFrequency;
StimParam.hfreq     = TorcObject.Params(1).HighestFrequency;
StimParam.octaves=log2(StimParam.hfreq/StimParam.lfreq);
StimParam.a1am   = {};
StimParam.a1rf   = {};
StimParam.a1ph   = {};
StimParam.a1rv   = {};

for ii = 1:StimParam.numrecs
    StimParam.a1am{ii} = TorcObject.Params(ii).RippleAmplitude;
    if StimParam.octaves==7 && TorcObject.Params(12).Scales(1)<=0.14
      StimParam.a1rf{ii} = TorcObject.Params(ii).Scales.*8./7;
    else
      StimParam.a1rf{ii} = TorcObject.Params(ii).Scales;
    end
    % for a few mis-matched phase unit U-Torcs
    %StimParam.a1ph{ii} = TorcObject.Params(ii).Phase.*180./pi;
    StimParam.a1ph{ii} = TorcObject.Params(ii).Phase;
    StimParam.a1rv{ii} = TorcObject.Params(ii).Rates;
end;

[waveParams,W,Omega,StimParam.nrips,StimParam.basep] = ...
    makestimprofile(StimParam.a1am,StimParam.a1rf,StimParam.a1ph,...
    StimParam.a1rv);

StimParam.basep = round(1000/min(abs(diff([0 unique(abs(W(find(W))))]))));
noct = round(1/min(abs(diff([0 unique(abs(Omega(find(Omega))))']))));
maxv = max(abs(W));
maxf = max(max(abs(Omega)));
saf = ceil(maxv*2 + 1000/StimParam.basep);
numcomp = ceil(maxf*2*noct + 1);

StStims = stimprofile(waveParams,W,Omega,StimParam.lfreq,...
    StimParam.hfreq,numcomp,StimParam.basep,saf);
%StStims = stimscale(StStims,'moddep',0.9,[],10*saf*StimParam.basep/1000,...
%    10*numcomp/noct);
StStims = stimscale(StStims,'moddep',0.9,[],10*saf*StimParam.basep/1000,...
    2*numcomp);

[stimX,stimT,numstims] = size(StStims);

binsize = StimParam.basep/stimT;

strfest = zeros(stimX,stimT);

% only loop over real (non-nan) repetitions, as there may be different
% numbers of reps for different torcs.
realrepcount=max(find(~isnan(r(1,:,1))));
[pp,bb]=fileparts(mfilename);

if dur<StimParam.basep*2 || options.usefirstcycle,
    % this is a kludge to squeeze more data out of DMS-tone detect
    disp('INCLUDING FIRST TORC CYCLE!!!');
    FirstStimTime=0;
else
    FirstStimTime=StimParam.basep;
end   

snr = get_snr(r,StStims,StimParam.basep,StimParam.mf,waveParams,StimParam.a1rv);
for rep = 1:realrepcount,
    for rec = 1:StimParam.numrecs,
        
        spkdata = r(:,rep,rec);
        if length(spkdata)<StimParam.stdur
            spkdata=cat(1,spkdata,ones(StimParam.stdur-length(spkdata),1).*nan);
        end
        
        [dsum,cnorm] = makepsth(spkdata,1000/StimParam.basep,FirstStimTime,...
            StimParam.stdur,StimParam.mf);
        
        % Normalization by # of cycles.  NOTE this may be variable for
        % TORCs, as TORCs could conceivably be shorter than the length
        % specified in exptparams! SVD 2006-07-22
        if ~isempty(dsum),
           dsum = dsum./cnorm;
           
           if binsize > 1/StimParam.mf,
              dsum = insteadofbin(dsum,binsize,StimParam.mf);
           end
           dsum = dsum*(1000/binsize);  % Normalization by binsize
           
           stim = StStims(:,:,rec);
           strftemp = zeros(size(strfest));
           for abc = 1:stimX,
              stimrow = stim(abc,:);
              strftemp(abc,:) = real(ifft(conj(fft(stimrow)).*fft(dsum')));
           end
           
           strftemp = strftemp/stimT; % Normalization
           strftemp = strftemp*(2*StimParam.nrips/mean(mean(stim.^2))/...
              StimParam.numrecs);%Normalization
           
           strfest = strfest + strftemp./realrepcount;
        end
    end
    
    if ~isempty(axeshandle)
      figure(get(axeshandle,'Parent'));
      axes(axeshandle);
      if sum(isnan(strfest(:)))==0,
        if LightNum==1; clim = []; end
         if isfield(options,'tfrac') && options.tfrac>0 && options.tfrac<StimParam.basep,
            bp=StimParam.basep*options.tfrac;
            ts=strfest(:,1:round(size(strfest,2).*options.tfrac));
            clim = stplot(ts,StimParam.lfreq,bp,1,StimParam.octaves,clim);
         else
            clim = stplot(strfest,StimParam.lfreq,StimParam.basep,1,StimParam.octaves,clim);
         end
         if options.scalesnr,
            scalemax=1;
            if snr>scalemax,
               bsnr=1;
            elseif snr>0,
               bsnr=mean(snr)./scalemax;
            elseif snr<0.001,
               bsnr=0.001;
            end
            cl=get(gca,'CLim')./bsnr;
            set(gca,'CLim',cl);
         end
      
      end
      if options.compact,
        if channel==1
          ht=title([sprintf('E.%d Rep.%d Sp.%d SNR %.2f',channel, realrepcount, nansum(r(:)),snr)],'FontSize',6);
        else
          ht=title([sprintf('E.%d Sp.%d SNR %.2f',channel,nansum(r(:)),snr)],'FontSize',6);
          set(gca,'XTickLabel',[]);
        end
        set(gca,'FontSize',6);
        ytick=num2str(str2num(get(gca,'YTickLabel'))./1000);
        set(gca,'YTickLabel',ytick);
      else
        xlabel(sprintf('%.1f sig, %d sp, snr %.2f',options.sigthreshold,nansum(r(:)),snr));
        ylabel(sprintf('frequency (Hz)'));
        if options.lfp,
          ht=title(sprintf('%s chan %d LFP rep %d',basename(mfilename),channel,realrepcount));
        else
          ht=title(sprintf('%s chan %d rep %d',basename(mfilename),channel,realrepcount));
        end
      end
      set(ht,'Interpreter','none');
      
      set(gcf,'Name',sprintf('%s(%d)',bb,realrepcount));
      
      drawnow;
    end
end

end

toc

return


%
% Begin subfunctions borrowed from computestrf_map
%
        
%----------------------------------------------------------------
% % Subfunction makestimprofile
%----------------------------------------------------------------
function  [waveParams,W,Omega,N,T,k] = makestimprofile(a1am,a1rf,a1ph,a1rv);
% [waveParams,W,Omega,N,T,k] = makestimprofile(a1am,a1rf,a1ph,a1rv);
%
% MAKEWAVEPARAMS: This is an important program which transforms the input 
%                 matrices (dim: #components X #waveforms) into the
%		  universal waveParams representation used in STSTRUCT.

%clear W Omega waveParams

numstims = size(a1am,2);

% Transfer negative velocities to Omega

vels = cat(2,a1rv{:});
frqs = cat(2,a1rf{:});
frqs(find(vels<0)) = -frqs(find(vels<0));
vels = unique(abs(vels));
frqs = unique(frqs);

N = size(unique([cat(2,a1rv{:});cat(2,a1rf{:})]','rows'),1);
W = vels;
T = round(1000/min(abs(diff([0 unique(abs(W(find(W))))]))));
%k = round(abs(cat(1,a1rv{:}))'*T/1000 + 1);

Onegs = frqs(find(frqs<0));
Oposs = frqs(find(frqs>=0));
Onegs = Onegs(:); Oposs = Oposs(:);

Omega(1:length(Oposs),1) = Oposs; 
Omega(1:length(Onegs),2) = Onegs; 

Omega = sort(Omega);
if size(Omega,2) == 2,
	Omega(:,2) = flipud(Omega(:,2));
elseif size(Omega,2) == 1,
	Omega(:,2) = zeros(size(Omega));
end
numvels = length(W);
numfrqs = size(Omega,1);

waveParams = zeros(2,numvels,numfrqs,2,numstims);

for fnum = 1:numstims,
	for cnum = 1:length(a1am{fnum}),
		temp = a1am{fnum};
		amp = temp(cnum);
		temp = a1ph{fnum};
		phs = temp(cnum);
		if amp < 0,
			amp = abs(amp);
			phs = phs - 180;
		end	
		temp = a1rv{fnum}(cnum);
                %ii = find(temp<0);
                ii = temp<0;
		%veli = find(W==abs(temp(cnum)));
                veli = find(W==abs(temp));
                temp = a1rf{fnum}(cnum); 
                if ii, %~isempty(ii), 
                   temp = -temp; 
                   %phs(ii) = phs(ii)-180;
                   phs = -(phs+90)-90;
                end
		if temp %temp(cnum),
			%[frqi,sgn]=find(Omega==temp(cnum));
                        [frqi,sgn]=find(Omega==temp);
		else,
			frqi = 1; sgn = 1;
		end
                %veli,frqi,sgn,fnum,amp,phs
		waveParams(:,veli,frqi,sgn,fnum) = [amp phs];
	end
end

%----------------------------------------------------------------
% % Subfunction stimprofile
%----------------------------------------------------------------
function [ststims,freqs]=stimprofile(waveParams,W,Omega,...
				 lfreq,hfreq,numcomp,T,saf);
% [ststims,freqs] = ststruct(waveParams,W,Omega,lfreq,hfreq,numcomp,T,saf);
%
% STSTRUCT : Spectro-temporal stimulus constructor.
%
% waveParams : 5-D matrix containing amplitude and phase pairs for 
%              all components of all waveforms (see MAKEWAVEPARAMS)
% W          : Vector of ripple velocities
% Omega      : Matrix of ripple frequencies
% lfreq      : lowest frequency component
% hfreq      : highest frequency component
% numcomp    : number of components (frequency length)
% T          : stimulus duration (ms)
% saf 	     : sampling frequency (default = 1000 Hz)

[ap,ws,omegs,lr,numstims] = size(waveParams);
[a,b]=size(Omega);
[c,d]=size(W);

if nargin==7, saf = 1000; end

if a*b*c*d ~= omegs*ws*lr,
	error('Omega and/or W don''t match waveParams')
end

freqs = logNspace(2,lfreq,hfreq,numcomp+1);
sffact = saf/1000;
leng = round(T*sffact);
t = (1:leng)-1;

%w0 = saf/T;
w0 = 1000/T;
W0 = 1/(log2(hfreq/lfreq));

k = round(W/w0);
l = round(Omega/W0);

ststims = zeros(numcomp,leng,numstims);

c = [floor(numcomp/2)+1,floor(leng/2)+1];

for wnum = 1:numstims,
	count = 0;
	stimHolder = zeros(numcomp,leng);
	for row = 1:ws,
		%dblu = W(row);
		for sgn = 1:lr,
			for col = 1:omegs,
			      	%omeg = Omega(col,sgn);

				count = count + 1;

				amp = waveParams(1,row,col,sgn,wnum);
				phs = waveParams(2,row,col,sgn,wnum);

				if amp,

				stimHolder(c(1)+l(col,sgn),c(2)+k(row))=...
				(amp/2)*exp(i*(phs-90)*pi/180);
				stimHolder(c(1)-l(col,sgn),c(2)-k(row))=...
				(amp/2)*exp(-i*(phs-90)*pi/180);
				
				end
			end
		end
	end
	ststims(:,:,wnum) = real(ifft2(ifftshift(stimHolder*(leng*numcomp))));
end

%----------------------------------------------------------------
% % Subfunction stimscale
%----------------------------------------------------------------

function stim = stimscale(stim,REGIME,OPTION1,OPTION2,tsiz,xsiz);
% stim = stimscal(stim,REGIME,OPTION1,OPTION2,tsaf,xsaf);
%
% STIMSCAL: Stimulus scaling according the REGIME and OPTION# input strings.
% 
% Possibilities for REGIME and OPTION#:
%   REGIME            OPTION#
% 1) 'var': 	Variance normalization;
%		OPTION1 is the value of the variance. The default is unity.
%		OPTION2 is not required.
% 2) 'rip':	Ripple component magnitude normalization;
%		OPTION1 is the value of the magnitude. The default is unity.
%		OPTION2 is the number of ripples in the stimulus. Default: 6.
% 3) 'moddep':	Specified modulation depth;
%		OPTION1 is the modulation depth as a fraction of 1.
%		The default is 0.9.
%		OPTION2 is not required.
% 4) 'dB':	Stimulus produced with logarithmic amplitude.
%		OPTION1 is the modulation depth.  The default is 0.9.
%		OPTION2 is the base amplitude. The default is 75dB.

if nargin < 6, xsiz = size(stim,1); end
if nargin < 5, tsiz = size(stim,2); end
if nargin < 4,
	if strcmp(REGIME,'rip'), OPTION2 = 6; 
	else OPTION2 = 75; end
end
if nargin == 2, 
	if strcmp(REGIME,'var')|strcmp(REGIME,'rip'), OPTION1 = 1;
	else OPTION1 = 0.9; end
end

base1 = 0;
if (~strcmp(REGIME,'var')&~strcmp(REGIME,'rip')&...
	~strcmp(REGIME,'moddep')&~strcmp(REGIME,'dB')),
	error('Specified REGIME does not match any valid choice')
end

for abc = 1:size(stim,3),

	temp = stim(:,:,abc);

	if strcmp(REGIME,'moddep')|strcmp(REGIME,'dB')
		if xsiz~=size(temp,1) & tsiz~=size(temp,2),
		  temp1 = interpft(interpft(temp,xsiz,1),tsiz,2);
		else 
		  temp1 = temp;
		end
		scl = max(abs([min(min(temp1)),max(max(temp1))]));
	  	temp2 = base1 + temp*OPTION1/scl;
	end
	
	if strcmp(REGIME,'dB'),
		stim(:,:,abc) = OPTION2 -10*log10(size(stim,1))+...
				20*log10(temp2);
	elseif strcmp(REGIME,'var'),
		stim(:,:,abc) = ...
			temp/(sqrt((1/OPTION1)*mean(mean(temp.^2))));
	elseif strcmp(REGIME,'rip'),
		stim(:,:,abc) = ...
			OPTION1*temp/sqrt(mean(mean(temp.^2))/(OPTION2/2));
	elseif strcmp(REGIME,'moddep'),
		stim(:,:,abc) = temp2;
	end
end

%----------------------------------------------------------------
% % Subfunction makepsth
%----------------------------------------------------------------
function [wrapdata,cnorm] = makepsth(dsum,fhist,startime,endtime,mf);
% [wrapdata,cnorm] = makepsth(dsum,fhist,startime,endtime,mf);
% 
% PSTH: Creates a period histogram according to the period
%       implied by the input frequency FHIST
%
% dsum: the spike data
% fhist: the frequency for which the histogram is performed
% startime: the start of the histogram data (ms)
% endtime: the end of the histogram data (ms)
% mf: multiplication factor

if nargin < 5, mf = 1; end
if fhist==0, fhist=1000/(endtime-startime); end
%if fhist==0, fhist=1; end
dsum = dsum(:);

period = 1000*(1/fhist)*mf;  % in samples
startime = startime*mf;      %     '' 
endtime = endtime*mf;        %     ''

if endtime>min(find(isnan(dsum))),
    endtime=min(find(isnan(dsum)))-1;
end

% SVD hacked to allow for inclusion of first TORC period!
mark1 = max(ceil(startime/period)*period,0);
markers = round(mark1:period:endtime);

period = ceil(period);
wrapdata = zeros(period,1);
cnorm = zeros(period,1);
eod = min(endtime,period);   % End of Data

for ii = 1:length(markers)-1,
    % added SVD 2006-07-22, support for truncated torcs, don't include
    % segments of response that contain nans.
    interval = markers(ii+1) - markers(ii);
    wrapdata(1:interval) = wrapdata(1:interval) + dsum(markers(ii)+1:markers(ii+1));
    cnorm(1:interval) = cnorm(1:interval) + 1;
end

% add on extra partial cycle
leftover = endtime-markers(ii+1);
wrapdata(1:leftover) = wrapdata(1:leftover) + dsum(markers(ii+1)+1:endtime);
cnorm(1:leftover) = cnorm(1:leftover) + 1;
cnorm = max(cnorm,1);

if fhist == 1, 
	wrapdata = wrapdata(startime+1:eod);
	cnorm = cnorm(startime+1:eod);
end

%----------------------------------------------------------------
% % Subfunction insteadofbin
%----------------------------------------------------------------
function dsum = insteadofbin(resp,binsize,mf);
% dsum = insteadofbin(resp,binsize,mf);
%
% Meant to replace bindata3.m.
% It downsamples the spike histogram given by resp (with resolution mf) 
% to a resolution given by binsize (ms). However it does so 
% by sinc-filtering and downsampling instead of binning.

if nargin < 3, mf = 1; end

[spikes,records] = size(resp);
outlen = spikes/binsize/mf;
if mod(outlen,1) > 1,
    warning('Non-integer # bins. Result may be distorted');
end
outlen = round(outlen);  % round or ceil or floor?
dsum = zeros(outlen,records);

for rec = 1:records,
   temp = fft(resp(:,rec));

   if ~mod(outlen,2),  % if even length, create the middle point
     temp(ceil((outlen-1)/2)+1) = abs(temp(ceil((outlen-1)/2)+1));
   end

   dsum(:,rec) = real(ifft([temp(1:ceil((outlen-1)/2)+1);...
                 conj(flipud(temp(2:floor((outlen-1)/2)+1)))]));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function snr = get_snr(spdata,stim,basep,mf,waveParams,a1rv)

% snr = get_snr(spdata,stim,basep,mf,waveParams)
%
% This function gets the snr using the spike data given in spdata
% The spike data and stims should include all inverse-repeat pairs of TORCs
% the method is valid only using TORC stimuli

% April 20, 2004

% if ~exist('waveParams','var') | isempty(waveParams) 
    invlist = []; 
% else
%     [istorc,invlist] = torctest(waveParams);
% end

[numdata,numsweeps,numrecs] = size(spdata);
[stimfreq,stimtime,numstims] = size(stim);
spdata(find(isnan(spdata)))=0;
snr = Inf;

if ~eq(numrecs,numstims)
    disp('Number of records and stimuli are not equal');
    return;
end

% Response variability as a function of frequency per stimulus(-pair)
% -------------------------------------------------------------------
n = numsweeps*numdata/mf/basep;
tmp = spdata(1:(floor(n/numsweeps)*mf*basep),:,:);
spdata2 = reshape(tmp(:),[basep*mf,numsweeps*floor(n/numsweeps),numrecs]);
n = numsweeps*floor(n/numsweeps);
if n/numsweeps > 1,
    spdata2(:,[1:n/numsweeps:n],:)=[]; %exclude first period of each sweep
end
n = size(spdata2,2);
if ~(size(invlist,1) < 2),
    vrf = 1e6*stimtime^2/basep^2/n*squeeze(std(fft((spdata2(:,:,invlist(1,:))-spdata2(:,:,invlist(2,:)))/2,[],1),0,2)).^2;
else
    vrf = 1e6*stimtime^2/basep^2/n*squeeze(std(fft(spdata2,[],1),0,2)).^2;
end

% Response power as function of frequency
% ---------------------------------------
spikeperiod = squeeze(mean(spdata2,2));

% downsample spike histogram using insteadofbin (in justin.good)
if basep/stimtime ~= 1/mf,
    spikeperiod = insteadofbin(spikeperiod,basep/stimtime,mf);
end
spikeperiod = spikeperiod*1e3/basep*stimtime;

if ~(size(invlist,1)<2), 
    spikeperiod = (spikeperiod(:,invlist(1,:)) - spikeperiod(:,invlist(2,:)))/2; 
end

prf = abs(fft(spikeperiod,[],1)).^2;  

% Variability of the STRF estimate (for TORC stimuli)
% ---------------------------------------------------
%stimpospolarity = find(ismember(invlist(1,:),setdiff(invlist(1,:),[])));
if ~(size(invlist,1) < 2),
    stimpospolarity = invlist(1,:);
else
    stimpospolarity = [1:size(stim,3)];
end
stim2 = stim(:,:,stimpospolarity);

freqindx = round(abs(cat(1,a1rv{:}))'*basep/1000 + 1);
freqindx = freqindx(:,stimpospolarity);

% These are 1/a^2 for each stimulus
as = 2*sum(freqindx>0)./(squeeze(mean(mean(stim2.^2))))'; %sum(stimpospolarity>0):number of ripples

% Estimate of the total power (ps) and error power (pes) of the STRF 
pt = 0; pes = 0;
for rec = 1:length(stimpospolarity)
    pt  = pt + 1/stimtime^2*as(rec)*sum(2*prf(freqindx(:,rec),rec)); % Total power
    pes = pes + 1/stimtime^2*as(rec)*sum(2*vrf(freqindx(:,rec),rec)); % Error power
end

snr = pt/pes - 1;
