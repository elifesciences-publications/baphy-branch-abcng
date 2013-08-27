% generates stimuli from McDermott, Wrobleski,and Oxenham (PNAS, 2011)
%
% mean_option controls average long-term power spectrum of stimuli
%
% mean_option=2 yields a flat (white) spectrum (when averaged over many
% stimuli; individual stimuli will vary about this mean)
% mean_option=1 yields an approximately pink spectrum (same power in each
% subband, for ERB-spaced subbands)
%
% example using default parameters from paper:
% [target_sounds, target_grids] =
% generate_gauss_sounds(40,320,1/.075,1/.065,.5,24000,2);
%
% June-19-2011 Josh McDermott

function [target_sounds, target_grids] = generate_gauss_sounds(num_sounds,dur_ms,fcorr,tcorr,cell_var,sr,mean_option)

%cell_var = .5;
win_ms=20;
num_win=round(dur_ms/10)-2;
num_sub = 38;
%sr=24000;
%low_lim = 20;
%hi_lim = 4300;

freq_corr = exp(-1/fcorr*[0:60]);
time_corr = exp(-1/tcorr*[0:num_win+10]);

[filts,win_array,C,signal_length] = make_mvgauss_pieces(win_ms,num_win,num_sub,time_corr,freq_corr,cell_var,sr);


target_sounds = [];
target_grids = [];
for n=1:num_sounds
    if rem(n,10)==0
        fprintf('%d of %d done...\n', n, num_sounds);
    end
    [target_sound, orig_grid] = make_mvgauss_sound_final(C,filts,win_array,signal_length,sr,mean_option);
    %[target_sound, orig_grid] = make_mvgauss_sound_iterative(C,filts,win_array,signal_length,sr,mean_option);
    target_sounds = [target_sounds; target_sound];
    target_grids = [target_grids; reshape(orig_grid,1,num_sub*(num_win+2))];
end


