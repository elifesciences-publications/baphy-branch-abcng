%
% [filts,win_array,C,signal_length] =
% make_mvgauss_pieces_general(win_ms,num_win,low_lim,hi_lim,num_channel,time_corr,freq_corr,cell_var,sr)
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
% make_mvgauss_pieces_lower_cutoff_zp(20,30,20,4300,38,-0.075*1.4528,-0.065,0.5,24000);
%
% July-27-2011 Josh McDermott

function [filts,win_array,C,signal_length] = make_mvgauss_pieces_general(win_ms,num_win,low_lim,hi_lim,num_channel,fcorr,tcorr,cell_var,sr)

%cell_var = .5;
%win_ms=20;
%num_win=30;

win_length = round(sr*win_ms/1000);
if rem(win_length,2)==0
    win_length = win_length+1;
end

%windows on end are half-length
signal_length=(num_win+1)*(win_length-1)/2;
N=num_channel-1;
%low_lim = 20;
%hi_lim = 4300;
[filts,Hz_cutoffs,freqs]=make_erb_cos_filters(signal_length*2,sr,N, ...
                                              low_lim,hi_lim);

filts = filts(:,1:num_channel); %throw out high end
win_array = make_subband_time_win_rcos(signal_length+1, win_length);

%express frequency correlation constant in subbands rather than ERB:
fcorr_sub = fcorr * (freq2e(Hz_cutoffs(end-1)) - freq2e(Hz_cutoffs(2))) / (num_channel-1);

freq_corr = exp(-fcorr*[0:num_channel+10]);
time_corr = exp(-tcorr*[0:num_win+10]);

%make covariance matrix - time corr x freq corr x cell variance
num_win=num_win+2;
C=zeros(num_win*num_channel);
for j=1:size(C,1)
    for k=j:size(C,2)
        %compute frequency, time coord of cells matrix entry describes
        sub_j = rem(j,num_channel);
        if sub_j==0
            sub_j=num_channel;
        end
        time_j = ceil(j/num_channel);
        sub_k = rem(k,num_channel);
        if sub_k==0
            sub_k=num_channel;
        end
        time_k = ceil(k/num_channel);
        
        C(j,k) = cell_var*time_corr(abs(time_k-time_j)+1)*freq_corr(abs(sub_k-sub_j)+1);
        C(k,j) = C(j,k);
    end
end

end

function erb = freq2e(freq);
erb = 9.265*log(1+freq./(24.7*9.265));
end