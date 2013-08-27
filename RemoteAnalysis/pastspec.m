function [strfest,indstrfs,resp]=pastspec(spdata,ststims,basep,stime,etime,hfreq,nrips,mf,VERB);
%[strfest,indstrfs,resp] = pastspec(spdata,ststims,basep,stime,etime,hfreq,nrips,mf,VERB);
%
% PASTSPEC : Spectro-temporal reverse correlation function.
%          : Cross-correlations implemented with FFTs
%
% spdata   : 3-D spike data matrix
% ststims  : 3-D stimulus matrix
% basep    : base period of stimuli
% stime	   : start time for usable response data (def = basep)
% etime    : end time for usable response data (def = end of data)
% hfreq    : highest frequency in stimulus (Hz) (def = 32)
% nrips    : # of unique ripple components in the stimulus set (def = 1)
% mf 	   : multiplication factor in data collection (def = 1)
% VERB	   : VERBOSE mode (binary, default 0)
%
% NOTE:    : It is assumed that the frequency range of the stimuli spans 
%            5 octaves

%spdata = spdata(stime+1:etime,:,:);
dim = length(size(spdata));
if dim == 3,
	[spikes,sweeps,records] = size(spdata); 
elseif dim == 2,
	[spikes,records] = size(spdata);  % for EP data
	sweeps = 1;
end
[nfreqs,sdur,nstims] = size(ststims);

if nargin < 9, VERB = 0; end
if nargin < 8, mf = 1; end
if nargin < 7, nrips = 1; warning('nrips not specified, scaling may be incorrect'); end
if nargin < 6, hfreq = 2^5; end
if nargin < 5, etime = spikes/mf; end
if nargin < 4, stime = basep; end

saf = 1000*sdur/basep;  % stimulus temporal sampling frequency
lfreq = hfreq/2^5; % hack
stimLeng = sdur; %round(basep*(saf/1000));  % check out if this rounding is OK
binsize = 1000/saf;  % in milliseconds
if stimLeng ~= sdur, 
	error('The length of ststims and stimLeng should match')
end
if records ~= nstims
	error('Number of stims. don''t match number of records')
end

strfest = zeros(nfreqs,stimLeng);
indstrfs = zeros(nfreqs,stimLeng,records);
resp = zeros(stimLeng,records);
%rm = zeros(size(strfest));  % for new 2-d fft feature
strftemp = zeros(size(strfest));
if VERB
   fig = figure;
end

for rec = 1:records;
	
        fprintf(1,'%s','Record '),fprintf(1,'%2d',rec),
        fprintf(1,'\b\b\b\b\b\b\b\b\b')

	stim = ststims(:,:,rec);
        
   	% Collapse sweeps
	if dim == 3,
		if sweeps > 1,
			dsum = sum(spdata(:,:,rec)');
		else,
			dsum = spdata(:,1,rec);
		end
	elseif dim ==2,
		dsum = spdata(:,rec);
	end
	dsum = dsum/sweeps;  % Normalization by # of sweeps.
         
	% PSTH generation
	[dsum,cnorm] = psth(dsum,1000/basep,stime,etime,mf);  
        %[dsum,cnorm] = psth(dsum,1000/basep,0,spikes,mf); 
	dsum = dsum./cnorm;  % Normalization by # of cycles.

	
	% Data binning (REPLACED BY FILTERING & DOWNSAMPLING)
	if binsize > 1/mf, 
		dsum = insteadofbin(dsum,binsize,mf);
		%dsum = bindata3(dsum,binsize,mf);
	end
	dsum = dsum*(1000/binsize);  % Normalization by binsize 

	resp(:,rec) = dsum;
	
        % Correlation operation
	if 0,
		rm(1,:) = dsum';
		strftemp = real(ifft2(fft2(rm).*fft2(fliplr(stim))));
	end
	if 1,
	for abc = 1:size(stim,1),
	       	stimrow = stim(abc,:);
          	strftemp(abc,:)=real(ifft(conj(fft(stimrow)).*fft(dsum')));
	end
	end
        
        strftemp = strftemp/stimLeng; % Normalization
	strftemp = strftemp*(2*nrips/mean(mean(stim.^2))/records);%Normalization

	strfest = strfest + strftemp;	
	indstrfs(:,:,rec) = strftemp;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if VERB,
	clf reset,
	set(gcf,'name','Spectro-temporal reverse correlation')
	subplot(221)
	stplot(stim,lfreq,stimLeng*(1000/saf))
	title(['Stimulus ' num2str(rec)])
	subplot(222)
	plot(dsum);axis tight,ylabel('spikes/sec')
	title(['Response ' num2str(rec)])
	subplot(223)
	stplot(strftemp,lfreq,stimLeng*(1000/saf))
	colorbar
	title(['Cross-Correlation ' num2str(rec)])
	subplot(224)
	stplot(strfest,lfreq,stimLeng*(1000/saf))
	colorbar
	title(['STRF estimate ' num2str(rec)])
	drawnow
	end
end		
%strfest = strfest/records;  % 

if 1
fprintf(1,'\n')		
if VERB, 
   figure(fig),
   set(gcf,'name','STRF estimate')
   stplot(interpft(interpft(strfest,100,1),250,2),lfreq,stimLeng*(1000/saf));
end
end
