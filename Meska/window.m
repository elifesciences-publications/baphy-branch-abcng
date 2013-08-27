pause(.5)

saveundo

if ~BAR,
 doubleclick = get(b1,'userdata');
else
 doubleclick = get(b2,'userdata');
end

if doubleclick,
 if ~BAR, 
     Ss = Ws; St = Wt; 
     if ~ONEFILE Ss2 = Ws2; St2 = Wt2; end;
 else, 
     Ss = []; St = []; 
     if ~ONEFILE Ss2 = []; St2 = []; end, 
 end
else
 
clear windows
nwin = str2num(get(e1,'string'));
for win = 1:nwin,
  disp(['Choose upper and lower point of window #' num2str(win)])
  [w1, w2] = ginput(2);
  windows(1,win) = round(mean(w1))-ts(1)+1;
  windows(2:3,win) = flipud(sort(w2));
end
disp('OK')

[temp1,temp2,temp3,temp4] = windiscr(Ss,St,windows);

if ~BAR,
  Ss = temp1;
  St = temp2;
  set(b1,'userdata',1)
else
  Ss = temp3;
  St = temp4;
  set(b2,'userdata',1)
end

if ~ONEFILE
    [temp5,temp6,temp7,temp8] = windiscr(Ss2,St2,windows);
    if ~BAR,
        Ss2 = temp5;
        St2 = temp6;
        set(b1,'userdata',1)
    else
        Ss2 = temp7;
        St2 = temp8;
        set(b2,'userdata',1)
    end
end
end

spikeselect
