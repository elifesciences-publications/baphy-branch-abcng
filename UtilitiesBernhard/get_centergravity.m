function [centgrav,mypn] = get_centergravity(strf,xaxis,dim,method)

% [centgrav,mypn] = get_centergravity(strf,dim,method)
%
% This function returns the the spectral/or temporal
% center of gravity of an strf
% (default, temporal center of gravity)
%
% mypn: is the normalized Fourier-doamin function (spectral or temporal)
% It is normalized to sum to 1

if ~exist('dim','var'), dim = 't'; end
if ~exist('method','var'), method = 1; end

centgrav = 0;

switch dim
    % ------- Temporal dimension -------------
    case 't',
        if ~exist('xaxis','var'),xaxis = 4:4:24;end %Hz
        len = length(xaxis);
        switch method
            case 2,
                y = abs(fftshift(fft2(strf))); %.^2
                y_mean = mean(y);                
                y_pos_neg = (fliplr(y_mean(1:len))+y_mean(len+2:end))/2;
                y_pos_neg_norm = y_pos_neg./mean(y_pos_neg);
                centgrav = mean(y_pos_neg_norm.*xaxis);
            case 3,
                y = abs(fftshift(fft2(strf))).^2;
                y_mean = mean(y);                
                ynorm_mean = y_mean((end-5):end)/sum(y_mean((end-5):end));
                centgrav = sum(ynorm_mean((end-5):end).*xaxis);
            case 4,
                fp = fft(strf')';
                yp = abs(fp);%.^2;
                myp = sum(yp(:,2:7));
                mypn = myp./sum(myp);
                centgrav = sum(mypn.*xaxis);
            case 5,
                spc = sum(abs(strf),2); %spectral sum
                indx = find(spc>mean(spc));
                fp = fft(strf(indx,:)')';
                yp = abs(fp).^2;
                myp = sum(yp(:,2:7));
                mypn = myp./sum(myp);
                centgrav = sum(mypn.*xaxis);
            otherwise
                fp = fft(strf')';
                yp = abs(fp);
                myp = mean(yp(:,2:len+1));
                mypn = myp./mean(myp);
                centgrav = mean(mypn.*xaxis);
        end
        % ------- Spectral dimension -------------
    case 's',
        if ~exist('xaxis','var') | isempty(xaxis),xaxis = 0.2:0.2:1.4;end %c/o
        switch method
            case 2, %cross section at max point only
                [s,t]=find(abs(strf)==max(abs(strf(:))));
                fp = fft(strf(:,t));
                yp = abs(fp).^2;
                myp = sum(yp(2:8,:),2)';
                mypn = myp./sum(myp);
                centgrav = sum(mypn.*xaxis);
            otherwise,
                fp = fft(strf);
                yp = abs(fp).^2;
                myp = sum(yp(2:8,:),2)';
                mypn = myp./sum(myp);
                centgrav = sum(mypn.*xaxis);
        end
    otherwise
        disp('unrecognized dimension!');
        return;
end

