% generates stimuli from McDermott, Wrobleski,and Oxenham (PNAS, 2011)
% generalized to allow control over the frequency range and number of
% frequency channels
%
% exponentially decaying correlations are imposed, specified in terms of
% the factor by which the correlation decays per ERB or per 10 ms time bin.
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
% generate_gauss_sounds_general(40,310,20,4300,38,.075*1.4528,.065,.5,24000,2);
%
% July-27-2011 Josh McDermott

function [target_sounds, target_grids] = generate_gauss_sounds_general(num_sounds,dur_ms,low_lim,hi_lim,num_channel,fcorr,tcorr,cell_var,sr,mean_option)

%cell_var = .5;
win_ms=20;
num_win=round(dur_ms/10)-1;
%num_channel = 38;
%sr=24000;
%low_lim = 20;
%hi_lim = 4300;

[filts,win_array,C,signal_length] = make_mvgauss_pieces_general(win_ms,num_win,low_lim,hi_lim,num_channel,fcorr,tcorr,cell_var,sr);


target_sounds = [];
target_grids = [];
for n=1:num_sounds
    if rem(n,10)==0
        fprintf('%d of %d done...\n', n, num_sounds);
    end
    [target_sound, orig_grid] = make_mvgauss_sound_final(C,filts,win_array,signal_length,sr,mean_option);
    %[target_sound, orig_grid] = make_mvgauss_sound_iterative(C,filts,win_array,signal_length,sr,mean_option);
    target_sounds = [target_sounds; target_sound];
    target_grids = [target_grids; reshape(orig_grid,1,num_channel*(num_win+2))];
end


