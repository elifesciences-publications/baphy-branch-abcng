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

mark1 = max(ceil(startime/period)*period,period); 
markers = round(mark1:period:endtime);

period = ceil(period);
wrapdata = zeros(period,1);
cnorm = zeros(period,1);
eod = min(endtime,period);   % End of Data

wrapdata(startime+1:eod) = dsum(startime+1:eod);
cnorm(startime+1:eod) = 1;
for ii = 1:length(markers)-1,
 interval = markers(ii+1) - markers(ii);
 wrapdata(1:interval) = wrapdata(1:interval) + dsum(markers(ii)+1:markers(ii+1));
 cnorm(1:interval) = cnorm(1:interval) + 1;
end

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
