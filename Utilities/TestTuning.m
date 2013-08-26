function TestTuning(globalparams)

global BAPHYHOME

% load any pre-saved settings
savefile=[BAPHYHOME filesep 'Config' filesep 'TestTuningSettings.mat'];
if exist(savefile,'file'),
    load(savefile);
    h=TestToneGui(datavector);
else
    h=TestToneGui;
end

try
  datavector=get(h,'UserData');
catch
  return;
end

globalparams.Physiology='No';
HW=InitializeHW(globalparams);

S=AMNoise;

stopnow=0;
lastdatavector=zeros(size(datavector));


while ~stopnow,
  try
    datavector=get(h,'UserData');
  catch
    stopnow=1;
    break;
  end
  
  if any(datavector~=lastdatavector),
    
    isrunning=datavector(1);
    freq=datavector(2);
    rate=datavector(3);
    level=datavector(4);
    duration=datavector(5);
    isi=datavector(6);
    bw=datavector(7);
    attendb=80-level;
    
    if ~isrunning && lastdatavector(1),
      fprintf('Stopping and saving settings.\n');
      save(savefile,'datavector');
    end
    
    lastdatavector=datavector;
  end
  
  if isrunning,
      fprintf('Playing at %.0fHz carrier / %.0f Hz AM (-%.0f dB) Dur: %.2f ISI: %.2f\n',...
        freq,rate,attendb,duration,isi);
      
      S=set(S,'PreStimSilence',isi/2);
      S=set(S,'PostStimSilence',isi/2);
      S=set(S,'Duration',duration);
      if ~bw,
        LowFreq=freq;
        HighFreq=freq;
        TonesPerOctave=0.1;
      else
        LowFreq=2.^(log2(freq)-bw/2);
        HighFreq=2.^(log2(freq)+bw/2);
        TonesPerOctave=0;
      end
      S=set(S,'LowFreq',LowFreq);
      S=set(S,'HighFreq',HighFreq);
      S=set(S,'TonesPerOctave',TonesPerOctave);
      S=set(S,'Count',1);
      S=set(S,'AM',rate);
      S=set(S,'SamplingRate',HW.params.fsAO);
      w=waveform(S,1);
      w=w./max(abs(w)).*5;
      HW=IOSetLoudness(HW,attendb);
      
      HW=IOLoadSound(HW,w);
      
      ev=IOStartAcquisition(HW);
      
      while IOGetTimeStamp(HW)<duration+isi,
        pause(0.01);
      end
      IOStopAcquisition (HW);
      [AuxData, ~, AINames] = IOReadAIData(HW);
      HW=niStop(HW);
  end
  
  pause(0.01);
end
ShutdownHW(HW);
save(savefile,'datavector');
