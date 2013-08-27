
baphy_set_path

globalparams.HWSetup=1;
globalparams.Physiology=1;

[HW,globalparams]=InitializeHW(globalparams);

T=Speech;
T=set(T,'PreStimSilence',0.5);
T=set(T,'PostStimSilence',0.5);
TrialSound=waveform(T,1);

HW = IOSetSamplingRate(HW, get(T, 'SamplingRate'));
HW = IOSetLoudness(HW,10);
IOSetAnalogInDuration(HW,3);
HW = IOLoadSound(HW, TrialSound);
StartEvent = IOStartAcquisition(HW);

pause(4);

ShutdownHW(HW);
