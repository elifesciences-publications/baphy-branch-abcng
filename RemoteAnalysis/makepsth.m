%----------------------------------------------------------------
% % Subfunction makepsth -- pulled from strf_online.m
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

%if endtime>min(find(isnan(dsum))),
%   endtime=min(find(isnan(dsum)))-1;
%end
if endtime>length(dsum),
   endtime=length(dsum);
end

fillmax=ceil(endtime/period).*period;
if fillmax>endtime,
   dsum((endtime+1):fillmax)=nan;
   endtime=fillmax;
end
dsum(1:startime)=nan;
repcount=fillmax./period;
dsum=reshape(dsum(1:endtime),period,repcount);

wrapdata=nansum(dsum,2);
cnorm=sum(~isnan(dsum),2);

%fin=find(isnan(dsum));
%if ~isempty(fin) && max(diff(fin))>1,
%   keyboard
%end

return

% SVD hacked to allow for inclusion of first TORC period!
mark1 = max(ceil(startime/period)*period,0);
markers = round(mark1:period:endtime);

period = ceil(period);
wrapdata = zeros(period,1);
cnorm = zeros(period,1);
eod = min(endtime,period);   % End of Data

if startime<mark1,
   wrapdata(startime:min(mark1,endtime))=dsum(startime:min(mark1,endtime));
   cnorm(startime:min(mark1,endtime))=1;
end

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
