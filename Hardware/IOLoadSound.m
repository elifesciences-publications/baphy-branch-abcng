function HW = IOLoadSound(HW, stim)
% function HW = IOLoadSound(HW, stim);
%
% The program loads the sound (stim) into the buffer and set the sampling
% frequency using HW.params.fsAO
%

%% MAKE SURE THE STIMULUS IS VERTICAL
if size(stim,1)<size(stim,2)  stim=stim'; end;

%% CALIBRATE SPECTRUM AND VOLUME FOR SOME SETUPS
if any(HW.params.HWSetup == [ 7,9,10,12 ] ) || ...
    isfield(HW.params,'driver') && strcmpi(HW.params.driver,'NIDAQMX'),
  if isfield(HW,'Calibration') && length(stim)>length(HW.Calibration.IIR)
    % ADAPT SAMPLING RATE
    cIIR = HW.Calibration.IIR; CalSR = HW.Calibration.SR;
    TCal = [0:1/CalSR:(length(cIIR)-1)/CalSR];
    TCurrent = [0:1/HW.params.fsAO:(length(cIIR)-1)/CalSR];
    cIIR = interp1(TCal,cIIR,TCurrent,'spline');
    % CONVOLVE WITH INVERSE IMPULSE RESPONSE OF SPEAKER
    tstim = conv(stim(:,1),cIIR)*CalSR/HW.params.fsAO;
    % UNDO SHIFT DUE TO CALIBRATION
    cDelaySteps = round(HW.Calibration.Delay*HW.params.fsAO);
    stim(:,1) = [tstim(cDelaySteps:end-length(cIIR)+1);zeros(cDelaySteps-1,1)];
  end
end

%% DETERMINE STIMULUS LENGTH
HW.StimLength = size(stim,1)/HW.params.fsAO;

% Nima, November 2005
switch HW.params.HWSetup
  case {0},
    HW.AO = audioplayer (stim/5, HW.params.fsAO); % the range for audioplayer is +-1,

  otherwise    

    % INTRODUCE STEREO IF NOT RETURNED BY SOUND OBJECT
    % OVERWRITES THE SECOND AO CHANNEL (ASSUMES THAT LIGHT IS NOT CONNECTED)
    if ~strcmpi(IODriver(HW),'NIDAQMX') && size(stim,2)<length(HW.AO.Channel)  stim(:,2) = zeros(size(stim)); end
    if strcmpi(IODriver(HW),'NIDAQMX') && size(stim,2)<HW.AO.NumChannels  stim(:,2) = zeros(size(stim)); end
    
    %% Apply software attenuation if specified
    % Only change level of channels named "Sound*":
    AudioChannels=IOGetAudioChannels(HW);
    if isfield(HW,'SoftwareAttendB')
      attend_db=HW.SoftwareAttendB;
      %fprintf('Applying software attenuation %d\n',atten_db);
      level_scale=10.^(-attend_db./20);
      stim(:,AudioChannels)=stim(:,AudioChannels).*level_scale;
    end
    if isfield(HW.params,'SoftwareEqz') && any(HW.params.SoftwareEqz),
      atten_db=HW.params.SoftwareEqz(1);
      level_scale=10.^(-atten_db./20);
      stim(:,AudioChannels)=stim(:,AudioChannels).*level_scale;
    end
    
    %% ADD STIMULATION
    if isfield(HW,'AnalogStimulation') && HW.AnalogStimulation
      AS = zeros(size(stim,1),1);
      ASparams = HW.params.AnalogStimulation;
      for i=1:length(ASparams)
        iStart = round(ASparams(i).Start*HW.params.fsAO);
        iStop = round((ASparams(i).Start+ASparams(i).Duration)*HW.params.fsAO)-1;
        Inds = [iStart:iStop];
        AS(Inds) = ASparams(i).Voltage;
      end
      stim(:,2) = AS;
    end
    
    switch IODriver(HW)
      case 'NIDAQMX';
      
      % RESET TRIGGER LINE
      aoidx=find(strcmp({HW.Didx.Name},'TrigAO'));
      TriggerDIO=HW.Didx(aoidx).Task;
      AOTriggerChan=HW.Didx(aoidx).Line;
      v=niGetValue(HW.DIO(TriggerDIO));
      v(AOTriggerChan)=HW.DIO(TriggerDIO).InitState(AOTriggerChan);
      niPutValue(HW.DIO(TriggerDIO),v);
      
      % make sure that the AO objects have sampling rates specified in
      % HW.params.fsAO
      HW=niSetAOSamplingRate(HW);
      
      % actually load the samples
      SamplesLoaded=niLoadAOData(HW.AO(1),stim);     
      case 'DAQTOOLBOX';
    
       %% RESET TRIGGER LINE
       TrigIndexAO=IOGetIndex(HW.DIO,'TrigAO');
       ResetValAO = IOGetTriggerValue(HW.AO,'RESET');
       putvalue(HW.DIO.Line(TrigIndexAO),ResetValAO);

       %% FRP 2: input range of amp is not +/- 5, which distorts the sound
       % if we use that range. So, we are reduce it to 1/3, and adjust the gain of the amp
       % to get the correct dB in the SPR.
       % Only adjusting auditory channel 0, leave AO1 (light) intact
       if HW.params.HWSetup==4  stim(:,1) = stim(:,1) / 3; end
    
       set(HW.AO, 'SampleRate', HW.params.fsAO);
       set(HW.AO, 'BufferingMode','Auto'); % bug fix, SVD 2006-09-27
       
    
       %% SEND STIMULUS TO CARD
       HW.StimLength = size(stim,1)/HW.params.fsAO;
       putdata(HW.AO, stim);
    end
end