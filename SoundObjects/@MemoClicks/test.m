% test
stim   = {};
events = {};
trialnum = 100; %input('Enter no. of trials: ');
o = MemoClicks();

for i = 1:trialnum
  [w, ev,o] = waveform (o,1,[],[],i);
  stim{i}   = w;
  events{i} = ev;
end

clc;

x=get(o,'stimulus');
length(find(x==0))
length(find(x==1))
length(find(x==2))


y=get(o,'Seeds');
y(find(x==2))