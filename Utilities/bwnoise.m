function [sf,spure]=bwnoise(freq,bw,dur,Fs);

    
t=((1:dur*Fs)')./Fs;

s=randn(size(t));
spure=sin(2*pi*freq.*t);

%[b,a] = ellip(4,0.1,40,[freq-bw/2 freq+bw/2]*2/Fs);

lo=2.^(log2(freq)-bw/2);
hi=2.^(log2(freq)+bw/2);

% [b,a] = butter(4,[lo hi]*2/Fs);
[b,a] = fir1(1024,[lo hi]*2/Fs);

sf = filter(b,a,s);
ss=std(sf);
sf=sf./ss./sqrt(2);

return

% crap for debugging

figure;
plot(t,s);
hold on
plot(t,sf,'r');
plot(t,spure,'g');
hold off

figure
Hs=spectrum.periodogram;
psd(Hs,sf1,'Fs',Fs);
psd(Hs,spure,'Fs',Fs);

Snd('Play',sf,Fs);
Snd('Play',spure,Fs);

Fs=22000;
[sf1,sp1]=bwnoise(1000,0.1,1,Fs);
[sf2,sp2]=bwnoise(500,0.1,1,Fs);
[sf3,sp3]=bwnoise(550,0.1,1,Fs);
Snd('Play',sf1,Fs);
Snd('Play',sf2,Fs);
Snd('Play',sf3,Fs);

Snd('Play',sp2,Fs);
Snd('Play',sp3,Fs);


