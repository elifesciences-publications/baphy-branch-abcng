% chirptest.m

%Y = CHIRP(T,F0,T1,F1)

Fs=22000;
dur=0.2;
f1=500;
f2=700;

t1=1;

t=((1:dur*Fs)')./Fs;

y1=chirp(t,f1,t1,f2);
y2=chirp(t,f2,t1,f1);
y3=chirp(t,f1,t1,f2+1000);

p1=sin(2*pi*f1.*t);
p3=sin(2*pi*(f1+100).*t);


Snd('Play',y1,Fs);

pause(dur);

Snd('Play',y2,Fs);
pause(dur);

Snd('Play',y3,Fs);
