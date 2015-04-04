function HW = IOLoadSound(HW, stim)
% function HW = IOLoadSound(HW, stim);
%
% The program loads the sound (stim) into the buffer and set the sampling
% frequency using HW.params.fsAO
%

%% MAKE SURE THE STIMULUS IS VERTICAL
 if size(stim,1)<size(stim,2)  stim=stim'; end;
 
 if isfield(HW,'TwoSpeakers') && HW.TwoSpeakers
   SpeakerNb = 2;
   if size(stim,2)==1
     stim(:,2) = stim(:,1);
   end
 else
   SpeakerNb = 1;%size(stim,2);
 end

%% CALIBRATE SPECTRUM AND VOLUME FOR SOME SETUPS
for SpeakerNum = 1:SpeakerNb
  if any(HW.params.HWSetup == [ 7,9,10,12 ] ) || ...
      isfield(HW.params,'driver') && strcmpi(HW.params.driver,'NIDAQMX'),
    if isfield(HW,'Calibration') && size(stim,1)>length(HW.Calibration(SpeakerNum).IIR)
      % ADAPT SAMPLING RATE
      cIIR = HW.Calibration(SpeakerNum).IIR; CalSR = HW.Calibration(SpeakerNum).SR;
      TCal = [0:1/CalSR:(length(cIIR)-1)/CalSR];
      TCurrent = [0:1/HW.params.fsAO:(length(cIIR)-1)/CalSR];
      cIIR = interp1(TCal,cIIR,TCurrent,'spline');
      % CONVOLVE WITH INVERSE IMPULSE RESPONSE OF SPEAKER
      tstim = conv(stim(:,SpeakerNum),cIIR)*CalSR/HW.params.fsAO;
      % UNDO SHIFT DUE TO CALIBRATION
      cDelaySteps = round(HW.Calibration(SpeakerNum).Delay*HW.params.fsAO);
      stim(:,SpeakerNum) = [tstim(cDelaySteps:end-length(cIIR)+1);zeros(cDelaySteps-1,1)];
    end
  end
end

%% DETERMINE STIMULUS LENGTH
HW.StimLength = size(stim,1)/HW.params.fsAO;

% Nima, November 2005
switch HW.params.HWSetup
  case {0},
      %disp('loading sound');
      stop(HW.AO);
      HW.AO = audioplayer(stim/10, HW.params.fsAO); % the range for audioplayer is +-1,
      try
          HW=IOMicTTLSetup(HW);
      catch
          %disp('no mic input');
          HW.AI=[];
      end
  otherwise    

    % INTRODUCE STEREO IF NOT RETURNED BY SOUND OBJECT
    % OVERWRITES THE SECOND AO CHANNEL (ASSUMES THAT LIGHT IS NOT CONNECTED)
    if ~strcmpi(IODriver(HW),'NIDAQMX') && size(stim,2)<length(HW.AO.Channel)  stim(:,2) = zeros(size(stim)); end
    if strcmpi(IODriver(HW),'NIDAQMX') && size(stim,2)<HW.AO.NumChannels  stim(:,2) = zeros(size(stim(:,1))); end
    
    % IN ORDER TO USE THE NEW LOUDNESS DETERMINATION METHOD
    % LOUDNESS_ADJUSTED can be set in a sound object, if it wants to adjust
    % the loudness itself, e.g. useful for ClickTrains
    global LoudnessAdjusted;
    if isempty(LoudnessAdjusted) || ~LoudnessAdjusted
      for SpeakerNum = 1:SpeakerNb
        switch HW.Calibration(SpeakerNum).Loudness.Method
          case 'MaxLocalStd';
            Duration = HW.Calibration(SpeakerNum).Loudness.Parameters.Duration;
            Val = maxLocalStd(stim(:,SpeakerNum),HW.params.fsAO,Duration);
            stim(:,SpeakerNum) =  HW.Calibration(SpeakerNum).Loudness.Parameters.SignalMatlab80dB*stim(:,SpeakerNum)/Val;
        end
      end
    end
    LoudnessAdjusted = 0;
    
    %% Apply software attenuation if specified
    % Only change level of channels named "Sound*":
    AudioChannels=IOGetAudioChannels(HW);
    if isfield(HW,'SoftwareAttendB')
      attend_db=HW.SoftwareAttendB;
    elseif isfield(HW.params,'SoftwareEqz') && any(HW.params.SoftwareEqz),
      atten_db=HW.params.SoftwareEqz(1);
    else
      atten_db = 0;
    end
    level_scale=10.^(-attend_db./20);
    stim(:,AudioChannels)=stim(:,AudioChannels).*level_scale;
    
    %% 2 SPEAKERS and Loudness are not been adjusted in the waveform of the SO
    if isfield(HW,'TwoSpeakers') && HW.TwoSpeakers && (isempty(LoudnessAdjusted) || ~LoudnessAdjusted)
      stim(:,1:SpeakerNb) = stim(:,1:SpeakerNb) * 0.5;
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
        % fill in empty AO channels with zeros
        if size(stim,2)<HW.AO(1).NumChannels,
            stim=cat(2,stim,zeros(size(stim,1),HW.AO(1).NumChannels-size(stim,2)));
        end
        
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
      
      % dulicate sound on the 2 channels if no analog stim on the 2nd one
      global SecondChannelAO;
      if ~isempty(SecondChannelAO) && ~SecondChannelAO && SpeakerNb == 1
        stim(:,2) = stim(:,1);
      % fill in empty AO channels with zeros %14/09-YB: from Steve' code
      elseif  ~isempty(SecondChannelAO) && ~SecondChannelAO && size(stim,2)<HW.AO(1).NumChannels  
        stim=cat(2,stim,zeros(size(stim,1),HW.AO(1).NumChannels-size(stim,2)));
      end
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
