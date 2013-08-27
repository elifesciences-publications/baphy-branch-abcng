%makes array of raised cosine windows
%assumes signal_length-1 is a multiple of (win_length-1)/2
function win_array = make_subband_time_win_rcos(signal_length, win_length)

n_win = (signal_length-1)/(win_length-1)*2-1;

win_array = zeros(signal_length,n_win+2);

l=1;
for k=1:n_win
    h = l+(win_length-1); %adjacent windows overlap by 50%
    avg = (l+h)/2;
    rnge = (h-l);
    win_array(l:h,k+1) = (1+cos(([l:h]-avg)/rnge*2*pi))/2; %map cutoffs to -pi, pi interval
    l = l+(win_length-1)/2;
end
%first window goes up to peak of first cos window
first_peak=find(win_array(:,2)==max(win_array(:,2)));
win_array(1:first_peak,1) = 1 - win_array(1:first_peak,2);
last_peak=find(win_array(:,n_win+1)==max(win_array(:,n_win+1)));
win_array(last_peak:signal_length,n_win+2) = 1 - win_array(last_peak:signal_length,n_win+1);

