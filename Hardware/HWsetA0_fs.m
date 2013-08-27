function HW=HWsetAO_fs(HW,fs);

disp('This function will be removed, please use IOSetSamplingRate instead');
try,
    if HW.params.HWSetup==0,  % ie, TEST MODE
        
        HW.params.fsAO=fs;
    else
        HW.params.fsAO=fs;
        set(HW.AO,'SampleRate',HW.params.fsAO); 
    end

catch,
    ShutdownHW;
    error(['error: ',lasterr]);
end
