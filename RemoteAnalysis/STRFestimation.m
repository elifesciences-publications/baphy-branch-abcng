function varargout = STRFestimation (mfilename,spikefile,channel,unit,axeshandle)
% function [strf, snr, stdmat, StimParam] = STRFestimation (mfilename,spikefile,channel,unit,axeshandle)
% 
% a general STRF estimation program that gets the parameter file, spike
% file, channel, unit and axes handle and return the STRF, SNR and strf variance. It works
% with most formats (old, daqc, baphy, etc.)

% Nima

if ~exist('axeshandle','var'),
    axeshandle=gca;
end
if ~exist('channel','var'),
    channel=1;
end
if ~exist('unit','var'),
    unit=1;
end
if ~exist('rasterfs','var'),
    rasterfs=1000;
end
snr=0;
fprintf('Analyzing channel %d, unit %d (rasterfs %d)\n',...
    channel,unit,rasterfs);
disp('Loading spikes...');
[r,tags]=loadspikeraster({spikefile,mfilename},channel,unit,rasterfs,0,{'TORC'});
disp('Estimating STRF...');
[StStims,StimParam,waveParams,TorcNames] = loadtorc(mfilename);
% I dont know why mf is 20 in some cases and this makes it a problem:
StimParam.mf = 1;
StimParam.stonset = 0;
%
if ~isempty(TorcNames)
    rold=r;
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
end

[stimX,stimT,numstims] = size(StStims);
binsize = StimParam.basep/stimT;
strfest = zeros(stimX,stimT);
% only loop over real (non-nan) repetitions, as there may be different
% numbers of reps for different torcs.
realrepcount=max(find(~isnan(r(1,:,1))));
[pp,bb]=fileparts(mfilename);
if nargout>1,
    snr = get_snr(r,StStims,StimParam.basep,StimParam.mf,waveParams,StimParam.a1rv);
    varargout{2} = snr;
end
for rep = 1:realrepcount,
    for rec = 1:StimParam.numrecs,
        spkdata = r(:,rep,rec);
        if length(spkdata)<StimParam.stdur
            spkdata=cat(1,spkdata,ones(StimParam.stdur-length(spkdata),1).*nan);
        end
        % currently, don't discard the first repetition!
        [dsum,cnorm] = makepsth(spkdata,1000/StimParam.basep,0,... StimParam.basep,... % StimParam.basep,...0
            StimParam.stdur,StimParam.mf);

        % Normalization by # of cycles.  NOTE this may be variable for
        % TORCs, as TORCs could conceivably be shorter than the length
        % specified in exptparams! SVD 2006-07-22
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

    figure(get(axeshandle,'Parent'));
    axes(axeshandle);
    if sum(isnan(strfest(:)))==0,
        if ~isfield(StimParam,'octaves'),
            StimParam.octaves = 5;
        end
        stplot(strfest,StimParam.lfreq,StimParam.basep,1,StimParam.octaves);
    end
    xlabel(sprintf('time lag (ms) -- %d spikes',nansum(r(:))));
    ylabel(sprintf('frequency (Hz)'));
    ht=title(sprintf('%s (sorted) chan %d unit %d rep %d',basename(mfilename),channel,unit,realrepcount));
    set(ht,'Interpreter','none');

    set(gcf,'Name',sprintf('%s(%d)',bb,realrepcount));

    drawnow;
end
varargout{1} = strfest;
% now calculate the variance if neccessary:
if nargout>2
    r(find(isnan(r)))=0;
    stdmat = get_strf_var_int(strfest,r,StStims,StimParam.basep,StimParam.nrips ...
        ,0,StimParam.stdur/1000,StimParam.mf,2);
    varargout{3} = stdmat;
end
if nargout>3
    varargout{4} = StimParam;
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
% what is going on ???
mf=1;
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STRF variance estimation:
function [stdmat,resp] = ...
    get_strf_var_int (strf, spdata,stim,basep,nrips,startime,endtime,mf,rank)

compute_strf_var = 1; 

% use spikes for stimulus period only
%spdata = spdata(floor(startime*1000)+1:floor(endtime*1000),:,:);
endtime = floor(endtime*1000) - floor(startime*1000);
startime = 0;

[numdata,numsweeps,numrecs] = size(spdata);
[stimfreq,stimtime,numstims] = size(stim);

if ~exist('rank','var'), rank = 2; end
if ~exist('mf','var'), mf = 1; end
if ~exist('endtime','var'), endtime =  numdata/mf; end
if ~exist('startime','var'), startime = basep; end
if ~exist('nrips','var'),
    nrips = 1; 
    warning('nrips not specified, scaling may be incorrect'); 
end

if isempty(endtime), endtime =  numdata/mf; end
if isempty(startime), startime = basep; end

% check inputs
if ~eq(numstims,numrecs)
    disp('# of records and stimuli are not equal!');
    return
end

stdmat = [];
if compute_strf_var
    % SVD clean and interpolate
    % -------------------------
    strf = svdclean(strf,rank);
%     strf = interpft(interpft(strf,100,1),250,2);
    
    % Compute STRF variations
    % -----------------------
    % bootstrapping
    [stimfreq,stimtime,numrecs] = size(stim);
    [resprun1,resp1,spdata1] = bootresp(spdata,basep,100,basep/stimtime,mf);
    
    strfrun = zeros(stimfreq,stimtime,size(resprun1,3));
    for abc = 1:size(resprun1,3),
        strfrun(:,:,abc) = resp2strf(resprun1(:,:,abc),stim,nrips);
        strfrun(:,:,abc) = svdclean(strfrun(:,:,abc),rank);
    end
    
    % interpolating
    strfrunbig = zeros(100,250,size(resprun1,3));
    for abc = 1:size(resprun1,3),
        strfrunbig(:,:,abc) = interpft(interpft(strfrun(:,:,abc),100,1),250,2);
    end
    stdmat = std(strfrunbig,0,3);
    stdmat = std(strfrun,0,3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strfest = resp2strf(resp,stims,nrips);

% compute STRF from binned PSTH

records = size(resp,2);
stimLeng = size(stims,2);
strfest = zeros(size(stims,1),stimLeng);
for rec = 1:records,
    
    stim = stims(:,:,rec);
    dsum = resp(:,rec);
    
    for abc = 1:size(stim,1),
        
        stimrow = stim(abc,:);
        strfest(abc,:) = strfest(abc,:) +...
            real(ifft(conj(fft(stimrow)).*fft(dsum'))) *...
            2*nrips/mean(mean(stim.^2))/records/stimLeng;
    end
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [strf,residue,u,s,v] = svdclean(strfest,N);

% projects STRF into svd vectors and keep only up to rank N.

if nargin ==1,
    end1 = 5; start2 = 8; end2 = 12;
    [a,b] = size(strfest);
    %strfest = strfest - ones(size(strfest,1),1)*mean(strfest,1);
    ss = svd(strfest(:,1:round(end1/13*b)))/sqrt(end1);
    sn = svd(strfest(:,round(start2/13*b):round(end2/13*b)))/sqrt(1+end2-start2);
    sn = sn(1);
    if ~isempty(max(find(ss>sn)))
        N = max(find(ss>sn));
    else
        N = 0;
    end
    disp(['Rank=',num2str(N)])
end

[u,s,v] = svd(strfest);
strf = u(:,1:N)*s(1:N,1:N)*v(:,1:N)';
residue = strfest - strf;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [resprun,resp,spdata] = bootresp(spdata,basep,n,binsize,mf,invlist);  
% [resprun,resp,spdata] = bootresp(spdata,basep,n,binsize,mf,invlist);
% 
% spdata: Spike data matrix (npoints x nsweeps x nrecords)
% basep: Base period (in milliseconds) at which bootstrap shuffling is done
% n: Number of bootstrap iterations [Default: 100]
% binsize: Bin size for PSTH, in milliseconds [Default: 1]
% mf: multiplication factor (binsize of spdata in milliseconds / 1000) [Default: 1]
% invlist: indicates pairs of inverse-repeat stimuli (see torctest.m) [Default: None]
%
% Note: First period of each sweep is disgarded
% N: Total # periods used

%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[spikes,sweeps,records] = size(spdata);

if nargin < 6, invlist = ''; elseif isempty(invlist), warning('invlist is empty'), end 
if nargin < 5, mf = 1; end
if nargin < 4, binsize = 1; end
if nargin < 3, n = 100; end
% possibly default basep to npoint

tleng = round(basep/binsize);

if ~(size(invlist,1)<2),
 recs = records/2;
else
 recs = records;
end

resprun = zeros(tleng,recs,n); 

stperswp = spikes/mf/basep;  % Number of stimulus periods per sweep
N = sweeps*stperswp;	     % Total number of stimulus periods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmp = spdata(1:(floor(N/sweeps)*mf*basep),:,:);
spdata = reshape(tmp(:),[basep*mf,sweeps*floor(N/sweeps),records]); 
stperswp = floor(N/sweeps);
N = sweeps*stperswp;
if stperswp > 1,
 spdata(:,[1:stperswp:N],:)=[];  % This line removes the first period of
end                              % each sweep
N = size(spdata,2);		 % Number of stimulus periods retained

% Form response from valid data
resp = squeeze(mean(spdata,2)); 
if binsize ~= 1/mf,
   resp = insteadofbin(resp,binsize,mf);
   %resp = bindata3(resp,binsize,mf);
end
resp = resp*1e3/binsize;
if ~(size(invlist,1)<2),
 resp = (resp(:,invlist(1,:)) - resp(:,invlist(2,:)))/2;
end

% Form bootstrapped responses
nzdata = zeros(size(spdata));
h = waitbar(0,'Bootstrapping...');
for run = 1:n,

 waitbar(run/n)

 for rec = 1:records,
  swselect = ceil(rand(1,N)*N);
  nzdata(:,:,rec) = spdata(:,swselect,rec);
 end

 temp = squeeze(mean(nzdata,2));
 if binsize ~= 1/mf,
  temp = insteadofbin(temp,binsize,mf);
  %temp = bindata3(temp,binsize,mf);
 end
 temp = temp*1e3/binsize;
 if ~(size(invlist,1)<2),
  resprun(:,:,run) = (temp(:,invlist(1,:))-temp(:,invlist(2,:)))/2;
 else
   resprun(:,:,run) = temp;
 end

end
close(h)
