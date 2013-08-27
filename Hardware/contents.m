% Hardware interface scripts:

        ShutdownHW (HW);
HW =    InitializeHW (globalparams);

ev          = IOControlPump (HW,PumpAction,Duration,PumpName)
ev          = IOControlShock (HW, Duration, Action)
Lick        = IOLickRead (HW, LickName);
[ll, ev]    = IOLightSwitch(HW,lightswitch,Duration,Action);

HW          = IOLoadSound(HW, stim);
flag        = IOIsPlaying (HW);
HW          = IOSetSamplingRate (HW, fs);
HW          = IOSetTrigger(HW, triggertype);
ev          = IOStartSound(HW,stim);
ev          = IOStopSound (HW);
IOSetLoudness (HW, dB);

ev          = IOStartAcquisition (HW);
ev          = IOStopAcquisition (HW);
d           = IOReadAIData(HW);
IOSetAnalogInDuration (HW, Duration);

timestamp   = IOGetTimeStamp(HW)
IOShutdownTimers(varargin);
