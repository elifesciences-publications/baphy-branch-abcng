%generates TF grid for a given sound
%includes end time windows
%
%this version makes filters inside the function
%
%if zp is 1, signal is zero-padded

function [energy_grid] = sound_energy_grid_full(s,sr,N,low_lim,hi_lim,win_ms,zp)

win_length = round(sr*win_ms/1000);
if rem(win_length,2)==0
    win_length = win_length+1;
end
if rem(length(s),win_length-1)~=0 | rem(length(s),win_length-1)~= (win_length-1)/2
    s = s(1:floor(length(s)/((win_length-1)/2))*(win_length-1)/2);
end

if zp==1
    if size(s,1)==1%row vector
        s = [s zeros(size(s))];
    elseif size(s,2)==1%column vector
        s = [s; zeros(size(s))];
    end
end

signal_length=length(s);
[filts,Hz_cutoffs,freqs]=make_erb_cos_filters(signal_length,sr,N,low_lim,hi_lim);
filts = filts(:,1:N+1); %throw out high end

subbands = generate_subbands(s,filts);
if zp==1
    subbands = subbands(1:end/2,:);
    signal_length = signal_length/2;
end
subbands = [subbands; zeros(1,N+1)];

win_array = make_subband_time_win_rcos(signal_length+1, win_length);

num_win = size(win_array,2);
num_sub = size(filts,2);

for s = 1:num_sub
    indices2 = find(filts(:,s)>0);
    for w = 1:num_win
        indices = find(win_array(:,w)>0);
        energy_grid(s,w) = rms(subbands(indices,s).*(win_array(indices,w).^2));
    end
end
