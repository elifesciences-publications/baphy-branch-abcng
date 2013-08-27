function [DC,AC1,norm,ACP,pst] = mpst(spdata,rv,binnum,pststart,pstend,mf);
%[DC,AC1,norm,ACP,pst] = mpst(spdata,rv,binnum,pststart,pstend,mf);
%
% MPST
%
% spdata: spike data
% rv: contains ripple velocities
% binnum: number of bins [16]
% pststart: start time of spike data used (ms) [250]
% pstend: end time of spike data used (ms) [1000]
% mf: multiplication factor [1]

[spikes,sweeps,records]=size(spdata);
if nargin < 6, mf = 1; end
if nargin < 5, pstend = 1000; end
if nargin < 4, pststart = 250; end
if nargin == 2, binnum = 16; end

for rec = 1:records
		
	swpsum = sum(spdata(:,:,rec)');  % Collapse sweeps
	swpsum = swpsum/sweeps;
	% Make period histogram
	[pstdata,hnorm]=psth(swpsum,abs(rv(rec)),pststart,pstend,mf);
	pstdata = pstdata./hnorm;

	% must decide on the binsize
	binsize = length(pstdata)/binnum;
	data = bindata3(pstdata,binsize);
	%data = bindata3(pstdata,binsize,mf);  % Bin the data
	data = data/(binsize*.001);   % The units of data are spikes/sec
size(data);
	%plot(data),pause
	pst(:,rec) = data;  

	X = fft(data)/length(data);

	DC(rec) = X(1);
	AC1(rec) = 2*abs(X(2));
	if sum(abs(X(2:9))),
	 	norm(rec) = abs(X(2))/sqrt(sum(abs(X(2:9)).^2));
	else 
		norm(rec) = 0;
	end
	ACP(rec) = angle(i*X(2)); % multiply by i to get sine phase not
	                          % cosine phase

end
