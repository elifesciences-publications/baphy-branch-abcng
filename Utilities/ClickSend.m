function ClickSend (dur,idx);
if nargin==1 | idx==0
    fs=8000;
    t=0:1/fs:1;
    w=rectpuls(t-0.05-dur/8,dur/4);  %send a pulse with width of dur/4, and dely 50 ms
else
    if idx==1
        [w,fs]=wavread('waterpouring.wav');   %~4 sec water bubles sound
    else
        [w,fs]=wavread('waterbubbles.wav');   %~4 sec water bubles sound
    end
    if dur>length(w)/fs
        dur=length(w)/fs;
    end
    w=w(1:round(dur*fs));
end
sound(w,fs);
disp('Send a reinforcement signal!!');