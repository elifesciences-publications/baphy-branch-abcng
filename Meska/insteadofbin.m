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
