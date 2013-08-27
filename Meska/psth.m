function [wrapdata,cnorm] = psth(dsum,fhist,startime,endtime,mf);
% [wrapdata,cnorm] = psth(dsum,fhist,startime,endtime,mf);
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
