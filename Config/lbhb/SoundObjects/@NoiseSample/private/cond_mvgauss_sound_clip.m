%generates draw from multivariate gaussian spectrogram with some of the
%cells fixed (for purpose of making probe stimuli for experiments in
%McDermott, Wrobleski,and Oxenham (PNAS, 2011)
%this is done by passing the function an original sound and a matrix
%specifying which cells in the time-frequency decomposition to fix.
%fixed_cells should have 1 in the cells that are fixed, and 0 elsewhere
%
% mean_option follows the conventions of make_mvgauss_sound_final:
% mean_option=2 yields a flat (white) spectrum (when averaged over many
% stimuli; individual stimuli will vary about this mean)
% mean_option=1 yields an approximately pink spectrum (same power in each
% subband, which for ERB-spaced subbands yields something pinkish)
%
% assumes raised cosine windows and filters (which can be obtained via
% make_mvgauss_pieces.m)
%
% June-26-2011 Josh McDermott

function [mvgauss_sound, clipped_logged_grid, transformed_orig_grid] = cond_mvgauss_sound_clip(orig_sound,fixed_cells,C,filts,win_array,signal_length,sr,mean_option)

cell_mean = -0.75;
log_const = 10^-12;

%windows on end are half-length
num_win = size(win_array,2);
num_sub = size(filts,2);

%mean vector
if mean_option==1
    mean_grid = ones(num_sub,num_win)*cell_mean;
elseif mean_option==2
    mean_grid = log10(sum(filts.^2))'*ones(1,num_win);
    mean_grid = mean_grid - mean(mean(mean_grid)) + cell_mean;
end

%compute energy grid for orig_sound - normalized rms in TF windows
x1 = [orig_sound'; zeros(size(orig_sound'))];
subbands1 = generate_subbands(x1,filts);
subbands1 = subbands1(1:end/2,:);
subbands1 = [subbands1; zeros(1,num_sub)];
for s = 1:num_sub
    for w = 1:num_win
        indices = find(win_array(:,w)~=0);
        orig_energy_grid(s,w) = rms(subbands1(indices,s).*(win_array(indices,w).^2));%/sqrt(sum(filts(:,s)));
    end
end
%transform to log-energy and normalize
log_orig_grid = log10(orig_energy_grid + log_const);
transformed_orig_grid = log_orig_grid-mean(mean(log_orig_grid))+cell_mean; %transform to same units as mean_grid
transformed_orig_grid = transformed_orig_grid + 3/20;%3dB for mixture - necessary because sounds were normalized after being generated
orig = reshape(transformed_orig_grid,num_sub*num_win,1);
fixed_vect = reshape(fixed_cells,num_sub*num_win,1);
mean_vect = reshape(mean_grid,num_sub*num_win,1);

fixed = find(fixed_vect);
unfixed = find(fixed_vect==0);
uC = C(unfixed,unfixed);
fC = C(fixed,fixed);
ufC = C(unfixed,fixed);
fuC = C(fixed,unfixed);
f_mean =mean_vect(fixed);
u_mean =mean_vect(unfixed);

cond_mean = u_mean + ufC*inv(fC)*(orig(fixed)-f_mean);
condC = uC - ufC*inv(fC)*fuC;

%draw random sample
if length(unfixed)>0
    cond_sample=j_mvnrnd(cond_mean,(condC+condC')/2);
    new_vect = orig;
    new_vect(unfixed) = cond_sample;
else
    new_vect=orig;
end

logged_grid = reshape(new_vect,num_sub,num_win);
clipped_logged_grid = logged_grid;
pts_to_clip = find(logged_grid>transformed_orig_grid);
clipped_logged_grid(pts_to_clip) = transformed_orig_grid(pts_to_clip);

energy_grid = 10.^clipped_logged_grid-log_const;

%because we normalized original sound prior to conditioning on it
energy_correction = 10^-(-mean(mean(log_orig_grid))+cell_mean +3/20);

gn=gnoise(round(signal_length/sr*1000)+10, 20, 20000, -25, 0, sr);
gn=gn(1:signal_length)';
gn = [gn; zeros(size(gn))];%zero-pad
subbands_n = generate_subbands(gn,filts);
subbands_n = subbands_n(1:end/2,:);%chop off zeroes
subbands_n = [subbands_n; zeros(1,num_sub)];

subbands_mod = zeros(size(subbands1));
for s = 1:num_sub
    for w = 1:num_win
        if fixed_cells(s,w) %set equal to original sound
            subbands_mod(:,s) = subbands_mod(:,s) + subbands1(:,s).*win_array(:,w);
        else %generate new bit of subband with desired amplitude
            indices = find(win_array(:,w)~=0);
            old_rms = rms(subbands_n(indices,s).*win_array(indices,w));%/sqrt(sum(filts(:,s)));
            
            subbands_mod(:,s) = subbands_mod(:,s) + subbands_n(:,s).*win_array(:,w)/old_rms*energy_grid(s,w)*energy_correction;
        end
    end
end

subbands_mod = [subbands_mod(1:end-1,:); zeros(size(subbands_mod(1:end-1,:)))]; %zero-pad

mvgauss_sound = collapse_subbands(subbands_mod,filts);
mvgauss_sound = mvgauss_sound(1:end/2); %chop off zeroes
mvgauss_sound = mvgauss_sound';

