
globalparams.HWSetup=4;
    globalparams.AOTriggerType = BaphyMainGuiItems('AOTriggerType',globalparams);
    globalparams.PumpMlPerSec = BaphyMainGuiItems('PumpMlPerSec',globalparams);
    globalparams.LickSign = BaphyMainGuiItems('LickSign',globalparams);
globalparams.Module= 'Delayed Match-To-Sample';
globalparams.Physiology='No';
HW=InitializeHW(globalparams);

disp('3 pulses of 10 sec');
ev = IOControlPump (HW,'Start',10);
pause(11);
ev = IOControlPump (HW,'Start',10);
pause(11);
ev = IOControlPump (HW,'Start',10);
pause(11);
disp('done');
return

if 0,   
    disp('30 seconds straight');
    iopump(DAQ,1);
    pause(30)
    iopump(DAQ,0);
else
    disp('30 seconds in one second increments');
    for ii=1:30,
        iopump(DAQ,1);
        pause(1);
        iopump(DAQ,0);
        pause(1);
    end 
end

disp('cleaning up DAQ');
delete(DAQ.DIO);
delete(DAQ.AO);
clear DAQ;
