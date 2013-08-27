function o = ObjUpdate(o);
% Update the changes of a Shepard Pair object
%
% benglitz 2010

FieldNames = get(o,'FieldNames');
FieldTypes = get(o,'FieldTypes');
for i=1:length(FieldNames) 
  switch FieldTypes{i}
    case 'edit';    
      tmp = get(o,FieldNames{i});
      if ~isnumeric(tmp) tmp = eval(['[',tmp,']']); end
      Par.(FieldNames{i}) = tmp;
    case 'popupmenu';  Par.(FieldNames{i}) = get(o,FieldNames{i}); 
    otherwise error('FieldType not implemented!');
  end
end

Par.PitchClasses = sort(Par.PitchClasses);
Par.PitchSteps = sort(Par.PitchSteps);
MaxIndex = length(Par.PitchSteps)*length(Par.PitchClasses);
o = set(o,'MaxIndex',MaxIndex);
o = set(o,'Par',Par);

% SET NAMES
NPitchClasses = length(Par.PitchClasses);
Durations = zeros(MaxIndex,1);
if length(Par.PairDurations)==1 Par.PairDurations = [Par.PairDurations,Par.PairDurations]; end
for Index=1:MaxIndex
  % GET PARAMETERS OF CURRENT Index
  iPitchStep = ceil(Index/NPitchClasses);
  cPitchStep = Par.PitchSteps(iPitchStep);
  iPitchClass = Index - (iPitchStep-1)*NPitchClasses;
  cPitchClass = Par.PitchClasses(iPitchClass);
  Pitches = mod([cPitchClass,cPitchClass+cPitchStep],12);
  
  % COMPUTE STIMULUS LENGTHS FOR DMS AHEAD OF WAVEFORM
  Durations(Index) = get(o,'PreStimSilence')+get(o,'PostStimSilence')+...
    sum(Par.PairDurations) + Par.BetweenPairPause;
  
  Names{Index} = ['PitchClass = ',n2s(cPitchClass),'  |  PitchStep = ',n2s(cPitchStep)];
end
o = set(o,'Names',Names);
o = set(o,'Duration',Durations);