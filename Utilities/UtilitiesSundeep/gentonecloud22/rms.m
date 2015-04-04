function [r] = rms(x,targetvalue,dimension)
%e.g. RMS=rms(x) to calculate the RMS power of a wave-form
% or  x=rms(x,10) to set the RMS power of a wave-form
% or to calculate RMS values along the 2nd dimension, x=rms(x,[],2);
% If 'dimension' is not specified, it will assuming that the longer of the 1st and 2nd dimension is the preferred one.

if ~exist('dimension','var')
    if size(x,1)>=size(x,2)
        dimension=1;
    else
        dimension=2;
    end;
end;

if ~exist('targetvalue','var')
    targetvalue=[];
end;

if isempty(targetvalue)
    r=sqrt(mean(x.^2,dimension));
else
    if numel(x)>length(x); error('This part is only programmed for vectors'); end;
    r=x/rms(x)*targetvalue;
end;



% if size(x,1) == 1
%     r = sqrt(x*x'/size(x,2));
% else
%     for ii=1:size(x,1)
%         r(ii) = sqrt(x(ii,:)*x(ii,:)'/size(x,2));
%     end;
% end
