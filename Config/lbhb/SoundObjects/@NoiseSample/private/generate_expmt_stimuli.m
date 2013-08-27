% generates stimuli from McDermott, Wrobleski,and Oxenham (PNAS, 2011),
% both target/distractor sounds and incorrect probe sounds needed for
% experiments
%
% mean_option controls average long-term power spectrum of stimuli
%
% mean_option=2 yields a flat (white) spectrum (when averaged over many
% stimuli; individual stimuli will vary about this mean)
% mean_option=1 yields an approximately pink spectrum (same power in each
% subband, for ERB-spaced subbands)
%
% example using default parameters from paper:
% [target_sounds, distractor_sounds, incorrect_probes, distractors_for_probes] =
% generate_expmt_stimuli(40,6,80,1,320,1/.075,1/.065,.5,24000,2);
%
% target_sounds and distractor_sounds contain target/distractor sounds in
% their rows
%
% incorrect_probes contains the incorrect probe sounds for each target
% sound. incorrect_probes(n,p,:) is the pth incorrect probe for the
% target_sounds(n,:)
%
% distractors_for_probes contains the target-distractor-probe pairings.
% distractors_for_probes(n,p) is the index of the distractor for which
% incorrect_probes(n,p,:) is a probe sound.
%
% if multiple stimulus sets are requested, only the last one is returned.
% all stimulus sets are saved to a file (stim_pt1, stim_pt2 etc.)
%
% June-26-2011 Josh McDermott


function [target_sounds, distractor_sounds, incorrect_probes, distractors_for_probes] = ...
    generate_expmt_stimuli(num_targets,num_probe,num_dis,num_set,dur_ms,fcorr,tcorr,cell_var,sr,mean_option)


%cell_var = .5;
win_ms=20;
num_win=round(dur_ms/10)-2;
num_sub = 38; %not using 39th (high end)
%sr=24000;
N=num_sub-1;
low_lim = 20;
hi_lim = 4300;
probe_mix_thresh = 7;
level_diff_thresh = 1;

freq_corr = exp(-1/fcorr*[0:60]);
time_corr = exp(-1/tcorr*[0:num_win+10]);

[filts,win_array,C,signal_length] = make_mvgauss_pieces(win_ms,num_win,num_sub,time_corr,freq_corr,cell_var,sr);

num_win = size(win_array,2); %need to redefine to include endpoints

%these are the time slices that are fixed to generate an incorrect probe
fixed_cells1=zeros(num_sub,num_win);
fixed_cells1(1:num_sub,1:num_win/8)=1;
fixed_cells2=zeros(num_sub,num_win);
fixed_cells2(1:num_sub,num_win/8+1:num_win/4)=1;
fixed_cells3=zeros(num_sub,num_win);
fixed_cells3(1:num_sub,num_win/4+1:3*num_win/8)=1;
fixed_cells4=zeros(num_sub,num_win);
fixed_cells4(1:num_sub,3*num_win/8+1:num_win/2)=1;
fixed_cells5=zeros(num_sub,num_win);
fixed_cells5(1:num_sub,num_win/2+1:5*num_win/8)=1;
fixed_cells6=zeros(num_sub,num_win);
fixed_cells6(1:num_sub,5*num_win/8+1:3*num_win/4)=1;
fixed_cells7=zeros(num_sub,num_win);
fixed_cells7(1:num_sub,3*num_win/4+1:7*num_win/8)=1;
fixed_cells8=zeros(num_sub,num_win);
fixed_cells8(1:num_sub,7*num_win/8+1:num_win)=1;


for set_n = 1:num_set
    fprintf('Starting part %d of %d...\n',set_n, num_set);
    target_sounds = [];
    target_grids = [];
    distractor_sounds = [];
    distractor_grids = [];
    incorrect_probes = [];
    incorrect_probe_grids = [];
    incorrect_probe_stats = [];
    distractors_for_probes = [];
    which_fix = [];
    num_breaks = zeros(num_targets,num_probe);
    %generate target sounds
    fprintf('Generating target sounds...\n');
    for n=1:num_targets
        [target_sound, orig_grid] = make_mvgauss_sound_final(C,filts,win_array,signal_length,sr,mean_option);
        %target_sounds = [target_sounds; target_sound];
        target_sounds(n,:) = target_sound;
        target_grids(n,:) = reshape(orig_grid,num_sub*num_win,1)';
    end
    %generate distractor sounds
    fprintf('Generating distractor sounds...\n');
    for n=1:num_dis
        [distractor_sound, orig_grid] = make_mvgauss_sound_final(C,filts,win_array,signal_length,sr,mean_option);
        distractor_sounds(n,:) = distractor_sound;
        distractor_grids(n,:) = reshape(orig_grid,num_sub*num_win,1)';
    end

    for current_target=1:num_targets
        fprintf('Starting target %d of %d...\n',current_target,num_targets);
        temp = [1:num_dis];
        temp2 = randperm(num_dis);
        distractor_index = 0;
        for probe_n=1:num_probe
            not_done=1;
            while not_done
                %loop through distractors trying to make an incorrect probe
                %that satisfies the constraints
                distractor_index = distractor_index+1;
                if distractor_index > num_dis
                    distractor_index=1;
                end
                distractors_for_probes(current_target,probe_n) = temp(temp2(distractor_index));
                %choose which time slice to fix
                which_fix(current_target,probe_n)=ceil(8*rand);
                if which_fix(current_target,probe_n)==1
                    fixed_cells = fixed_cells1;
                elseif which_fix(current_target,probe_n)==2
                    fixed_cells = fixed_cells2;
                elseif which_fix(current_target,probe_n)==3
                    fixed_cells = fixed_cells3;
                elseif which_fix(current_target,probe_n)==4
                    fixed_cells = fixed_cells4;
                elseif which_fix(current_target,probe_n)==5
                    fixed_cells = fixed_cells5;
                elseif which_fix(current_target,probe_n)==6
                    fixed_cells = fixed_cells6;
                elseif which_fix(current_target,probe_n)==7
                    fixed_cells = fixed_cells7;
                elseif which_fix(current_target,probe_n)==8
                    fixed_cells = fixed_cells8;
                end
                fixed_vect = reshape(fixed_cells,num_sub*num_win,1);
                unfixed = find(fixed_vect==0);

                current_dis = distractors_for_probes(current_target,probe_n);
                
                mixture = target_sounds(current_target,:)+distractor_sounds(current_dis,:);

                diff_enough=0;
                num_tries = 0;
                while diff_enough==0
                    %generate conditional samples, clip them with mixture,
                    %see if they satisfy constraints
                    num_tries = num_tries+1;
                    [probe_sound, probe_grid] = cond_mvgauss_sound_clip(mixture,...
                        fixed_cells,C,filts,win_array,signal_length,sr,mean_option);
                    
                    [mixture_rms_grid] = sound_energy_grid_full(mixture',sr,N,low_lim,hi_lim,win_ms,1);
                    [target_rms_grid] = sound_energy_grid_full(target_sounds(current_target,:)',sr,N,low_lim,hi_lim,win_ms,1);
                    [false_rms_grid] = sound_energy_grid_full(probe_sound',sr,N,low_lim,hi_lim,win_ms,1);                    
                    mg = reshape(mixture_rms_grid,num_sub*num_win,1);
                    tg = reshape(target_rms_grid,num_sub*num_win,1);
                    fg = reshape(false_rms_grid,num_sub*num_win,1);
                    avg_db_diff_target = mean(abs(20*log10(fg./tg))); %probe-target difference
                    avg_db_diff_mixture = mean(abs(20*log10(fg(unfixed)./mg(unfixed)))); %probe-mixture difference
                    avg_db_diff_mix_all = mean(abs(20*log10(fg./mg))); %probe-mixture difference, all cells
                    avg_db_diff_mix_targ = mean(abs(20*log10(tg./mg))); %target-mixture difference
                    fprintf('target # %d; probe_n = %d; fix = %d; dis = %f; targ_diff = %3.2f; mix_diff = %3.2f; mix_diff_all = %3.2f; targ_mix_diff = %3.2f; ft rms = %3.2f\n',...
                        current_target,probe_n,which_fix(current_target,probe_n),distractors_for_probes(current_target,probe_n),avg_db_diff_target,avg_db_diff_mixture,avg_db_diff_mix_all,avg_db_diff_mix_targ,rms(probe_sound));

                    %check whether probe-mixture difference exceeds
                    %threshold for inclusion, and that probe rms is within
                    %1 dB of target rms (which is always .1)
                    if avg_db_diff_mixture>probe_mix_thresh & (rms(probe_sound)>.1*10^(-level_diff_thresh/20) | rms(probe_sound)>.1*10^(level_diff_thresh/20))
                        diff_enough=1;
                    end
                    %if can't find a suitable probe for this
                    %target-distractor pairing within 20 tries, move on
                    if num_tries>20
                        num_breaks(current_target,probe_n) = num_breaks(current_target,probe_n)+1;
                        break
                    end
                end
                if diff_enough
                    not_done=0;
                end
            end
            incorrect_probe_stats(current_target,probe_n,:) = [avg_db_diff_target avg_db_diff_mixture avg_db_diff_mix_all avg_db_diff_mix_targ rms(probe_sound)];
            incorrect_probes(current_target,probe_n,:) = probe_sound;
            incorrect_probe_grids(current_target,probe_n,:) = reshape(probe_grid,num_sub*num_win,1);
        end
    end

    eval(['save stim_pt' num2str(set_n) ' distractors_for_probes which_fix num_breaks target_sounds target_grids distractor_sounds distractor_grids incorrect_probes incorrect_probe_grids incorrect_probe_stats']);
end

