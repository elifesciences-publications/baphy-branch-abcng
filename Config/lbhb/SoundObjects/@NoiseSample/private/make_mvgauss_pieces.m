%
% [filts,win_array,C,signal_length] =
% make_mvgauss_pieces(win_ms,num_win,num_sub,time_corr,freq_corr,cell_var,sr);
%
% This function returns filters, time windows, and a correlation matrix,
% for use in generating stimuli (as in McDermott et al., 2011) whose
% spectrograms are samples from a multivariate Gaussian
%
% makes filters suitable for zero-padded signals
%
% uses raised cosine time windows, half-cosine freq responses
%
% example:
% [filts,win_array,C,signal_length] =
% make_mvgauss_pieces_lower_cutoff_zp(20,30,38,exp(-0.065*[0:40]),exp(-0.075*[0:60]),0.5,24000);
%
% June-19-2011 Josh McDermott

function [filts,win_array,C,signal_length] = make_mvgauss_pieces(win_ms,num_win,num_sub,time_corr,freq_corr,cell_var,sr);

%cell_var = .5;
%win_ms=20;
%num_win=30;

win_length = round(sr*win_ms/1000);
if rem(win_length,2)==0
    win_length = win_length+1;
end

%windows on end are half-length
signal_length=(num_win+1)*(win_length-1)/2;
N=num_sub-1;
low_lim = 20;
hi_lim = 8000; %4300;
[filts,Hz_cutoffs,freqs]=make_erb_cos_filters(signal_length*2,sr,N,low_lim,hi_lim);
filts = filts(:,1:num_sub); %throw out high end
win_array = make_subband_time_win_rcos(signal_length+1, win_length);

%make covariance matrix - time corr x freq corr x cell variance
num_win=num_win+2;
C=zeros(num_win*num_sub);
for j=1:size(C,1)
    for k=j:size(C,2)
        %compute frequency, time coord of cells matrix entry describes
        sub_j = rem(j,num_sub);
        if sub_j==0
            sub_j=num_sub;
        end
        time_j = ceil(j/num_sub);
        sub_k = rem(k,num_sub);
        if sub_k==0
            sub_k=num_sub;
        end
        time_k = ceil(k/num_sub);
        
        C(j,k) = cell_var*time_corr(abs(time_k-time_j)+1)*freq_corr(abs(sub_k-sub_j)+1);
        C(k,j) = C(j,k);
    end
end

