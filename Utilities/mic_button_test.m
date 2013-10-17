
globalparams=struct();
globalparams.HWSetup=0;
globalparams.Physiology='No';
HW=InitializeHW(globalparams);

% HW.AI is a daq object that reads from Mic line of sound card
HW=IOMicTTLSetup(HW);
start(HW.AI);

clickcount=0;
lastclick=0;
while clickcount<3,
    pause(0.001);
    lick=IOLickRead(HW);
    if lick && lastclick==0,
        clickcount=clickcount+1;
        fprintf('Click %d\n',clickcount);
        lastclick=1;
    elseif ~lick,
        lastclick=0;
    end
    
end
stop(HW.AI);
disp('done');

    