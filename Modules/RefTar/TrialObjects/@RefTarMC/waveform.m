function [TrialSound , Events , O] = waveform(O,TrialIndex)

%% GET REFERENCE AND TARGET OBJECT, SRs AND INDICES
Par = get(O); % Get Parameters of Trialobject
Objects.Ref = Par.ReferenceHandle; SR.Ref = ifstr2num(get(Objects.Ref, 'SamplingRate'));
Objects.Tar = Par.TargetHandle;      SR.Tar = ifstr2num(get(Objects.Tar, 'SamplingRate'));
SR = max(SR.Ref,SR.Tar); O = set(O, 'SamplingRate', SR);
Objects.Ref = set(Objects.Ref, 'SamplingRate', SR);
Objects.Tar = set(Objects.Tar, 'SamplingRate', SR);
Indices.Ref = Par.ReferenceIndices{TrialIndex};
Indices.Tar = Par.TargetIndices{TrialIndex};

%% GENERATE REFERENCE & TARGET
Conds = {'Ref','Tar'}; TrialSound = []; Events = []; LastStop = 0; 
RelativeTarRefdB = get(O,'RelativeTarRefdB');

for iCond=1:length(Conds)
  cCond = Conds{iCond};
  if strcmp(cCond,'Tar') & strcmp(O.TargetClass,'None') continue; end
  % LOOP OVER SEQUENCES OF STIMULI
  for i = 1:length(Indices.(cCond))  % go through all the reference sounds in the trial
    [cWaveform, cEvents,Objects.(cCond)] = waveform(Objects.(cCond), Indices.(cCond)(i),strcmp(cCond,'Ref'));
    
    % PROCESS DIFFERENCES BETWEEN REFERENCE & TARGET
    switch cCond
      case 'Ref'; cNote = [' , Reference , ', num2str(RelativeTarRefdB) ,'dB'];
        cWaveform = cWaveform * (10^(RelativeTarRefdB/20));
      case 'Tar'; cNote = [' , Target '];
    end
    
    TrialSound = [TrialSound ; cWaveform];

    % ADD EVENTS
    for j = 1:length(cEvents)
        cEvents(j).Note = [cEvents(j).Note,cNote];
        cEvents(j).StartTime = cEvents(j).StartTime + LastStop;
        cEvents(j).StopTime = cEvents(j).StopTime + LastStop;
        cEvents(j).Trial = TrialIndex;
    end
    Events = [Events cEvents]; LastStop = Events(end).StopTime;
  end
end

% CHECK IF TARGET POSITION IS SET
FN = fieldnames(Objects.Tar);
if ~any(strcmp(FN,'CurrentTargetPositions')) % Association between stimulus and spout
  Objects.Tar = set(Objects.Tar,'CurrentTargetPositions',{'center'});
end

O = set(O,'ReferenceHandle',Objects.Ref);
O = set(O,'TargetHandle',Objects.Tar);