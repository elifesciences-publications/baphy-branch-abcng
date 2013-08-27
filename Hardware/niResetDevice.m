function niResetDevice(Device)

S = DAQmxResetDevice(Device);
if S NI_MSG(S); end

