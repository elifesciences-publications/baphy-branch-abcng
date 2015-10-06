function [TrialSound , Events , O] = waveform(O,TrialInRep,TrialTotal)

%% GET REFERENCE AND TARGET OBJECT, SRs AND INDICES
Par = get(O); % Get Parameters of Trialobject
Objects.Ref = Par.ReferenceHandle; SR.Ref = ifstr2num(get(Objects.Ref, 'SamplingRate'));
Objects.Tar = Par.TargetHandle;      SR.Tar = ifstr2num(get(Objects.Tar, 'SamplingRate'));
SR = max(SR.Ref,SR.Tar); O = set(O, 'SamplingRate', SR);
Objects.Ref = set(Objects.Ref, 'SamplingRate', SR);
Objects.Tar = set(Objects.Tar, 'SamplingRate', SR);
Indices.Ref = Par.ReferenceIndices{TrialInRep};
Indices.Tar = Par.TargetIndices{TrialInRep};

%% GENERATE REFERENCE & TARGET
Conds = {'Ref','Tar'}; TrialSound = []; Events = []; LastStop = 0; 

for iCond=1:length(Conds)
  cCond = Conds{iCond};
  if strcmp(cCond,'Tar') & strcmp(O.TargetClass,'None') continue; end
  % LOOP OVER SEQUENCES OF STIMULI
  for i = 1:length(Indices.(cCond))  % go through all the reference sounds in the trial
    try
      [cWaveform, cEvents,Objects.(cCond)] = waveform(Objects.(cCond), Indices.(cCond)(i),strcmp(cCond,'Ref'),[],TrialTotal);
    catch
      [cWaveform, cEvents] = waveform(Objects.(cCond), Indices.(cCond)(i),strcmp(cCond,'Ref'));
    end

    TrialSound = [TrialSound ; cWaveform];

    % PROCESS DIFFERENCES BETWEEN REFERENCE & TARGET
    switch cCond
      case 'Ref'; cNote = [' , Reference '];
      case 'Tar'; cNote = [' , Target '];
    end

    % ADD EVENTS
    for j = 1:length(cEvents)
        cEvents(j).Note = [cEvents(j).Note,cNote];
        cEvents(j).StartTime = cEvents(j).StartTime + LastStop;
        cEvents(j).StopTime = cEvents(j).StopTime + LastStop;
        cEvents(j).Trial = TrialInRep;
    end
    Events = [Events cEvents]; LastStop = Events(end).StopTime;
  end
end

O = set(O,'ReferenceHandle',Objects.Ref);
O = set(O,'TargetHandle',Objects.Tar);