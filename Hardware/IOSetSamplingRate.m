function HW = IOSetSamplingRate (HW, fs);
% function HW = IOSetSamplingRate (HW, fs);
% This function set the sampling rate of analog output and input (if is
% given)
% fs is the sampling rates array in the form: [AnalogOut_fs  AnalogIn_fs]
% 
% SVD update 2012-05-30 : added Nidaqmx support

% Nima, November 2005
switch HW.params.HWSetup
  case {0},  % ie, TEST MODE
    HW.params.fsAO = fs(1);  % for test, analog in does not exist
    set(HW.AO, 'SampleRate', HW.params.fsAO);
  otherwise
    
    if strcmpi(IODriver(HW),'NIDAQMX'),
      % SET ANALOG OUT SAMPLING RATE
      %niStop(HW.AO);
      HW=niSetAOSamplingRate(HW,'SR',fs(1));
      %S = DAQmxStartTask(HW.AO.Ptr);
      %if S NI_MSG(S); end
      
      % SET ANALOG IN SAMPLING RATE
      if length(fs) > 1
         HW=niSetAISamplingRate(HW,'SR',fs(2));
      end
      
    else
      % SET ANALOG OUT SAMPLING RATE
      HW.params.fsAO = fs(1);
      fsAOreal = setverify(HW.AO, 'SampleRate', HW.params.fsAO);
      if fsAOreal~=HW.params.fsAO
        error('CRITICAL: DAQ Card cannot exactly produce the requested Sampling Rate');
      end
      % SET ANALOG IN SAMPLING RATE
      if length(fs) > 1
        HW.params.fsAI = fs(2);
        fsAIreal = setverify(HW.AI, 'SampleRate', HW.params.fsAI);
        if fsAIreal~=HW.params.fsAI
          error('CRITICAL: DAQ Card cannot exactly aquire at the requested Sampling Rate');
        end
      end
    end
end
