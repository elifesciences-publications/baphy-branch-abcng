function [spikes,times,spikesbar,timesbar] = windiscr(spikes,times,windows);

nwin = size(windows,2);
tvec = windows(1,:);
his = windows(2,:);
los = windows(3,:);

tfea = size(spikes,1);
nspk = size(spikes,2);
feamat = spikes(tvec,:);
temp1 = his'*ones(1,nspk) - feamat; 
temp2 = feamat - los'*ones(1,nspk); 
dead = unique(sort([find(sum(temp1<0,1)), find(sum(temp2<0,1))]));

spikesbar = spikes(:,dead);
timesbar = times(dead);
spikes(:,dead) = [];
times(dead) = [];

