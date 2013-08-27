%generates sound by sampling time-frequency log energy grid from a multivariate
%gaussian with covariance matrix C
%
% mean_option=2 yields a flat (white) spectrum (when averaged over many
% stimuli; individual stimuli will vary about this mean)
% mean_option=1 yields an approximately pink spectrum (same power in each
% subband, which for ERB-spaced subbands yields something pinkish)
%
% assumes raised cosine windows and filters (which can be obtained via
% make_mvgauss_pieces.m)
%
% June-19-2011 Josh McDermott

function [mvgauss_sound, logged_grid] = make_mvgauss_sound_final(C,filts,win_array,signal_length,sr,mean_option)

cell_mean = -0.75;
log_const = 10^-12;

num_win = size(win_array,2);
num_sub = size(filts,2);

%mean vector
if mean_option==1
    mean_grid = ones(num_sub,num_win)*cell_mean;
elseif mean_option==2
    mean_grid = log10(sum(filts.^2))'*ones(1,num_win);
    mean_grid = mean_grid - mean(mean(mean_grid)) + cell_mean;
end

%draw random sample --- SVD 2013_08_06 this area controls modulation depth,
%I think!
y=j_mvnrnd(zeros(num_sub*num_win,1),C);
corred_grid = reshape(y,num_sub,num_win);
%add mean
logged_grid = corred_grid+mean_grid;
energy_grid = 10.^logged_grid-log_const;

x1=gnoise(round(signal_length/sr*1000)+10, 20, 20000, -25, 0, sr);
x1=x1(1:signal_length)';
x1 = [x1; zeros(size(x1))];%zero-pad
subbands1 = generate_subbands(x1,filts);
subbands1 = subbands1(1:end/2,:);%chop off zeroes
subbands1 = [subbands1; zeros(1,num_sub)];

subbands_mod = zeros(size(subbands1));
for s = 1:num_sub
    for w = 1:num_win
        indices = find(win_array(:,w)~=0);
        noise_rms = rms(subbands1(indices,s).*win_array(indices,w));%/sqrt(sum(filts(:,s)));
        subbands_mod(:,s) = subbands_mod(:,s) + subbands1(:,s).*win_array(:,w)/noise_rms*energy_grid(s,w);
        %figure(1);clf;plot(subbands_mod(:,s));pause(0.1);
    end
end

subbands_mod = [subbands_mod(1:end-1,:); zeros(size(subbands_mod(1:end-1,:)))]; %zero-pad

mvgauss_sound = collapse_subbands(subbands_mod,filts);
mvgauss_sound = mvgauss_sound(1:end/2); %chop off zeroes

mvgauss_sound = mvgauss_sound/rms(mvgauss_sound)*.1;
mvgauss_sound = mvgauss_sound';
